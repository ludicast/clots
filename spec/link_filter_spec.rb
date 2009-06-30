require File.dirname(__FILE__) + '/spec_helper'

describe "Link Filters" do

  include Clot::UrlFilters
  include Clot::FormFilters
  include Liquid

  before(:each) do
    @context = {}    
  end

  context "should produce restful link" do
    context "with title" do

      it "for viewing" do
        obj = get_drop @@text_content_default_values
        test_link = view_link obj, "OBJECT TITLE"
        test_link.should == "<a href=\"/liquid_demo_models/1\">OBJECT TITLE</a>"
      end

      it "for deletion" do
        obj = get_drop @@text_content_default_values
        test_link = delete_link object_url(obj), 'DELETE ME'
        test_link.should == "<a href=\"/liquid_demo_models/1\" onclick=\"if (confirm('Are you sure?')) { var f = document.createElement('form'); f.style.display = 'none'; this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;var m = document.createElement('input'); m.setAttribute('type', 'hidden'); m.setAttribute('name', '_method'); m.setAttribute('value', 'delete'); f.appendChild(m);f.submit(); };return false;\">DELETE ME</a>"
      end


      it "for index" do
        cts_index = index_link "contents", "Index"
        assert_equal cts_index, '<a href="/contents">Index</a>'
      end
      
      it "for editing" do
        test_link = edit_link "/foo/1", "EDIT"
        test_link.should == '<a href="/foo/1/edit">EDIT</a>'
      end

      it "for creating" do
        test_link = new_link "contents", "CREATE NAME"
        test_link.should == '<a href="/contents/new">CREATE NAME</a>'
      end

    end

    context "without title" do
      it "for viewing" do
        obj = get_drop @@text_content_default_values
        test_link = view_link obj
        test_link.should == "<a href=\"/liquid_demo_models/1\">View</a>"
      end

      it "for deletion" do
        obj = get_drop @@text_content_default_values
        test_link = delete_link(object_url(obj))
        test_link.should == "<a href=\"/liquid_demo_models/1\" onclick=\"if (confirm('Are you sure?')) { var f = document.createElement('form'); f.style.display = 'none'; this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;var m = document.createElement('input'); m.setAttribute('type', 'hidden'); m.setAttribute('name', '_method'); m.setAttribute('value', 'delete'); f.appendChild(m);f.submit(); };return false;\">Delete</a>"
      end

      it "for index" do
        cts_index = index_link "contents"
        assert_equal cts_index, '<a href="/contents">Contents Index</a>'
      end

      it "for editing" do
        test_link = edit_link "/foo/1"
        test_link.should == '<a href="/foo/1/edit">Edit</a>'
      end

      it "for creating" do
        test_link = new_link "contents"
        test_link.should == '<a href="/contents/new">New Content</a>'
      end

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

end