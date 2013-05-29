module Searcher
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def has_searcher(args = {})
      send(:include, PgSearch)

      if args[:starting_query]
        define_singleton_method :searcher_starting_query do
          args[:starting_query]
        end
      end

      define_singleton_method :searcher do |params, args = {}|
        return_object = { meta: {} }
        return_object[:meta][:page] = [params[:page].to_i, 1].max
        return_object[:meta][:per_page] = 10

        query = self.add_params_to_query((args[:starting_query] || self.searcher_starting_query), params, args)
        return query if args[:chainable]
        return query.count if args[:count_only]

        if self.respond_to?(:search_meta_info) && args[:include_meta_info]
          return_object[:meta].merge! self.search_meta_info(params, args)
        end

        return_object[:meta][:total] = query.count
        return_object[:meta][:last_page] = [(return_object[:meta][:total].to_f / return_object[:meta][:per_page]).ceil, 1].max
        return_object[:meta][:page] = [return_object[:meta][:last_page], return_object[:meta][:page]].min

        return_object[:results] = query.limit(return_object[:meta][:per_page])
                                       .offset((return_object[:meta][:page] - 1)*return_object[:meta][:per_page])

        return_object
      end
    end
  end
end