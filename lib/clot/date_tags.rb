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
  end

  class SelectMinute < NumberedTag
    def time_method
      :min
    end
    def render_string
        %{<select id="date_minute" name="date[minute]">} + get_options(0, 59, @value_string) + "</select>"
    end
  end

  class SelectSecond < NumberedTag
    def time_method
      :sec
    end
    def render_string
        %{<select id="date_second" name="date[second]">} + get_options(0, 59, @value_string) + "</select>"
    end
  end
end