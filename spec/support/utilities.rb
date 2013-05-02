include ApplicationHelper

class FakeUserSession
  def initialize(user_id)
    class_eval %Q{
      def record
        User.find(#{user_id})
      end
    }
  end
end

def wait_until
  require "timeout"
  Timeout.timeout(Capybara.default_wait_time) do
    sleep(0.1) until value = yield
    value
  end
end

def sign_in(user)
  UserSession.stub!(:find).and_return(FakeUserSession.new(user.id))
end

def sign_out
  UserSession.stub!(:find).and_return(nil)
end

def ensure_loading
  expect(page).to have_selector('.loading-indicator', visible: true)
end

def ensure_done_loading
  expect(page).to_not have_selector('.loading .loading-indicator')
end

def wait_for_load
  ensure_loading
  ensure_done_loading
end

def refresh
  visit current_path
end

def ensure_request_has_finished
  wait_until do
    page.evaluate_script('$.active') == 0
  end
end

def before_and_after_refresh(&block)
  instance_eval(&block)
  refresh
  instance_eval(&block)
end

def have_bid_link(bid)
  have_selector('[href="'+project_bid_path(bid.project, bid)+'"]')
end

def pagination_should_be_on_page(page_number)
  page.find('.pagination').should have_selector('li.active a', text: Regexp.new("^#{page_number.to_s}$"))
end

def pagination_should_have_pages(page_numbers)
  Array(page_numbers).each do |page_number|
    page.find('.pagination').should have_selector('li', text: Regexp.new("^#{page_number.to_s}$"))
  end
end

def pagination_should_not_have_pages(page_numbers)
  Array(page_numbers).each do |page_number|
    page.find('.pagination').should_not have_selector('li', text: Regexp.new("^#{page_number.to_s}$"))
  end
end

def ensure_bid_page_is_starred
  expect(page).to have_selector('[data-backbone-star].icon-star')
end

def ensure_bid_page_is_unstarred
  expect(page).to have_selector('[data-backbone-star].icon-star-empty')
end

def be_starred
  have_selector('[data-backbone-star] .icon-star')
end

def be_unstarred
  have_selector('[data-backbone-star] .icon-star-empty')
end

def render_404
  raise_error(ActionController::RoutingError)
end

def sort_by(x)
  find(".js-sort-select").set(x)
  find(".js-sort-select").trigger('change')
  wait_for_load
end

def ensure_bid_is_first_then_reverse_and_ensure_last(bid)
  page.should have_bid_link(bid)
  find(".js-direction-select").click
  wait_for_load
  page.should_not have_bid_link(bid)
end