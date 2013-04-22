ProcureIo.Backbone.VendorList = Backbone.Collection.extend
  model: ProcureIo.Backbone.Vendor
  parse: ProcureIo.Backbone.Overrides.parse
