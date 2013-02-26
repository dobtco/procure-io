ProcureIo.Backbone.CollaboratorList = Backbone.Collection.extend
  existingEmails: ->
    @.map (c) ->
      return c.attributes.officer.email.toLowerCase()

  model: ProcureIo.Backbone.Collaborator
