module PickAndRejectHelper
  def pick(obj, *keys)
    filtered = {}

    if obj.is_a?(Hash)
      obj.each do |key, value|
        filtered[key.to_sym] = value if keys.include?(key.to_sym)
      end
    else
      keys.each do |key|
        filtered[key.to_sym] = obj.send(key)
      end
    end

    filtered
  end

  def reject(hash, *keys)
    filtered = {}
    hash.each do |key, value|
      filtered[key.to_sym] = value unless keys.include?(key.to_sym)
    end
    filtered
  end
end