# == Schema Information
#
# Table name: questions
#
#  id          :integer          not null, primary key
#  project_id  :integer
#  asker_id    :integer
#  answerer_id :integer
#  body        :text
#  answer_body :text
#  created_at  :datetime
#  updated_at  :datetime
#

require 'spec_helper'

describe Question do
  before do
    @question = FactoryGirl.build(:question)
  end

  subject { @question }

  describe '#generate_question_asked_events' do
    it 'should create the correct event' do
      @question.project = (@project = FactoryGirl.create(:project))
      @question.project.should_receive(:create_events).with(:question_asked, anything, anything, anything)
      @question.save
    end
  end

  describe '#generate_question_answered_events' do
    it 'should create the correct event' do
      @question.project = (@project = FactoryGirl.create(:project))
      @question.project.should_receive(:create_events).with(:question_answered, anything, anything, anything)
      @question.send(:generate_question_answered_events_without_delay!)
    end
  end

  describe 'after update' do
    before do
      @question.stub(:project).and_return (@project = OpenStruct.new)
      @project.stub(:create_events)
      @project.stub(:active_watchers).and_return []
      @question.save
    end

    it 'should run #generate_question_answered_events if the answer body is changed' do
      @question.should_receive(:generate_question_answered_events!)
      @question.update_attributes(answer_body: "yo")
    end

    it 'should not run #generate_question_answered_events if the answer body is unchanged' do
      @question.should_not_receive(:generate_question_answered_events!)
      @question.save
    end

    it 'should not run #generate_question_answered_events if the answer body is set to blank' do
      @question.should_not_receive(:generate_question_answered_events!)
      @question.update_attributes(answer_body: "")
    end
  end
end
