# == Schema Information
#
# Table name: vendors
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  slug           :string(255)
#  email          :string(255)
#  address_line_1 :string(255)
#  address_line_2 :string(255)
#  city           :string(255)
#  state          :string(255)
#  zip            :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  phone_number   :string(255)
#  contact_name   :string(255)
#

class Vendor < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: :slugged

  include Behaviors::TargetableForEvents

  AUTOFILLABLE_FIELDS = [:address_line_1, :address_line_2, :city, :state, :zip]

  validates :name, presence: true, length: { minimum: 3, maximum: 100 }
  validates :email, presence: true, email: true

  has_many :bids, dependent: :destroy
  has_many :vendor_team_members, dependent: :destroy
  has_many :users,
           -> { select('users.*, vendor_team_members.owner as owner').uniq },
           through: :vendor_team_members
  has_many :vendor_registrations

  # after_update do
  #   bids.update_all(updated_at: Time.now)
  # end

  def owner
    users.where(vendor_team_members: { owner: true }).first
  end

  def profile_incomplete?
    address_line_1.blank? ||
    city.blank? ||
    state.blank? ||
    zip.blank?
  end
end
