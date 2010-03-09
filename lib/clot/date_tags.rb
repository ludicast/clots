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
    end
    

  end


  class SelectSecond < NumberedTag
    def render_string
        get_options 0, 59, @value_string
    end
  end
end