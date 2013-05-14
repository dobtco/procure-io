ProcureIo.Backbone.BidReviewSubviews = []

# Bids <thead>
ProcureIo.Backbone.BidReviewSubviews.push Backbone.View.extend
  el: ".subview-bids-thead"

  initialize: ->
    @listenTo @options.parentView.pageOptions, 'change:keyFields', @render
    @listenTo @options.parentView.router.filterOptions, 'change', @render

  render: ->
    @$el.html JST['bid_review/thead']({parentView: @options.parentView})

# Field chooser
ProcureIo.Backbone.BidReviewSubviews.push Backbone.View.extend
  el: ".subview-field-chooser"

  initialize: ->
    @listenTo @options.parentView.pageOptions, "change:keyFields", @render

  render: ->
    fieldSelected = (id) =>
      _.find @options.parentView.pageOptions.get('keyFields'), (kf) ->
        kf == id

    @$el.html JST['bid_review/field_chooser']
      responseFields: @options.parentView.options.project.response_fields
      fieldSelected: fieldSelected

# Actions (label, dismiss, award)
ProcureIo.Backbone.BidReviewSubviews.push Backbone.View.extend
  el: ".subview-actions-wrapper"

  initialize: ->
    @listenTo @options.parentView.labels, "add", @render
    @listenTo @options.parentView.labels, "remove", @render

  render: ->
    @$el.html JST['bid_review/actions']
      labels: @options.parentView.labels
      abilities: @options.parentView.abilities

    rivets.bind @$el,
      pageOptions: @options.parentView.pageOptions
      filterOptions: @options.parentView.router.filterOptions

# Sidebar filters (open, dismissed, awarded)
ProcureIo.Backbone.BidReviewSubviews.push Backbone.View.extend
  el: ".subview-sidebar-filter"

  render: ->
    @$el.html JST['bid_review/sidebar_filter']()

    rivets.bind @$el,
      pageOptions: @options.parentView.pageOptions
      filterOptions: @options.parentView.router.filterOptions
      counts: @options.parentView.counts

