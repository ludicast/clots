module Clot
  
  class NumberedTag < ClotTag

    def can_show(val)
      true
    end

    def value_string(val)
      val
    end

    def get_options(from_val,to_val, selected_value = nil)
      options = ""

      if from_val < to_val
        range = (from_val..to_val)
      else
        range = (to_val..from_val).to_a.reverse
      end

      range.each do |val|
        if can_show(val)
          if selected_value == val
            options << %{<option selected="selected" value="#{val}">#{value_string(val)}</option>}
          else
            options << %{<option value="#{val}">#{value_string(val)}</option>}
          end
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
        when "id_string_val" then
          @id_string = %{id="#{value}"}
        when "name_string_val" then
          @name_string = %{name="#{value}"}
        when "field_name" then
          @field_name = value
        when "prefix" then
          @prefix = value
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

    def id_string(field_name)
      @id_string || if field_name && ! field_name.blank?
        %{id="#{@prefix || 'date'}_#{field_name}"}
      else
        %{id="#{@prefix || 'date'}"}
      end
    end

    def name_string(field_name)
      @name_string || if field_name && ! field_name.blank?
        %{name="#{@prefix || 'date'}[#{field_name}]"}
      else
        %{name="#{@prefix || 'date'}"}        
      end
    end

    def render_string
      field_name = @field_name || default_field_name
      %{<select #{id_string(field_name)} #{name_string(field_name)}>#{@prompt_val}} + get_options(default_start, default_end, @value_string) + "</select>"
    end

    def time_method
      default_field_name
    end
  end

  class PaddedNumberedTag < NumberedTag
    def value_string(val)
      if val < 10
       "0#{val}"
      else
        val
      end
    end
  end

  class SelectMinute < PaddedNumberedTag
    def time_method
      :min
    end
    def default_field_name
      "minute"
    end

    def can_show(val)
      @minute_step.nil? || (val % @minute_step) == 0
    end

    def personal_attributes(name,value)
      case name
        when "minute_step" then
          @minute_step = value
      end || super(name, value)
    end

  end

  class SelectHour < PaddedNumberedTag
    def default_field_name
      "hour"
    end
    def default_end
      23
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

  class SelectMonth < NumberedTag
    def default_field_name
      "month"
    end

    def default_start
      1
    end

    def default_end
      12
    end

    def personal_attributes(name,value)
      case name
        when "use_month_numbers" then
          @use_month_numbers = value
        when "add_month_numbers" then
          @add_month_numbers = value
        when "use_short_month" then
          @use_short_month = value
        when "use_month_names" then
          @use_month_names = value
      end || super(name, value)
    end

    def value_string(val)
      if @use_month_numbers
        super(val)
      else
        if @use_month_names
          month_name = @use_month_names[val]
        else
          months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
          month_name = months[val - 1]
        end
        if @add_month_numbers
          "#{val} - #{month_name}"
        elsif @use_short_month
          month_name[0..2]
        else
          month_name
        end
      end
    end

  end



  class SelectYear < PaddedNumberedTag
    def default_field_name
      "year"
    end

    def default_start
      (@start_year || @value_string - 5)
    end

    def default_end
      (@end_year || @value_string + 5)
    end

    def personal_attributes(name,value)
      case name
        when "start_year" then
          @start_year = value
        when "end_year" then
          @end_year = value
      end || super(name, value)
    end


  end


  class SelectSecond < PaddedNumberedTag
    def time_method
      :sec
    end
    def default_field_name
      "second"
    end
  end

  class MultiDateTag < ClotTag    

    def set_primary_attributes(context)
      @time = resolve_value(@params.shift,context) || Time.now
    end

    def personal_attributes(name,value)
      case name
        when "discard_day" then
          @discard_day = true  
        when "include_blank" then
          @include_blank = true
        when "minute_step" then
          @minute_step = "minute_step:#{value},"
        when "order" then
          @order = value
        when "start_year" then
          @start_year = "start_year:#{value},"
        when "prefix" then
          @prefix = ",prefix:'#{value}'"
        when "discard_type" then
          @discard_type = ",field_name:''"
        when "datetime_separator" then
          @datetime_separator = value
        when "date_separator" then
          @date_separator = value
        when "time_separator" then
          @time_separator = value
        when "include_seconds" then
          @include_seconds = true
        when "use_month_numbers" then
          @use_month_numbers = "use_month_numbers:true,"        
        when /(.*)_prompt/ then
          value_string = value === true ? 'true' : "'#{value}'"
          instance_variable_set("@#{$1}_prompt".to_sym,",prompt:#{value_string}")
        when "prompt" then
          @prompt = ",prompt:true"        
      end || super(name,value)
    end

    def render(context)
      instance_variables.map(&:to_sym).each do |var|
        unless [:@_params, :@markup, :@tag_name].include? var
          instance_variable_set var, nil  #this is because the same parse tag is re-rendered
        end
      end
      @params = @_params.clone
      set_attributes(context)
      render_nested(context)
    end  

    def set_unit(unit)
        prompt = instance_variable_get("@#{unit}_prompt".to_sym)
        line = "#{@time.send(time_unit(unit).to_sym).to_s} #{@discard_type}#{@prefix}#{prompt || @prompt}"
        instance_variable_set "@#{unit}",
           "Clot::Select#{unit.capitalize}".constantize.new(".select_#{unit}", line,[])
    end
    
    def time_unit(unit)
      case unit
        when "second" then "sec"
        when "minute" then "min"
        else unit
      end
    end

    def render_units(units, context, separator = nil)
      data = ""
      not_first = false
      units.each do |unit|
         set_unit unit
         if not_first && separator
           data << separator
         end

         val = instance_variable_get("@#{unit}".to_sym)
         data << val.render(context)
         not_first = true
      end
      data
    end


  end

  class SelectDate < MultiDateTag
    def render_nested(context)
      order = @order || ['year', 'month', 'day']
      render_units(order, context, @date_separator)
    end
  end

  class SelectTime < MultiDateTag
    def render_nested(context)
      units = ["hour", "minute"]
      if @include_seconds
        units << "second"
      end
      render_units(units, context, @time_separator)
    end
  end

  class SelectDatetime < MultiDateTag
    def render_nested(context)
      time_units = ["hour", "minute"]
      if @include_seconds
        time_units << "second"
      end
      time_result = render_units(time_units, context, @time_separator)

      order = @order || ['year', 'month', 'day']
      date_result = render_units(order, context, @date_separator)
      
      date_result + @datetime_separator.to_s + time_result
    end

  end

end