module AwardableAndDismissableByOfficer
  def self.included(base)
    base.belongs_to :dismissed_by_officer, foreign_key: "dismissed_by_officer_id"
    base.belongs_to :awarded_by_officer, foreign_key: "awarded_by_officer_id"
    base.scope :dismissed, base.where("dismissed_at IS NOT NULL")
    base.scope :awarded, base.where("awarded_at IS NOT NULL")
    base.scope :where_open, base.where("dismissed_at IS NULL AND awarded_at IS NULL")


    base.extend(ClassMethods)
    base.question_alias :dismissed, :awarded
    base.dangerous_alias :unaward_by_officer, :undismiss_by_officer, :award_by_officer, :dismiss_by_officer
  end

  module ClassMethods
  end

  def dismiss_by_officer(officer)
    return false if self.dismissed_at
    self.dismissed_at = Time.now
    self.dismissed_by_officer_id = officer.id
    after_dismiss_by_officer(officer) if self.respond_to?(:after_dismiss_by_officer, true)
  end

  def award_by_officer(officer)
    return false if self.awarded_at
    self.awarded_at = Time.now
    self.awarded_by_officer_id = officer.id
    after_award_by_officer(officer) if self.respond_to?(:after_award_by_officer, true)
  end

  def undismiss_by_officer(officer)
    return false if !self.dismissed_at
    self.dismissed_at = nil
    self.dismissed_by_officer_id = nil
    after_undismiss_by_officer(officer) if self.respond_to?(:after_undismiss_by_officer, true)
  end

  def unaward_by_officer(officer)
    return false if !self.awarded_at
    self.awarded_at = nil
    self.awarded_by_officer_id = nil
    after_unaward_by_officer(officer) if self.respond_to?(:after_unaward_by_officer, true)
  end

  def dismissed
    dismissed_at ? true : false
  end

  def awarded
    awarded_at ? true : false
  end

  def text_status
    if dismissed_at
      I18n.t('g.dismissed')
    elsif awarded_at
      I18n.t('g.awarded')
    else
      I18n.t('g.open')
    end
  end

end
