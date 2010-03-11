module Clot
  
  class NumberedTag < ClotTag
    def get_options(from_val,to_val, selected_value = nil)
      options = ""
      (from_val..to_val).each do |val|
        if selected_value == val
          options << %{<option selected="selected" value="#{val}">#{val}</option>}
        else
          options << %{<option value="#{val}">#{val}</option>}
        end
      end
      options
    end

    def set_primary_attributes(context)
      @value_string = resolve_value(@params.shift,context)
      if @value_string.is_a? Time
        @value_string = @value_string.send(time_method)
      end
    end

    def personal_attributes(name,value)
      case name
        when "field_name" then
          @field_name = value
        when "prompt" then
          prompt_text = (value === true) ? default_field_name.pluralize.capitalize : value
          @prompt_val = "<option value=\"\">#{prompt_text}</option>"
      end
    end

    def render_string
      field_name = @field_name || default_field_name
      %{<select id="date_#{field_name}" name="date[#{field_name}]">#{@prompt_val}} + get_options(0, 59, @value_string) + "</select>"
    end

  end

  class SelectMinute < NumberedTag
    def time_method
      :min
    end
    def default_field_name
      "minute"
    end
  end

  class SelectHour < NumberedTag
    def time_method
      :hour
    end
    def default_field_name
      "hour"
    end
  end

  class SelectDay < NumberedTag
    def time_method
      :day
    end
    def default_field_name
      "day"
    end
  end

  class SelectSecond < NumberedTag
    def time_method
      :sec
    end
    def default_field_name
      "second"
    end
  end
end