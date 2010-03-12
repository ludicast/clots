require File.dirname(__FILE__) + '/spec_helper'

def get_options(from_val,to_val)
  options = ""
  (from_val..to_val).each do |val|
    options << %{<option value="#{val}">#{val}</option>}
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
    it "should set default year" do
      time = Time.now
      @tag = "{% select_year time,start_year:1992,end_year:2020 %}"
      @tag.should parse_with_vars_to('<select id="date_year" name="date[year]">' + get_options(1992,time.year - 1) + %{<option selected="selected" value="#{time.year}">#{time.year}</option>} + get_options(time.year + 1,2020) + "</select>", 'time' => time)
    end

           "
    # Generates a select field for years that defaults to the current year that
    # has ascending year values
    select_year(Date.today, :start_year => 1992, :end_year => 2007)

    # Generates a select field for years that defaults to the current year that
    # is named 'birth' rather than 'year'
    select_year(Date.today, :field_name => 'birth')

    # Generates a select field for years that defaults to the current year that
    # has descending year values
    select_year(Date.today, :start_year => 2005, :end_year => 1900)

    # Generates a select field for years that defaults to the year 2006 that
    # has ascending year values
    select_year(2006, :start_year => 2000, :end_year => 2010)

    # Generates a select field for years with a custom prompt.  Use :prompt => true for a
    # generic prompt.
    select_year(14, :prompt => 'Choose year')
    
            "


  end


end
