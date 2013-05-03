module ProjectAdminSpecHelper
  def have_collaborator(officer)
    have_selector('td', text: officer.user.email)
  end

  def collaborator(officer_or_email_address)
    find("tr[data-email=\"#{officer_or_email_address.is_a?(String) ? officer_or_email_address : officer_or_email_address.user.email}\"]")
  end

  def last_collaborator
    find("#collaborators-tbody tr:last-child")
  end

  def be_owner
    have_text(I18n.t('g.owner'))
  end

  def be_invited
    have_text(I18n.t('g.invited'))
  end

  def have_collaborators_count(num)
    have_selector('#collaborators-tbody tr', count: num)
  end
end
