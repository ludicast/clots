require File.dirname(__FILE__) + '/spec_helper'

describe "Url Filters" do

  include Clot::UrlFilters
  include Clot::FormFilters
  include Liquid

  before(:each) do
    @context = {}    
  end


  context "for stylesheets" do
    it "should get url" do
      test_url = stylesheet_url "stylesheet.css"
      test_url.should == "/stylesheets/stylesheet.css"
    end
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
      url.should == expected_url
    end  
  end

end