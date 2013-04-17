module Searcher
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def searcher(params, args = {})
      return_object = { meta: {} }
      return_object[:meta][:page] = [params[:page].to_i, 1].max
      return_object[:meta][:per_page] = 10

      query = self.add_params_to_query(args[:starting_query], params)
      return query if args[:chainable]
      return query.count if args[:count_only]

      return_object = self.add_search_meta_to_return_object(return_object, params, args) if self.respond_to?(:add_search_meta_to_return_object)

      return_object[:meta][:total] = query.count
      return_object[:meta][:last_page] = [(return_object[:meta][:total].to_f / return_object[:meta][:per_page]).ceil, 1].max
      return_object[:page] = [return_object[:meta][:last_page], return_object[:meta][:page]].min

      return_object[:results] = query.limit(return_object[:meta][:per_page])
                                     .offset((return_object[:meta][:page] - 1)*return_object[:meta][:per_page])

      return_object
    end
  end
end