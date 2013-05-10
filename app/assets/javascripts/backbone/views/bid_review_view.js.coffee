ProcureIo.Backbone.BidsTableHeadView = Backbone.View.extend
  el: "#bids-thead"

  render: ->
    @$el.html JST['bid_review/thead']
      pageOptions: @options.parentView.pageOptions
      parentView: @options.parentView
      filteredHref: @options.parentView.filteredHref
      filterOptions: ProcureIo.Backbone.router.filterOptions

ProcureIo.Backbone.BidsFieldChooserView = Backbone.View.extend
  el: ".field-chooser"

  render: ->
    fieldSelected = (id) =>
      _.find @options.parentView.pageOptions.get('keyFields'), (kf) ->
        kf == id

    @$el.html JST['bid_review/field_chooser']
      responseFields: @options.parentView.options.project.response_fields
      fieldSelected: fieldSelected

ProcureIo.Backbone.BidsFooterView = Backbone.View.extend
  el: "#bids-footer-wrapper"

  render: ->
    @$el.html JST['bid_review/footer']
      emailsUrl: "#{ProcureIo.Backbone.Bids.baseUrl}/emails?#{$.param(ProcureIo.Backbone.router.filterOptions.toJSON())}"

    @$el.find(".js-view-filtered-emails").on "click", (e) ->
      $modal = $("""
        <div class="modal" tabindex="-1">
          <div class="modal-body">
            <pre class="js-email-target">Loading...</pre>
          </div>
        </div>
      """).appendTo("body").modal('show')

      $.getJSON $(@).data('href'), (data) ->
        $modal.find(".js-email-target").text(data)

ProcureIo.Backbone.BidReviewActionsView = Backbone.View.extend
  el: "#actions-wrapper"

  initialize: ->
    @listenTo ProcureIo.Backbone.Labels, "add", @render
    @listenTo ProcureIo.Backbone.Labels, "remove", @render

  render: ->
    bidsChecked = ProcureIo.Backbone.Bids.find (b) -> b.attributes.checked
    @$el.html JST['bid_review/actions']
      project: @options.project
      labels: ProcureIo.Backbone.Labels
      bidsChecked: bidsChecked
      filterOptions: ProcureIo.Backbone.router.filterOptions.toJSON()
      abilities: @options.parentView.options.abilities

    @$el.find(".dropdown-form").submit ->
      $(@).closest(".dropdown").dropdown('toggle')

ProcureIo.Backbone.BidReviewSidebarFilterView = Backbone.View.extend
  el: "#sidebar-filter-wrapper"

  render: ->
    @$el.html JST['bid_review/sidebar_filter']
      filterOptions: ProcureIo.Backbone.router.filterOptions.toJSON()
      filteredHref: @options.parentView.filteredHref
      counts: ProcureIo.Backbone.Bids.meta.counts

