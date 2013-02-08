# @todo clear backbone views when navigating with turbolinks?

ProcureIo.Backbone.BidReviewView = Backbone.View.extend
  tagName: "tbody"
  className: "bid-tbody"

  events:
    "click [data-backbone-star]": "toggleStarred"
    "click [data-backbone-read]": "toggleRead"

  initialize: ->
    @parentView = @options.parentView
    @model.bind "change", @render, @
    @model.bind "destroy", @remove, @

  render: ->

    getValue = (id) =>
      response = _.find @model.get('bid_responses'), (bidResponse) ->
        bidResponse.response_field_id is id

      response.value

    @$el.html JST['bid_review/bid'](_.extend(@model.toJSON(), {pageOptions: @parentView.pageOptions, getValue: getValue}))

    return @

  clear: ->
    @model.destroy()

  toggleStarred: ->
    @model.set 'my_bid_review.starred', (if @model.get('my_bid_review.starred') then false else true)
    @model.save()

  toggleRead: ->
    @model.set 'my_bid_review.read', (if @model.get('my_bid_review.read') then false else true)
    @model.save()


ProcureIo.Backbone.BidReviewPage = Backbone.View.extend

  el: "#bid-review-page"

  events:
    "click [data-backbone-activefilter]": "updateActiveFilter"
    "click [data-backbone-activesubfilter]": "updateActiveSubfilter"

  initialize: ->
    ProcureIo.Backbone.Bids = new ProcureIo.Backbone.BidList()
    ProcureIo.Backbone.Bids.url = "/projects/#{@options.projectId}/bids"

    ProcureIo.Backbone.Bids.bind 'add', @addOne, @
    ProcureIo.Backbone.Bids.bind 'reset', @reset, @

    @pageOptions = new Backbone.Model
      keyFields: [
        {
          label: "bid",
          id: 46
        },
        {
          label: "price",
          id: 43
        }
      ]
      activeFilter: "allBids"
      activeSubfilter: "openBids"

    @render()
    ProcureIo.Backbone.Bids.reset(@options.bootstrapData)

  reset: ->
    # @todo loop through model and remove all views?
    # $("#response-fields").remove
    @addAll()

  render: ->
    @$el.html JST['bid_review/page'](@pageOptions.toJSON())
    rivets.bind(@$el, {pageOptions: @pageOptions})
    return @

  updateActiveFilter: (e) ->
    @pageOptions.set "activeFilter", $(e.target).data("backbone-activefilter")

  updateActiveSubfilter: (e) ->
    @pageOptions.set "activeSubfilter", $(e.target).data("backbone-activesubfilter")

  addOne: (bid) ->
    view = new ProcureIo.Backbone.BidReviewView({model: bid, parentView: @})
    $("#bids-table").append(view.render().el)

  addAll: ->
    ProcureIo.Backbone.Bids.each @addOne, @

