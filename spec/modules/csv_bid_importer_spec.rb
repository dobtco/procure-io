require_relative '../support/no_rails_tests'
require_relative '../../lib/csv_bid_importer'
require 'csv'
require 'active_support/all'

describe CSVBidImporter do

  describe '#initialize' do
    before do
      CSVBidImporter.any_instance.stub(:setup_response_fields)
      CSVBidImporter.any_instance.stub(:import)
    end

    it 'should parse the csv contents' do
      CSV.should_receive(:parse).with("contents", anything)
      importer = CSVBidImporter.new(mock("Project"), "contents", {label_imported_bids: ""})
      importer.instance_variable_get("@options").has_key?(:label).should == false
    end

    it 'should set a label if the param is set' do
      CSV.should_receive(:parse).with("contents", anything)
      importer = CSVBidImporter.new(mock("Project", labels: NoRailsTests::FakeQuery.new), "contents", {label_imported_bids: "yooo"})
      importer.instance_variable_get("@options").has_key?(:label).should == true
    end

    it 'should create response fields only if the option is set'
  end

  describe '#setup_response_fields' do
    it 'should destroy the existing response fields'
    it 'should create response fields for each unique header'
    it 'should reject "vendor id" or "email" as headers if :associate_vendor_account is true'
  end

  describe '#import' do
    it 'should transform each row'
    it 'should associate vendors by id'
    it 'should associate vendors by email'
    it 'should create a bid'
    it 'should create the correct responses'
    it 'should add the label'
    it 'should increment the count'
  end

  describe '#transform_row' do
    it 'should remove blank values'
    it 'should downcase keys'
    it 'should join identical keys'
  end

end
