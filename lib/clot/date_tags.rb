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
          prompt_text = (value === true) ? default_prompt : value
          @prompt_val = "<option value=\"\">#{prompt_text}</option>"
      end
    end

  end

  class SelectMinute < NumberedTag
    def time_method
      :min
    end
    def default_prompt
      "Minutes"
    end

    def render_string
      field_name = @field_name || "minute"
      %{<select id="date_#{field_name}" name="date[#{field_name}]">#{@prompt_val}} + get_options(0, 59, @value_string) + "</select>"
    end
  end

  class SelectHour < NumberedTag
    def time_method
      :hour
    end
    def default_prompt
      "Hours"
    end

    def render_string
      field_name = @field_name || "hour"
      %{<select id="date_#{field_name}" name="date[#{field_name}]">#{@prompt_val}} + get_options(0, 59, @value_string) + "</select>"
    end
  end


  class SelectSecond < NumberedTag
    def time_method
      :sec
    end
    def default_prompt
      "Seconds"
    end

    def render_string
      field_name = @field_name || "second"
      %{<select id="date_#{field_name}" name="date[#{field_name}]">#{@prompt_val}} + get_options(0, 59, @value_string) + "</select>"
    end
  end
end