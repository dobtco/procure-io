class Officers::InvitationsController < Devise::InvitationsController
   private
   def resource_params
     params.permit(officer: [:name, :email,:invitation_token])[:officer]
   end
end