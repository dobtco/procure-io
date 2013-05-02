require 'spec_helper'

describe 'Bid Review', js: true do

  before { sign_in(officers(:adam).user) }

  describe 'bids/index' do
    before do
      15.times { |i| FactoryGirl.create(:bid, project: projects(:one), submitted_at: Time.now + i.seconds) }
      visit project_bids_path(projects(:one))
    end

    describe 'sorting' do
      it 'should automatically sort by vendor name' do
        first_bid = projects(:one).bids.first
        ensure_bid_is_first_then_reverse_and_ensure_last(first_bid)
      end

      it 'should sort by created at' do
        first_bid = projects(:one).bids.joins(:vendor).order("created_at ASC").first
        sort_by('created_at')
        ensure_bid_is_first_then_reverse_and_ensure_last(first_bid)
      end

      it 'by response field' do
        first_bid = projects(:one)
                    .bids
                    .join_responses_for_response_field_id(response_fields(:three).id)
                    .order("CASE WHEN responses.response_field_id IS NULL then 1 else 0 end,
                            responses.sortable_value::numeric ASC")
                    .first

        sort_by(response_fields(:three).id)

        # When we sort by a response field, we should see it in the table.
        page.should have_selector('th', text: response_fields(:three).label)
        page.should have_selector('td', text: first_bid.responses.where(response_field_id: response_fields(:three).id).first.display_value)

        ensure_bid_is_first_then_reverse_and_ensure_last(first_bid)
      end
    end

    describe 'pagination' do
      it 'should render and show 10 bids at a time' do
        pagination_should_be_on_page(1)
        page.should have_selector('#bids-tbody tr', count: 10)
      end

      it 'should render longer paginations' do
        120.times { |i| FactoryGirl.create(:bid, project: projects(:one), submitted_at: Time.now + i.seconds) }
        refresh
        pagination_should_have_pages([1, 2, 3, 4, 5, 6, 7, 8, 9, 13, 14])
        pagination_should_not_have_pages([10, 11, 12])
        find('.pagination').click_link('14')
        wait_for_load
        pagination_should_have_pages([14, 13, 12, 11, 10, 9, 8, 7, 6, 2, 1])
        pagination_should_not_have_pages([5, 4, 3])
      end

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
          ensure_pagination_has_num_pages(1)
        end
      end
    end

    describe 'individual action' do
      it 'should mark bids as starred' do
        first_bid = find('.bid-tr:eq(1)')
        first_bid.should be_starred
        first_bid.find('[data-backbone-star]').click
        before_and_after_refresh do
          first_bid.should be_unstarred
        end
      end
    end

    describe 'key fields' do
      it 'should show key fields in table' do
        page.should have_selector('th', text: response_fields(:one).label)
        page.should have_selector('td', text: bids(:one).responses.where(response_field_id: response_fields(:one).id).first.display_value)
        page.should_not have_selector('th', text: response_fields(:two).label)
        response_fields(:two).update_attributes(key_field: true)
        refresh
        page.should have_selector('th', text: response_fields(:two).label)
        page.should have_selector('td', text: bids(:one).responses.where(response_field_id: response_fields(:two).id).first.display_value)
      end
    end

    describe 'labels' do
      it 'should sort by label'
      it 'should create and destroy labels'
    end

    describe 'searching' do
      it 'should search bids'
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
      it 'should dismiss and undismiss bids' do
        # Dismiss
        page.should have_selector('.badge', text: I18n.t('g.open'))
        click_button I18n.t('g.dismiss')
        before_and_after_refresh do
          page.should have_selector('.badge', text: 'Dismissed')
        end

        # Undismiss
        click_button I18n.t('g.undismiss')
        before_and_after_refresh do
          page.should have_selector('.badge', text: I18n.t('g.open'))
        end
      end
    end

    describe 'should award and unaward bids' do
      it 'should award and unaward bids' do
        # Award
        page.should have_selector('.badge', text: I18n.t('g.open'))
        click_button I18n.t('g.award')
        before_and_after_refresh do
          page.should have_selector('.badge', text: I18n.t('g.awarded'))
        end

        # Unaward
        click_button I18n.t('g.unaward')
        before_and_after_refresh do
          page.should have_selector('.badge', text: I18n.t('g.open'))
        end
      end
    end

    describe 'starring' do
      it 'should recalculate star count asynchronously' do
        page.should have_selector('.total-stars', text: "1")
        find('[data-backbone-star]').click
        page.should have_selector('.total-stars', text: "0")
      end

      it 'should save star count when refreshing' do
        find('[data-backbone-star]').click
        before_and_after_refresh do
          ensure_bid_page_is_unstarred
        end
      end
    end

    describe 'unread' do
      it 'should mark as read when reloading the page' do
        bid_reviews(:one).update_attributes(read: false)
        refresh
        page.should have_selector('.icon-circle-blank')
      end
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

    describe 'labeling' do
      it 'should label and unlabel bid'
    end
  end
end