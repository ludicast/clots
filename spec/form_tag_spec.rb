require File.dirname(__FILE__) + '/spec_helper'

describe "Form Tag" do

  include Liquid
  
  context "when consisting of the same identical inner tag" do
    it "produces unique tags each time" do
      user_drop = get_drop user_default_values
      def user_drop.child_ids
        [1,3]
      end

      expected = "<form action=\"/users\" method=\"post\"><input checked=\"checked\" id=\"foo\" name=\"foo\" type=\"checkbox\" value=\"1\" /><input id=\"foo\" name=\"foo\" type=\"checkbox\" value=\"2\" /><input checked=\"checked\" id=\"foo\" name=\"foo\" type=\"checkbox\" value=\"3\" /></form>"
      template = %{{% form_tag users_path %}{% for val in one_two_three %}{% check_box_tag 'foo',val,collection:liquid_demo_model_drop.child_ids, member:val %}{% endfor %}{% endform_tag %}}
      template.should parse_with_vars_to(expected,
        'liquid_demo_model_drop' => user_drop, 'one_two_three' => [1,2,3]
      )
    end
  end


  it "should produce blank form tag" do
    form = "{% form_tag '/posts' %}{% endform_tag %}"
    form.should parse_to('<form action="/posts" method="post"></form>')
  end

  it "should allow alternate HTTP methods" do
    form = "{% form_tag '/posts/1' method:put %}{% endform_tag %}"
    form.should parse_to('<form action="/posts/1" method="put"></form>')
  end

  it "should allow multipart" do
    form = "{% form_tag '/upload' multipart:true %}{% endform_tag %}"
    form.should parse_to('<form action="/upload" method="post" enctype="multipart/form-data"></form>')    
  end

  it "should allow get method" do
    form = "{% form_tag '/upload' method:get %}{% endform_tag %}"
    form.should parse_to('<form action="/upload" method="get"></form>')    
  end

  it "should allow path" do
    form = "{% form_tag users_path %}{% endform_tag %}"
    form.should parse_to('<form action="/users" method="post"></form>')    
  end

  it "should take inner tags" do
    form = "{% form_tag '/posts' %}<div>{% submit_tag 'Save' %}</div>{% endform_tag %}"
    form.should parse_to('<form action="/posts" method="post"><div><input type="submit" name="commit" value="Save" /></div></form>')
  end

end