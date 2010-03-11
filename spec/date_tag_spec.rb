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
      @tag = "{% select_day 33 %}"
      @tag.should parse_to('<select id="date_day" name="date[day]">' + get_options(0,32) + '<option selected="selected" value="33">33</option>' + get_options(34,59) + "</select>")
    end
    it "should take a prompt" do
      @tag = "{% select_day 33, prompt:'Choose day' %}"
      @tag.should parse_to('<select id="date_day" name="date[day]"><option value="">Choose day</option>' + get_options(0,32) + '<option selected="selected" value="33">33</option>' + get_options(34,59) + "</select>")
    end
    it "should take a prompt" do
      @tag = "{% select_day 33, prompt:true %}"
      @tag.should parse_to('<select id="date_day" name="date[day]"><option value="">Days</option>' + get_options(0,32) + '<option selected="selected" value="33">33</option>' + get_options(34,59) + "</select>")
    end
    it "should take a field_name" do
      @tag = "{% select_day 33,field_name:'stride' %}"
      @tag.should parse_to('<select id="date_stride" name="date[stride]">' + get_options(0,32) + '<option selected="selected" value="33">33</option>' + get_options(34,59) + "</select>")
    end
    it "should take a Time" do
      time = Time.now
      @tag = "{% select_day time %}"
      @tag.should parse_with_vars_to('<select id="date_day" name="date[day]">' + get_options(0,(time.day - 1)) + %{<option selected="selected" value="#{time.day}">#{time.day}</option>} + get_options((time.day + 1),59) + "</select>", 'time' => time)
    end
  end


end
