require File.dirname(__FILE__) + '/spec_helper'

describe "Form Tag" do

  include Liquid


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