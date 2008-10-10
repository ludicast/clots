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
  
  def test_link_chains
    obj = get_drop @@text_content_default_values
    test_link = edit_link(object_url(obj))
    assert (! test_link.blank?)
    test_link = view_link(object_url(obj))
    assert (! test_link.blank?)
    test_link = delete_link(object_url(obj))
    assert (! test_link.blank?) 
  end

  def test_view_url
    obj = get_drop @@text_content_default_values
    test_link = view_link obj
    assert (! test_link.blank?)
  end  

  def test_delete_url
    obj = get_drop @@text_content_default_values
    test_link = delete_link(object_url(obj))
    assert (! test_link.blank?)
  end

  def test_object_url
    obj = get_drop @@text_content_default_values
    test_url = object_url obj
    assert_equal test_url, "/" + obj.dropped_class.to_s.tableize + "/" + obj.record_id.to_s
    
    obj = get_drop @@text_content_default_values
    test_url = object_url obj, "image_contents"
    assert_equal test_url, "/image_contents/" + obj.record_id.to_s
  end



  def test_edit_link
    test_link = edit_link "/foo/1", "EDIT"
    assert_equal test_link, '<a href="/foo/1/edit">EDIT</a>'
  end

  def test_stylesheet_url
    test_url = stylesheet_url "stylesheet.css"
    assert_equal test_url, "/stylesheets/stylesheet.css"
  end
  
  def test_content_drop
    get_drop(@@text_content_default_values)
  end
  
  def test_index_link
    cts_index = index_link "contents"
    assert_equal cts_index, '<a href="/contents">Contents Index</a>'
    cts_index = index_link "contents", "Index"
    assert_equal cts_index, '<a href="/contents">Index</a>'
    cts_index = index_link "image_contents"
    assert_equal cts_index, '<a href="/image_contents">Image Contents Index</a>'
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
  
  def test_get_nested_url
    obj = get_drop @@text_content_default_values
    
    url = get_nested_url obj, obj
    expected_url = "/liquid_demo_models/1/liquid_demo_models/1"
    assert_equal url, expected_url    

    url = get_nested_url obj, "/child"
    expected_url = "/liquid_demo_models/1/child"
    assert_equal url, expected_url

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

  def test_replace_form_item_param
    expected = '<input dummy="ffgg" type="password" ilse="sss" />'
    template = '{{ \'<input dummy="ffgg" type="text" ilse="sss" />\' | set_param: "type", "password" }}'
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

  def test_submit_button_filter  
    expected = '<div class="form-submit-button"><input type="submit" value="I am here"/></div>'
    template = '{{ "I am here" | submit_button }}'
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

  def test_paginator
    expected = "<div class=\"pagination-links\"><a href=\"/urls/?page=1\">&lt;&lt;</a> <a href=\"/urls/?page=1\">&lt;</a> <a href=\"/urls/?page=1\">1</a> | 2</div>"
    template = '{{ paginator | will_paginate: "/urls/" }}'
    assert_template_result(expected, template, 'paginator' => WillPaginate::Collection.new(2,2,4))

#  TODO --- wierd gt; match problem -- check later
#   expected = "<div class=\"pagination-links\">1 | <a href=\"/urls/?page=2\">2</a> <a href=\"/urls/?page=0\">&gt;</a> <a href=\"/urls/?page=2\">&gt;&gt;</a></div>"
#    template = '{{ paginator | will_paginate: "/urls/" }}'
#    assert_template_result(expected, template, 'paginator' => WillPaginate::Collection.new(1,2,4))

  end

end


