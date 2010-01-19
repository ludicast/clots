require File.dirname(__FILE__) + '/spec_helper'

describe "tags for forms that use models" do
  include Clot::UrlFilters
  include Clot::FormFilters
  include Liquid


  def parse_form_tag_to(inner_code)
      template = "{% formfor liquid_demo_model %}#{@tag}{% endformfor %}"
      expected = %{<form method="POST" action="#{object_url @user}"><input type="hidden" name="_method" value="PUT"/>#{inner_code}</form>}
      template.should parse_with_atributes_to(expected, 'liquid_demo_model' => @user)
  end

  def tag_should_parse_to expected
    @tag.should parse_with_atributes_to(expected, 'liquid_demo_model' => @user)
  end
  
  before do
    @user = get_drop @@user_default_values
  end

  context "for text_field" do
    context "outside of form" do
      it "should take regular name" do
        @tag = "{% text_field liquid_demo_model,name %}"
        tag_should_parse_to %{<input id="liquid_demo_model_name" name="liquid_demo_model[name]" type="text" value="#{@user.name}" />}
      end
    end
    context "inside of form" do
      it "should take regular name" do
        @tag = "{% text_field name %}"
        parse_form_tag_to %{<input id="liquid_demo_model_name" name="liquid_demo_model[name]" type="text" value="#{@user.name}" />}
      end
    end

  end

end