module VendorWatchingProjectsSpecHelper
  def click_watch_button
    find('.project-watch-button .js-yes').click
  end

  def click_unwatch_button
    find('.project-watch-button .js-no').click
  end

  def be_watching
    have_selector('.project-watch-button .btn.dropdown-toggle', text: /^#{I18n.t('g.watching')}$/)
  end
end
