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
      @tag.should parse_to(get_options(0,32) + '<option selected="selected" value="33">33</option>' + get_options(34,59))
    end
  end
end
