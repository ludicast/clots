#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/test_helper'

class ClotTest < Test::Unit::TestCase
  include Clot::UrlFilters
  include Clot::FormFilters
  
  include Liquid
  
  def initialize(test_method_name)
    @context ||= {}
    super 
  end
  
 
  
  def test_object_to_link
    obj = get_drop @@text_content_default_values
    test_link = edit_link(object_url(obj))
    test_link2 = edit_link obj
    assert (! test_link.blank?)
    assert_equal test_link, test_link2  
    test_link = view_link(object_url(obj))
    test_link2 = view_link obj
    assert (! test_link.blank?)
    assert_equal test_link, test_link2        
    test_link = delete_link(object_url(obj))
    test_link2 = delete_link obj
    assert (! test_link.blank?)
    assert_equal test_link, test_link2        
  end
  

#get_nested_url(target, nested_target, class_name = "", nested_class_name = "")

  
  def test_form_item_class
    expected = "<p><label>hello there</label>form_item</p>"
    template = '{{"form_item" | form_item: "hello there" }}'
    assert_template_result(expected, template)
    
    expected = '<p><label>hmm<span class="required">*</span></label>h2</p>'
    template = '{{"h2" | form_item: "hmm", true }}'
    assert_template_result(expected, template)
    
    expected = "<p><label for=\"item\">nyuk</label><i id=\"item\"></p>"
    template = '{{\'<i id="item">\' | form_item: "nyuk" }}'
    assert_template_result(expected, template)
  end


  def test_add_form_item_param
    expected = '<input dummy="ffgg" ilse="sss"  type="password"/>'
    template = '{{ \'<input dummy="ffgg" ilse="sss" />\' | set_param: "type", "password" }}'
    assert_template_result(expected, template)
    expected = '<input dummy="ffgg" ilse="sss"  type="password">'
    template = '{{ \'<input dummy="ffgg" ilse="sss" >\' | set_param: "type", "password" }}'
    assert_template_result(expected, template)
  end

 

  def test_input_to_text_area_filter
    expected = '<textarea>HELLO</textarea>'
    template = '{{ \'<input type="text" value="HELLO" />\' | input_to_text }}'
    assert_template_result(expected, template)    
    expected = '<textarea name="g-luv"></textarea>'
    template = '{{ \'<input type="text" name="g-luv" />\' | input_to_text }}'
    assert_template_result(expected, template)
  end

end


