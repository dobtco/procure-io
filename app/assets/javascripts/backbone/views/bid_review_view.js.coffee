# @todo clear backbone views when navigating with turbolinks?

ProcureIo.Backbone.BidReviewActionsView = Backbone.View.extend
  el: "#actions-wrapper"

  initialize: ->
    @listenTo ProcureIo.Backbone.Labels, "add", @render
    @listenTo ProcureIo.Backbone.Labels, "remove", @render

  render: ->
    bidsChecked = ProcureIo.Backbone.Bids.find (b) -> b.attributes.checked
    @$el.html JST['bid_review/actions']({project: @options.project, labels: ProcureIo.Backbone.Labels, bidsChecked: bidsChecked, filterOptions: ProcureIo.Backbone.router.filterOptions.toJSON()})

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

ProcureIo.Backbone.BidReviewSortersView = Backbone.View.extend
  el: "#sorters-wrapper"

  initialize: ->
    @sortOptions = [{key: "created_at", label: "Created at"}, {key: "stars", label: "Stars"}]

    _.each @options.project.key_fields, (kf) =>
      @sortOptions.push {key: ""+kf.id, label: kf.label}

  render: ->
    @$el.html JST['bid_review/sorters']({filterOptions: ProcureIo.Backbone.router.filterOptions.toJSON(), filteredHref: @options.filteredHref, sortOptions: @sortOptions})

ProcureIo.Backbone.BidReviewView = Backbone.View.extend
  tagName: "tr"
  className: "bid-tr"

  events:
    "click .vendor-name": "openBid"
    "click [data-backbone-star]": "toggleStarred"
    "click [data-backbone-read]": "toggleRead"

  initialize: ->
    @parentView = @options.parentView
    @listenTo @model, "destroy", @remove
    @listenTo @model, "change", @render
    @listenTo @model, "sync", @checkForRefetch

  checkForRefetch: ->
    # @todo this could cause some terrible recursion
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

    @$el.html JST['bid_review/bid'](_.extend(@model.toJSON(), {pageOptions: @parentView.pageOptions, getValue: getValue}))
    rivets.bind(@$el, {bid: @model})

    @$el[if !@model.get("my_bid_review.read") then "addClass" else "removeClass"]('bid-tr-unread')

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
        starrers = _.map data.bids, (bid) ->
          if bid.officer.me then "You" else bid.officer.display_name

        newTitle = if starrers.length > 0 then starrers.join(", ") else "No stars yet."

        $(@).attr('data-original-title', newTitle).tooltip('fixTitle')

        if $(@).data('tooltip').$tip.is(":visible")
          $(@).tooltip('show')

    @$el.find(".total-stars").on "mouseover", loadStarrers

    return @

  clear: ->
    @model.destroy()

  openBid: (e) ->
    return if e.metaKey
    e.preventDefault()

    if !@bidOpened
      @bidOpened = true
      $.ajax
        url: "/projects/#{@parentView.project.id}/bids/#{@model.id}/read_notifications.json"
        type: "POST"

    @toggleRead() unless @model.get('my_bid_review.read')

    @$modal = $("""
      <div class="modal container hide modal-fullscreen" tabindex="-1">
        <div class="modal-body">
          <div class="modal-bid-view-wrapper"></div>
          <div class="modal-comments-view-wrapper"></div>
        </div>
      </div>
    """).appendTo("body")

    @modalBidView = new ProcureIo.Backbone.BidPageView
      bid: @model
      project: @parentView.project
      el: @$modal.find(".modal-bid-view-wrapper")

    if ProcureIo.GlobalConfig.comments_enabled
      @modalCommentsView = new ProcureIo.Backbone.CommentPageView
        commentableType: "bid"
        commentableId: @model.id
        el: @$modal.find(".modal-comments-view-wrapper")

    @$modal.modal('show')

    @$modal.on "hidden", =>
      @modalBidView.remove()
      @$modal.remove()

  toggleStarred: ->
    @model.set 'my_bid_review.starred', (if @model.get('my_bid_review.starred') then false else true)
    @model.save()

  toggleRead: ->
    @model.set 'my_bid_review.read', (if @model.get('my_bid_review.read') then false else true)
    @model.save()


ProcureIo.Backbone.BidReviewPage = Backbone.View.extend

  el: "#bid-review-page"

  events:
    "click .sort-wrapper a": "updateFilter"
    "click [data-backbone-updatefilter]": "updateFilter"
    "click [data-backbone-dismiss]:not(.disabled)": "dismissCheckedBids"
    "click [data-backbone-award]:not(.disabled)": "awardCheckedBids"
    "click [data-backbone-label]": "labelCheckedBids"
    "click [data-backbone-togglelabeladmin]": "toggleLabelAdmin"
    "submit .bid-search-form": "submitBidSearchForm"

  initialize: ->
    @project = @options.project
    @options.projectId = @options.project.id

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


    ProcureIo.Backbone.router = new ProcureIo.Backbone.BidReviewRouter()
    ProcureIo.Backbone.router.filterOptions.bind "change", @renderExistingSubviews, @

    @subviews = {}

    @render()

    Backbone.history.start
      pushState: true

  reset: ->
    $("#bids-tbody").html('')
    @addAll()

  render: ->
    @$el.html JST['bid_review/page'](@pageOptions.toJSON())
    rivets.bind(@$el, {pageOptions: @pageOptions, filterOptions: ProcureIo.Backbone.router.filterOptions})
    return @

  renderAllSubviews: ->
    (@subviews['sidebarFilter'] ||= new ProcureIo.Backbone.BidReviewSidebarFilterView({parentView: @})).render()
    (@subviews['topFilter'] ||= new ProcureIo.Backbone.BidReviewTopFilterView({project: @options.project, filteredHref: @filteredHref})).render()
    (@subviews['sorters'] ||= new ProcureIo.Backbone.BidReviewSortersView({project: @options.project, filteredHref: @filteredHref})).render()
    (@subviews['labelFilter'] ||= new ProcureIo.Backbone.BidReviewLabelFilterView({project: @options.project, filteredHref: @filteredHref})).render()
    (@subviews['labelAdmin'] ||= new ProcureIo.Backbone.BidReviewLabelAdminListView({project: @options.project, filteredHref: @filteredHref})).render()
    (@subviews['actions'] ||= new ProcureIo.Backbone.BidReviewActionsView({project: @project})).render()
    (@subviews['pagination'] ||= new ProcureIo.Backbone.PaginationView({filteredHref: @filteredHref, collection: ProcureIo.Backbone.Bids})).render()

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

  dismissCheckedBids: ->
    ids = _.map ProcureIo.Backbone.Bids.where({checked:true}), (b) ->
      b.set("set_dismissed", true)
      b.attributes.id

    @sendBatchAction('dismiss', ids)

  awardCheckedBids: ->
    ids = _.map ProcureIo.Backbone.Bids.where({checked:true}), (b) -> b.attributes.id
    @sendBatchAction('award', ids)

  labelCheckedBids: (e) ->
    ids = _.map ProcureIo.Backbone.Bids.where({checked:true}), (b) -> b.attributes.id
    @sendBatchAction('label', ids, {label_name: $(e.target).data('backbone-label')})

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

  refetch: ->
    $("#bid-review-page").addClass 'loading'
    ProcureIo.Backbone.Bids.fetch {data: ProcureIo.Backbone.router.filterOptions.toJSON()}
