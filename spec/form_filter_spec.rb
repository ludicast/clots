require File.dirname(__FILE__) + '/spec_helper'

describe "Form Filter" do

  include Clot::UrlFilters
  include Clot::FormFilters
  include Liquid

  before(:each) do
    @context = {}    
  end

  context "input_to_text translates to text area" do
    specify "converting value attribute to text contents" do
      expected = '<textarea>HELLO</textarea>'
      template = '{{ \'<input type="text" value="HELLO" />\' | input_to_text }}'
      template.should parse_to(expected)
    end

    specify "keeping other attributes" do
      expected = '<textarea name="g-luv"></textarea>'
      template = '{{ \'<input type="text" name="g-luv" />\' | input_to_text }}'
      template.should parse_to(expected)
    end

  end

  context "form_item filter" do
    it "adds label to arbitrary data" do
      expected = "<p><label>hello there</label>form_item</p>"
      template = '{{"form_item" | form_item: "hello there" }}'
      template.should parse_to(expected)
    end

    it "includes 'required' class" do
      expected = '<p><label>hmm<span class="required">*</span></label>h2</p>'
      template = '{{"h2" | form_item: "hmm", true }}'
      template.should parse_to(expected)
    end

    it "populates 'for' attribute dwith contents of 'id' attribute" do
      expected = "<p><label for=\"item\">nyuk</label><i id=\"item\"></p>"
      template = '{{\'<i id="item">\' | form_item: "nyuk" }}'
      template.should parse_to(expected)
    end
  end
 
  context "the set_param filter" do
    it "should let you change params on an input" do
      expected = '<input dummy="ffgg" type="password" ilse="sss" />'
      template = '{{ \'<input dummy="ffgg" type="text" ilse="sss" />\' | set_param: "type", "password" }}'
      template.should parse_to(expected)
    end

    it "should let you add params to an input" do
      expected = '<input dummy="ffgg" ilse="sss"  type="password"/>'
      template = '{{ \'<input dummy="ffgg" ilse="sss" />\' | set_param: "type", "password" }}'
      template.should parse_to(expected)
    end

    it "should work on tags that are open" do
      expected = '<input dummy="ffgg" ilse="sss"  type="password">'
      template = '{{ \'<input dummy="ffgg" ilse="sss" >\' | set_param: "type", "password" }}'
      template.should parse_to(expected)
    end      
  end
  
  context "the submit_button filter" do
    it "converts text to submit button" do
      expected = '<div class="form-submit-button"><input type="submit" value="I am here"/></div>'
      template = '{{ "I am here" | submit_button }}'
      template.should parse_to(expected)
    end
  end
end