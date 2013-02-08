ProcureIo.Backbone.BidReviewPage = Backbone.View.extend

  el: "#bid-review-page"

  template: _.template """
    <div class="row-fluid">
      <div class="span3">
        <ul class="nav nav-pills nav-stacked">
          <li data-class-active="options.activeFilter | eq allBids"><a data-backbone-activefilter="allBids">All Bids</a></li>
          <li data-class-active="options.activeFilter | eq starredBids"><a data-backbone-activefilter="starredBids">Starred Bids</a></li>
        </ul>
      </div>
      <div class="span9">
        <p>No active filters.</p>
        <ul class="nav nav-tabs">
          <li data-class-active="options.activeSubfilter | eq openBids"><a data-backbone-activesubfilter="openBids">Open Bids</a></li>
          <li data-class-active="options.activeSubfilter | eq closedBids"><a data-backbone-activesubfilter="closedBids">Closed Bids</a></li>
        </ul>
        <table class="table">
          <thead>
            <tr>
              <th>&nbsp;</th>
              <th>Name</th>
              <th>Price</th>
            </tr>
          </thead>
          <tbody id="bids-tbody"></tbody>
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

    @options = new Backbone.Model
      activeFilter: "allBids"
      activeSubfilter: "openBids"

    @render()
    ProcureIo.Backbone.Bids.reset(@options.bootstrapData)

  reset: ->
    # $("#response-fields").html('')
    @addAll()

  render: ->
    @$el.html @template()
    rivets.bind(@$el, {options: @options})
    return @

  updateActiveFilter: (e) ->
    @options.set "activeFilter", $(e.target).data("backbone-activefilter")

  updateActiveSubfilter: (e) ->
    @options.set "activeSubfilter", $(e.target).data("backbone-activesubfilter")

  addOne: (responseField) ->
    # view = new ProcureIo.Backbone["#{responseField.attributes.field_type.capitalize()}ResponseFieldView"]({model: responseField, parentView: @})

    # $("#response-fields").append(view.render().el)
    # $("#response-fields").sortable('destroy')
    # $("#response-fields").sortable
    #   forcePlaceholderSize: true

  addAll: ->
    ProcureIo.Backbone.Bids.each @addOne, @

