module Clot
  
  class NumberedTag < ClotTag
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
        if selected_value == val
          options << %{<option selected="selected" value="#{val}">#{value_string(val)}</option>}
        else
          options << %{<option value="#{val}">#{value_string(val)}</option>}
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
      super(name, value) || case name
        when "use_month_numbers" then
          @use_month_numbers = value
        when "add_month_numbers" then
          @add_month_numbers = value
        when "use_short_month" then
          @use_short_month = value
        when "use_month_names" then
          @use_month_names = value
      end
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

  class MultiDateTag < ClotTag
    def set_primary_attributes(context)
      @time = resolve_value(@params.shift,context) || Time.now
    end

     def personal_attributes(name,value)
      super(name,value) || case name
        when "order" then
          puts "received order #{value}"
          @order = value
      end
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

  end

  class SelectDate < MultiDateTag
    def render_nested(context)
      @year = SelectYear.new(".select_year",@time.year.to_s,[])
      @month = SelectMonth.new(".select_month",@time.month.to_s,[])
      @day = SelectDay.new(".select_day",@time.day.to_s,[])

      puts "order #{@order}"
      order = @order || ['year', 'month', 'day']

      data = ""
      order.each do |unit|
        val = instance_variable_get("@#{unit}".to_sym)
        data << val.render(context)
      end   
      data
    end
  end

  class SelectTime < MultiDateTag

    def render_nested(context)
      @hour = SelectHour.new(".select_hour",@time.hour.to_s,[])
      @minute = SelectMinute.new(".select_minute",@time.min.to_s,[])
      @hour.render(context) + @minute.render(context)
    end
  end

end