require File.dirname(__FILE__) + '/spec_helper'

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



  context "for time_select" do


    it "should generate selection based on model and field" do
      @tag = "{% time_select dummy,'registered_at' %}"
      @year_string = %{<input id="dummy_registered_at_1i" name="dummy[registered_at(1i)]" type="hidden" value="#{@time.year}" />}
      @month_string = %{<input id="dummy_registered_at_2i" name="dummy[registered_at(2i)]" type="hidden" value="#{@time.month}" />}
      @day_string = %{<input id="dummy_registered_at_3i" name="dummy[registered_at(3i)]" type="hidden" value="#{@time.day}" />}

      @hour_string = '<select id="dummy_registered_at_4i" name="dummy[registered_at(4i)]">' + get_options(0,(@time.hour - 1)) + %{<option selected="selected" value="#{@time.hour}">#{@time.hour}</option>} + get_options((@time.hour + 1),59) + "</select>"
      @minute_string = '<select id="dummy_registered_at_5i" name="dummy[registered_at(5i)]">' + get_options(0,(@time.min - 1)) + %{<option selected="selected" value="#{@time.min}">#{@time.min}</option>} + get_options((@time.min + 1),59) + "</select>"
      tag_should_parse_to @year_string + @month_string + @day_string + @hour_string + @minute_string

    end

    it "should allow seconds to be included" do
      @tag = "{% time_select dummy,'registered_at',include_seconds:true %}"
      @year_string = %{<input id="dummy_registered_at_1i" name="dummy[registered_at(1i)]" type="hidden" value="#{@time.year}" />}
      @month_string = %{<input id="dummy_registered_at_2i" name="dummy[registered_at(2i)]" type="hidden" value="#{@time.month}" />}
      @day_string = %{<input id="dummy_registered_at_3i" name="dummy[registered_at(3i)]" type="hidden" value="#{@time.day}" />}

      @hour_string = '<select id="dummy_registered_at_4i" name="dummy[registered_at(4i)]">' + get_options(0,(@time.hour - 1)) + %{<option selected="selected" value="#{@time.hour}">#{@time.hour}</option>} + get_options((@time.hour + 1),59) + "</select>"
      @minute_string = '<select id="dummy_registered_at_5i" name="dummy[registered_at(5i)]">' + get_options(0,(@time.min - 1)) + %{<option selected="selected" value="#{@time.min}">#{@time.min}</option>} + get_options((@time.min + 1),59) + "</select>"
      @second_string = '<select id="dummy_registered_at_6i" name="dummy[registered_at(6i)]">' + get_options(0,(@time.sec - 1)) + %{<option selected="selected" value="#{@time.sec}">#{@time.sec}</option>} + get_options((@time.sec + 1),59) + "</select>"
      tag_should_parse_to @year_string + @month_string + @day_string + @hour_string + @minute_string + @second_string

    end

  end


end
