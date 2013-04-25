class FakeModel < OpenStruct
  def self.belongs_to(*args) end
  def self.where(*args) end
  def self.scope(*args) end
  def self.dangerous_alias(*args) end
  def self.question_alias(*args) end
end
