require File.dirname(__FILE__) + '/spec_helper'

def get_month(val)
  months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
  months[val - 1]
end


def fill_zeros(val)
  if val < 10
    "0#{val}"
  else
    val
  end
end


def get_short_month(val)
  get_month(val)[0..2]
end

def spanish_month_names
  ["enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"]
end

def get_spanish_month_name(val)
  spanish_month_names[val]
end

def get_month_with_numbers(val)
  "#{val} - #{get_month val}" 
end

def get_options(from_val,to_val, hash = {})
  options = ""
  range = (from_val..to_val)
  if hash[:reverse]
    range = range.to_a.reverse
  end

  range.each do |val|
    if hash[:label_func]
      print_val = send(hash[:label_func], val)
    elsif hash[:ignore_zeros]
      print_val = val
    else
      print_val = fill_zeros(val)
    end
    options << %{<option value="#{val}">#{print_val}</option>}
  end
  options
end

describe "for date and time tags" do
  context "for select_second" do
    it "should take a number" do
      @tag = "{% select_second 33 %}"
      @tag.should parse_to('<select id="date_second" name="date[second]">' + get_options(0,32) + '<option selected="selected" value="33">33</option>' + get_options(34,59) + "</select>")
    end
    it "should take a prompt" do
      @tag = "{% select_second 33, prompt:'Choose seconds' %}"
      @tag.should parse_to('<select id="date_second" name="date[second]"><option value="">Choose seconds</option>' + get_options(0,32) + '<option selected="selected" value="33">33</option>' + get_options(34,59) + "</select>")
    end
    it "should take a prompt" do
      @tag = "{% select_second 33, prompt:true %}"
      @tag.should parse_to('<select id="date_second" name="date[second]"><option value="">Seconds</option>' + get_options(0,32) + '<option selected="selected" value="33">33</option>' + get_options(34,59) + "</select>") 
    end
    it "should take a field_name" do
      @tag = "{% select_second 33,field_name:'stride' %}"
      @tag.should parse_to('<select id="date_stride" name="date[stride]">' + get_options(0,32) + '<option selected="selected" value="33">33</option>' + get_options(34,59) + "</select>")
    end
    it "should take a Time" do
      time = Time.now
      @tag = "{% select_second time %}"
      @tag.should parse_with_vars_to('<select id="date_second" name="date[second]">' + get_options(0,(time.sec - 1)) + %{<option selected="selected" value="#{time.sec}">#{fill_zeros time.sec}</option>} + get_options((time.sec + 1),59) + "</select>", 'time' => time)
    end
  end

  context "for select_minute" do
    it "should take a number" do
      @tag = "{% select_minute 33 %}"
      @tag.should parse_to('<select id="date_minute" name="date[minute]">' + get_options(0,32) + '<option selected="selected" value="33">33</option>' + get_options(34,59) + "</select>")
    end
    it "should take a prompt" do
      @tag = "{% select_minute 33, prompt:'Choose minutes' %}"
      @tag.should parse_to('<select id="date_minute" name="date[minute]"><option value="">Choose minutes</option>' + get_options(0,32) + '<option selected="selected" value="33">33</option>' + get_options(34,59) + "</select>")
    end
    it "should take a prompt" do
      @tag = "{% select_minute 33, prompt:true %}"
      @tag.should parse_to('<select id="date_minute" name="date[minute]"><option value="">Minutes</option>' + get_options(0,32) + '<option selected="selected" value="33">33</option>' + get_options(34,59) + "</select>")
    end
    it "should take a field_name" do
      @tag = "{% select_minute 33,field_name:'stride' %}"
      @tag.should parse_to('<select id="date_stride" name="date[stride]">' + get_options(0,32) + '<option selected="selected" value="33">33</option>' + get_options(34,59) + "</select>")
    end
    it "should take a Time" do
      time = Time.now
      @tag = "{% select_minute time %}"
      @tag.should parse_with_vars_to('<select id="date_minute" name="date[minute]">' + get_options(0,(time.min - 1)) + %{<option selected="selected" value="#{time.min}">#{fill_zeros time.min}</option>} + get_options((time.min + 1),59) + "</select>", 'time' => time)
    end
  end

  context "for select_hour" do
    it "should take a number" do
      @tag = "{% select_hour 13 %}"
      @tag.should parse_to('<select id="date_hour" name="date[hour]">' + get_options(0,12) + '<option selected="selected" value="13">13</option>' + get_options(14,23) + "</select>")
    end
    it "should take a prompt" do
      @tag = "{% select_hour 13, prompt:'Choose hours' %}"
      @tag.should parse_to('<select id="date_hour" name="date[hour]"><option value="">Choose hours</option>' + get_options(0,12) + '<option selected="selected" value="13">13</option>' + get_options(14,23) + "</select>")
    end
    it "should take a prompt" do
      @tag = "{% select_hour 13, prompt:true %}"
      @tag.should parse_to('<select id="date_hour" name="date[hour]"><option value="">Hours</option>' + get_options(0,12) + '<option selected="selected" value="13">13</option>' + get_options(14,23) + "</select>")
    end
    it "should take a field_name" do
      @tag = "{% select_hour 13,field_name:'stride' %}"
      @tag.should parse_to('<select id="date_stride" name="date[stride]">' + get_options(0,12) + '<option selected="selected" value="13">13</option>' + get_options(14,23) + "</select>")
    end
    it "should take a Time" do
      time = Time.now
      @tag = "{% select_hour time %}"
      @tag.should parse_with_vars_to('<select id="date_hour" name="date[hour]">' + get_options(0,(time.hour - 1)) + %{<option selected="selected" value="#{time.hour}">#{fill_zeros time.hour}</option>} + get_options((time.hour + 1),23) + "</select>", 'time' => time)
    end
  end

  context "for select_day" do
    it "should take a number" do
      @tag = "{% select_day 14 %}"
      @tag.should parse_to('<select id="date_day" name="date[day]">' + get_options(1,13,:ignore_zeros => true) + '<option selected="selected" value="14">14</option>' + get_options(15,31,:ignore_zeros => true) + "</select>")
    end
    it "should take a prompt" do
      @tag = "{% select_day 14, prompt:'Choose day' %}"
      @tag.should parse_to('<select id="date_day" name="date[day]"><option value="">Choose day</option>' + get_options(1,13,:ignore_zeros => true) + '<option selected="selected" value="14">14</option>' + get_options(15,31,:ignore_zeros => true) + "</select>")
    end
    it "should take a prompt" do
      @tag = "{% select_day 14, prompt:true %}"
      @tag.should parse_to('<select id="date_day" name="date[day]"><option value="">Days</option>' + get_options(1,13,:ignore_zeros => true) + '<option selected="selected" value="14">14</option>' + get_options(15,31,:ignore_zeros => true) + "</select>")
    end
    it "should take a field_name" do
      @tag = "{% select_day 14,field_name:'stride' %}"
      @tag.should parse_to('<select id="date_stride" name="date[stride]">' + get_options(1,13,:ignore_zeros => true) + '<option selected="selected" value="14">14</option>' + get_options(15,31,:ignore_zeros => true) + "</select>")
    end
    it "should take a Time" do
      time = Time.now
      @tag = "{% select_day time %}"
      @tag.should parse_with_vars_to('<select id="date_day" name="date[day]">' + get_options(1,(time.day - 1),:ignore_zeros => true) + %{<option selected="selected" value="#{time.day}">#{time.day}</option>} + get_options((time.day + 1),31,:ignore_zeros => true) + "</select>", 'time' => time)
    end
  end

  context "for select_year" do
    it "should set default year" do
      @tag = "{% select_year 2009 %}"
      @tag.should parse_to('<select id="date_year" name="date[year]">' + get_options(2004,2008) + %{<option selected="selected" value="2009">2009</option>} + get_options(2010,2014) + "</select>")
    end
    it "should set take start and end in ascending order" do
      time = Time.now
      @tag = "{% select_year time,start_year:1992,end_year:2020 %}"
      @tag.should parse_with_vars_to('<select id="date_year" name="date[year]">' + get_options(1992,time.year - 1) + %{<option selected="selected" value="#{time.year}">#{time.year}</option>} + get_options(time.year + 1,2020) + "</select>", 'time' => time)
    end

    it "should set take start and end in descending order" do
      time = Time.now
      @tag = "{% select_year time,start_year:2020,end_year:1992 %}"
      @tag.should parse_with_vars_to('<select id="date_year" name="date[year]">' + get_options(time.year + 1,2020, {:reverse => true}) + %{<option selected="selected" value="#{time.year}">#{time.year}</option>} +  get_options(1992,time.year - 1, {:reverse => true}) + "</select>", 'time' => time)
    end    

    it "should set take start and end in ascending order with year" do
      @tag = "{% select_year 2006,start_year:1992,end_year:2020 %}"
      @tag.should parse_to('<select id="date_year" name="date[year]">' + get_options(1992,2005) + %{<option selected="selected" value="2006">2006</option>} + get_options(2007,2020) + "</select>")
    end

    it "should take a prompt parameter" do
      @tag = "{% select_year 14,prompt:'Choose year' %}"
    @tag.should parse_to('<select id="date_year" name="date[year]"><option value="">Choose year</option>' + get_options(9,13) + %{<option selected="selected" value="14">14</option>} + get_options(15,19) + "</select>")
    end

    it "should take a field_name parameter" do
      time = Time.now
      @tag = "{% select_year time,field_name:'birth' %}"
      @tag.should parse_with_vars_to('<select id="date_birth" name="date[birth]">' + get_options(time.year-5,time.year - 1) + %{<option selected="selected" value="#{time.year}">#{time.year}</option>} + get_options(time.year + 1,time.year + 5) + "</select>", 'time' => time)
    end
  end

  context "for select_month" do
    it "should take number produce month names by default" do
      @tag = "{% select_month 5 %}"
      @tag.should parse_to('<select id="date_month" name="date[month]">' + get_options(1,4,{:label_func => :get_month}) + %{<option selected="selected" value="5">May</option>} + get_options(6,12,{:label_func => :get_month}) + "</select>")
    end
    it "should take time object produce month names by default" do
      time = Time.now
      @tag = "{% select_month time %}"
      @tag.should parse_with_vars_to('<select id="date_month" name="date[month]">' + get_options(1,time.month - 1,{:label_func => :get_month}) + %{<option selected="selected" value="#{time.month}">#{get_month time.month}</option>} + get_options(time.month + 1,12,{:label_func => :get_month}) + "</select>", 'time' => time)
    end
    it "should take a prompt" do
      time = Time.now
      @tag = "{% select_month time, prompt:'Choose month...' %}"
      @tag.should parse_with_vars_to('<select id="date_month" name="date[month]"><option value="">Choose month...</option>' + get_options(1,time.month - 1,{:label_func => :get_month}) + %{<option selected="selected" value="#{time.month}">#{get_month time.month}</option>} + get_options(time.month + 1,12,{:label_func => :get_month}) + "</select>", 'time' => time)
    end
    it "should take different field_name" do
      time = Time.now
      @tag = "{% select_month time, field_name:'start' %}"
      @tag.should parse_with_vars_to('<select id="date_start" name="date[start]">' + get_options(1,time.month - 1,{:label_func => :get_month}) + %{<option selected="selected" value="#{time.month}">#{get_month time.month}</option>} + get_options(time.month + 1,12,{:label_func => :get_month}) + "</select>", 'time' => time)
    end
    it "should let you use numbers for months" do
      time = Time.now
      @tag = "{% select_month time, use_month_numbers:true %}"
      @tag.should parse_with_vars_to('<select id="date_month" name="date[month]">' + get_options(1,time.month - 1,:ignore_zeros => true) + %{<option selected="selected" value="#{time.month}">#{time.month}</option>} + get_options(time.month + 1,12,:ignore_zeros => true) + "</select>", 'time' => time)
    end

    it "should let you add numbers for months" do
      time = Time.now
      @tag = "{% select_month time, add_month_numbers:true %}"
      @tag.should parse_with_vars_to('<select id="date_month" name="date[month]">' + get_options(1,time.month - 1,{:label_func => :get_month_with_numbers}) + %{<option selected="selected" value="#{time.month}">#{time.month} - #{get_month time.month}</option>} + get_options(time.month + 1,12,{:label_func => :get_month_with_numbers}) + "</select>", 'time' => time)
    end

    it "should let you use short name for months" do
      time = Time.now
      @tag = "{% select_month time, use_month_names:spanish_month_names %}"
      @tag.should parse_with_vars_to('<select id="date_month" name="date[month]">' + get_options(1,time.month - 1,{:label_func => :get_spanish_month_name}) + %{<option selected="selected" value="#{time.month}">#{get_spanish_month_name time.month}</option>} + get_options(time.month + 1,12,{:label_func => :get_spanish_month_name}) + "</select>", 'time' => time, 'spanish_month_names' => spanish_month_names)
    end
    it "should let you use alternate names for months" do
      time = Time.now
      @tag = "{% select_month time, use_short_month:true %}"
      @tag.should parse_with_vars_to('<select id="date_month" name="date[month]">' + get_options(1,time.month - 1,{:label_func => :get_short_month}) + %{<option selected="selected" value="#{time.month}">#{get_short_month time.month}</option>} + get_options(time.month + 1,12,{:label_func => :get_short_month}) + "</select>", 'time' => time)
    end
  end

  context "for select_date tag" do
    it "should take default time" do
      time = Time.now
      @tag = "{% select_date time %}"
      @year_string = '<select id="date_year" name="date[year]">' + get_options(time.year-5,time.year - 1) + %{<option selected="selected" value="#{time.year}">#{time.year}</option>} + get_options(time.year + 1,time.year + 5) + "</select>"
      @month_string = '<select id="date_month" name="date[month]">' + get_options(1,time.month - 1,{:label_func => :get_month}) + %{<option selected="selected" value="#{time.month}">#{get_month time.month}</option>} + get_options(time.month + 1,12,{:label_func => :get_month}) + "</select>"
      @day_string = '<select id="date_day" name="date[day]">' + get_options(1,(time.day - 1),:ignore_zeros => true) + %{<option selected="selected" value="#{time.day}">#{time.day}</option>} + get_options((time.day + 1),31,:ignore_zeros => true) + "</select>"
      @tag.should parse_with_vars_to(@year_string + @month_string + @day_string, 'time' => time)
    end
    it "should allow other orders" do
      time = Time.now
      @tag = "{% select_date time,order:['day' 'month' 'year'] %}"
      @year_string = '<select id="date_year" name="date[year]">' + get_options(time.year-5,time.year - 1) + %{<option selected="selected" value="#{time.year}">#{time.year}</option>} + get_options(time.year + 1,time.year + 5) + "</select>"
      @month_string = '<select id="date_month" name="date[month]">' + get_options(1,time.month - 1,{:label_func => :get_month}) + %{<option selected="selected" value="#{time.month}">#{get_month time.month}</option>} + get_options(time.month + 1,12,{:label_func => :get_month}) + "</select>"
      @day_string = '<select id="date_day" name="date[day]">' + get_options(1,(time.day - 1),:ignore_zeros => true) + %{<option selected="selected" value="#{time.day}">#{time.day}</option>} + get_options((time.day + 1),31,:ignore_zeros => true) + "</select>"
      @tag.should parse_with_vars_to(@day_string + @month_string + @year_string, 'time' => time)
    end
    it "should allow discarding of type" do
      time = Time.now
      @tag = "{% select_date time,discard_type:true %}"
      @year_string = '<select id="date" name="date">' + get_options(time.year-5,time.year - 1) + %{<option selected="selected" value="#{time.year}">#{time.year}</option>} + get_options(time.year + 1,time.year + 5) + "</select>"
      @month_string = '<select id="date" name="date">' + get_options(1,time.month - 1,{:label_func => :get_month}) + %{<option selected="selected" value="#{time.month}">#{get_month time.month}</option>} + get_options(time.month + 1,12,{:label_func => :get_month}) + "</select>"
      @day_string = '<select id="date" name="date">' + get_options(1,(time.day - 1),:ignore_zeros => true) + %{<option selected="selected" value="#{time.day}">#{time.day}</option>} + get_options((time.day + 1),31,:ignore_zeros => true) + "</select>"
      @tag.should parse_with_vars_to(@year_string + @month_string + @day_string, 'time' => time)
    end
    it "should set default time to current time" do
      time = Time.now
      @tag = "{% select_date %}"
      @year_string = '<select id="date_year" name="date[year]">' + get_options(time.year-5,time.year - 1) + %{<option selected="selected" value="#{time.year}">#{time.year}</option>} + get_options(time.year + 1,time.year + 5) + "</select>"
      @month_string = '<select id="date_month" name="date[month]">' + get_options(1,time.month - 1,{:label_func => :get_month}) + %{<option selected="selected" value="#{time.month}">#{get_month time.month}</option>} + get_options(time.month + 1,12,{:label_func => :get_month}) + "</select>"
      @day_string = '<select id="date_day" name="date[day]">' + get_options(1,(time.day - 1),:ignore_zeros => true) + %{<option selected="selected" value="#{time.day}">#{time.day}</option>} + get_options((time.day + 1),31,:ignore_zeros => true) + "</select>"
      @tag.should parse_to(@year_string + @month_string + @day_string)
    end

    it "should take separator option" do
      time = Time.now
      @tag = "{% select_date time,date_separator:'/' %}"
      @year_string = '<select id="date_year" name="date[year]">' + get_options(time.year-5,time.year - 1) + %{<option selected="selected" value="#{time.year}">#{time.year}</option>} + get_options(time.year + 1,time.year + 5) + "</select>"
      @month_string = '<select id="date_month" name="date[month]">' + get_options(1,time.month - 1,{:label_func => :get_month}) + %{<option selected="selected" value="#{time.month}">#{get_month time.month}</option>} + get_options(time.month + 1,12,{:label_func => :get_month}) + "</select>"
      @day_string = '<select id="date_day" name="date[day]">' + get_options(1,(time.day - 1),:ignore_zeros => true) + %{<option selected="selected" value="#{time.day}">#{time.day}</option>} + get_options((time.day + 1),31,:ignore_zeros => true) + "</select>"
      @tag.should parse_with_vars_to(@year_string + "/" + @month_string + "/" + @day_string, 'time' => time)
    end
    it "should take prefix option" do
      time = Time.now
      @tag = "{% select_date time,prefix:'payday' %}"
      @year_string = '<select id="payday_year" name="payday[year]">' + get_options(time.year-5,time.year - 1) + %{<option selected="selected" value="#{time.year}">#{time.year}</option>} + get_options(time.year + 1,time.year + 5) + "</select>"
      @month_string = '<select id="payday_month" name="payday[month]">' + get_options(1,time.month - 1,{:label_func => :get_month}) + %{<option selected="selected" value="#{time.month}">#{get_month time.month}</option>} + get_options(time.month + 1,12,{:label_func => :get_month}) + "</select>"
      @day_string = '<select id="payday_day" name="payday[day]">' + get_options(1,(time.day - 1),:ignore_zeros => true) + %{<option selected="selected" value="#{time.day}">#{time.day}</option>} + get_options((time.day + 1),31,:ignore_zeros => true) + "</select>"
      @tag.should parse_with_vars_to(@year_string + @month_string + @day_string, 'time' => time)
    end

    it "should take prompt" do
      time = Time.now
      @tag = %{{% select_date time, day_prompt:"Choose Day", month_prompt:"Choose Month", year_prompt:"Choose Year" %}}
      @year_string = '<select id="date_year" name="date[year]"><option value="">Choose Year</option>' + get_options(time.year-5,time.year - 1) + %{<option selected="selected" value="#{time.year}">#{time.year}</option>} + get_options(time.year + 1,time.year + 5) + "</select>"
      @month_string = '<select id="date_month" name="date[month]"><option value="">Choose Month</option>' + get_options(1,time.month - 1,{:label_func => :get_month}) + %{<option selected="selected" value="#{time.month}">#{get_month time.month}</option>} + get_options(time.month + 1,12,{:label_func => :get_month}) + "</select>"
      @day_string = '<select id="date_day" name="date[day]"><option value="">Choose Day</option>' + get_options(1,(time.day - 1),:ignore_zeros => true) + %{<option selected="selected" value="#{time.day}">#{time.day}</option>} + get_options((time.day + 1),31,:ignore_zeros => true) + "</select>"
      @tag.should parse_to(@year_string + @month_string + @day_string)
    end
    it "should take generic prompts" do
      time = Time.now
      @tag = %{{% select_date time, day_prompt:true, month_prompt:true, year_prompt:true %}}
      @year_string = '<select id="date_year" name="date[year]"><option value="">Years</option>' + get_options(time.year-5,time.year - 1) + %{<option selected="selected" value="#{time.year}">#{time.year}</option>} + get_options(time.year + 1,time.year + 5) + "</select>"
      @month_string = '<select id="date_month" name="date[month]"><option value="">Months</option>' + get_options(1,time.month - 1,{:label_func => :get_month}) + %{<option selected="selected" value="#{time.month}">#{get_month time.month}</option>} + get_options(time.month + 1,12,{:label_func => :get_month}) + "</select>"
      @day_string = '<select id="date_day" name="date[day]"><option value="">Days</option>' + get_options(1,(time.day - 1),:ignore_zeros => true) + %{<option selected="selected" value="#{time.day}">#{time.day}</option>} + get_options((time.day + 1),31,:ignore_zeros => true) + "</select>"
      @tag.should parse_to(@year_string + @month_string + @day_string)
    end
    it "should take generic prompts for all" do
      time = Time.now
      @tag = %{{% select_date time, prompt:true %}}
      @year_string = '<select id="date_year" name="date[year]"><option value="">Years</option>' + get_options(time.year-5,time.year - 1) + %{<option selected="selected" value="#{time.year}">#{time.year}</option>} + get_options(time.year + 1,time.year + 5) + "</select>"
      @month_string = '<select id="date_month" name="date[month]"><option value="">Months</option>' + get_options(1,time.month - 1,{:label_func => :get_month}) + %{<option selected="selected" value="#{time.month}">#{get_month time.month}</option>} + get_options(time.month + 1,12,{:label_func => :get_month}) + "</select>"
      @day_string = '<select id="date_day" name="date[day]"><option value="">Days</option>' + get_options(1,(time.day - 1),:ignore_zeros => true) + %{<option selected="selected" value="#{time.day}">#{time.day}</option>} + get_options((time.day + 1),31,:ignore_zeros => true) + "</select>"
      @tag.should parse_to(@year_string + @month_string + @day_string)
    end
  end

  context "for select_time tag" do
    it "should take default time" do
      time = Time.now
      @tag = "{% select_time time %}"
      @hour_string = '<select id="date_hour" name="date[hour]">' + get_options(0,(time.hour - 1)) + %{<option selected="selected" value="#{time.hour}">#{fill_zeros time.hour}</option>} + get_options((time.hour + 1),23) + "</select>"
      @minute_string = '<select id="date_minute" name="date[minute]">' + get_options(0,(time.min - 1)) + %{<option selected="selected" value="#{time.min}">#{fill_zeros time.min}</option>} + get_options((time.min + 1),59) + "</select>"
      @tag.should parse_with_vars_to(@hour_string + @minute_string, 'time' => time)
    end

    it "should set default time to current time" do
      time = Time.now
      @tag = "{% select_time %}"
      @hour_string = '<select id="date_hour" name="date[hour]">' + get_options(0,(time.hour - 1)) + %{<option selected="selected" value="#{time.hour}">#{fill_zeros time.hour}</option>} + get_options((time.hour + 1),23) + "</select>"
      @minute_string = '<select id="date_minute" name="date[minute]">' + get_options(0,(time.min - 1)) + %{<option selected="selected" value="#{time.min}">#{fill_zeros time.min}</option>} + get_options((time.min + 1),59) + "</select>"
      @tag.should parse_to(@hour_string + @minute_string)
    end
    it "should allow separator" do
      time = Time.now
      @tag = "{% select_time time, time_separator:':' %}"
      @hour_string = '<select id="date_hour" name="date[hour]">' + get_options(0,(time.hour - 1)) + %{<option selected="selected" value="#{time.hour}">#{fill_zeros time.hour}</option>} + get_options((time.hour + 1),23) + "</select>"
      @minute_string = '<select id="date_minute" name="date[minute]">' + get_options(0,(time.min - 1)) + %{<option selected="selected" value="#{time.min}">#{fill_zeros time.min}</option>} + get_options((time.min + 1),59) + "</select>"
      @tag.should parse_with_vars_to(@hour_string + ":" + @minute_string, 'time' => time)
    end

    it "should allow seconds" do
      time = Time.now
      @tag = "{% select_time time, include_seconds:true %}"
      @hour_string = '<select id="date_hour" name="date[hour]">' + get_options(0,(time.hour - 1)) + %{<option selected="selected" value="#{time.hour}">#{fill_zeros time.hour}</option>} + get_options((time.hour + 1),23) + "</select>"
      @minute_string = '<select id="date_minute" name="date[minute]">' + get_options(0,(time.min - 1)) + %{<option selected="selected" value="#{time.min}">#{fill_zeros time.min}</option>} + get_options((time.min + 1),59) + "</select>"
      @second_string = '<select id="date_second" name="date[second]">' + get_options(0,(time.sec - 1)) + %{<option selected="selected" value="#{time.sec}">#{fill_zeros time.sec}</option>} + get_options((time.sec + 1),59) + "</select>"
      @tag.should parse_with_vars_to(@hour_string + @minute_string + @second_string, 'time' => time)
    end

    it "should allow seconds and separator" do
      time = Time.now
      @tag = "{% select_time time, include_seconds:true, time_separator:':' %}"
      @hour_string = '<select id="date_hour" name="date[hour]">' + get_options(0,(time.hour - 1)) + %{<option selected="selected" value="#{time.hour}">#{fill_zeros time.hour}</option>} + get_options((time.hour + 1),23) + "</select>"
      @minute_string = '<select id="date_minute" name="date[minute]">' + get_options(0,(time.min - 1)) + %{<option selected="selected" value="#{time.min}">#{fill_zeros time.min}</option>} + get_options((time.min + 1),59) + "</select>"
      @second_string = '<select id="date_second" name="date[second]">' + get_options(0,(time.sec - 1)) + %{<option selected="selected" value="#{time.sec}">#{fill_zeros time.sec}</option>} + get_options((time.sec + 1),59) + "</select>"
      @tag.should parse_with_vars_to(@hour_string + ":" + @minute_string + ":" + @second_string, 'time' => time)
    end

    it "should allow prompts" do
      time = Time.now
      @tag = "{% select_time time, include_seconds:true, second_prompt:'input seconds',minute_prompt:'input minutes',hour_prompt:'input hours' %}"
      @hour_string = '<select id="date_hour" name="date[hour]"><option value="">input hours</option>' + get_options(0,(time.hour - 1)) + %{<option selected="selected" value="#{time.hour}">#{fill_zeros time.hour}</option>} + get_options((time.hour + 1),23) + "</select>"
      @minute_string = '<select id="date_minute" name="date[minute]"><option value="">input minutes</option>' + get_options(0,(time.min - 1)) + %{<option selected="selected" value="#{time.min}">#{fill_zeros time.min}</option>} + get_options((time.min + 1),59) + "</select>"
      @second_string = '<select id="date_second" name="date[second]"><option value="">input seconds</option>' + get_options(0,(time.sec - 1)) + %{<option selected="selected" value="#{time.sec}">#{fill_zeros time.sec}</option>} + get_options((time.sec + 1),59) + "</select>"
      @tag.should parse_with_vars_to(@hour_string + @minute_string + @second_string, 'time' => time)
    end

    it "should allow default prompt" do
      time = Time.now
      @tag = "{% select_time time,hour_prompt:true %}"
      @hour_string = '<select id="date_hour" name="date[hour]"><option value="">Hours</option>' + get_options(0,(time.hour - 1)) + %{<option selected="selected" value="#{time.hour}">#{fill_zeros time.hour}</option>} + get_options((time.hour + 1),23) + "</select>"
      @minute_string = '<select id="date_minute" name="date[minute]">' + get_options(0,(time.min - 1)) + %{<option selected="selected" value="#{time.min}">#{fill_zeros time.min}</option>} + get_options((time.min + 1),59) + "</select>"
      @tag.should parse_with_vars_to(@hour_string + @minute_string, 'time' => time)
    end

    it "should allow default prompt" do
      time = Time.now
      @tag = "{% select_time time,prompt:true %}"
      @hour_string = '<select id="date_hour" name="date[hour]"><option value="">Hours</option>' + get_options(0,(time.hour - 1)) + %{<option selected="selected" value="#{time.hour}">#{fill_zeros time.hour}</option>} + get_options((time.hour + 1),23) + "</select>"
      @minute_string = '<select id="date_minute" name="date[minute]"><option value="">Minutes</option>' + get_options(0,(time.min - 1)) + %{<option selected="selected" value="#{time.min}">#{fill_zeros time.min}</option>} + get_options((time.min + 1),59) + "</select>"
      @tag.should parse_with_vars_to(@hour_string + @minute_string, 'time' => time)
    end

  end


  context "for select_datetime" do
    it "should work with default time" do
      time = Time.now
      @hour_string = '<select id="date_hour" name="date[hour]">' + get_options(0,(time.hour - 1)) + %{<option selected="selected" value="#{time.hour}">#{fill_zeros time.hour}</option>} + get_options((time.hour + 1),23) + "</select>"
      @minute_string = '<select id="date_minute" name="date[minute]">' + get_options(0,(time.min - 1)) + %{<option selected="selected" value="#{time.min}">#{fill_zeros time.min}</option>} + get_options((time.min + 1),59) + "</select>"
      @year_string = '<select id="date_year" name="date[year]">' + get_options(time.year-5,time.year - 1) + %{<option selected="selected" value="#{time.year}">#{time.year}</option>} + get_options(time.year + 1,time.year + 5) + "</select>"
      @month_string = '<select id="date_month" name="date[month]">' + get_options(1,time.month - 1,{:label_func => :get_month}) + %{<option selected="selected" value="#{time.month}">#{get_month time.month}</option>} + get_options(time.month + 1,12,{:label_func => :get_month}) + "</select>"
      @day_string = '<select id="date_day" name="date[day]">' + get_options(1,(time.day - 1),:ignore_zeros => true) + %{<option selected="selected" value="#{time.day}">#{time.day}</option>} + get_options((time.day + 1),31,:ignore_zeros => true) + "</select>"

      @tag = "{% select_datetime %}"
      @tag.should parse_to(@year_string + @month_string +@day_string + @hour_string + @minute_string)
    end

    it "should work with inputted time" do
      time = Time.now
      @hour_string = '<select id="date_hour" name="date[hour]">' + get_options(0,(time.hour - 1)) + %{<option selected="selected" value="#{time.hour}">#{fill_zeros time.hour}</option>} + get_options((time.hour + 1),23) + "</select>"
      @minute_string = '<select id="date_minute" name="date[minute]">' + get_options(0,(time.min - 1)) + %{<option selected="selected" value="#{time.min}">#{fill_zeros time.min}</option>} + get_options((time.min + 1),59) + "</select>"
      @year_string = '<select id="date_year" name="date[year]">' + get_options(time.year-5,time.year - 1) + %{<option selected="selected" value="#{time.year}">#{time.year}</option>} + get_options(time.year + 1,time.year + 5) + "</select>"
      @month_string = '<select id="date_month" name="date[month]">' + get_options(1,time.month - 1,{:label_func => :get_month}) + %{<option selected="selected" value="#{time.month}">#{get_month time.month}</option>} + get_options(time.month + 1,12,{:label_func => :get_month}) + "</select>"
      @day_string = '<select id="date_day" name="date[day]">' + get_options(1,(time.day - 1),:ignore_zeros => true) + %{<option selected="selected" value="#{time.day}">#{time.day}</option>} + get_options((time.day + 1),31,:ignore_zeros => true) + "</select>"

      @tag = "{% select_datetime time %}"
      @tag.should parse_with_vars_to(@year_string + @month_string +@day_string + @hour_string + @minute_string, 'time' => time)
    end

    it "should work with inputted order" do
      time = Time.now
      @hour_string = '<select id="date_hour" name="date[hour]">' + get_options(0,(time.hour - 1)) + %{<option selected="selected" value="#{time.hour}">#{fill_zeros time.hour}</option>} + get_options((time.hour + 1),23) + "</select>"
      @minute_string = '<select id="date_minute" name="date[minute]">' + get_options(0,(time.min - 1)) + %{<option selected="selected" value="#{time.min}">#{fill_zeros time.min}</option>} + get_options((time.min + 1),59) + "</select>"
      @year_string = '<select id="date_year" name="date[year]">' + get_options(time.year-5,time.year - 1) + %{<option selected="selected" value="#{time.year}">#{time.year}</option>} + get_options(time.year + 1,time.year + 5) + "</select>"
      @month_string = '<select id="date_month" name="date[month]">' + get_options(1,time.month - 1,{:label_func => :get_month}) + %{<option selected="selected" value="#{time.month}">#{get_month time.month}</option>} + get_options(time.month + 1,12,{:label_func => :get_month}) + "</select>"
      @day_string = '<select id="date_day" name="date[day]">' + get_options(1,(time.day - 1),:ignore_zeros => true) + %{<option selected="selected" value="#{time.day}">#{time.day}</option>} + get_options((time.day + 1),31,:ignore_zeros => true) + "</select>"

      @tag = "{% select_datetime time,order:['month' 'day' 'year'] %}"
      @tag.should parse_with_vars_to(@month_string + @day_string + @year_string + @hour_string + @minute_string, 'time' => time)

    end

    it "should work with date separators" do
      time = Time.now
      @hour_string = '<select id="date_hour" name="date[hour]">' + get_options(0,(time.hour - 1)) + %{<option selected="selected" value="#{time.hour}">#{fill_zeros time.hour}</option>} + get_options((time.hour + 1),23) + "</select>"
      @minute_string = '<select id="date_minute" name="date[minute]">' + get_options(0,(time.min - 1)) + %{<option selected="selected" value="#{time.min}">#{fill_zeros time.min}</option>} + get_options((time.min + 1),59) + "</select>"
      @year_string = '<select id="date_year" name="date[year]">' + get_options(time.year-5,time.year - 1) + %{<option selected="selected" value="#{time.year}">#{time.year}</option>} + get_options(time.year + 1,time.year + 5) + "</select>"
      @month_string = '<select id="date_month" name="date[month]">' + get_options(1,time.month - 1,{:label_func => :get_month}) + %{<option selected="selected" value="#{time.month}">#{get_month time.month}</option>} + get_options(time.month + 1,12,{:label_func => :get_month}) + "</select>"
      @day_string = '<select id="date_day" name="date[day]">' + get_options(1,(time.day - 1),:ignore_zeros => true) + %{<option selected="selected" value="#{time.day}">#{time.day}</option>} + get_options((time.day + 1),31,:ignore_zeros => true) + "</select>"

      @tag = "{% select_datetime time,date_separator:'/' %}"
      @tag.should parse_with_vars_to(@year_string + '/' + @month_string + '/' + @day_string + @hour_string + @minute_string, 'time' => time)
    end

    it "should work with total separators" do
      time = Time.now
      @hour_string = '<select id="date_hour" name="date[hour]">' + get_options(0,(time.hour - 1)) + %{<option selected="selected" value="#{time.hour}">#{fill_zeros time.hour}</option>} + get_options((time.hour + 1),23) + "</select>"
      @minute_string = '<select id="date_minute" name="date[minute]">' + get_options(0,(time.min - 1)) + %{<option selected="selected" value="#{time.min}">#{fill_zeros time.min}</option>} + get_options((time.min + 1),59) + "</select>"
      @year_string = '<select id="date_year" name="date[year]">' + get_options(time.year-5,time.year - 1) + %{<option selected="selected" value="#{time.year}">#{time.year}</option>} + get_options(time.year + 1,time.year + 5) + "</select>"
      @month_string = '<select id="date_month" name="date[month]">' + get_options(1,time.month - 1,{:label_func => :get_month}) + %{<option selected="selected" value="#{time.month}">#{get_month time.month}</option>} + get_options(time.month + 1,12,{:label_func => :get_month}) + "</select>"
      @day_string = '<select id="date_day" name="date[day]">' + get_options(1,(time.day - 1),:ignore_zeros => true) + %{<option selected="selected" value="#{time.day}">#{time.day}</option>} + get_options((time.day + 1),31,:ignore_zeros => true) + "</select>"

      @tag = "{% select_datetime time,date_separator:'/',time_separator:':',datetime_separator:'---' %}"
      @tag.should parse_with_vars_to(@year_string + '/' + @month_string + '/' + @day_string + "---" + @hour_string + ":" +  @minute_string, 'time' => time)
    end

    it "should work discard type" do
      time = Time.now
      @hour_string = '<select id="date" name="date">' + get_options(0,(time.hour - 1)) + %{<option selected="selected" value="#{time.hour}">#{fill_zeros time.hour}</option>} + get_options((time.hour + 1),23) + "</select>"
      @minute_string = '<select id="date" name="date">' + get_options(0,(time.min - 1)) + %{<option selected="selected" value="#{time.min}">#{fill_zeros time.min}</option>} + get_options((time.min + 1),59) + "</select>"
      @year_string = '<select id="date" name="date">' + get_options(time.year-5,time.year - 1) + %{<option selected="selected" value="#{time.year}">#{time.year}</option>} + get_options(time.year + 1,time.year + 5) + "</select>"
      @month_string = '<select id="date" name="date">' + get_options(1,time.month - 1,{:label_func => :get_month}) + %{<option selected="selected" value="#{time.month}">#{get_month time.month}</option>} + get_options(time.month + 1,12,{:label_func => :get_month}) + "</select>"
      @day_string = '<select id="date" name="date">' + get_options(1,(time.day - 1),:ignore_zeros => true) + %{<option selected="selected" value="#{time.day}">#{time.day}</option>} + get_options((time.day + 1),31,:ignore_zeros => true) + "</select>"

      @tag = "{% select_datetime time,discard_type:true %}"
      @tag.should parse_with_vars_to(@year_string + @month_string +@day_string + @hour_string + @minute_string, 'time' => time)
    end
    it "should work with new prefix" do
      time = Time.now
      @hour_string = '<select id="payday_hour" name="payday[hour]">' + get_options(0,(time.hour - 1)) + %{<option selected="selected" value="#{time.hour}">#{fill_zeros time.hour}</option>} + get_options((time.hour + 1),23) + "</select>"
      @minute_string = '<select id="payday_minute" name="payday[minute]">' + get_options(0,(time.min - 1)) + %{<option selected="selected" value="#{time.min}">#{fill_zeros time.min}</option>} + get_options((time.min + 1),59) + "</select>"
      @year_string = '<select id="payday_year" name="payday[year]">' + get_options(time.year-5,time.year - 1) + %{<option selected="selected" value="#{time.year}">#{time.year}</option>} + get_options(time.year + 1,time.year + 5) + "</select>"
      @month_string = '<select id="payday_month" name="payday[month]">' + get_options(1,time.month - 1,{:label_func => :get_month}) + %{<option selected="selected" value="#{time.month}">#{get_month time.month}</option>} + get_options(time.month + 1,12,{:label_func => :get_month}) + "</select>"
      @day_string = '<select id="payday_day" name="payday[day]">' + get_options(1,(time.day - 1),:ignore_zeros => true) + %{<option selected="selected" value="#{time.day}">#{time.day}</option>} + get_options((time.day + 1),31,:ignore_zeros => true) + "</select>"

      @tag = "{% select_datetime time,prefix:'payday' %}"
      @tag.should parse_with_vars_to(@year_string + @month_string +@day_string + @hour_string + @minute_string, 'time' => time)
    end

    it "should work with take prompts" do
      time = Time.now
      @hour_string = '<select id="date_hour" name="date[hour]"><option value="">foo</option>' + get_options(0,(time.hour - 1)) + %{<option selected="selected" value="#{time.hour}">#{fill_zeros time.hour}</option>} + get_options((time.hour + 1),23) + "</select>"
      @minute_string = '<select id="date_minute" name="date[minute]">' + get_options(0,(time.min - 1)) + %{<option selected="selected" value="#{time.min}">#{fill_zeros time.min}</option>} + get_options((time.min + 1),59) + "</select>"
      @year_string = '<select id="date_year" name="date[year]">' + get_options(time.year-5,time.year - 1) + %{<option selected="selected" value="#{time.year}">#{time.year}</option>} + get_options(time.year + 1,time.year + 5) + "</select>"
      @month_string = '<select id="date_month" name="date[month]"><option value="">bar</option>' + get_options(1,time.month - 1,{:label_func => :get_month}) + %{<option selected="selected" value="#{time.month}">#{get_month time.month}</option>} + get_options(time.month + 1,12,{:label_func => :get_month}) + "</select>"
      @day_string = '<select id="date_day" name="date[day]">' + get_options(1,(time.day - 1),:ignore_zeros => true) + %{<option selected="selected" value="#{time.day}">#{time.day}</option>} + get_options((time.day + 1),31,:ignore_zeros => true) + "</select>"

      @tag = "{% select_datetime time,hour_prompt:'foo',month_prompt:'bar' %}"
      @tag.should parse_with_vars_to(@year_string + @month_string +@day_string + @hour_string + @minute_string, 'time' => time)
    end

    it "should work with take default prompts" do
      time = Time.now
      @hour_string = '<select id="date_hour" name="date[hour]"><option value="">Hours</option>' + get_options(0,(time.hour - 1)) + %{<option selected="selected" value="#{time.hour}">#{fill_zeros time.hour}</option>} + get_options((time.hour + 1),23) + "</select>"
      @minute_string = '<select id="date_minute" name="date[minute]">' + get_options(0,(time.min - 1)) + %{<option selected="selected" value="#{time.min}">#{fill_zeros time.min}</option>} + get_options((time.min + 1),59) + "</select>"
      @year_string = '<select id="date_year" name="date[year]">' + get_options(time.year-5,time.year - 1) + %{<option selected="selected" value="#{time.year}">#{time.year}</option>} + get_options(time.year + 1,time.year + 5) + "</select>"
      @month_string = '<select id="date_month" name="date[month]"><option value="">Months</option>' + get_options(1,time.month - 1,{:label_func => :get_month}) + %{<option selected="selected" value="#{time.month}">#{get_month time.month}</option>} + get_options(time.month + 1,12,{:label_func => :get_month}) + "</select>"
      @day_string = '<select id="date_day" name="date[day]">' + get_options(1,(time.day - 1),:ignore_zeros => true) + %{<option selected="selected" value="#{time.day}">#{time.day}</option>} + get_options((time.day + 1),31,:ignore_zeros => true) + "</select>"

      @tag = "{% select_datetime time,hour_prompt:true,month_prompt:true %}"
      @tag.should parse_with_vars_to(@year_string + @month_string +@day_string + @hour_string + @minute_string, 'time' => time)
    end

    it "should work with take default prompt" do
      time = Time.now
      @hour_string = '<select id="date_hour" name="date[hour]"><option value="">Hours</option>' + get_options(0,(time.hour - 1)) + %{<option selected="selected" value="#{time.hour}">#{fill_zeros time.hour}</option>} + get_options((time.hour + 1),23) + "</select>"
      @minute_string = '<select id="date_minute" name="date[minute]"><option value="">Minutes</option>' + get_options(0,(time.min - 1)) + %{<option selected="selected" value="#{time.min}">#{fill_zeros time.min}</option>} + get_options((time.min + 1),59) + "</select>"
      @year_string = '<select id="date_year" name="date[year]"><option value="">Years</option>' + get_options(time.year-5,time.year - 1) + %{<option selected="selected" value="#{time.year}">#{time.year}</option>} + get_options(time.year + 1,time.year + 5) + "</select>"
      @month_string = '<select id="date_month" name="date[month]"><option value="">Months</option>' + get_options(1,time.month - 1,{:label_func => :get_month}) + %{<option selected="selected" value="#{time.month}">#{get_month time.month}</option>} + get_options(time.month + 1,12,{:label_func => :get_month}) + "</select>"
      @day_string = '<select id="date_day" name="date[day]"><option value="">Days</option>' + get_options(1,(time.day - 1),:ignore_zeros => true) + %{<option selected="selected" value="#{time.day}">#{time.day}</option>} + get_options((time.day + 1),31,:ignore_zeros => true) + "</select>"

      @tag = "{% select_datetime time,prompt:true %}"
      @tag.should parse_with_vars_to(@year_string + @month_string +@day_string + @hour_string + @minute_string, 'time' => time)
    end

  end

end