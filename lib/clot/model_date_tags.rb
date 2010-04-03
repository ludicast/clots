module Clot
  class ModelMultiDateTag < MultiDateTag
    include ModelTag
    
    def set_unit(unit)
      order = get_unit_order(unit)
      prompt = instance_variable_get("@#{unit}_prompt".to_sym)
      id_string = %{id_string_val:"#{@first_attr}_#{@attribute_name}_#{order}i",}
      name_string = %{name_string_val:"#{@first_attr}[#{@attribute_name}(#{order}i)]",}
      @include_blank && (prompt ||= "prompt:'',")
      line = "#{@time.send(time_unit(unit).to_sym).to_s},#{id_string} #{name_string}#{@minute_step}#{@start_year}#{@use_month_numbers}#{prompt || @prompt}"
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
      @time = @value_string || Time.now
      time_units = ["hour", "minute"]
      if @include_seconds
        time_units << "second"
      end
      time_result = render_units(time_units, context, @time_separator)
      year = %{<input id="#{@first_attr}_#{@attribute_name}_1i" name="#{@first_attr}[#{@attribute_name}(1i)]" type="hidden" value="#{@time.year}" />}
      month = %{<input id="#{@first_attr}_#{@attribute_name}_2i" name="#{@first_attr}[#{@attribute_name}(2i)]" type="hidden" value="#{@time.month}" />}
      day = %{<input id="#{@first_attr}_#{@attribute_name}_3i" name="#{@first_attr}[#{@attribute_name}(3i)]" type="hidden" value="#{@time.day}" />}
      year + month + day + time_result
    end



  end

  class DateSelect < ModelMultiDateTag
    def render_nested(context)
      @time = @value_string || Time.now
      date_units = @order || ['year', 'month', 'day']
      @discard_day && date_units.delete("day")

      date_result = render_units(date_units, context, @date_separator)
      date_result
    end
  end

  class DatetimeSelect < ModelMultiDateTag
    def render_nested(context)
      @time = @value_string || Time.now
      date_units =  ['year', 'month', 'day']
      time_units = ["hour", "minute"]
      time_result = render_units(time_units, context, @time_separator)
      date_result = render_units(date_units, context, @date_separator)
      date_result + @datetime_separator.to_s + time_result
    end
  end

end