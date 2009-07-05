module Clot
  module FormFilters
    
    def form_item(tag, message, required = false)
      tag_id = get_attribute_value("id", tag)
      
      form_string = ""
      if tag_id 
        form_string = " for=\"#{tag_id}\""
      end
      
      if required
        required_string = "<span class=\"required\">*</span>"
      else
        required_string = ""
      end
      
      "<p><label#{form_string}>#{message}#{required_string}</label>#{tag}</p>"
    end

#################

   #note - must reconstruct from scratch...
    def input_to_text(input)

      value_match = /value="([^"]*)"/.match input
      if value_match
        value_text = value_match[1]
      else
        value_text = ""
      end

      name_match = /name="[^"]*"/.match input
      if name_match
        name_text = " #{name_match[0]}"
      else
        name_text = ""
      end

      "<textarea#{name_text}>#{value_text}</textarea>"
    end

    def concat(string1, string2)
      "#{string1}#{string2}"
    end
    

    def get_id_from_name(name)
      name.sub("[", "_").sub("]","")
    end

    def drop_class_to_table_item(clazz)
      match = /_drops/.match clazz.to_s.tableize
      match.pre_match
    end  
    
    def get_attribute_value(prop, input)
      prop_match = /#{prop}="([^"]*)"/.match input
      if prop_match
        prop_match[1]
      end
    end


    def set_param(tag, key, value)
      match = /#{key}="[^"]*"/.match tag
      if match
        return match.pre_match + "#{key}=\"#{value}\"" + match.post_match
      end

      match = /(\/>|>)/.match tag
      if match
        match.pre_match + " #{key}=\"#{value}\"" + match.to_s + match.post_match
      else
        tag
      end
    end

    def submit_button(message)
        '<div class="form-submit-button"><input type="submit" value="' + message + '"/></div>'
    end      

    def form_input_item(name, value, errors )
      error_string = ""
      unless errors.blank?
        error_string = ' class="error-item"'
      end
      input = "<input type=\"text\" id=\"#{get_id_from_name(name)}\" name=\"#{name}\" value=\"#{value}\"#{error_string}/>"
      input
    end    

    def input_to_checkbox(input)
      set_param(input, "type", "checkbox")
    end


    def input_to_select(input, items = [])
      name = get_attribute_value("name", input)
      open_tag = "<select name=\"#{name}\">"
      option_string = ''
      items.each do |item|
        option_string += "<option value=\"#{item[:id]}\">#{item[:name]}</option>"
      end
      close_tag = "</select>"
      open_tag + option_string + close_tag
    end

  end
end
