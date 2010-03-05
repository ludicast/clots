require File.dirname(__FILE__) + '/spec_helper'

describe "Url Filters" do

  include Clot::UrlFilters
  include Liquid

  before(:each) do
    @context = {}    
  end

  context "stylesheet_url filter" do
    specify "should get url for stylesheet" do
      test_url = stylesheet_url "stylesheet"
      test_url.should == "/stylesheets/stylesheet.css"
    end 
  end

  context "object_url filter" do 
    specify "should get url for object" do
      obj = get_drop text_content_default_values
      test_url = object_url obj
      test_url.should == "/" + obj.dropped_class.to_s.tableize + "/" + obj.id.to_s
    end

    specify "with alternate resource name should get url for object within alternate resource" do
      obj = get_drop text_content_default_values
      test_url = object_url obj, "image_contents"
      test_url.should == "/image_contents/" + obj.id.to_s
    end
  end

  context "get_nested_url filter" do
    before(:each) do
      @obj = get_drop text_content_default_values
    end
   
    specify "should produce nested urls of objects" do
      url = get_nested_url @obj, @obj
      expected_url = "/liquid_demo_models/1/liquid_demo_models/1"
      url.should == expected_url
    end

    specify "should produce nested urls of classes" do
      url = get_nested_url @obj, "/child"
      expected_url = "/liquid_demo_models/1/child"
      url.should == expected_url
    end  
  end

  context "get_nested_edit_url filter" do
    before(:each) do
      @obj = get_drop text_content_default_values
    end

    specify "should produce nested urls with edit tag" do
      url = get_nested_edit_url @obj, @obj
      expected_url = "/liquid_demo_models/1/liquid_demo_models/1/edit"
      url.should == expected_url
    end

  end

end