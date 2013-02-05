ProcureIo.Backbone.Collaborator = Backbone.Model.extend
  validate: (attrs) ->
    errors = []

    if (!attrs.email)
      return true # throws an error but does not trigger the errorAdding events
    else if (!attrs.id && ProcureIo.Backbone.Collaborators.existing_emails().indexOf(attrs.email.toLowerCase()) != -1)
      errors.push "That collaborator already exists."

    if errors.length > 0
      alert errors
      return errors

  defaults: ->
    owner: false