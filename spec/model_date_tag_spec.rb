require File.dirname(__FILE__) + '/spec_helper'

def get_month(val)
  months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
  months[val - 1]
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

def fill_zeros(val)
  if val < 10
    "0#{val}"
  else
    val
  end
end


describe "tags for forms that use models" do
  include Clot::UrlFilters
  include Clot::FormFilters
  include Liquid

  def parse_form_tag_to(inner_code, hash = {})
      template = "{% formfor dummy %}#{@tag}{% endformfor %}"
      expected = %{<form method="POST" action="#{object_url @user}"><input type="hidden" name="_method" value="PUT"/>#{inner_code}</form>}
      template.should parse_with_vars_to(expected, hash.merge( 'dummy' => @user))
  end

  def tag_should_parse_to(expected, hash = {})
    @tag.should parse_with_vars_to(expected, hash.merge( 'dummy' => @user ))
  end

  before do
    @time = Time.now
    @user = mock_drop user_default_values
    @user.stub!(:registered_at).and_return(@time)
  end

  context "for datetime_select" do
    context "within form" do
      it "should generate selection event when class is nil" do
        @user.stub!(:registered_at).and_return(nil)
        @tag = "{% datetime_select 'registered_at' %}"

        @year_string = '<select id="dummy_registered_at_1i" name="dummy[registered_at(1i)]">' + get_options(@time.year-5,@time.year - 1) + %{<option selected="selected" value="#{@time.year}">#{@time.year}</option>} + get_options(@time.year + 1,@time.year + 5) + "</select>"
        @month_string = '<select id="dummy_registered_at_2i" name="dummy[registered_at(2i)]">' + get_options(1,@time.month - 1,{:label_func => :get_month}) + %{<option selected="selected" value="#{@time.month}">#{get_month @time.month}</option>} + get_options(@time.month + 1,12,{:label_func => :get_month}) + "</select>"
        @day_string = '<select id="dummy_registered_at_3i" name="dummy[registered_at(3i)]">' + get_options(1,(@time.day - 1),:ignore_zeros => true) + %{<option selected="selected" value="#{@time.day}">#{@time.day}</option>} + get_options((@time.day + 1),31,:ignore_zeros => true) + "</select>"

        @hour_string = '<select id="dummy_registered_at_4i" name="dummy[registered_at(4i)]">' + get_options(0,(@time.hour - 1)) + %{<option selected="selected" value="#{@time.hour}">#{fill_zeros @time.hour}</option>} + get_options((@time.hour + 1),23) + "</select>"
        @minute_string = '<select id="dummy_registered_at_5i" name="dummy[registered_at(5i)]">' + get_options(0,(@time.min - 1)) + %{<option selected="selected" value="#{@time.min}">#{fill_zeros @time.min}</option>} + get_options((@time.min + 1),59) + "</select>"

        parse_form_tag_to @year_string + @month_string + @day_string + @hour_string + @minute_string
      end
    end


    it "should generate selection" do
      @tag = "{% datetime_select dummy,'registered_at' %}"

      @year_string = '<select id="dummy_registered_at_1i" name="dummy[registered_at(1i)]">' + get_options(@time.year-5,@time.year - 1) + %{<option selected="selected" value="#{@time.year}">#{@time.year}</option>} + get_options(@time.year + 1,@time.year + 5) + "</select>"
      @month_string = '<select id="dummy_registered_at_2i" name="dummy[registered_at(2i)]">' + get_options(1,@time.month - 1,{:label_func => :get_month}) + %{<option selected="selected" value="#{@time.month}">#{get_month @time.month}</option>} + get_options(@time.month + 1,12,{:label_func => :get_month}) + "</select>"
      @day_string = '<select id="dummy_registered_at_3i" name="dummy[registered_at(3i)]">' + get_options(1,(@time.day - 1),:ignore_zeros => true) + %{<option selected="selected" value="#{@time.day}">#{@time.day}</option>} + get_options((@time.day + 1),31,:ignore_zeros => true) + "</select>"

      @hour_string = '<select id="dummy_registered_at_4i" name="dummy[registered_at(4i)]">' + get_options(0,(@time.hour - 1)) + %{<option selected="selected" value="#{@time.hour}">#{fill_zeros @time.hour}</option>} + get_options((@time.hour + 1),23) + "</select>"
      @minute_string = '<select id="dummy_registered_at_5i" name="dummy[registered_at(5i)]">' + get_options(0,(@time.min - 1)) + %{<option selected="selected" value="#{@time.min}">#{fill_zeros @time.min}</option>} + get_options((@time.min + 1),59) + "</select>"


      tag_should_parse_to @year_string + @month_string + @day_string + @hour_string + @minute_string
    end



    it "should take separators" do
      @tag = "{% datetime_select dummy,'registered_at',date_separator:'/',datetime_separator:' - ',time_separator:':' %}"

      @year_string = '<select id="dummy_registered_at_1i" name="dummy[registered_at(1i)]">' + get_options(@time.year-5,@time.year - 1) + %{<option selected="selected" value="#{@time.year}">#{@time.year}</option>} + get_options(@time.year + 1,@time.year + 5) + "</select>"
      @month_string = '<select id="dummy_registered_at_2i" name="dummy[registered_at(2i)]">' + get_options(1,@time.month - 1,{:label_func => :get_month}) + %{<option selected="selected" value="#{@time.month}">#{get_month @time.month}</option>} + get_options(@time.month + 1,12,{:label_func => :get_month}) + "</select>"
      @day_string = '<select id="dummy_registered_at_3i" name="dummy[registered_at(3i)]">' + get_options(1,(@time.day - 1),:ignore_zeros => true) + %{<option selected="selected" value="#{@time.day}">#{@time.day}</option>} + get_options((@time.day + 1),31,:ignore_zeros => true) + "</select>"

      @hour_string = '<select id="dummy_registered_at_4i" name="dummy[registered_at(4i)]">' + get_options(0,(@time.hour - 1)) + %{<option selected="selected" value="#{@time.hour}">#{fill_zeros @time.hour}</option>} + get_options((@time.hour + 1),23) + "</select>"
      @minute_string = '<select id="dummy_registered_at_5i" name="dummy[registered_at(5i)]">' + get_options(0,(@time.min - 1)) + %{<option selected="selected" value="#{@time.min}">#{fill_zeros @time.min}</option>} + get_options((@time.min + 1),59) + "</select>"


      tag_should_parse_to @year_string + '/' + @month_string + '/' + @day_string + ' - ' + @hour_string + ':' + @minute_string

    end


    it "should take prompts" do
      @tag = "{% datetime_select dummy,'registered_at',year_prompt:true,month_prompt:'pick a month',hour_prompt:'hora' %}"

      @year_string = '<select id="dummy_registered_at_1i" name="dummy[registered_at(1i)]"><option value="">Years</option>' + get_options(@time.year-5,@time.year - 1) + %{<option selected="selected" value="#{@time.year}">#{@time.year}</option>} + get_options(@time.year + 1,@time.year + 5) + "</select>"
      @month_string = '<select id="dummy_registered_at_2i" name="dummy[registered_at(2i)]"><option value="">pick a month</option>' + get_options(1,@time.month - 1,{:label_func => :get_month}) + %{<option selected="selected" value="#{@time.month}">#{get_month @time.month}</option>} + get_options(@time.month + 1,12,{:label_func => :get_month}) + "</select>"
      @day_string = '<select id="dummy_registered_at_3i" name="dummy[registered_at(3i)]">' + get_options(1,(@time.day - 1),:ignore_zeros => true) + %{<option selected="selected" value="#{@time.day}">#{@time.day}</option>} + get_options((@time.day + 1),31,:ignore_zeros => true) + "</select>"

      @hour_string = '<select id="dummy_registered_at_4i" name="dummy[registered_at(4i)]"><option value="">hora</option>' + get_options(0,(@time.hour - 1)) + %{<option selected="selected" value="#{@time.hour}">#{fill_zeros @time.hour}</option>} + get_options((@time.hour + 1),23) + "</select>"
      @minute_string = '<select id="dummy_registered_at_5i" name="dummy[registered_at(5i)]">' + get_options(0,(@time.min - 1)) + %{<option selected="selected" value="#{@time.min}">#{fill_zeros @time.min}</option>} + get_options((@time.min + 1),59) + "</select>"


      tag_should_parse_to @year_string + @month_string + @day_string + @hour_string + @minute_string
    end

    it "should take default prompts" do
      @tag = "{% datetime_select dummy,'registered_at',prompt:true %}"

      @year_string = '<select id="dummy_registered_at_1i" name="dummy[registered_at(1i)]"><option value="">Years</option>' + get_options(@time.year-5,@time.year - 1) + %{<option selected="selected" value="#{@time.year}">#{@time.year}</option>} + get_options(@time.year + 1,@time.year + 5) + "</select>"
      @month_string = '<select id="dummy_registered_at_2i" name="dummy[registered_at(2i)]"><option value="">Months</option>' + get_options(1,@time.month - 1,{:label_func => :get_month}) + %{<option selected="selected" value="#{@time.month}">#{get_month @time.month}</option>} + get_options(@time.month + 1,12,{:label_func => :get_month}) + "</select>"
      @day_string = '<select id="dummy_registered_at_3i" name="dummy[registered_at(3i)]"><option value="">Days</option>' + get_options(1,(@time.day - 1),:ignore_zeros => true) + %{<option selected="selected" value="#{@time.day}">#{@time.day}</option>} + get_options((@time.day + 1),31,:ignore_zeros => true) + "</select>"

      @hour_string = '<select id="dummy_registered_at_4i" name="dummy[registered_at(4i)]"><option value="">Hours</option>' + get_options(0,(@time.hour - 1)) + %{<option selected="selected" value="#{@time.hour}">#{fill_zeros @time.hour}</option>} + get_options((@time.hour + 1),23) + "</select>"
      @minute_string = '<select id="dummy_registered_at_5i" name="dummy[registered_at(5i)]"><option value="">Minutes</option>' + get_options(0,(@time.min - 1)) + %{<option selected="selected" value="#{@time.min}">#{fill_zeros @time.min}</option>} + get_options((@time.min + 1),59) + "</select>"

      tag_should_parse_to @year_string + @month_string + @day_string + @hour_string + @minute_string
    end

  end


  context "for date_select" do

    context "within form" do
      it "should generate selection event when class is nil" do
        @user.stub!(:registered_at).and_return(nil)
        @tag = "{% date_select 'registered_at' %}"

        @year_string = '<select id="dummy_registered_at_1i" name="dummy[registered_at(1i)]">' + get_options(@time.year-5,@time.year - 1) + %{<option selected="selected" value="#{@time.year}">#{@time.year}</option>} + get_options(@time.year + 1,@time.year + 5) + "</select>"
        @month_string = '<select id="dummy_registered_at_2i" name="dummy[registered_at(2i)]">' + get_options(1,@time.month - 1,{:label_func => :get_month}) + %{<option selected="selected" value="#{@time.month}">#{get_month @time.month}</option>} + get_options(@time.month + 1,12,{:label_func => :get_month}) + "</select>"
        @day_string = '<select id="dummy_registered_at_3i" name="dummy[registered_at(3i)]">' + get_options(1,(@time.day - 1),:ignore_zeros => true) + %{<option selected="selected" value="#{@time.day}">#{@time.day}</option>} + get_options((@time.day + 1),31,:ignore_zeros => true) + "</select>"

        parse_form_tag_to @year_string + @month_string + @day_string
      end
    end

    it "should generate selection based on model and field" do
      @tag = "{% date_select dummy,'registered_at' %}"

      @year_string = '<select id="dummy_registered_at_1i" name="dummy[registered_at(1i)]">' + get_options(@time.year-5,@time.year - 1) + %{<option selected="selected" value="#{@time.year}">#{@time.year}</option>} + get_options(@time.year + 1,@time.year + 5) + "</select>"
      @month_string = '<select id="dummy_registered_at_2i" name="dummy[registered_at(2i)]">' + get_options(1,@time.month - 1,{:label_func => :get_month}) + %{<option selected="selected" value="#{@time.month}">#{get_month @time.month}</option>} + get_options(@time.month + 1,12,{:label_func => :get_month}) + "</select>"
      @day_string = '<select id="dummy_registered_at_3i" name="dummy[registered_at(3i)]">' + get_options(1,(@time.day - 1),:ignore_zeros => true) + %{<option selected="selected" value="#{@time.day}">#{@time.day}</option>} + get_options((@time.day + 1),31,:ignore_zeros => true) + "</select>"

      tag_should_parse_to @year_string + @month_string + @day_string
    end


    it "should take prompts" do
      @tag = "{% date_select dummy,'registered_at',day_prompt:'Choose Day',month_prompt:'Choose Month',year_prompt:'Choose Year' %}"

      @year_string = '<select id="dummy_registered_at_1i" name="dummy[registered_at(1i)]"><option value="">Choose Year</option>' + get_options(@time.year-5,@time.year - 1) + %{<option selected="selected" value="#{@time.year}">#{@time.year}</option>} + get_options(@time.year + 1,@time.year + 5) + "</select>"
      @month_string = '<select id="dummy_registered_at_2i" name="dummy[registered_at(2i)]"><option value="">Choose Month</option>' + get_options(1,@time.month - 1,{:label_func => :get_month}) + %{<option selected="selected" value="#{@time.month}">#{get_month @time.month}</option>} + get_options(@time.month + 1,12,{:label_func => :get_month}) + "</select>"
      @day_string = '<select id="dummy_registered_at_3i" name="dummy[registered_at(3i)]"><option value="">Choose Day</option>' + get_options(1,(@time.day - 1),:ignore_zeros => true) + %{<option selected="selected" value="#{@time.day}">#{@time.day}</option>} + get_options((@time.day + 1),31,:ignore_zeros => true) + "</select>"


      tag_should_parse_to @year_string + @month_string + @day_string
    end

    it "should generate selection with start year" do
      @tag = "{% date_select dummy,'registered_at',start_year:1995 %}"

      @year_string = '<select id="dummy_registered_at_1i" name="dummy[registered_at(1i)]">' + get_options(1995,@time.year - 1) + %{<option selected="selected" value="#{@time.year}">#{@time.year}</option>} + get_options(@time.year + 1,@time.year + 5) + "</select>"
      @month_string = '<select id="dummy_registered_at_2i" name="dummy[registered_at(2i)]">' + get_options(1,@time.month - 1,{:label_func => :get_month}) + %{<option selected="selected" value="#{@time.month}">#{get_month @time.month}</option>} + get_options(@time.month + 1,12,{:label_func => :get_month}) + "</select>"
      @day_string = '<select id="dummy_registered_at_3i" name="dummy[registered_at(3i)]">' + get_options(1,(@time.day - 1),:ignore_zeros => true) + %{<option selected="selected" value="#{@time.day}">#{@time.day}</option>} + get_options((@time.day + 1),31,:ignore_zeros => true) + "</select>"

      tag_should_parse_to @year_string + @month_string + @day_string 
    end

    it "should generate selection with start year, month_numbers, blank, and excluding day" do
      @tag = "{% date_select dummy,'registered_at',start_year:1995,use_month_numbers:true,discard_day:true,include_blank:true %}"

      @year_string = '<select id="dummy_registered_at_1i" name="dummy[registered_at(1i)]"><option value=""></option>' + get_options(1995,@time.year - 1) + %{<option selected="selected" value="#{@time.year}">#{@time.year}</option>} + get_options(@time.year + 1,@time.year + 5) + "</select>"
      @month_string = '<select id="dummy_registered_at_2i" name="dummy[registered_at(2i)]"><option value=""></option>' + get_options(1,@time.month - 1, :ignore_zeros => true) + %{<option selected="selected" value="#{@time.month}">#{@time.month}</option>} + get_options(@time.month + 1,12,:ignore_zeros => true) + "</select>"

      tag_should_parse_to @year_string + @month_string
    end
    it "should allow reordering" do
      @tag = "{% date_select dummy,'registered_at',order:['month' 'day' 'year'] %}"

      @year_string = '<select id="dummy_registered_at_1i" name="dummy[registered_at(1i)]">' + get_options(@time.year-5,@time.year - 1) + %{<option selected="selected" value="#{@time.year}">#{@time.year}</option>} + get_options(@time.year + 1,@time.year + 5) + "</select>"
      @month_string = '<select id="dummy_registered_at_2i" name="dummy[registered_at(2i)]">' + get_options(1,@time.month - 1,{:label_func => :get_month}) + %{<option selected="selected" value="#{@time.month}">#{get_month @time.month}</option>} + get_options(@time.month + 1,12,{:label_func => :get_month}) + "</select>"
      @day_string = '<select id="dummy_registered_at_3i" name="dummy[registered_at(3i)]">' + get_options(1,(@time.day - 1),:ignore_zeros => true) + %{<option selected="selected" value="#{@time.day}">#{@time.day}</option>} + get_options((@time.day + 1),31,:ignore_zeros => true) + "</select>"

      tag_should_parse_to  @month_string + @day_string + @year_string
    end
  end


  context "for time_select" do
    context "within form" do
      it "should generate selection event when class is nil" do
        @user.stub!(:registered_at).and_return(nil)        
        @tag = "{% time_select 'registered_at' %}"
        @year_string = %{<input id="dummy_registered_at_1i" name="dummy[registered_at(1i)]" type="hidden" value="#{@time.year}" />}
        @month_string = %{<input id="dummy_registered_at_2i" name="dummy[registered_at(2i)]" type="hidden" value="#{@time.month}" />}
        @day_string = %{<input id="dummy_registered_at_3i" name="dummy[registered_at(3i)]" type="hidden" value="#{@time.day}" />}

        @hour_string = '<select id="dummy_registered_at_4i" name="dummy[registered_at(4i)]">' + get_options(0,(@time.hour - 1)) + %{<option selected="selected" value="#{@time.hour}">#{fill_zeros @time.hour}</option>} + get_options((@time.hour + 1),23) + "</select>"
        @minute_string = '<select id="dummy_registered_at_5i" name="dummy[registered_at(5i)]">' + get_options(0,(@time.min - 1)) + %{<option selected="selected" value="#{@time.min}">#{fill_zeros @time.min}</option>} + get_options((@time.min + 1),59) + "</select>"
        parse_form_tag_to @year_string + @month_string + @day_string + @hour_string + @minute_string

      end
    end

    it "should generate selection based on model and field" do
      @tag = "{% time_select dummy,'registered_at' %}"
      @year_string = %{<input id="dummy_registered_at_1i" name="dummy[registered_at(1i)]" type="hidden" value="#{@time.year}" />}
      @month_string = %{<input id="dummy_registered_at_2i" name="dummy[registered_at(2i)]" type="hidden" value="#{@time.month}" />}
      @day_string = %{<input id="dummy_registered_at_3i" name="dummy[registered_at(3i)]" type="hidden" value="#{@time.day}" />}

      @hour_string = '<select id="dummy_registered_at_4i" name="dummy[registered_at(4i)]">' + get_options(0,(@time.hour - 1)) + %{<option selected="selected" value="#{@time.hour}">#{fill_zeros @time.hour}</option>} + get_options((@time.hour + 1),23) + "</select>"
      @minute_string = '<select id="dummy_registered_at_5i" name="dummy[registered_at(5i)]">' + get_options(0,(@time.min - 1)) + %{<option selected="selected" value="#{@time.min}">#{fill_zeros @time.min}</option>} + get_options((@time.min + 1),59) + "</select>"
      tag_should_parse_to @year_string + @month_string + @day_string + @hour_string + @minute_string

    end

    it "should allow prompt to be included" do
      @tag = "{% time_select dummy,'registered_at',hour_prompt:'choose hour',minute_prompt:'choose minute' %}"
      @year_string = %{<input id="dummy_registered_at_1i" name="dummy[registered_at(1i)]" type="hidden" value="#{@time.year}" />}
      @month_string = %{<input id="dummy_registered_at_2i" name="dummy[registered_at(2i)]" type="hidden" value="#{@time.month}" />}
      @day_string = %{<input id="dummy_registered_at_3i" name="dummy[registered_at(3i)]" type="hidden" value="#{@time.day}" />}

      @hour_string = '<select id="dummy_registered_at_4i" name="dummy[registered_at(4i)]"><option value="">choose hour</option>' + get_options(0,(@time.hour - 1)) + %{<option selected="selected" value="#{@time.hour}">#{fill_zeros @time.hour}</option>} + get_options((@time.hour + 1),23) + "</select>"
      @minute_string = '<select id="dummy_registered_at_5i" name="dummy[registered_at(5i)]"><option value="">choose minute</option>' + get_options(0,(@time.min - 1)) + %{<option selected="selected" value="#{@time.min}">#{fill_zeros @time.min}</option>} + get_options((@time.min + 1),59) + "</select>"
      tag_should_parse_to @year_string + @month_string + @day_string + @hour_string + @minute_string
    end

    it "should allow default prompts to be included" do
      @tag = "{% time_select dummy,'registered_at',hour_prompt:true,minute_prompt:true %}"
      @year_string = %{<input id="dummy_registered_at_1i" name="dummy[registered_at(1i)]" type="hidden" value="#{@time.year}" />}
      @month_string = %{<input id="dummy_registered_at_2i" name="dummy[registered_at(2i)]" type="hidden" value="#{@time.month}" />}
      @day_string = %{<input id="dummy_registered_at_3i" name="dummy[registered_at(3i)]" type="hidden" value="#{@time.day}" />}

      @hour_string = '<select id="dummy_registered_at_4i" name="dummy[registered_at(4i)]"><option value="">Hours</option>' + get_options(0,(@time.hour - 1)) + %{<option selected="selected" value="#{@time.hour}">#{fill_zeros @time.hour}</option>} + get_options((@time.hour + 1),23) + "</select>"
      @minute_string = '<select id="dummy_registered_at_5i" name="dummy[registered_at(5i)]"><option value="">Minutes</option>' + get_options(0,(@time.min - 1)) + %{<option selected="selected" value="#{@time.min}">#{fill_zeros @time.min}</option>} + get_options((@time.min + 1),59) + "</select>"
      tag_should_parse_to @year_string + @month_string + @day_string + @hour_string + @minute_string
    end

    it "should allow default prompt to be included" do
      @tag = "{% time_select dummy,'registered_at',prompt:true %}"
      @year_string = %{<input id="dummy_registered_at_1i" name="dummy[registered_at(1i)]" type="hidden" value="#{@time.year}" />}
      @month_string = %{<input id="dummy_registered_at_2i" name="dummy[registered_at(2i)]" type="hidden" value="#{@time.month}" />}
      @day_string = %{<input id="dummy_registered_at_3i" name="dummy[registered_at(3i)]" type="hidden" value="#{@time.day}" />}

      @hour_string = '<select id="dummy_registered_at_4i" name="dummy[registered_at(4i)]"><option value="">Hours</option>' + get_options(0,(@time.hour - 1)) + %{<option selected="selected" value="#{@time.hour}">#{fill_zeros @time.hour}</option>} + get_options((@time.hour + 1),23) + "</select>"
      @minute_string = '<select id="dummy_registered_at_5i" name="dummy[registered_at(5i)]"><option value="">Minutes</option>' + get_options(0,(@time.min - 1)) + %{<option selected="selected" value="#{@time.min}">#{fill_zeros @time.min}</option>} + get_options((@time.min + 1),59) + "</select>"
      tag_should_parse_to @year_string + @month_string + @day_string + @hour_string + @minute_string
    end


    it "should allow minute steps to be included" do
      @tag = "{% time_select dummy,'registered_at',minute_step:15 %}"
      @time.stub!(:min).and_return(15)

      @year_string = %{<input id="dummy_registered_at_1i" name="dummy[registered_at(1i)]" type="hidden" value="#{@time.year}" />}
      @month_string = %{<input id="dummy_registered_at_2i" name="dummy[registered_at(2i)]" type="hidden" value="#{@time.month}" />}
      @day_string = %{<input id="dummy_registered_at_3i" name="dummy[registered_at(3i)]" type="hidden" value="#{@time.day}" />}

      @hour_string = '<select id="dummy_registered_at_4i" name="dummy[registered_at(4i)]">' + get_options(0,(@time.hour - 1)) + %{<option selected="selected" value="#{@time.hour}">#{fill_zeros(@time.hour)}</option>} + get_options((@time.hour + 1),23) + "</select>"
      @minute_string = '<select id="dummy_registered_at_5i" name="dummy[registered_at(5i)]"><option value="0">00</option><option selected="selected" value="15">15</option><option value="30">30</option><option value="45">45</option></select>'
            
      tag_should_parse_to @year_string + @month_string + @day_string + @hour_string + @minute_string
    end


  end
end
