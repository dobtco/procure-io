ProcureIo.Backbone.CollaboratorList = Backbone.Collection.extend
  existing_emails: ->
    @.map (c) ->
      return c.attributes.email.toLowerCase()

  model: ProcureIo.Backbone.Collaborator
