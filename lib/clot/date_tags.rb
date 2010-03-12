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

    def default_start
      0
    end

    def default_end
      59
    end

    def render_string
      field_name = @field_name || default_field_name
      %{<select id="date_#{field_name}" name="date[#{field_name}]">#{@prompt_val}} + get_options(default_start, default_end, @value_string) + "</select>"
    end
    def time_method
      default_field_name
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
    def default_field_name
      "hour"
    end
  end

  class SelectDay < NumberedTag
    def default_field_name
      "day"
    end

    def default_start
      1
    end

    def default_end
      31
    end
  end

  class SelectYear < NumberedTag
    def default_field_name
      "year"
    end

    def default_start
      @start_year || @value_string - 5
    end

    def default_end
      @end_year || @value_string + 5
    end

    def personal_attributes(name,value)
      super(name,value) || case name
        when "start_year" then
          @start_year = value
        when "end_year" then
          @end_year = value
      end
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