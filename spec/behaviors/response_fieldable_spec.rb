require_relative '../support/no_rails_tests'
require_relative '../../lib/behaviors/response_fieldable'
require 'active_support/core_ext/string'

class Model < FakeModel
  include Behaviors::ResponseFieldable
end

class ResponseField
end

describe Behaviors::ResponseFieldable do

  before { @model = Model.new }

  describe '#use_form_template!' do
    it 'should destroy all response fields and copy them from the template' do
      @model.should_receive(:response_fields).at_least(:once).and_return(r = OpenStruct.new(foo: "bar"))
      r.should_receive(:destroy_all)
      r.should_receive(:<<).with(1)
      r.should_receive(:<<).with(2)
      ResponseField.should_receive(:new).with(1).and_return(1)
      ResponseField.should_receive(:new).with(2).and_return(2)
      @model.should_receive(:update_attributes).with(form_options: "foo")
      @model.use_form_template!(OpenStruct.new(response_fields: [1, 2], form_options: "foo"))
    end
  end

  describe '#form_confirmation_message' do
    it 'should return the configured message if one exists' do
      @model.stub(:form_options).and_return({"form_confirmation_message" => "foo"})
      @model.form_confirmation_message.should == "foo"
    end

    it 'should return the i18n-ized message if a custom message does not exist' do
      @model.stub(:form_options).and_return({"form_confirmation_message" => ""})
      @model.stub(:class).and_return(OpenStruct.new(name: "bid"))
      I18n.should_receive(:t).with("g.bid_form_confirmation_message")
      @model.form_confirmation_message
    end

    it 'should return the i18n-ized message specific for its class' do
      @model.stub(:form_options).and_return({"form_confirmation_message" => ""})
      @model.stub(:class).and_return(OpenStruct.new(name: "zoo"))
      I18n.should_receive(:t).with("g.zoo_form_confirmation_message")
      @model.form_confirmation_message
    end
  end

end
