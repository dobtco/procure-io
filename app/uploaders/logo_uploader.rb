class LogoUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

  storage (Rails.env.development? ? :file : :fog)

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  version :thumb do
    process resize_to_limit: [100, 100]
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end
end
