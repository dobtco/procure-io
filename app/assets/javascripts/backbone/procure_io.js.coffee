#= require_self
#= require_tree ./models
#= require_tree ./collections
#= require_tree ./views
#= require_tree ./routers

ProcureIo.Backbone =
  DEFAULT_LABEL_COLOR: "898989"

# Override Model#url to append '.json'
Backbone.Model.prototype.url = ->
    base = _.result(@, 'urlRoot') || _.result(@collection, 'baseUrl') || _.result(@collection, 'url')
    return base if this.isNew()
    pieces = base.split('?')
    pieces[0] + (if base.charAt(base.length - 1) == '/' then '' else '/') + encodeURIComponent(@id) + ".json" + (if pieces[1]? then "?#{pieces[1]}" else "")

# Override Collection#parse to store meta data
Backbone.Collection.prototype.parse = (resp, xhr) ->
  if resp.results?
    @meta = resp.meta
    resp.results

  else
    resp

ProcureIo.Backbone.Mixins =
  # Navigates the current router to a URL constructed from the passed params
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
