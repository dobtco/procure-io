ProcureIo.Backbone.PaginationView = Backbone.View.extend
  el: "#pagination-wrapper"

  pushIfDoesntExist: (page, pagesArray, lastPage) ->
    pagesArray.push page unless (pagesArray.indexOf(page) > -1) or (page < 1) or (page > lastPage)

  getPagesArray: (meta) ->
    if meta.last_page is 1 then return [1]

    pagesArray = [1, 2]
    @pushIfDoesntExist(meta.last_page, pagesArray, meta.last_page)
    @pushIfDoesntExist(meta.last_page - 1, pagesArray, meta.last_page)

    offset = 0
    currentPage = meta.page
    while pagesArray.length < 11 and (currentPage - offset >= 1 or currentPage + offset <= meta.last_page)
      @pushIfDoesntExist(currentPage - offset, pagesArray, meta.last_page)
      @pushIfDoesntExist(currentPage + offset, pagesArray, meta.last_page)
      offset++

    pagesArray = _.sortBy pagesArray, (p) -> p

    pagesArrayWithBreak = []
    _.each pagesArray, (p, index) ->
      if pagesArray[index - 1]? and p - pagesArray[index - 1] > 1
        pagesArrayWithBreak.push "break"

      pagesArrayWithBreak.push p

    pagesArrayWithBreak

  initialize: ->
    @filteredHref = @options.filteredHref
    @collection = @options.collection

  render: ->
    @$el.html JST['shared/pagination']({meta: @collection.meta, pages: @getPagesArray(@collection.meta), filteredHref: @filteredHref})
