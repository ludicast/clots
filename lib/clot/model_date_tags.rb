module Clot
  class ModelMultiDateTag < MultiDateTag
    include ModelTag

    def set_unit(unit)
        order = get_unit_order(unit)
        prompt = instance_variable_get("@#{unit}_prompt".to_sym)
        id_string = %{id_string_val:"#{@first_attr}_#{@attribute_name}_#{order}i",}
        name_string = %{name_string_val:"#{@first_attr}[#{@attribute_name}(#{order}i)]",}

        line = "#{@time.send(time_unit(unit).to_sym).to_s},#{id_string} #{name_string}#{@minute_step}#{prompt || @prompt}"

        instance_variable_set "@#{unit}",
           "Clot::Select#{unit.capitalize}".constantize.new(".select_#{unit}", line,[])
    end

    def get_unit_order(unit)
      case unit
        when "year" then 1
        when "month" then 2
        when "day" then 3
        when "hour" then 4
        when "minute" then 5
        when "second" then 6
      end
    end    

  end

  class TimeSelect < ModelMultiDateTag


    def render_nested(context)
      @time = @value_string
      time_units = ["hour", "minute"]
      if @include_seconds
        time_units << "second"
      end
      time_result = render_units(time_units, context, @time_separator)
      year = %{<input id="#{@first_attr}_#{@attribute_name}_1i" name="#{@first_attr}[#{@attribute_name}(1i)]" type="hidden" value="2010" />}
      month = %{<input id="#{@first_attr}_#{@attribute_name}_2i" name="#{@first_attr}[#{@attribute_name}(2i)]" type="hidden" value="3" />}
      day = %{<input id="#{@first_attr}_#{@attribute_name}_3i" name="#{@first_attr}[#{@attribute_name}(3i)]" type="hidden" value="15" />}
      year + month + day + time_result
    end



  end

  class DateSelect < MultiDateTag

  end

  class DatetimeSelect < MultiDateTag

  end

end