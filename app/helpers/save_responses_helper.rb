module SaveResponsesHelper
  def save_responses(responsable, response_fields)
    response_fields.each do |response_field|
      response = responsable.responses.where(response_field_id: response_field.id).first_or_initialize

      case response_field.field_type
      when "text", "paragraph", "dropdown", "radio", "price", "number", "date", "website", "time"
        response.update_attributes(value: params[:response_fields][response_field.id.to_s])

      when "checkboxes"
        values = {}

        (response_field[:field_options]["options"] || []).each_with_index do |option, index|
          label = response_field.field_options["options"][index]["label"]
          values[option["label"]] = params[:response_fields][response_field.id.to_s] && params[:response_fields][response_field.id.to_s][index.to_s] == "on"
        end

        response.update_attributes(value: values)

      when "file"
        response.upload = params[:response_fields][response_field.id.to_s]
        response.save!
      end
    end

    responsable.save
  end
end