require File.dirname(__FILE__) + '/spec_helper'

describe "Default Filters" do

  include Clot::UrlFilters
  include Clot::FormFilters
  include Liquid

  before(:each) do
    @context = {}    
  end

  it "should produce url for views" do
    obj = get_drop @@text_content_default_values
    test_link = view_link obj
    test_link.should_not be_blank
  end

  it "should produce link for deletion" do
    obj = get_drop @@text_content_default_values
    test_link = delete_link(object_url(obj))
    test_link.should_not be_blank
  end

  it "should produce edit link" do
    test_link = edit_link "/foo/1", "EDIT"
    test_link.should == '<a href="/foo/1/edit">EDIT</a>'
  end

  it "should get url for stylesheets" do
    test_url = stylesheet_url "stylesheet.css"
    test_url.should == "/stylesheets/stylesheet.css"
  end
 
  it "should get url for object" do
    obj = get_drop @@text_content_default_values
    test_url = object_url obj
    test_url.should == "/" + obj.dropped_class.to_s.tableize + "/" + obj.record_id.to_s
  end

  it "should get url for object within alternate class" do  
    obj = get_drop @@text_content_default_values
    test_url = object_url obj, "image_contents"
    test_url.should == "/image_contents/" + obj.record_id.to_s
  end

  context "index link" do
    it "should generate link with default title based on content type" do
      cts_index = index_link "contents"
      assert_equal cts_index, '<a href="/contents">Contents Index</a>'
    end

    it "should generate link with with optional title"  do
      cts_index = index_link "contents", "Index"
      assert_equal cts_index, '<a href="/contents">Index</a>'
    end
  end

  it "should produce parsed version of template" do
    expected = '<div class="form-submit-button"><input type="submit" value="I am here"/></div>'
    template = '{{ "I am here" | submit_button }}'
    template.should parse_to(expected)
  end

  context "when an object url exists" do
    before(:each) do
      @obj = get_drop @@text_content_default_values
    end

    it "edit link should not be blank" do
      test_link = edit_link(object_url(@obj))
      test_link.should_not be_blank
    end

    it "view link should not be blank" do
      test_link = view_link(object_url(@obj))
      test_link.should_not be_blank
    end

    it "delete link should not be blank" do
      test_link = delete_link(object_url(@obj))
      test_link.should_not be_blank
    end
  end

  it "should let you set params on an input" do
    expected = '<input dummy="ffgg" type="password" ilse="sss" />'
    template = '{{ \'<input dummy="ffgg" type="text" ilse="sss" />\' | set_param: "type", "password" }}'
    template.should parse_to(expected)
  end

  context "it should produce nested urls" do
    before(:each) do
      @obj = get_drop @@text_content_default_values
    end

    it "should have default nestings" do
      url = get_nested_url @obj, @obj
      expected_url = "/liquid_demo_models/1/liquid_demo_models/1"
      url.should == expected_url
    end

    it "should allow you to nested resource" do
      url = get_nested_url @obj, "/child"
      expected_url = "/liquid_demo_models/1/child"
      assert_equal url, expected_url
    end  
  end

  def test_content_drop
    get_drop(@@text_content_default_values)
  end

end