module SerializationHelper
  # Ripped from Discourse:
  #
  # This is odd, but it seems that in Rails `render json: obj` is about
  # 20% slower than calling MultiJSON.dump ourselves. I'm not sure why
  # Rails doesn't call MultiJson.dump when you pass it json: obj but
  # it seems we don't need whatever Rails is doing.
  def serialized(*args)

    obj = args[0]
    is_collection = obj.respond_to?(:each)

    if args[1].is_a?(Hash)
      opts = args[1]
      serializer = args[2]
    elsif args[1]
      serializer = args[1]
      opts = args[2]
    end

    if !serializer && !(is_collection && obj.empty?)
      serializer = "#{is_collection ? obj[0].class.name : obj.class.name}Serializer".constantize
    end

    opts = {} if !opts

    if opts[:meta]
      opts[:root] = "results"
    else
      opts[:root] = false
    end

    if opts.has_key?(:scope)
      scope = opts.delete(:scope)
    elsif defined?(current_user)
      scope = current_user
    else
      scope = false
    end

    # If it's an array, apply the serializer as an each_serializer to the elements
    serializer_opts = {scope: scope}.merge!(opts)
    if is_collection
      serializer_opts[:each_serializer] = serializer if serializer
      ActiveModel::ArraySerializer.new(obj, serializer_opts).as_json
    else
      serializer.new(obj, serializer_opts).as_json
    end
  end

  def render_serialized(*args)
    render_json_dump serialized(*args)
  end

  def render_json_dump(obj)
    render json: MultiJson.dump(obj)
  end
end