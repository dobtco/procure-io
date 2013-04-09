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

    describe "response fields" do
      before do
        bids(:one).destroy # remove the current bid from this officer
        visit new_project_bid_path(projects(:one))
      end

      describe "rendering properly" do
        it { should have_selector('label:contains("'+response_fields(:one).label+'")') }
        it { should have_selector('label:contains("'+response_fields(:two).label+'")') }
        it { should have_selector('input[type=text][name="response_fields['+response_fields(:one).id.to_s+']"]') }
        it { should have_selector('textarea[name="response_fields['+response_fields(:two).id.to_s+']"]') }
      end

      describe "validations" do
        pending "haven't yet implemented client-side *or* server-side validations"
      end
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
        page.should have_selector('dd', 'Yo')
        page.should have_selector('dd', 'This is my essay.')
      end
    end
  end

  describe "as officer", js: true do
    before { login_as(officers(:adam), scope: :officer) }

    describe "index page" do
      before do
        15.times { |i| FactoryGirl.create(:bid, project: projects(:one), submitted_at: Time.now + i.seconds) }
        visit project_bids_path(projects(:one))
      end

      it "should show 10 bids" do
        page.should have_selector('#bids-tbody tr', count: 10)
      end

      # @todo we could test other sorting orders too
      describe "sorting" do
        before { visit project_bids_path(projects(:one)) }

        it "should order from newest to oldest by default" do
          page.should have_selector('[href="'+project_bid_path(projects(:one), projects(:one).bids.submitted.last)+'"]')
          page.should_not have_selector('[href="'+project_bid_path(projects(:one), projects(:one).bids.submitted.first)+'"]')
        end

        it "should reverse the order when clicking the same order link" do
          click_link "Created at"
          expect(page).to have_selector('#bid-review-page:not(.loading)')
          page.should_not have_selector('[href="'+project_bid_path(projects(:one), projects(:one).bids.last)+'"]')
          page.should have_selector('[href="'+project_bid_path(projects(:one), projects(:one).bids.first)+'"]')
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
        it "should mark bids as starred" do
          find("#bids-tbody tr:eq(1) .icon-star-empty").click
          page.should have_selector("#bids-tbody tr:eq(1) .icon-star")
          visit project_bids_path(projects(:one))
          page.should have_selector("#bids-tbody tr:eq(1) .icon-star")
        end
      end

      describe "key fields" do
        pending
      end
    end

    describe "show page" do
      before do
        visit project_bid_path(projects(:one), bids(:one))
      end

      describe "when vendor has not submitted bid", js: false do
        before { bids(:one).update_attributes(submitted_at: nil) }
        it "should render 404" do
          expect { visit project_bid_path(projects(:one), bids(:one)) }.to raise_error(ActionController::RoutingError)
        end
      end

      describe "basic rendering" do
        it { should have_text(bids(:one).vendor.name) }
        it "should show all responses" do
          bids(:one).responses.each do |response|
            page.should have_selector('dd', response.value)
          end
        end
      end

      describe "dismissal" do
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
          it "should undismiss bids properly" do
            page.should have_selector('.badge:contains("Dismissed")')
            click_button "Undismiss"
            page.should have_selector('.badge:contains("Open")')
            visit project_bid_path(projects(:one), bids(:one))
            page.should have_selector('.badge:contains("Open")')
          end
        end
      end

      describe "starring" do
        it { should have_selector('.icon-star') }

        it "should recalculate star count asynchronously" do
          count = find('.total-stars').text.to_i
          find('.icon-star').click
          page.should have_selector('.icon-star-empty')
          page.should have_selector('.total-stars:contains("' + (count - 1).to_s + '")')
        end

        it "should save star count when refreshing" do
          find('.icon-star').click
          visit project_bid_path(projects(:one), bids(:one))
          page.should have_selector('.icon-star-empty')
        end
      end

      describe "unread" do
        it { should have_selector('.icon-circle-blank') }

        it "should mark as read when reloading the page" do
          find('.icon-circle-blank').click
          page.should have_selector('.icon-circle')
          visit project_bid_path(projects(:one), bids(:one))
          page.should have_selector('.icon-circle-blank')
        end
      end

      describe "comments" do
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
            logout(:officer)
            login_as(officers(:clay), scope: :officer)
            visit project_bid_path(projects(:one), bids(:one))
            page.should have_selector('.comment', text: comments(:one).body)
            page.should_not have_selector('.comment a.delete')
          end
        end
      end
    end
  end
end