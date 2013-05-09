# == Schema Information
#
# Table name: questions
#
#  id          :integer          not null, primary key
#  project_id  :integer
#  vendor_id   :integer
#  officer_id  :integer
#  body        :text
#  answer_body :text
#  created_at  :datetime
#  updated_at  :datetime
#

require 'spec_helper'

describe Question do

  let(:question) { questions(:blank) }

  describe '#generate_question_asked_events' do
    it 'should create the correct event' do
      q = Question.new(project: projects(:one))
      q.project.should_receive(:create_events).with(:question_asked, anything, anything, anything)
      q.save
    end
  end

  describe '#generate_question_answered_events' do
    it 'should create the correct event' do
      q = Question.new(project: projects(:one), vendor: vendors(:one))
      q.project.should_receive(:create_events).with(:question_answered, anything, anything, anything)
      q.send(:generate_question_answered_events_without_delay!)
    end
  end

  describe 'after update' do
    it 'should run #generate_question_answered_events if the answer body is changed' do
      question.should_receive(:generate_question_answered_events!)
      question.update_attributes(answer_body: "yo")
    end

    it 'should not run #generate_question_answered_events if the answer body is unchanged' do
      questions(:filled_out).should_not_receive(:generate_question_answered_events!)
      questions(:filled_out).save
    end

    it 'should not run #generate_question_answered_events if the answer body is set to blank' do
      questions(:filled_out).should_not_receive(:generate_question_answered_events!)
      questions(:filled_out).update_attributes(answer_body: "")
    end
  end
end
