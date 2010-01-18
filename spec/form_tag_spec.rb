require File.dirname(__FILE__) + '/spec_helper'

module Clot
  class FormTag < LiquidForm

    def get_form_header(context)
      "<form action=\"#{@form_object}\" method=\"#{@http_method}\"#{@upload_info}>" 
    end
    def get_form_errors
      ""
    end

    def set_variables(context)
      set_method
      set_upload
      #super
    end

    def set_method
      @http_method = @attributes['method'] ||= 'post'
    end
    
  end


end


Liquid::Template.register_tag('form_tag', Clot::FormTag)

describe "Form Tag" do

  include Clot::UrlFilters
  include Clot::FormFilters
  include Liquid

  before(:each) do
    @context = {}    
  end

  it "should produce blank form tag" do
    form = "{% form_tag /posts %}{% endform_tag %}"
    form.should parse_to('<form action="/posts" method="post"></form>')
  end

  it "should allow alternate HTTP methods" do
    form = "{% form_tag /posts/1 method:put %}{% endform_tag %}"
    form.should parse_to('<form action="/posts/1" method="put"></form>')
  end

  it "should allow multipart" do
    form = "{% form_tag /upload multipart:true %}{% endform_tag %}"
    form.should parse_to('<form action="/upload" method="post" enctype="multipart/form-data"></form>')    
  end

  it "should take inner tags" do
    form = "{% form_tag /posts %}<div>{% submit_tag Save %}</div>{% endform_tag %}"
    form.should parse_to('<form action="/posts" method="post"><div><input type="submit" name="submit" value="Save" /></div></form>')
  end

end