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
    test_url = stylesheet_url "stylesheet"
    test_url.should == "/stylesheets/stylesheet.css"
  end
 
  it "should get url for object" do
    obj = get_drop @@text_content_default_values
    test_url = object_url obj
    test_url.should == "/" + obj.dropped_class.to_s.tableize + "/" + obj.id.to_s
  end

  it "should get url for object within alternate class" do  
    obj = get_drop @@text_content_default_values
    test_url = object_url obj, "image_contents"
    test_url.should == "/image_contents/" + obj.id.to_s
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

  context "it should get same links from either url or object" do
    before(:each) do
      @obj = get_drop @@text_content_default_values
    end

    it "for editing" do
      test_link = edit_link(object_url(@obj))
      test_link2 = edit_link @obj
      test_link.should == test_link2
    end

    it "for deleting" do
      test_link = delete_link(object_url(@obj))
      test_link2 = delete_link @obj
      test_link.should == test_link2
    end

    it "for viewing" do
      test_link = view_link(object_url(@obj))
      test_link2 = view_link @obj  
      test_link.should == test_link2
    end

  end

  context "should set param on form items" do
    it "that are closed" do
      expected = '<input dummy="ffgg" ilse="sss"  type="password"/>'
      template = '{{ \'<input dummy="ffgg" ilse="sss" />\' | set_param: "type", "password" }}'
      template.should parse_to(expected)  
    end

    it "that are open" do
      expected = '<input dummy="ffgg" ilse="sss"  type="password">'
      template = '{{ \'<input dummy="ffgg" ilse="sss" >\' | set_param: "type", "password" }}'
      template.should parse_to(expected)
    end
  end

  context "should translate to text area" do
    it "converting vaues to text contents" do
      expected = '<textarea>HELLO</textarea>'
      template = '{{ \'<input type="text" value="HELLO" />\' | input_to_text }}'
      template.should parse_to(expected)
    end

    it "keeping original attributes" do
      expected = '<textarea name="g-luv"></textarea>'
      template = '{{ \'<input type="text" name="g-luv" />\' | input_to_text }}'
      template.should parse_to(expected)
    end

  end

  context "should label form items" do
    it "should label form item" do
      expected = "<p><label>hello there</label>form_item</p>"
      template = '{{"form_item" | form_item: "hello there" }}'
      template.should parse_to(expected)
    end

    it "should have 'required' option for form item's label" do
      expected = '<p><label>hmm<span class="required">*</span></label>h2</p>'
      template = '{{"h2" | form_item: "hmm", true }}'
      template.should parse_to(expected)
    end

    it "should populate 'for' attribute depending on 'id' field" do    
      expected = "<p><label for=\"item\">nyuk</label><i id=\"item\"></p>"
      template = '{{\'<i id="item">\' | form_item: "nyuk" }}'
      template.should parse_to(expected)
    end
  end


  def test_content_drop
    get_drop(@@text_content_default_values)
  end

end