module SaveResponsesHelper
  def save_responses(responsable, response_fields)
    response_fields.each do |response_field|
      next unless params[:response_fields] && (response_field_params = params[:response_fields][response_field.id.to_s])

      response = responsable.responses.where(response_field_id: response_field.id).first_or_initialize(user_id: current_user.id)

      case response_field.field_type
      when "text", "paragraph", "dropdown", "radio", "price", "number", "date", "website", "time"
        response.update_attributes(value: response_field_params)

      when "checkboxes"
        values = {}

        (response_field[:field_options]["options"] || []).each_with_index do |option, index|
          label = response_field.field_options["options"][index]["label"]
          values[option["label"]] = response_field_params && response_field_params[index.to_s] == "on"
        end

        response.update_attributes(value: values)

      when "file"
        response.upload = response_field_params
        response.save!
      end
    end

    responsable.save
  end
end