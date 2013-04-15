mouseoverSelectTimeout = false

# Hack to keep us from "selecting" a new bid when the window is automatically scrolled.
# Suggestions for better solutions welcomed.
keepBidInView = (bid, scrollTo) ->
  ProcureIo.BidsOnMouseoverSelect = false
  clearTimeout(mouseoverSelectTimeout)

  if scrollTo is "bid"
    bottom = bid.offset().top + bid.height()
    current_bottom = $(window).scrollTop() + $(window).height()

    top = bid.offset().top
    current_top = $(window).scrollTop()

    if (current_bottom < bottom) then $('html, body').scrollTop(bottom - $(window).height())
    if (current_top > top) then $('html, body').scrollTop(bid.offset().top)

  else if scrollTo is "bottom"
    $("body").scrollTop($("body").scrollTop() + 25)

  else if scrollTo is "top"
    $('html, body').scrollTop(0)

  mouseoverSelectTimeout = setTimeout ->
    ProcureIo.BidsOnMouseoverSelect = true
  , 200

selectBid = (bid, scrollTo) ->
  $(".bid-tr").removeClass('bid-tr-selected')
  bid.addClass('bid-tr-selected')
  if scrollTo then keepBidInView(bid, scrollTo)

moveBidSelection = (direction) ->
  selected_bid = $(".bid-tr-selected")
  all_bids = $(".bid-tr")
  selected_index = all_bids.index(selected_bid)
  new_index = selected_index + (if direction is "up" then -1 else 1)

  if new_index == -1
    return selectBid(selected_bid, "top")

  if new_index == all_bids.length
    return keepBidInView(undefined, "bottom")

  new_selection = $(".bid-tr").eq(new_index)
  if new_selection.length > 0 then selectBid(new_selection, "bid")

rateBid = (rating) ->
  $(".bid-tr-selected").find("select").val(rating).trigger('change')

ProcureIo.Hotkeys["bids#index"] = [
  key: "j"
  description: "Move selection down"
  run: ->
    moveBidSelection("down")
,
  key: "k"
  description: "Move selection up"
  run: ->
    moveBidSelection("up")
,
  key: "s"
  description: "Star bid"
  run: ->
    $(".bid-tr-selected").find("[data-backbone-star]").click()
,
  key: "return"
  description: "View bid"
  run: ->
    $(".bid-tr-selected").find(".vendor-name").click()
,
  key: "left"
  description: "Previous page"
  run: ->
    $(".pagination-previous").click()
,
  key: "right"
  description: "Next page"
  run: ->
    $(".pagination-next").click()
,
  key: "1"
  description: "Rating 1"
  run: ->
    rateBid(1)
,
  key: "2"
  description: "Rating 2"
  run: ->
    rateBid(2)
,
  key: "3"
  description: "Rating 3"
  run: ->
    rateBid(3)
,
  key: "4"
  description: "Rating 4"
  run: ->
    rateBid(4)
,
  key: "5"
  description: "Rating 5"
  run: ->
    rateBid(5)
]