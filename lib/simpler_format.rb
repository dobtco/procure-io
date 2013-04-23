module SimplerFormat
  def simpler_format(text, html_options={}, options={})
    text = '' if text.nil?
    text = text.dup
    text = sanitize(text) unless options[:sanitize] == false
    text = text.to_str
    text.gsub!(/\r\n?/, "\n")                    # \r\n and \r -> \n
    text.gsub!(/\n\n+/, "<br /><br />")  # 2+ newline  -> br br
    text.gsub!(/([^\n]\n)(?=[^\n])/, '\1<br />') # 1 newline   -> br
    text.html_safe
  end
end