require 'spec_helper'

describe "Bid" do

  subject { page }

  describe "as vendor" do

    before { login_as(vendors(:one), scope: :vendor) }

    describe "new bid page" do
      before do
        bids(:one).destroy # remove the current bid from this officer
        visit new_project_bid_path(projects(:one))
      end

      it { should have_selector('h4', 'New Bid') }
      it { should have_selector('label', 'Name') }
      it { should have_selector('textarea[name="response_fields[2]"]') }
    end

    describe "show bid" do
      before do
        visit project_bid_path(projects(:one), bids(:one))
      end

      it { should have_selector('dd', 'Bananas!') }
      it { should have_selector('dd', 'Melons!') }
    end

    describe "create bid", js: true do
      before do
        bids(:one).destroy
        visit new_project_bid_path(projects(:one))
        fill_in "response_fields[1]", with: "Yo"
        fill_in "response_fields[2]", with: "This is my essay."
      end

      it "should save your draft" do
        expect(page).to have_selector('#save-draft-button:not(.disabled)')
        find("#save-draft-button").click
        expect(page).to have_selector('#save-draft-button.disabled')
        visit new_project_bid_path(projects(:one))
        find_field("response_fields[1]").value.should == 'Yo'
        find_field("response_fields[2]").value.should == 'This is my essay.'
      end

      it "should submit bids" do
        click_button "Submit Bid"
        page.should have_selector('a', 'your bid')
        click_link 'your bid'
        page.should have_selector('dd', 'Yo')
        page.should have_selector('dd', 'This is my essay.')
      end
    end
  end

  describe "as officer" do
    before { login_as(officers(:adam), scope: :officer) }

    describe "index page", js: true do
      before do
        @first_bid = FactoryGirl.create(:bid, project: projects(:one))
        15.times { FactoryGirl.create(:bid, project: projects(:one)) }
        @last_bid = FactoryGirl.create(:bid, project: projects(:one))
        visit project_bids_path(projects(:one))
      end

      it "should show 10 bids" do
        page.should have_selector('#bids-tbody tr', count: 10)
      end

      # @todo we could test other sorting orders too
      describe "sorting" do
        it "should order from newest to oldest by default" do
          page.should have_selector('[href="'+project_bid_path(projects(:one), @last_bid)+'"]')
          page.should_not have_selector('[href="'+project_bid_path(projects(:one), @first_bid)+'"]')
        end

        it "should reverse the order when clicking the same order link" do
          click_link "Created at"
          page.should_not have_selector('[href="'+project_bid_path(projects(:one), @last_bid)+'"]')
          page.should have_selector('[href="'+project_bid_path(projects(:one), @first_bid)+'"]')
        end
      end

      # @todo we *should* test for > 10 pages
      describe "pagination" do
        it "should render the pagination" do
          page.should have_selector('li.active a', '1')
          page.should have_selector('li a', '2')
        end

        it "should paginate properly" do
          find(".pagination a:contains(2)").click
          page.should have_selector('#loading-indicator', visible: true)
          page.should have_selector('li a', '1')
          page.should have_selector('li.active a', '2')
          page.should_not have_selector('[href="'+project_bid_path(projects(:one), @last_bid)+'"]')
          page.should have_selector('[href="'+project_bid_path(projects(:one), @first_bid)+'"]')
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
            page.should_not have_selector('[href="'+project_bid_path(projects(:one), @first_bid)+'"]')
          end
        end

        describe "dismissed" do
          before { bids(:one).dismiss_by_officer!(officers(:adam)) }

          it "should only show dismissed bids" do
            click_link "Dismissed Bids"
            page.should have_selector('[href="'+project_bid_path(projects(:one), bids(:one))+'"]')
            page.should_not have_selector('[href="'+project_bid_path(projects(:one), @first_bid)+'"]')
          end
        end
      end

      describe "bulk actions" do
        describe "dismissal" do
          it "should correctly mark multiple bids as dismissed" do
            all("#bids-tbody input[type=checkbox]").each { |e| e.set(true) }
            click_button "Dismiss"
            expect(page).to have_selector('#loading-indicator', visible: true)
            expect(page).to have_selector('#bid-review-page:not(.loading)')
            page.should have_selector('.pagination ul li', count: 3)
          end
        end
      end

      describe "individual action" do
        it "should mark bids as starred" do
          find("#bids-tbody tr:eq(1) .icon-star-empty").click
          page.should have_selector("#bids-tbody tr:eq(1) .icon-star")
          visit project_bids_path(projects(:one))
          page.should have_selector("#bids-tbody tr:eq(1) .icon-star")
        end

        it "should mark bids as read" do
          find("#bids-tbody tr:eq(1) .icon-circle").click
          page.should have_selector("#bids-tbody tr:eq(1) .icon-circle-blank")
          visit project_bids_path(projects(:one))
          page.should have_selector("#bids-tbody tr:eq(1) .icon-circle-blank")
        end
      end
    end

    describe "show page" do
      # when vendor has not submitted
    end
  end
end