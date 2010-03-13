require File.dirname(__FILE__) + '/spec_helper'

def get_month(val)
  months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
  months[val - 1]
end

def get_short_month(val)
  get_month(val)[0..2]
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
    else
      print_val = val
    end
    options << %{<option value="#{val}">#{print_val}</option>}
  end
  options
end

describe "for date tags" do
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
      @tag.should parse_with_vars_to('<select id="date_second" name="date[second]">' + get_options(0,(time.sec - 1)) + %{<option selected="selected" value="#{time.sec}">#{time.sec}</option>} + get_options((time.sec + 1),59) + "</select>", 'time' => time)
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
      @tag.should parse_with_vars_to('<select id="date_minute" name="date[minute]">' + get_options(0,(time.min - 1)) + %{<option selected="selected" value="#{time.min}">#{time.min}</option>} + get_options((time.min + 1),59) + "</select>", 'time' => time)
    end
  end

  context "for select_hour" do
    it "should take a number" do
      @tag = "{% select_hour 33 %}"
      @tag.should parse_to('<select id="date_hour" name="date[hour]">' + get_options(0,32) + '<option selected="selected" value="33">33</option>' + get_options(34,59) + "</select>")
    end
    it "should take a prompt" do
      @tag = "{% select_hour 33, prompt:'Choose hours' %}"
      @tag.should parse_to('<select id="date_hour" name="date[hour]"><option value="">Choose hours</option>' + get_options(0,32) + '<option selected="selected" value="33">33</option>' + get_options(34,59) + "</select>")
    end
    it "should take a prompt" do
      @tag = "{% select_hour 33, prompt:true %}"
      @tag.should parse_to('<select id="date_hour" name="date[hour]"><option value="">Hours</option>' + get_options(0,32) + '<option selected="selected" value="33">33</option>' + get_options(34,59) + "</select>")
    end
    it "should take a field_name" do
      @tag = "{% select_hour 33,field_name:'stride' %}"
      @tag.should parse_to('<select id="date_stride" name="date[stride]">' + get_options(0,32) + '<option selected="selected" value="33">33</option>' + get_options(34,59) + "</select>")
    end
    it "should take a Time" do
      time = Time.now
      @tag = "{% select_hour time %}"
      @tag.should parse_with_vars_to('<select id="date_hour" name="date[hour]">' + get_options(0,(time.hour - 1)) + %{<option selected="selected" value="#{time.hour}">#{time.hour}</option>} + get_options((time.hour + 1),59) + "</select>", 'time' => time)
    end
  end

  context "for select_day" do
    it "should take a number" do
      @tag = "{% select_day 14 %}"
      @tag.should parse_to('<select id="date_day" name="date[day]">' + get_options(1,13) + '<option selected="selected" value="14">14</option>' + get_options(15,31) + "</select>")
    end
    it "should take a prompt" do
      @tag = "{% select_day 14, prompt:'Choose day' %}"
      @tag.should parse_to('<select id="date_day" name="date[day]"><option value="">Choose day</option>' + get_options(1,13) + '<option selected="selected" value="14">14</option>' + get_options(15,31) + "</select>")
    end
    it "should take a prompt" do
      @tag = "{% select_day 14, prompt:true %}"
      @tag.should parse_to('<select id="date_day" name="date[day]"><option value="">Days</option>' + get_options(1,13) + '<option selected="selected" value="14">14</option>' + get_options(15,31) + "</select>")
    end
    it "should take a field_name" do
      @tag = "{% select_day 14,field_name:'stride' %}"
      @tag.should parse_to('<select id="date_stride" name="date[stride]">' + get_options(1,13) + '<option selected="selected" value="14">14</option>' + get_options(15,31) + "</select>")
    end
    it "should take a Time" do
      time = Time.now
      @tag = "{% select_day time %}"
      @tag.should parse_with_vars_to('<select id="date_day" name="date[day]">' + get_options(1,(time.day - 1)) + %{<option selected="selected" value="#{time.day}">#{time.day}</option>} + get_options((time.day + 1),31) + "</select>", 'time' => time)
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
    it "should take different field_name" do
      time = Time.now
      @tag = "{% select_month time, field_name:'start' %}"
      @tag.should parse_with_vars_to('<select id="date_start" name="date[start]">' + get_options(1,time.month - 1,{:label_func => :get_month}) + %{<option selected="selected" value="#{time.month}">#{get_month time.month}</option>} + get_options(time.month + 1,12,{:label_func => :get_month}) + "</select>", 'time' => time)
    end
    it "should let you use numbers for months" do
      time = Time.now
      @tag = "{% select_month time, use_month_numbers:true %}"
      @tag.should parse_with_vars_to('<select id="date_month" name="date[month]">' + get_options(1,time.month - 1) + %{<option selected="selected" value="#{time.month}">#{time.month}</option>} + get_options(time.month + 1,12) + "</select>", 'time' => time)
    end

    it "should let you add numbers for months" do
      time = Time.now
      @tag = "{% select_month time, add_month_numbers:true %}"
      @tag.should parse_with_vars_to('<select id="date_month" name="date[month]">' + get_options(1,time.month - 1,{:label_func => :get_month_with_numbers}) + %{<option selected="selected" value="#{time.month}">#{time.month} - #{get_month time.month}</option>} + get_options(time.month + 1,12,{:label_func => :get_month_with_numbers}) + "</select>", 'time' => time)
    end

    it "should let you use short name for months" do
      time = Time.now
      @tag = "{% select_month time, use_short_month:true %}"
      @tag.should parse_with_vars_to('<select id="date_month" name="date[month]">' + get_options(1,time.month - 1,{:label_func => :get_short_month}) + %{<option selected="selected" value="#{time.month}">#{get_short_month time.month}</option>} + get_options(time.month + 1,12,{:label_func => :get_short_month}) + "</select>", 'time' => time)
    end
  end
end

