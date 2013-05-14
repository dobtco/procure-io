# == Schema Information
#
# Table name: roles
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  role_type   :integer          default(1), not null
#  permissions :text
#  created_at  :datetime
#  updated_at  :datetime
#  undeletable :boolean
#  default     :boolean
#

require 'spec_helper'

describe Role do

  describe 'Role#role_type_name' do
    it 'should look up the correct translation' do
      I18n.should_receive(:t).with("roles.role_types.foo")
      Role.role_type_name(:foo)
    end
  end

  describe '#is_god' do
    it 'should return true when role_type is god' do
      r = Role.new(role_type: Role.role_types[:god])
      r.is_god?.should == true
    end

    it 'should return false otherwise' do
      r = Role.new(role_type: Role.role_types[:admin])
      r.is_god?.should == false
    end
  end

  describe 'default permissions' do
    it 'should be set on initialization' do
      r = Role.new
      r.permissions.should == Role.low_permissions
    end
  end

end
