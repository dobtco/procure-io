require 'spec_helper'
include BidReviewSpecHelper

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

      it 'should sort by rating'

      it 'should sort by response field'
    end

    describe 'pagination' do
      it 'should render and show 10 bids at a time' do
        pagination_should_be_on_page(1)
        page.should have_num_bids(10)
      end

      it 'should render longer paginations' do
        120.times { |i| FactoryGirl.create(:bid, project: projects(:one), submitted_at: Time.now + i.seconds) }
        refresh
        pagination_should_have_pages([1, 2, 3, 4, 5, 6, 7, 8, 9, 13, 14])
        pagination_should_not_have_pages([10, 11, 12])
        find('.pagination').find('a', text: '14').click
        wait_for_load
        pagination_should_have_pages([14, 13, 12, 11, 10, 9, 8, 7, 6, 2, 1])
        pagination_should_not_have_pages([5, 4, 3])
      end

      it 'should paginate' do
        find('.pagination').find('a', text: '2').click
        wait_for_load
        pagination_should_be_on_page(2)
        page.should_not have_bid_link(projects(:one).bids.first)
        page.should have_bid_link(projects(:one).bids.last)

        # it should remove pagination when clicking on another filter/sorter
        find('.subview-bids-thead a', text: response_fields((:two)).label).click
        pagination_should_be_on_page(1)
      end
    end

    describe 'filters' do
      describe 'dismissed' do
        before { bids(:one).dismiss_by_officer!(officers(:adam)) }

        it 'should only show dismissed bids' do
          find('a', text: I18n.t('g.dismissed')).click
          page.should have_bid_link(projects(:one).bids.dismissed.first)
          page.should_not have_bid_link(projects(:one).bids.where_open.first)
        end
      end
    end

    describe 'bulk actions' do
      describe 'dismissal' do
        it 'should correctly mark multiple bids as dismissed' do
          check_all_bids_in_list
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
        first_bid.find('[data-backbone-click=toggleStarred]').click
        before_and_after_refresh do
          first_bid.should be_unstarred
        end
      end
    end

    describe 'key fields' do
      it 'should show key fields in table'
    end

    describe 'labels' do
      it 'should sort by label' do
        @new_label = projects(:one).labels.create(name: 'Baz')
        bids(:one).labels << @new_label
        refresh
        page.should have_num_bids(10)
        find(".subview-label-filter a", text: @new_label.name).click
        page.should have_num_bids(1)
        page.should have_bid_link(bids(:one))
        find(".subview-label-filter a", text: @new_label.name).click
        page.should have_num_bids(10)
      end

      it 'should create, edit and destroy labels' do
        page.should have_num_labels(1)

        # Create
        within "#new-label-form" do
          fill_in I18n.t('g.new_label_name'), with: "Phooey"
          click_button "Create Label"
        end

        before_and_after_refresh do
          page.should have_num_labels(2)
          page.should have_selector("#labels-admin-list a", text: "Phooey")
        end

        # Edit
        find("[data-backbone-click=toggleLabelAdmin]", visible: true).click
        find("#labels-admin-list a", text: "Phooey").click

        within "[data-backbone-submit=saveLabel]" do
          find("[data-rv-value=\"label.name\"]").set('Blooey')
          find("[data-rv-value=\"label.name\"]").trigger('change')
          click_button I18n.t('g.save_changes')
        end

        find("[data-backbone-click=toggleLabelAdmin]", visible: true).click

        before_and_after_refresh do
          page.should have_selector("#labels-admin-list a", text: "Blooey")
        end

        page.should have_num_labels(2)

        # Destroy
        find("[data-backbone-click=toggleLabelAdmin]", visible: true).click
        find("#labels-admin-list a", text: "Blooey").click
        find("[data-backbone-click=removeLabel]").click

        before_and_after_refresh do
          page.should have_num_labels(1)
        end
      end
    end

    describe 'searching' do
      it 'should perform a simple search' do
        page.should have_num_bids(10)

        within ".bid-search-form" do
          fill_in I18n.t('g.searches_all_fields'), with: responses(:one).value
        end

        find("#filter-form").trigger(:submit)
        wait_for_ajax

        page.should have_num_bids(1)
        page.should have_bid_link(bids(:one))
      end
    end
  end

  describe 'bids/show' do
    before do
      visit project_bid_path(projects(:one), bids(:one))
    end

    describe 'when vendor has not submitted bid' do
      it 'should render 404', js: false do
        bids(:one).update_attributes(submitted_at: nil)
        visit project_bid_path(projects(:one), bids(:one))
        ensure_404
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
        find('.dropdown-toggle', text: I18n.t('g.dismiss')).click
        find('.dropdown-form button', text: I18n.t('g.dismiss')).click
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
        find('.dropdown-toggle', text: I18n.t('g.award')).click
        find('.dropdown-form button', text: I18n.t('g.award')).click
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
        find('[data-backbone-click=toggleStarred]').click
        page.should have_selector('.total-stars', text: "0")
      end

      it 'should save star count when refreshing' do
        find('[data-backbone-click=toggleStarred]').click
        before_and_after_refresh do
          ensure_bid_page_is_unstarred
        end
      end
    end

    describe 'unread' do
      it 'should mark as read when reloading the page' do
        bid_reviews(:one).update_attributes(read: false)
        refresh
        bid_reviews(:one).reload
        bid_reviews(:one).read.should == true
      end
    end

    describe 'comments' do
      it 'should render the comment body' do
        page.should have_selector('.comment', comments(:one).body)
      end

      it 'should create a new comment' do
        find('#new-comment-form textarea').set('Hey dudes.')
        click_button I18n.t('g.post_comment')
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
      it 'should label and unlabel bid' do
        bid_should_not_be_labeled_as(labels(:one).name)
        find("[data-backbone-click=toggleLabeled]", text: labels(:one).name).click
        before_and_after_refresh { bid_should_be_labeled_as(labels(:one).name) }
      end
    end
  end
end
