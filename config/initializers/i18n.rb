I18n.exception_handler = lambda do |exception, locale, key, options|
  e = exception.respond_to?(:to_exception) ? exception.to_exception : exception
  # log rotate, because it's not important enough to keep
  @log ||= Logger.new(File.join(Rails.root, 'log', 'missing_translations.log'),2,5*1024*1024)
  if e.is_a? I18n::MissingTranslationData
    @log.info "#{locale}.#{key}"
  else
    raise e
  end
  exception.to_s
end