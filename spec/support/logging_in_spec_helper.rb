module LoggingInSpecHelper
  def be_logged_in
    have_text I18n.t('g.sign_out')
  end
end