ProcureIo.Backbone.BidReviewLabelFilterView = Backbone.View.extend
  el: "#label-filter-wrapper"

  initialize: ->
    @listenTo ProcureIo.Backbone.Labels, "add", @addOneLabel

  render: ->
    @$el.html JST['bid_review/label_filter']
      filterOptions: ProcureIo.Backbone.router.filterOptions.toJSON()
      filteredHref: @options.project.filteredHref
      abilities: @options.parentView.options.abilities

    @$el.find("#new-label-form").on "submit", (e) ->
      e.preventDefault()

      labelName = $(@).find('input[name="label[name]"]').val()
      labelColor = $(@).find('input[name="label[color]"]').val().replace(/^\#/, '') || ProcureIo.Backbone.DEFAULT_LABEL_COLOR
      labelExists = ProcureIo.Backbone.Labels.existingNames().indexOf(labelName.toLowerCase()) != -1

      $(@).resetForm()

      $(".color-swatches .swatch.selected").removeClass 'selected'
      $(".color-swatches .swatch:eq(0)").addClass 'selected'
      $(".color-wrapper, .custom-color-input").addClass 'hide'

      return if !labelName or labelExists

      ProcureIo.Backbone.Labels.create
        name: labelName
        color: labelColor
      ,
        error: (obj, err) ->
          obj.destroy()

    @$el.find("#new-label-form input").on "focus", ->
      $(".color-wrapper").removeClass 'hide'

    @$el.find(".color-swatches .swatch").on "click", ->
      if !$(@).hasClass 'selected'
        $(@).siblings().removeClass 'selected'
        $(@).addClass 'selected'
        $("#new-label-form .custom-color-input").val('')
        $("#new-label-form .hidden-color-input").val($(@).data('color'))

    @$el.find(".custom-color-input").on "input", ->
      @$el.find(".color-swatches .swatch.selected").removeClass 'selected'
      $("#new-label-form .hidden-color-input").val($(@).val())


    @resetLabels()

  resetLabels: ->
    $("#labels-list").html('')
    @addAllLabels()

  addAllLabels: ->
    ProcureIo.Backbone.Labels.each @addOneLabel, @

  addOneLabel: (label) ->
    view = new ProcureIo.Backbone.BidReviewLabelView({model: label, parentView: @, filterOptions: ProcureIo.Backbone.router.filterOptions.toJSON()})
    $("#labels-list").append(view.render().el)

ProcureIo.Backbone.BidReviewLabelAdminListView = Backbone.View.extend
  el: "#label-admin-wrapper"

  initialize: ->
    @listenTo ProcureIo.Backbone.Labels, "add", @addOneLabel

  render: ->
    @$el.html JST['bid_review/label_admin_list']({filterOptions: ProcureIo.Backbone.router.filterOptions.toJSON(), filteredHref: @options.project.filteredHref})
    @resetLabels()

  resetLabels: ->
    $("#labels-admin-list").html('')
    @addAllLabels()

  addAllLabels: ->
    ProcureIo.Backbone.Labels.each @addOneLabel, @

  addOneLabel: (label) ->
    view = new ProcureIo.Backbone.BidReviewLabelAdminView({model: label, parentView: @, filterOptions: ProcureIo.Backbone.router.filterOptions.toJSON()})
    $("#labels-admin-list").append(view.render().el)

ProcureIo.Backbone.BidReviewLabelAdminView = Backbone.View.extend
  tagName: "li"

  events:
    "click a": "showEditPane"

  initialize: ->
    @listenTo @model, "destroy", @remove
    @listenTo @model, "change", @render

  showEditPane: ->

    @$el.siblings().popover 'destroy'

    if !@$el.data('popover')?.$el?
      @popover = @$el.popover
        content: (new ProcureIo.Backbone.BidReviewLabelEditView({label: @model, parentView: @})).render().el
        html: true
        animation: false
        trigger: "click"
        template: """
          <div class="popover"><div class="arrow"></div><div class="popover-inner"><div class="popover-content"></div></div></div
        """

      @$el.popover 'show'

  render: ->
    @$el.html JST['bid_review/label_admin'] _.extend @model.toJSON(),
      filteredHref: @options.parentView.options.filteredHref
      filterOptions: ProcureIo.Backbone.router.filterOptions.toJSON()

    return @

  clear: ->
    @model.destroy()

ProcureIo.Backbone.BidReviewLabelEditView = Backbone.View.extend
  events:
    "submit #edit-label-form": "save"
    "click [data-backbone-destroy-label]": "clear"

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

  save: (e) ->
    e.preventDefault()
    @label.save()
    @parentView.$el.popover 'destroy'

  clear: ->
    @parentView.$el.popover 'destroy'
    @label.destroy()

ProcureIo.Backbone.BidReviewLabelView = Backbone.View.extend
  tagName: "li"

  initialize: ->
    @listenTo @model, "destroy", @remove
    @listenTo @model, "change", @render

  render: ->
    @$el.html JST['bid_review/label'] _.extend @model.toJSON(),
      filteredHref: @options.parentView.options.filteredHref
      filterOptions: ProcureIo.Backbone.router.filterOptions.toJSON()
      count: ProcureIo.Backbone.Bids.meta.counts[@model.get('id')]

    if @model.get('name') is ProcureIo.Backbone.router.filterOptions.toJSON().label
      @$el.addClass('active')

    return @

  clear: ->
    @model.destroy()

ProcureIo.Backbone.BidReviewTopFilterView = Backbone.View.extend
  el: "#top-filter-wrapper"

  render: ->
    @$el.html JST['bid_review/top_filter']
      filterOptions: ProcureIo.Backbone.router.filterOptions.toJSON()
      filteredHref: @options.filteredHref
      counts: ProcureIo.Backbone.Bids.meta.counts

    rivets.bind(@$el, {filterOptions: ProcureIo.Backbone.router.filterOptions})

ProcureIo.Backbone.BidReviewView = Backbone.View.extend
  tagName: "tr"
  className: "bid-tr"

  events:
    "click .vendor-name": "openBid"
    "click [data-backbone-star]": "toggleStarred"
    "click [data-backbone-read]": "toggleRead"
    "mouseenter": "selectBid"

  initialize: ->
    @parentView = @options.parentView
    @listenTo @model, "destroy", @remove
    @listenTo @model, "change", @render
    @listenTo @model, "sync", @checkForRefetch

  checkForRefetch: ->
    if (ProcureIo.Backbone.router.filterOptions.get("f1") == "starred" && @model.get("total_stars") < 1) ||
       (ProcureIo.Backbone.router.filterOptions.get("f2") == "open" && (@model.get("dismissed_at") || @model.get("awarded_at"))) ||
       (ProcureIo.Backbone.router.filterOptions.get("f2") == "dismissed" && !@model.get("dismissed_at")) ||
       (ProcureIo.Backbone.router.filterOptions.get("f2") == "awarded" && !@model.get("awarded_at"))

      @parentView.refetch()

  render: ->
    getValue = (id) =>
      response = _.find @model.get('responses'), (response) ->
        response.response_field_id is id

      if response then response.display_value else ""

    @$el.html JST['bid_review/bid']
      bid: @model.toJSON()
      pageOptions: @parentView.pageOptions
      getValue: getValue
      project: @parentView.project
      getLabel: @parentView.getLabel

    rivets.bind(@$el, {bid: @model})

    @$el[if !@model.get("read") then "addClass" else "removeClass"]('bid-tr-unread')
    @$el[if @model.get("checked") then "addClass" else "removeClass"]('bid-tr-checked')

    @$el.find(".rating-select").raty
      score: ->
        $(@).attr('data-score')
      click: (score) =>
        @model.set('rating', score)
        @model.save()

    if @parentView.options.abilities.seeAllBidReviews
      @$el.find(".total-stars").tooltip
        title: "Loading..."
        animation: false
        delay:
          show: 1000
          hide: 100

      @starrersLoaded = false
      self = @

      loadStarrers = ->
        return if self.starrersLoaded

        if !$(@).data('tooltip')?.$tip?
          return setTimeout (=> loadStarrers.call(@)), 1000

        self.starrersLoaded = true

        $.getJSON "#{ProcureIo.Backbone.Bids.baseUrl}/#{self.model.get('id')}/reviews.json", (data) =>
          starrers = _.map data, (bid) ->
            if bid.officer.me then "You" else bid.officer.display_name

          newTitle = if starrers.length > 0 then starrers.join(", ") else "No stars yet."

          $(@).attr('data-original-title', newTitle).tooltip('fixTitle')

          if $(@).data('tooltip').$tip?.is(":visible")
            $(@).tooltip('show')

      @$el.find(".total-stars").on "mouseover", loadStarrers

      @$el.find(".rating-select").on "change", =>
        @save()

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
          <div class="modal-comments-view-wrapper"></div>
        </div>
      </div>
    """).appendTo("body")

    @modalBidView = new ProcureIo.Backbone.BidPageView
      bid: @model
      project: @parentView.project
      el: @$modal.find(".modal-bid-view-wrapper")
      abilities: @parentView.options.abilities

    if ProcureIo.GlobalConfig.comments_enabled && @parentView.options.abilities.readAndWriteBidComments
      @modalCommentsView = new ProcureIo.Backbone.CommentPageView
        commentableType: "Bid"
        commentableId: @model.id
        el: @$modal.find(".modal-comments-view-wrapper")

    if @parentView.options.abilities.seeAllBidReviews
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

  events:
    "click .sort-wrapper a": "updateFilter"
    "click .js-toggle-response-field": "toggleResponseField"
    "click [data-backbone-updatefilter]": "updateFilter"
    "click [data-backbone-dismiss]:not(.disabled)": "dismissCheckedBids"
    "submit [data-backbone-dismiss-form]": "dismissCheckedBids"
    "submit [data-backbone-award-form]": "awardCheckedBids"
    "click [data-backbone-award]:not(.disabled)": "awardCheckedBids"
    "click [data-backbone-label-id]": "labelCheckedBids"
    "click [data-backbone-togglelabeladmin]": "toggleLabelAdmin"
    "submit .bid-search-form": "submitBidSearchForm"
    "click .js-collapse-sidebar": "toggleCollapseSidebar"

  initialize: ->
    ProcureIo.BidsOnMouseoverSelect = true

    @project = @options.project
    @options.projectId = @options.project.id

    @keyFieldStorageKey = "project#{@project.id}-keyfields"
    @sidebarStorageKey = "project#{@project.id}-sidebar"

    ProcureIo.Backbone.Bids = new ProcureIo.Backbone.BidList()
    ProcureIo.Backbone.Bids.baseUrl = "/projects/#{@options.projectId}/bids"
    ProcureIo.Backbone.Bids.url = "#{ProcureIo.Backbone.Bids.baseUrl}.json"

    ProcureIo.Backbone.Bids.bind 'add', @addOne, @
    ProcureIo.Backbone.Bids.bind 'reset', @reset, @
    ProcureIo.Backbone.Bids.bind 'reset', @removeLoadingSpinner, @

    ProcureIo.Backbone.Bids.bind 'reset', @renderAllSubviews, @

    ProcureIo.Backbone.Labels = new ProcureIo.Backbone.LabelList()
    ProcureIo.Backbone.Labels.url = "/projects/#{@options.project.id}/labels"
    ProcureIo.Backbone.Labels.reset(@options.project.labels)

    @pageOptions = new Backbone.Model
      keyFields: @options.project.key_fields

    @setKeyFields()

    @filteredHref = (newFilters) =>
      existingParams = ProcureIo.Backbone.router.filterOptions.toJSON()

      for k, v of newFilters
        existingParams[k] = v

      newParams = {}
      hasParams = false

      _.each existingParams, (val, key) ->
        if val
          hasParams = true
          newParams[key] = val

      if hasParams
        "/projects/#{@options.projectId}/bids?#{$.param(newParams)}"
      else
        "/projects/#{@options.projectId}/bids"


    ProcureIo.Backbone.router = new ProcureIo.Backbone.SearchRouter ProcureIo.Backbone.Bids,
      f1: "all"
      f2: "open"
      sort: "name"
      direction: "asc"

    ProcureIo.Backbone.router.filterOptions.bind "change", @renderExistingSubviews, @

    @subviews = {}

    @getLabel = (label_id) ->
      ProcureIo.Backbone.Labels.find((label) -> label.get('id') == label_id).toJSON()

    @render()

    if store.get(@sidebarStorageKey) == 'collapsed'
      @collapseSidebarImmediately()

    Backbone.history.start
      pushState: true

  reset: ->
    $("#bids-tbody").html('')
    @addAll()

  render: ->
    @$el.html JST['bid_review/page']
      pageOptions: @pageOptions.toJSON()
      project: @project
    rivets.bind(@$el, {pageOptions: @pageOptions, filterOptions: ProcureIo.Backbone.router.filterOptions})
    return @

  renderAllSubviews: ->
    (@subviews['sidebarFilter'] ||= new ProcureIo.Backbone.BidReviewSidebarFilterView({parentView: @})).render()
    (@subviews['topFilter'] ||= new ProcureIo.Backbone.BidReviewTopFilterView({project: @options.project, filteredHref: @filteredHref})).render()
    (@subviews['labelFilter'] ||= new ProcureIo.Backbone.BidReviewLabelFilterView({project: @options.project, filteredHref: @filteredHref, parentView: @})).render()
    (@subviews['labelAdmin'] ||= new ProcureIo.Backbone.BidReviewLabelAdminListView({project: @options.project, filteredHref: @filteredHref})).render()
    (@subviews['actions'] ||= new ProcureIo.Backbone.BidReviewActionsView({project: @project, parentView: @})).render()
    (@subviews['pagination'] ||= new ProcureIo.Backbone.PaginationView({filteredHref: @filteredHref, collection: ProcureIo.Backbone.Bids})).render()
    (@subviews['bidsFooter'] ||= new ProcureIo.Backbone.BidsFooterView()).render()
    (@subviews['bidsTableHead'] ||= new ProcureIo.Backbone.BidsTableHeadView({parentView: @})).render()
    (@subviews['fieldChooser'] ||= new ProcureIo.Backbone.BidsFieldChooserView({parentView: @})).render()

  renderExistingSubviews: ->
    for subview in @subviews
      subview.render()

  renderSubview: (name) ->
    @subviews[name]?.render()

  addOne: (bid) ->
    view = new ProcureIo.Backbone.BidReviewView({model: bid, parentView: @})
    @listenTo bid, "change:checked", ( => @renderSubview('actions') )
    $("#bids-tbody").append(view.render().el)

  addAll: ->
    ProcureIo.Backbone.Bids.each @addOne, @

  updateFilter: (e) ->
    $a = if $(e.target).is("a") then $(e.target) else $(e.target).closest("a")
    return if e.metaKey
    ProcureIo.Backbone.router.navigate $a.attr('href'), {trigger: true}
    e.preventDefault()

  dismissCheckedBids: (e) ->
    e.preventDefault()

    options =
      dismissal_message: $(e.target).find(".js-dismissal-message").val()
      show_dismissal_message_to_vendor: $(e.target).find(".js-show-dismissal-message-to-vendor").is(":checked")

    ids = _.map ProcureIo.Backbone.Bids.where({checked:true}), (b) -> b.attributes.id

    @sendBatchAction('dismiss', ids, options)

  awardCheckedBids: (e) ->
    e.preventDefault()

    options =
      award_message: $(e.target).find(".js-award-message").val()

    ids = _.map ProcureIo.Backbone.Bids.where({checked:true}), (b) -> b.attributes.id

    @sendBatchAction('award', ids, options)

  labelCheckedBids: (e) ->
    ids = _.map ProcureIo.Backbone.Bids.where({checked:true}), (b) -> b.attributes.id
    @sendBatchAction('label', ids, {label_id: $(e.target).data('backbone-label-id')})

  toggleLabelAdmin: ->
    @$el.toggleClass 'editing-labels'

  submitBidSearchForm: (e) ->
    ProcureIo.Backbone.router.navigate @filteredHref({q: $(e.target).find("input").val(), page: 1}), {trigger: true}
    e.preventDefault()

  sendBatchAction: (action, ids, options = {}) ->
    $("#bid-review-page").addClass 'loading'

    $.ajax
      url: "#{ProcureIo.Backbone.Bids.baseUrl}/batch"
      type: "PUT"
      data:
        ids: ids
        bid_action: action
        options: options
      success: =>
        @refetch()

  removeLoadingSpinner: ->
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

    keyFields.unshift 'name'

    @pageOptions.set 'keyFields', keyFields

  storeKeyFields: ->
    store.set(@keyFieldStorageKey, @pageOptions.get('keyFields'))

  sortedKeyFields: (keyFields) ->
    sortedKeyFields = []

    # sort name first
    if _.contains keyFields, 'name'
      sortedKeyFields.push 'name'

    # sort other fields in the order they came in
    for responseField in @project.response_fields
      sortedKeyFields.push(responseField.id) if _.contains(keyFields, responseField.id)

    sortedKeyFields

  toggleResponseField: (e) ->
    id = $(e.target).data('response-field-id')

    if _.contains @pageOptions.get('keyFields'), id
      newKeyFields = _.without(@pageOptions.get('keyFields'), id)
    else
      newKeyFields = _.union(@pageOptions.get('keyFields'), [id])

    @pageOptions.set 'keyFields', @sortedKeyFields(newKeyFields)
    @storeKeyFields()

    @renderSubview('fieldChooser')
    @renderSubview('bidsTableHead')

    ProcureIo.Backbone.Bids.each (b) ->
      b.trigger 'change'


  refetch: ->
    $("#bid-review-page").addClass 'loading'
    ProcureIo.Backbone.Bids.fetch {data: ProcureIo.Backbone.router.filterOptions.toJSON()}

  collapseSidebarImmediately: ->
    $sidebar = @$el.find(".sidebar-wrapper")
    $rightSideSpan = @$el.find(".right-side-span")
    $sidebar.removeClass('span3').addClass('span1')
    $rightSideSpan.removeClass('span9').addClass('span11')
    $sidebar.toggleClass 'sidebar-collapsed'
    @$el.find(".js-collapse-sidebar").toggleText()

  toggleCollapseSidebar: ->
    $sidebar = @$el.find(".sidebar-wrapper")
    $rightSideSpan = @$el.find(".right-side-span")

    if $sidebar.hasClass 'sidebar-collapsed'
      # restore
      $sidebar.css({width: 70})

      $sidebar.removeClass('span1').addClass('span3')
      $rightSideSpan.removeClass('span11').addClass('span9')
      @$el.find(".search-query").attr('placeholder', @$el.find(".search-query").data('original-placeholder'))

      $sidebar.animate
        width: 270
      , 300

      setTimeout ->
        $sidebar.toggleClass 'sidebar-collapsed'
      , 200

      store.remove(@sidebarStorageKey)

    else
      # collapse
      $preHides = $sidebar.find(".badge, #new-label-form")
      $preHides.addClass('hide')
      @$el.find(".search-query").data('original-placeholder', @$el.find(".search-query").attr('placeholder'))
      @$el.find(".search-query").removeAttr('placeholder')
      $sidebar.toggleClass 'sidebar-collapsed'

      $sidebar.animate
        width: 70
      , 300, ->
        $sidebar.css({width: ''})
        $sidebar.removeClass('span3').addClass('span1')
        $rightSideSpan.removeClass('span9').addClass('span11')
        $preHides.removeClass('hide')

      store.set(@sidebarStorageKey, 'collapsed')

