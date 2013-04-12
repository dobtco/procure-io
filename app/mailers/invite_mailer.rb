class InviteMailer < ActionMailer::Base
  include EmailBuilder

  def invite_email(officer, project)
    build_email officer.user.email,
                'invite',
                project_title: project.title,
                name: officer.display_name,
                invite_url: invite_officers_url(token: officer.user.perishable_token)
  end
end
