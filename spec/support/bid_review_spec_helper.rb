module BidReviewSpecHelper

  def ensure_bid_page_is_starred
    expect(page).to have_selector('[data-backbone-click=toggleStarred].icon-star')
  end

  def ensure_bid_page_is_unstarred
    expect(page).to have_selector('[data-backbone-click=toggleStarred].icon-star-empty')
  end

  def be_starred
    have_selector('.icon-star')
  end

  def be_unstarred
    have_selector('.icon-star-empty')
  end

  def have_bid_link(bid)
    have_selector('[href="'+project_bid_path(bid.project, bid)+'"]')
  end

  def ensure_bid_is_first_then_reverse_and_ensure_last(bid)
    page.should have_bid_link(bid)
    find(".subview-bids-thead").find("i.icon-chevron-down, i.icon-chevron-up").click
    wait_for_load
    page.should_not have_bid_link(bid)
  end

  def have_num_bids(num)
    have_selector('#bids-tbody tr', count: num)
  end

  def have_num_labels(num)
    have_selector("#labels-list li", count: num)
  end

  def bid_should_be_labeled_as(label_name)
    page.should have_selector(".badge", text: label_name)
    page.should have_selector("li.active a[data-backbone-click=toggleLabeled]", text: label_name)
  end

  def bid_should_not_be_labeled_as(label_name)
    page.should_not have_selector(".badge", text: label_name)
    page.should_not have_selector("li.active a[data-backbone-click=toggleLabeled]", text: label_name)
  end

  def check_all_bids_in_list
    all('#bids-tbody input[type=checkbox]').each { |e| e.set(true) }
  end

  def toggle_filter_by_label(label_name)
    find(".subview-label-filter a", text: label_name).click
    wait_for_load
  end

end
