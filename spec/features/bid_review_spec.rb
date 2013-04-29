require 'spec_helper'

describe "Bid Review", js: true do

  subject { page }

  before { sign_in(officers(:adam).user) }

  describe "bids/index" do
    before do
      15.times { |i| FactoryGirl.create(:bid, project: projects(:one), submitted_at: Time.now + i.seconds) }
      visit project_bids_path(projects(:one))
    end

    it "should show 10 bids" do
      page.should have_selector('#bids-tbody tr', count: 10)
    end

    # @todo sorting
    it "should sort"

    # @todo we *should* test for > 10 pages
    describe "pagination" do
      it "should render the pagination" do
        page.should have_selector('li.active a', '1')
        page.should have_selector('li a', '2')
      end

      it "should paginate properly" do
        find(".pagination a:contains(2)").click
        expect(page).to have_selector('.loading-indicator', visible: true)
        page.should have_selector('li a', '1')
        page.should have_selector('li.active a', '2')
        page.should_not have_selector('[href="'+project_bid_path(projects(:one), projects(:one).bids.last)+'"]')
        page.should have_selector('[href="'+project_bid_path(projects(:one), projects(:one).bids.first)+'"]')
      end

      # @todo this would be a better test with bids in each category.
      it "should remove pagination when clicking on another filter" do
        page.should have_selector('li.active a', '2')
        find('a:contains("Dismissed Bids")')[:href].should_not match("page=")
      end
    end

    describe "filters" do
      describe "starring" do
        it "should only show starred bids" do
          click_link "Starred Bids"
          page.should have_selector('[href="'+project_bid_path(projects(:one), bids(:one))+'"]')
          page.should_not have_selector('[href="'+project_bid_path(projects(:one), projects(:one).bids.where(total_stars: 0).first)+'"]')
          page.should_not have_selector('[href="'+project_bid_path(projects(:one), projects(:one).bids.where(total_stars: 0).last)+'"]')
        end
      end

      describe "dismissed" do
        before { bids(:one).dismiss_by_officer!(officers(:adam)) }

        it "should only show dismissed bids" do
          click_link "Dismissed Bids"
          page.should have_selector('[href="'+project_bid_path(projects(:one), bids(:one))+'"]')
          page.should_not have_selector('[href="'+project_bid_path(projects(:one), projects(:one).bids.first)+'"]')
        end
      end
    end

    describe "bulk actions" do
      describe "dismissal" do
        it "should correctly mark multiple bids as dismissed" do
          all("#bids-tbody input[type=checkbox]").each { |e| e.set(true) }
          click_button "Dismiss"
          page.should have_selector('.loading-indicator', visible: true)
          page.should have_selector('#bid-review-page:not(.loading)')
          page.should have_selector('.pagination ul li', count: 3)
        end
      end
    end

    describe "individual action" do
      it "should mark bids as starred"
    end

    describe "key fields" do
      pending
    end
  end

  describe "bids/show" do
    describe "when vendor has not submitted bid" do
      it "should render 404" #do
        # bids(:one).update_attributes(submitted_at: nil)
        # expect { visit project_bid_path(projects(:one), bids(:one)) }.to raise_error(ActionController::RoutingError)
      # end
    end

    describe "basic rendering" do
      before { visit project_bid_path(projects(:one), bids(:one)) }
      it { should have_text(bids(:one).vendor.name) }
      it "should show all responses" do
        bids(:one).responses.each do |response|
          page.should have_selector('dd', response.value)
        end
      end
    end

    describe "dismissal" do
      before { visit project_bid_path(projects(:one), bids(:one)) }
      it { should have_selector('.badge:contains("Open")') }
      it "should dismiss bids properly" do
        click_button "Dismiss"
        page.should have_selector('.badge:contains("Dismissed")')
        visit project_bid_path(projects(:one), bids(:one))
        page.should have_selector('.badge:contains("Dismissed")')
      end

      describe "undismissal" do
        before do
          bids(:one).dismiss_by_officer!(officers(:adam))
          visit project_bid_path(projects(:one), bids(:one))
        end
        it "should undismiss bids properly"
      end
    end

    describe "starring" do
      before { visit project_bid_path(projects(:one), bids(:one)) }
      it { should have_selector('[data-backbone-star]') }

      it "should recalculate star count asynchronously" do
      end

      it "should save star count when refreshing" do
        find('[data-backbone-star]').click
        visit project_bid_path(projects(:one), bids(:one))
        page.should have_selector('.icon-star-empty')
      end
    end

    describe "unread" do
      before { visit project_bid_path(projects(:one), bids(:one)) }
      it "should mark as read when reloading the page"
    end

    describe "comments" do
      before { visit project_bid_path(projects(:one), bids(:one)) }
      it { should have_selector('.comment', comments(:one).body) }

      it "should create a new comment" do
        find("#new-comment-form textarea").set("Hey dudes.")
        click_button "Post Comment"
        page.should have_selector('.comment', text: 'Hey dudes.')
        visit project_bid_path(projects(:one), bids(:one))
        page.should have_selector('.comment', text: 'Hey dudes.')
      end

      describe "deleting comments" do
        it "should let you delete your own comments" do
          page.should have_selector('.comment', text: comments(:one).body)
          find(".comment a.delete").click
          page.should_not have_selector('.comment', text: comments(:one).body)
          visit project_bid_path(projects(:one), bids(:one))
          page.should_not have_selector('.comment', text: comments(:one).body)
        end

        it "should not let you delete other officers' comments" do
          sign_out
          sign_in(officers(:clay).user)
          visit project_bid_path(projects(:one), bids(:one))
          page.should have_selector('.comment', text: comments(:one).body)
          page.should_not have_selector('.comment a.delete')
        end
      end
    end
  end
end