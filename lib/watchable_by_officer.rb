module WatchableByOfficer
  def self.included(base)
    base.has_many :officer_watches, as: :watchable
    base.extend(ClassMethods)
  end

  module ClassMethods
  end

  def watched_by?(officer)
    officer_watches.where(officer_id: officer.id, disabled: false).first ? true : false
  end

  def ever_watched_by?(officer)
    officer_watches.where(officer_id: officer.id).first ? true : false
  end
end