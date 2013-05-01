require 'spec_helper'

describe 'Bid Review', js: true, retry: 3 do

  before { sign_in(officers(:adam).user) }

  describe 'bids/index' do
    before do
      15.times { |i| FactoryGirl.create(:bid, project: projects(:one), submitted_at: Time.now + i.seconds) }
      visit project_bids_path(projects(:one), sort: 'created_at', direction: 'asc')
    end

    it 'should show 10 bids' do
      page.should have_selector('#bids-tbody tr', count: 10)
    end

    it 'should sort'

    describe 'pagination' do
      it 'should render' do
        pagination_should_be_on_page(1)
      end

      it 'should render longer paginations'

      it 'should paginate' do
        find('.pagination').click_link('2')
        wait_for_load
        pagination_should_be_on_page(2)
        page.should_not have_bid_link(projects(:one).bids.first)
        page.should have_bid_link(projects(:one).bids.last)
      end

      it 'should remove pagination when clicking on another filter' do
        find('.pagination').click_link('2')
        wait_for_load
        pagination_should_be_on_page(2)
        find_link('Dismissed Bids')[:href].should_not match('page=')
      end
    end

    describe 'filters' do
      describe 'starring' do
        it 'should only show starred bids' do
          click_link 'Starred Bids'
          page.should have_bid_link(bids(:one))
          page.should_not have_bid_link(projects(:one).bids.where(total_stars: 0).first)
          page.should_not have_bid_link(projects(:one).bids.where(total_stars: 0).last)
        end
      end

      describe 'dismissed' do
        before { bids(:one).dismiss_by_officer!(officers(:adam)) }

        it 'should only show dismissed bids' do
          click_link 'Dismissed Bids'
          page.should have_bid_link(projects(:one).bids.dismissed.first)
          page.should_not have_bid_link(projects(:one).bids.where_open.first)
        end
      end
    end

    describe 'bulk actions' do
      describe 'dismissal' do
        it 'should correctly mark multiple bids as dismissed' do
          all('#bids-tbody input[type=checkbox]').each { |e| e.set(true) }
          click_button 'Dismiss'
          wait_for_load
          page.should have_selector('.pagination ul li', count: 3)
        end
      end
    end

    describe 'individual action' do
      it 'should mark bids as starred'
    end

    describe 'key fields' do
      pending
    end
  end

  describe 'bids/show' do
    before do
      visit project_bid_path(projects(:one), bids(:one))
    end

    describe 'when vendor has not submitted bid' do
      it 'should render 404', js: false do
        bids(:one).update_attributes(submitted_at: nil)
        expect { visit project_bid_path(projects(:one), bids(:one)) }.to render_404
      end
    end

    describe 'basic rendering' do
      it 'should show the vendors name' do
        page.should have_text(bids(:one).vendor.name)
      end

      it 'should show all responses' do
        bids(:one).responses.each do |response|
          page.should have_selector('dd', text: response.value)
        end
      end
    end

    describe 'dismissal' do
      it 'should initially be open' do
        page.should have_selector('.badge', text: 'Open')
      end

      it 'should dismiss bids' do
        click_button 'Dismiss'
        before_and_after_refresh do
          page.should have_selector('.badge', text: 'Dismissed')
        end
      end
    end

    describe 'undismissal' do
      before { bids(:one).dismiss_by_officer!(officers(:adam)) }
      it 'should undismiss bids'
    end

    describe 'starring' do
      it 'should initially be starred' do
        ensure_bid_is_starred
      end

      it 'should recalculate star count asynchronously'

      it 'should save star count when refreshing' do
        find('[data-backbone-star]').click
        ensure_request_has_finished
        before_and_after_refresh do
          ensure_bid_is_unstarred
        end
      end
    end

    describe 'unread' do
      it 'should mark as read when reloading the page'
    end

    describe 'comments' do
      it 'should render the comment body' do
        page.should have_selector('.comment', comments(:one).body)
      end

      it 'should create a new comment' do
        find('#new-comment-form textarea').set('Hey dudes.')
        click_button 'Post Comment'
        before_and_after_refresh do
          page.should have_selector('.comment', text: 'Hey dudes.')
        end
      end

      describe 'deleting comments' do
        it 'should let you delete your own comments' do
          find('.comment a.delete').click
          before_and_after_refresh do
            page.should_not have_selector('.comment', text: comments(:one).body)
          end
        end

        it 'should not let you delete other officers comments' do
          sign_out
          sign_in(officers(:clay).user)
          refresh
          page.should have_selector('.comment', text: comments(:one).body)
          page.should_not have_selector('.comment a.delete')
        end
      end
    end
  end
end