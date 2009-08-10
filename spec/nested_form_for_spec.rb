require File.dirname(__FILE__) + '/spec_helper'

describe "Form For" do

  include Clot::UrlFilters
  include Clot::FormFilters
  include Liquid

  before(:each) do
    @context = {}
  end


  context "when building form for nested route" do
    before(:each) do
      @child_drop = get_drop @@text_content_default_values
      @parent_drop = get_drop @@text_content_default_values.merge({ :record_id => 2, :name => 'parent' })
    end

    it "should be created with valid route" do
      expected = '<form method="POST" action="' + (object_url @parent_drop) + (object_url @child_drop)  + '"><input type="hidden" name="_method" value="PUT"/></form>'
      template = "{% nested_formfor parent child %}{% endnested_formfor %}"
      template.should parse_with_atributes_to(expected, 'child' => @child_drop, 'parent' => @parent_drop)
    end

    it "should allow elements that refer to both the parent and the child" do
      expected = '<form method="POST" action="' + (object_url @parent_drop) + (object_url @child_drop)  + '"><input type="hidden" name="_method" value="PUT"/><input type="text" id="liquid_demo_model_name" name="liquid_demo_model[name]" value="Basic Essay Here"/><input type="text" id="liquid_demo_model_name" name="liquid_demo_model[name]" value="parent"/></form>'
      template = "{% nested_formfor parent child %}{{ form_name }}{{ parent_form_name }}{% endnested_formfor %}"
      template.should parse_with_atributes_to(expected, 'child' => @child_drop, 'parent' => @parent_drop)
    end
  end
  
end
