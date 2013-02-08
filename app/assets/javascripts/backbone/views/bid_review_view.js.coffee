# @todo clear backbone views when navigating with turbolinks?

ProcureIo.Backbone.BidReviewView = Backbone.View.extend
  tagName: "tbody"
  className: "bid-tbody"

  template: _.template """
    <tr>
      <td>1</td>

      <% for (keyField in pageOptions.attributes.keyFields) { %>
        <td><%= getValue(pageOptions.attributes.keyFields[keyField]["id"]) %></td>
      <% } %>
    </tr>
    <tr>
      <td colspan="3">
        Bid Details
      </td>
    </tr>
  """

  # events:
  #   "click [data-backbone-clear]": "clear"

  initialize: ->
    @parentView = @options.parentView
    @model.bind "change", @render, @
    @model.bind "destroy", @remove, @

  render: ->

    getValue = (id) =>
      response = _.find @model.get('bid_responses'), ->
        @response_field_id = id

      response.value

    @$el.html @template(_.extend(@model.toJSON(), {pageOptions: @parentView.pageOptions, getValue: getValue}))
    return @

  clear: ->
    @model.destroy()


ProcureIo.Backbone.BidReviewPage = Backbone.View.extend

  el: "#bid-review-page"

  template: _.template """
    <div class="row-fluid">
      <div class="span3">
        <ul class="nav nav-pills nav-stacked">
          <li data-class-active="pageOptions.activeFilter | eq allBids"><a data-backbone-activefilter="allBids">All Bids</a></li>
          <li data-class-active="pageOptions.activeFilter | eq starredBids"><a data-backbone-activefilter="starredBids">Starred Bids</a></li>
        </ul>
      </div>
      <div class="span9">
        <p>No active filters.</p>
        <ul class="nav nav-tabs">
          <li data-class-active="pageOptions.activeSubfilter | eq openBids"><a data-backbone-activesubfilter="openBids">Open Bids</a></li>
          <li data-class-active="pageOptions.activeSubfilter | eq closedBids"><a data-backbone-activesubfilter="closedBids">Closed Bids</a></li>
        </ul>
        <table class="table" id="bids-table">
          <thead>
            <tr>
              <th>&nbsp;</th>
              <% for (keyField in keyFields) { %>
                <th><%= keyFields[keyField]["label"] %></th>
              <% } %>
            </tr>
          </thead>
        </table>
      </div>
    </div>
  """

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
    @$el.html @template(@pageOptions.toJSON())
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

