#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/test_helper'

class LiquidCmsTest < Test::Unit::TestCase
  include Clot::UrlFilters
  include Liquid
  

  def test_empty_form_builder
    text_drop = get_drop @@text_content_default_values

    expected = '<form method="POST" action="' + (object_url text_drop) + '"><input type="hidden" name="_method" value="PUT"/></form>'
    template = '{% formfor text %}{% endformfor %}'
    
    
    assert_template_result(expected, template, 'text' => text_drop)  
  end  

  def test_form_builder_element
    user_drop = get_drop @@user_default_values

    expected = '<form method="POST" action="' + (object_url user_drop) + '"><input type="hidden" name="_method" value="PUT"/><br/><input type="text" id="liquid_demo_model[login]" name="liquid_demo_model[login]" value="' + user_drop.login + '"/></form>'
    template = '{% formfor liquid_demo_model %}<br/>{{ form_login }}{% endformfor %}'
    assert_template_result(expected, template, 'liquid_demo_model' => user_drop)  
  end
  
  
  def test_new_form
    expected = '<form method="POST" action="/liquid_demo_model_drops/"><input type="text" id="liquid_demo_model_drop[name]" name="liquid_demo_model_drop[name]" value="My Name"/></form>'
    template = '{% formfor liquid_demo_model_drop obj_class:liquid_demo_model_drops %}{{ form_name }}{% endformfor %}'
    assert_template_result(expected, template)
  end

  def test_form_builder_class
    user_drop = get_drop @@user_default_values
    expected = '<form method="POST" class="tester" action="' + (object_url user_drop) + '"><input type="hidden" name="_method" value="PUT"/></form>'
    template = '{% formfor user class:tester %}{% endformfor %}'
    assert_template_result(expected, template, 'user' => user_drop)  
  end  

  def test_form_error_default
    user_drop = get_drop @@user_default_values
    user_drop.errors.add("error")
    expected = '<form method="POST" class="tester" action="' + (object_url user_drop) + '"><input type="hidden" name="_method" value="PUT"/><div id="error-explanation"><h2>1 error(s) occurred while processing information</h2><ul><li>error - is invalid</li></ul></div></form>'
    template = '{% formfor user class:tester %}{% endformfor %}'
    assert_template_result(expected, template, 'user' => user_drop)  

    user_drop.errors.add("error", "other message")
    user_drop.errors.add("login", "login already used")
    expected = '<form method="POST" class="tester" action="' + (object_url user_drop) + '"><input type="hidden" name="_method" value="PUT"/><div id="error-explanation"><h2>3 error(s) occurred while processing information</h2><ul><li>error - is invalid</li><li>error - other message</li><li>login - login already used</li></ul></div><input type="text" id="liquid_demo_model[login]" name="liquid_demo_model[login]" value="' + user_drop[:login] + '" class="error-item"/></form>'
    template = '{% formfor user class:tester %}{{ form_login }}{% endformfor %}'
    assert_template_result(expected, template, 'user' => user_drop)  

    user_drop.errors.add("login", "login too short")
    expected = '<form method="POST" class="tester" action="' + (object_url user_drop) + '"><input type="hidden" name="_method" value="PUT"/><div id="error-explanation"><h2>4 error(s) occurred while processing information</h2><ul><li>error - is invalid</li><li>error - other message</li><li>login - login already used</li><li>login - login too short</li></ul></div><input type="text" id="liquid_demo_model[login]" name="liquid_demo_model[login]" value="' + user_drop[:login] + '" class="error-item"/></form>'
    template = '{% formfor user class:tester %}{{ form_login }}{% endformfor %}'
    assert_template_result(expected, template, 'user' => user_drop)    
  end  


  def test_form_scope
    user_drop = get_drop @@user_default_values
    expected = '<form method="POST" class="tester" action="' + (object_url user_drop) + '"><input type="hidden" name="_method" value="PUT"/></form>'
    template = '{% formfor user class:tester %}{% endformfor %}{{form_login}}'
    assert_template_result(expected, template, 'user' => user_drop)  
  end  

  def test_form_builder_class
    user_drop = get_drop @@user_default_values
    expected = '<form method="POST" action="' + (object_url user_drop) + '"><input type="hidden" name="_method" value="PUT"/></form>'
    template = '{% formfor user %}{% endformfor %}'
    assert_template_result(expected, template, 'user' => user_drop)
  end  


end


