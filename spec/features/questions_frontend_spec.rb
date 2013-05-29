require 'spec_helper'

describe 'Questions Frontend', js: true do

  pending " :) "

  # before do
  #   sign_in(vendors(:one).user)
  #   visit project_path(projects(:one))
  # end

  # it 'should render questions properly' do
  #   find(".question", text: questions(:filled_out).body).find("a", text: I18n.t('g.show_answer')).click
  #   page.should have_selector('.question', text: questions(:filled_out).body)
  #   page.should have_selector('.question', text: questions(:filled_out).answer_body)
  #   page.should have_selector('.question', text: questions(:filled_out).officer.display_name)
  # end

  # describe 'asking questions' do
  #   it "should create a new question" do
  #     page.should have_selector("textarea#question_body", visible: false)
  #     find("#ask-question-toggle").click
  #     page.should have_selector("textarea#question_body", visible: true)
  #     find("#question_body").set("Shoop?")
  #     click_button I18n.t('g.submit')

  #     before_and_after_refresh do
  #       page.should have_selector('.question', text: 'Shoop?')
  #     end
  #   end

  #   it "should not create blank questions" do
  #     count = all("#questions-list .question").length
  #     find("#ask-question-toggle").click
  #     find("#question_body").set("")
  #     click_button I18n.t('g.submit')

  #     before_and_after_refresh do
  #       page.should have_selector("#questions-list .question", count: count)
  #     end
  #   end
  # end

end