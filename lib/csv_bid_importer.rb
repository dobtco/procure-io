class CSVBidImporter
  attr_reader :count

  def initialize(project, params = {})
  end
    # require 'csv'

    # count = 0
    # label = @project.labels.where(name: "Imported from CSV").first_or_create(color: "4FEB5A")
    # csv = CSV.parse params[:file].read, headers: true
    # csv.each do |row|
    #   new_hash = {}
    #   row.to_hash.each_pair do |k,v|
    #     new_hash.merge!({k.downcase => v})
    #   end

    #   @project.create_bid_from_hash!(new_hash, label)

    #   count += 1
    # end
end