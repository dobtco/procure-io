class ProjectAttachmentUploader < CarrierWave::Uploader::Base
  storage (Rails.env.development? ? :file : :fog)

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
end
