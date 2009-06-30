require File.dirname(__FILE__) + '/spec_helper'

describe "Form Builder" do

  include Clot::UrlFilters
  include Clot::FormFilters
  include Liquid

  before(:each) do
    @context = {}    
  end


  context "should set param on form items" do
    it "that are closed" do
      expected = '<input dummy="ffgg" ilse="sss"  type="password"/>'
      template = '{{ \'<input dummy="ffgg" ilse="sss" />\' | set_param: "type", "password" }}'
      template.should parse_to(expected)
    end

    it "that are open" do
      expected = '<input dummy="ffgg" ilse="sss"  type="password">'
      template = '{{ \'<input dummy="ffgg" ilse="sss" >\' | set_param: "type", "password" }}'
      template.should parse_to(expected)
    end
  end

  context "should translate to text area" do
    it "converting vaues to text contents" do
      expected = '<textarea>HELLO</textarea>'
      template = '{{ \'<input type="text" value="HELLO" />\' | input_to_text }}'
      template.should parse_to(expected)
    end

    it "keeping original attributes" do
      expected = '<textarea name="g-luv"></textarea>'
      template = '{{ \'<input type="text" name="g-luv" />\' | input_to_text }}'
      template.should parse_to(expected)
    end

  end

  context "should label form items" do
    it "should label form item" do
      expected = "<p><label>hello there</label>form_item</p>"
      template = '{{"form_item" | form_item: "hello there" }}'
      template.should parse_to(expected)
    end

    it "should have 'required' option for form item's label" do
      expected = '<p><label>hmm<span class="required">*</span></label>h2</p>'
      template = '{{"h2" | form_item: "hmm", true }}'
      template.should parse_to(expected)
    end

    it "should populate 'for' attribute depending on 'id' field" do
      expected = "<p><label for=\"item\">nyuk</label><i id=\"item\"></p>"
      template = '{{\'<i id="item">\' | form_item: "nyuk" }}'
      template.should parse_to(expected)
    end
  end

  it "should let you set params on an input" do
    expected = '<input dummy="ffgg" type="password" ilse="sss" />'
    template = '{{ \'<input dummy="ffgg" type="text" ilse="sss" />\' | set_param: "type", "password" }}'
    template.should parse_to(expected)
  end

  it "should produce parsed version of template" do
    expected = '<div class="form-submit-button"><input type="submit" value="I am here"/></div>'
    template = '{{ "I am here" | submit_button }}'
    template.should parse_to(expected)
  end  

end