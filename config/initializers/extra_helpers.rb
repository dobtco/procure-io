module ActionView::Helpers::TextHelper
  def self.remove_small_words(str)
    str.split(/\s+/).uniq.reject { |x| x.length < 3 }.join(" ")
  end
end