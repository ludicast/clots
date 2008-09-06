module Clot
  module FormFilters
    
    def form_item(tag, message, required = false)
      tag_id = get_tag_prop("id", tag)
      
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
    
    def input_to_select(input, data_class, sort_field="name")
      
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
      
      retval = "<select#{name_text}>"
      
      if data_class == "users"        
        users = get_regular_users
      elsif data_class == "projects"
        users = get_projects
      end
      
      users.each do | user |
        if (user.id.to_s == value_text)
          select_string = "selected=\"selected\""   
        end
        retval += "<option value=\"#{user.id}\" #{select_string}>" + user[sort_field] + "</option>"
      end
      
      retval += "</select>"      
      
      retval
    end
    
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
    
    def input_to_checkbox(input)
      
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
      
      "<input type=\"checkbox\" value=\"true\" #{name_text} #{value_text == 'true' ? 'checked' : ''} />"
    end    
    
    
    def concat(string1, string2)
      "#{string1}#{string2}"
    end
    
    def simple_form_helper(name, value, errors )
      error_string = ""
      unless errors.blank?
        error_string = ' class="error-item"'
      end
      
      input = "<input type=\"text\" id=\"#{name}\" name=\"#{name}\" value=\"#{value}\"#{error_string}/>"
      
      input
    end

    
    def drop_class_to_table_item(clazz)
      match = /_drops/.match clazz.to_s.tableize
      match.pre_match
    end
    
    
    def get_by_id(class_name, id, name_field)
      obj = class_name.constantize.send :find, id
      obj[:name_field]
    end  
    
    def get_tag_prop(prop, input)
      prop_match = /#{prop}="([^"]*)"/.match input
      if prop_match
        prop_match[1]
      end
    end
     
    def escape_html(html)
      html_escape(html)
    end    
    
  end
end
