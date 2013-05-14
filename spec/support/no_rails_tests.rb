require 'ostruct'
require_relative '../../app/helpers/pick_helper'

include PickHelper

module NoRailsTests
  class FakeModel < OpenStruct
    def self.belongs_to(*args) end
    def self.has_many(*args) end
    def self.where(*args) end
    def self.scope(*args) end
    def self.dangerous_alias(*args) end
    def self.question_alias(*args) end
  end

  class FakeQuery
    def method_missing(meth, *args)
      self
    end
  end
end
