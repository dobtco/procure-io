ActiveRecord::Base.send(:include, AdditionalAliases)
ActiveRecord::Base.send(:include, Searcher)
ActiveRecord::Base.send(:include, Calculator)
ActiveRecord::Base.send(:include, Behaviors::TouchesSelf)
