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
  ensure_request_has_finished
  refresh
  instance_eval(&block)
end

def have_bid_link(bid)
  have_selector('[href="'+project_bid_path(bid.project, bid)+'"]')
end

def pagination_should_be_on_page(page_number)
  expect(page).to have_selector('.pagination')
  page.should have_selector('li.active a', text: page_number.to_s)
end

def ensure_bid_is_starred
  expect(page).to have_selector('[data-backbone-star].icon-star')
end

def ensure_bid_is_unstarred
  expect(page).to have_selector('[data-backbone-star].icon-star-empty')
end

def render_404
  raise_error(ActionController::RoutingError)
end