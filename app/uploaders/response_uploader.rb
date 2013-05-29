# encoding: utf-8

class ResponseUploader < CarrierWave::Uploader::Base
  include CarrierWave::MimeTypes
  include CarrierWave::RMagick

  process :set_content_type
  storage (Rails.env.development? ? :file : :fog)

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  version :thumb, if: :image? do
    process resize_to_limit: [200, 200]
  end

  protected
  def image?(new_file)
    new_file.content_type.include? 'image'
  end
end
