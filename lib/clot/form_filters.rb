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
      match = /_drops/.match clazz.name.tableize
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

    def submit_button(obj)
      if obj.is_a? String
        message = obj
      elsif obj.id.is_a?(Fixnum) && obj.id > 0
        message = "Update"
      else
        message = "Create"
      end

        '<div class="form-submit-button"><input type="submit" value="' + message + '"/></div>'
    end      

    def form_input_item(name, value, errors )
      input = "<input type=\"text\" id=\"#{get_id_from_name(name)}\" name=\"#{name}\" value=\"#{value}\"#{get_error_class(errors)}/>"
      input
    end    

    def form_text_item(name, value, errors )
      text = "<textarea id=\"#{get_id_from_name(name)}\" name=\"#{name}\"#{get_error_class(errors)}>#{value}</textarea>"
      text
    end

    def form_file_item(name, errors )
      input = "<input type=\"file\" id=\"#{get_id_from_name(name)}\" name=\"#{name}\" />"
      input
    end

    def form_select_item(name, value, collection, errors, blank_option = nil)
      prompt = ""
      if blank_option
        prompt = "<option>#{blank_option}</option>"
      end

      select = "<select id=\"#{get_id_from_name(name)}\" name=\"#{name}\"#{get_error_class(errors)}>"
      select += prompt
      collection.each do |item|
        @_id = @_label = item.to_s
        if item.respond_to?(:id) && item.respond_to?(:collection_label)
          @_id = item.id
          @_label = item.collection_label
        end
        select += "<option value=\"#{@_id}\"#{get_selection_value(value, item)}>#{@_label}</option>"

      end
      select += "</select>"
    end

    def get_selection_value(value,item)
        matched_value = item.to_s
        if item.respond_to?(:collection_label)
          matched_value = item.id
        end
        value.to_s == matched_value.to_s ? ' selected="true"' : ''
    end

    def get_error_class(errors)
      errors.blank? ? "" : ' class="error-item"'
    end
  end
end
