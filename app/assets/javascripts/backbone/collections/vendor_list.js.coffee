ProcureIo.Backbone.VendorList = Backbone.Collection.extend
  model: ProcureIo.Backbone.Vendor
  parse: (resp, xhr) ->
    @meta = resp.meta
    resp.vendors