# Label filters
ProcureIo.Backbone.BidReviewSubviews.push Backbone.View.extend
  el: ".subview-label-filter"

  initialize: ->
    @listenTo @options.parentView.labels, "add", @addOneLabel

  createLabel: (e, $el) ->
    labelName = $el.find('input[name="label[name]"]').val()
    labelColor = $el.find('input[name="label[color]"]').val().replace(/^\#/, '') || ProcureIo.Backbone.DEFAULT_LABEL_COLOR
    labelExists = @options.parentView.labels.existingNames().indexOf(labelName.toLowerCase()) != -1

    return if !labelName or labelExists

    @options.parentView.labels.create
      name: labelName
      color: labelColor

    @render() # resets everything

  showColors: ->
    $(".color-wrapper").removeClass 'hide'

  selectSwatch: (e, $el) ->
    return if $el.hasClass 'selected'
    $el.siblings().removeClass 'selected'
    $el.addClass 'selected'
    @$el.find("#new-label-form .custom-color-input").val($el.data('color'))

  typingCustomColor: (e) ->
    @$el.find(".color-swatches .swatch.selected").removeClass 'selected'
    $("#new-label-form .custom-color-input").val($(e.target).val())

  render: ->
    @$el.html JST['bid_review/label_filter']
      abilities: @options.parentView.options.abilities

    @resetLabels()

  resetLabels: ->
    $("#labels-list").html('')
    @addAllLabels()

  addAllLabels: ->
    @options.parentView.labels.each @addOneLabel, @

  addOneLabel: (label) ->
    view = new ProcureIo.Backbone.BidReviewLabelView
      model: label
      parentView: @

    el = view.render().el
    @$el.find("#labels-list").append(el)
    rivets.bind el,
      pageOptions: @options.parentView.pageOptions
      filterOptions: @options.parentView.router.filterOptions

# Label admin
ProcureIo.Backbone.BidReviewSubviews.push Backbone.View.extend
  el: ".subview-label-admin"

  initialize: ->
    @listenTo @options.parentView.labels, "add", @addOneLabel

  render: ->
    @$el.html JST['bid_review/label_admin_list']()
    @resetLabels()

  resetLabels: ->
    $("#labels-admin-list").html('')
    @addAllLabels()

  addAllLabels: ->
    @options.parentView.labels.each @addOneLabel, @

  addOneLabel: (label) ->
    view = new ProcureIo.Backbone.BidReviewLabelAdminView
      model: label
      parentView: @

    @$el.find("#labels-admin-list").append(view.render().el)

ProcureIo.Backbone.BidReviewLabelAdminView = Backbone.View.extend
  tagName: "li"

  initialize: ->
    @listenTo @model, "destroy", @remove
    @listenTo @model, "change", @render

  showEditPane: (e) ->
    if @$el.data('popover')
      return @$el.popover 'toggle'

    @$el.siblings().popover 'destroy'

    @$el.popover
      content: (new ProcureIo.Backbone.BidReviewLabelEditView({label: @model, parentView: @})).render().el
      html: true
      animation: false
      trigger: "manual"
      template: """
        <div class="popover"><div class="arrow"></div><div class="popover-inner"><div class="popover-content"></div></div></div
      """

    @$el.popover 'show'

    e.preventDefault()

  render: ->
    @$el.html JST['bid_review/label_admin']
      model: @model

    return @

  clear: ->
    @model.destroy()

ProcureIo.Backbone.BidReviewLabelEditView = Backbone.View.extend
  initialize: ->
    @label = @options.label
    @parentView = @options.parentView
    @listenTo @label, "destroy", @remove

  render: ->
    @$el.html JST['bid_review/label_edit']({label: @label})
    rivets.bind(@$el, {label: @label})

    @$el.find(".swatch").removeClass 'selected'

    if @$el.find(".swatch[data-color=\"#{@label.get('color')}\"]").length > 0
      @$el.find(".swatch[data-color=\"#{@label.get('color')}\"]").addClass 'selected'

    else
      @$el.find(".custom-color-input").removeClass 'hide'
      @$el.find(".custom-color-input").val @label.get('color')

    self = @

    @$el.find(".custom-color-input").on "input", ->
      self.$el.find(".color-swatches .swatch.selected").removeClass 'selected'
      self.$el.find("[data-rv-value=\"label\.color\"]").val($(@).val()).trigger('change') # trigger rivets update

    @$el.find(".color-swatches .swatch").on "click", ->
      if !$(@).hasClass 'selected'
        $(@).siblings().removeClass 'selected'
        $(@).addClass 'selected'
        self.$el.find(".custom-color-input").val('')
        self.$el.find("[data-rv-value=\"label\.color\"]").val($(@).data('color')).trigger('change') # trigger rivets update

    return @

  saveLabel: (e) ->
    @label.save()
    @removePopover()

  removeLabel: ->
    @label.destroy()
    @removePopover()

  removePopover: ->
    @parentView.$el.popover 'destroy'

ProcureIo.Backbone.BidReviewLabelView = Backbone.View.extend
  tagName: "li"

  initialize: ->
    @listenTo @model, "destroy", @remove
    @listenTo @model, "change", @render
    @listenTo @options.parentView.options.parentView.router.filterOptions, "change:label", @addOrRemoveActiveClass

  render: ->
    @$el.html JST['bid_review/label']
      label: @model

    rivets.bind @$el,
      counts: @options.parentView.options.parentView.counts

    return @

  clear: ->
    @model.destroy()

  addOrRemoveActiveClass: ->
    if @options.parentView.options.parentView.router.filterOptions.get('label') == @model.get('name')
      @$el.addClass('active')
    else
      @$el.removeClass('active')

ProcureIo.Backbone.BidReviewBidView = Backbone.View.extend
  tagName: "tr"
  className: "bid-tr"

  events:
    "mouseenter": "selectBid"

  initialize: ->
    @parentView = @options.parentView
    @listenTo @model, "destroy", @remove
    @listenTo @model, "change", @render
    @listenTo @model, "sync", @checkForRefetch

  checkForRefetch: ->
    if (@parentView.router.filterOptions.get("status") == "open" && (@model.get("dismissed_at") || @model.get("awarded_at"))) ||
       (@parentView.router.filterOptions.get("status") == "dismissed" && !@model.get("dismissed_at")) ||
       (@parentView.router.filterOptions.get("status") == "awarded" && !@model.get("awarded_at"))

      @parentView.refetch()

  render: ->
    @$el.html JST['bid_review/bid']
      bid: @model
      parentView: @parentView

    rivets.bind @$el,
      bid: @model

    @$el[if !@model.get("read") then "addClass" else "removeClass"]('bid-tr-unread')
    @$el[if @model.get("checked") then "addClass" else "removeClass"]('bid-tr-checked')

    @$el.find(".rating-select").raty
      score: ->
        $(@).attr('data-score')
      click: (score) =>
        @model.set('rating', score)
        @model.save()

    return @

  clear: ->
    @model.destroy()

  openBid: (e) ->
    return if e.metaKey
    return @$modal.modal('show') if @$modal?
    e.preventDefault()

    if !@bidOpened
      @bidOpened = true
      $.ajax
        url: "/projects/#{@parentView.project.id}/bids/#{@model.id}/read_notifications.json"
        type: "POST"

    @toggleRead() unless @model.get('read')

    @$modal = $("""
      <div class="modal container hide modal-fullscreen" tabindex="-1">
        <div class="modal-body">
          <div class="modal-bid-view-wrapper"></div>
          <div class="modal-bid-view-reviews-wrapper"></div>
          <h4>#{I18n.t('g.comments')}</h4>
          <div class="row">
            <div class="span8">
              <div class="modal-comments-view-wrapper"></div>
            </div>
          </div>
        </div>
      </div>
    """).appendTo("body")

    @modalBidView = new ProcureIo.Backbone.BidPageView
      bid: @model
      project: @parentView.project
      el: @$modal.find(".modal-bid-view-wrapper")
      abilities: @parentView.abilities

    if ProcureIo.GlobalConfig.comments_enabled && @parentView.abilities.readAndWriteBidComments
      @modalCommentsView = new ProcureIo.Backbone.CommentPageView
        commentableType: "Bid"
        commentableId: @model.id
        el: @$modal.find(".modal-comments-view-wrapper")

    if @parentView.abilities.seeAllBidReviews
      @modalReviewsView = new ProcureIo.Backbone.BidPageReviewsView
        project_id: @parentView.project.id
        bid_id: @model.id
        el: @$modal.find(".modal-bid-view-reviews-wrapper")

    @$modal.modal('show')

    @$modal.on "hidden", =>
      @modalBidView.remove()
      @modalCommentsView?.remove()
      @modalReviewsView?.remove()
      @$modal.remove()
      @$modal = undefined

  toggleStarred: ->
    @model.set 'starred', (if @model.get('starred') then false else true)
    @save()

  toggleRead: ->
    @model.set 'read', (if @model.get('read') then false else true)
    @save()

  save: ->
    @model.save()

  selectBid: ->
    if ProcureIo.BidsOnMouseoverSelect
      $(".bid-tr-selected").removeClass("bid-tr-selected")
      @$el.addClass 'bid-tr-selected'

ProcureIo.Backbone.BidReviewPage = Backbone.View.extend
  el: "#bid-review-page"

  initialize: ->
    # Hack for hotkey selection
    ProcureIo.BidsOnMouseoverSelect = true

    @project = @options.project
    @abilities = @options.abilities

    @keyFieldStorageKey = "project#{@project.id}-keyfields"
    @sidebarStorageKey = "project#{@project.id}-sidebar"

    @bids = new ProcureIo.Backbone.BidList()
    # @todo investigate
    @bids.baseUrl = "/projects/#{@project.id}/bids"
    @bids.url = "#{@bids.baseUrl}.json"

    @bids.bind 'add', @addOne, @
    @bids.bind 'reset', @reset, @
    @bids.bind 'reset', @doneLoading, @
    @bids.bind 'reset', @renderPagination, @
    @bids.bind 'reset', @setCounts, @

    @labels = new ProcureIo.Backbone.LabelList()
    @labels.url = "/projects/#{@options.project.id}/labels"
    @labels.reset(@project.labels)

    @counts = new Backbone.Model

    @pageOptions = new Backbone.Model
      keyFields: @project.key_fields

    @setKeyFields()

    @router = new ProcureIo.Backbone.SearchRouter @bids,
      status: "open"
      sort: "name"
      direction: "asc"

    @subviews = {}

    @render()

    for subview in ProcureIo.Backbone.BidReviewSubviews
      new subview({parentView: @}).render()

    if store.get(@sidebarStorageKey) == 'collapsed'
      @collapseSidebarImmediately()

    if @options.bootstrapData
      @bids.reset(@options.bootstrapData, {parse: true})
      bootstrapped = true

    Backbone.history.start
      pushState: true
      silent: bootstrapped?

  getLabel: (label_id) ->
    @labels.find ( (label) -> label.get('id') == label_id )

  reset: ->
    $("#bids-tbody").html('')
    @addAll()

  render: ->
    @$el.html JST['bid_review/page']()

    rivets.bind @$el,
      pageOptions: @pageOptions
      filterOptions: @router.filterOptions

  renderPagination: ->
    # @todo unify paginations and render this with the rest of the subviews
    (@paginationSubview ||= new ProcureIo.Backbone.PaginationView({filteredHref: @router.filteredHref, collection: @bids})).render()

  addOne: (bid) ->
    view = new ProcureIo.Backbone.BidReviewBidView({model: bid, parentView: @})
    @listenTo bid, "change:checked", ( => @seeIfBidsChecked() )
    @$el.find("#bids-tbody").append(view.render().el)

  seeIfBidsChecked: ->
    if @bids.find ((b) -> b.get('checked') == true)
      @pageOptions.set('bidsChecked', true)
    else
      @pageOptions.unset('bidsChecked')

  addAll: ->
    @bids.each @addOne, @

  updateFilter: (e, $el, params) ->
    willRemoveHref = false

    if !$el.attr('href')
      willRemoveHref = true
      if (labelName = $el.data('label-name'))
        $el.attr 'href', (@router.filteredHref
          label: if (@router.filterOptions.get('label') == labelName) then false else labelName
          page: false
        )

      else
        # if no href, attempt to construct from parameters
        $el.attr 'href', @router.filteredHref(params)

    return if e.metaKey
    @router.navigate $el.attr('href'), {trigger: true}
    $el.removeAttr('href') if willRemoveHref

  checkedBidIds: (e) ->
    _.map @bids.where({checked:true}), (b) -> b.attributes.id

  dismissCheckedBids: (e) ->
    options =
      dismissal_message: $(e.target).find(".js-dismissal-message").val()
      show_dismissal_message_to_vendor: $(e.target).find(".js-show-dismissal-message-to-vendor").is(":checked")

    @sendBatchAction('dismiss', @checkedBidIds(), options)

  awardCheckedBids: (e) ->
    options =
      award_message: $(e.target).find(".js-award-message").val()

    @sendBatchAction('award', @checkedBidIds(), options)

  labelCheckedBids: (e, $el, labelId) ->
    @sendBatchAction('label', @checkedBidIds(), {label_id: labelId})

  toggleLabelAdmin: ->
    @$el.toggleClass 'editing-labels'

  sendBatchAction: (action, ids, options = {}) ->
    $("#bid-review-page").addClass 'loading'

    $.ajax
      url: "#{@bids.baseUrl}/batch"
      type: "PUT"
      data:
        ids: ids
        bid_action: action
        options: options
      success: =>
        @refetch()

  doneLoading: ->
    $("#bid-review-page").removeClass 'loading'

  getResponseField: (id) ->
    _.find @project.response_fields, (rf) ->
      rf.id == id

  setKeyFields: ->
    if (storedKeyFields = store.get(@keyFieldStorageKey))
      @pageOptions.set 'keyFields', @sortedKeyFields(storedKeyFields)
    else
      @setDefaultKeyFields()
      @storeKeyFields()

  setDefaultKeyFields: ->
    keyFields = []

    for responseField in @project.response_fields
      keyFields.push responseField.id
      break if keyFields.length == 2

    keyFields.unshift 'rating', 'comments', 'name'

    @pageOptions.set 'keyFields', keyFields

  storeKeyFields: ->
    store.set(@keyFieldStorageKey, @pageOptions.get('keyFields'))

  sortedKeyFields: (keyFields) ->
    sortedKeyFields = []

    # sort these first
    for i in ['rating', 'comments', 'name']
      if _.contains keyFields, i
        sortedKeyFields.push i

    # sort other fields in the order they came in
    for responseField in @project.response_fields
      sortedKeyFields.push(responseField.id) if _.contains(keyFields, responseField.id)

    sortedKeyFields

  toggleKeyField: (e) ->
    id = $(e.target).data('response-field-id')

    if _.contains @pageOptions.get('keyFields'), id
      newKeyFields = _.without(@pageOptions.get('keyFields'), id)
    else
      newKeyFields = _.union(@pageOptions.get('keyFields'), [id])

    @pageOptions.set 'keyFields', @sortedKeyFields(newKeyFields)
    @storeKeyFields()

    @bids.each (b) ->
      b.trigger 'change'

  refetch: ->
    $("#bid-review-page").addClass 'loading'
    @bids.fetch
      data: @router.filterOptions.toJSON()

  collapseSidebarImmediately: ->
    $sidebar = @$el.find(".sidebar-wrapper")
    $rightSideSpan = @$el.find(".right-side-span")
    $sidebar.removeClass('span3').addClass('span1')
    $rightSideSpan.removeClass('span9').addClass('span11')
    $sidebar.toggleClass 'sidebar-collapsed'
    @$el.find("[data-backbone-click=toggleCollapseSidebar]").toggleText()
    @pageOptions.set('sidebarCollapsed', true)

  toggleCollapseSidebar: ->
    $sidebar = @$el.find(".sidebar-wrapper")
    $rightSideSpan = @$el.find(".right-side-span")

    if $sidebar.hasClass 'sidebar-collapsed'
      # restore
      $sidebar.css({width: 70})

      $sidebar.removeClass('span1').addClass('span3')
      $rightSideSpan.removeClass('span11').addClass('span9')

      $sidebar.animate
        width: 270
      , 300

      setTimeout ->
        $sidebar.toggleClass 'sidebar-collapsed'
      , 200

      store.remove(@sidebarStorageKey)
      @pageOptions.unset('sidebarCollapsed')

    else
      # collapse
      $preHides = $sidebar.find(".badge, #new-label-form")
      $preHides.addClass('hide')
      $sidebar.toggleClass 'sidebar-collapsed'

      $sidebar.animate
        width: 70
      , 300, ->
        $sidebar.css({width: ''})
        $sidebar.removeClass('span3').addClass('span1')
        $rightSideSpan.removeClass('span9').addClass('span11')
        $preHides.removeClass('hide')

      store.set(@sidebarStorageKey, 'collapsed')
      @pageOptions.set('sidebarCollapsed', true)

  submitSearch: (e) ->
    @router.navigate @router.filteredHref({page: 1}), {trigger: true}

  setCounts: ->
    for k, v of @bids.meta.counts
      @counts.set(k, v)

  viewFilteredEmails: (e) ->
    $modal = $("""
      <div class="modal" tabindex="-1">
        <div class="modal-body">
          <pre class="js-email-target">Loading...</pre>
        </div>
      </div>
    """).appendTo("body").modal('show')

    $.getJSON "/projects/#{@project.id}/bids/emails?#{$.param(@router.filterOptions.toJSON())}", (data) ->
      $modal.find(".js-email-target").text(data)
