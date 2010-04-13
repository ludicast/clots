require File.dirname(__FILE__) + '/spec_helper'

describe "Form Filter" do

  include Clot::UrlFilters
  include Clot::FormFilters
  include Liquid

  before(:each) do
    @context = {}    
  end


  context "form_item filter" do
    it "adds label to arbitrary data" do
      expected = "<p><label>hello there</label>form_item</p>"
      template = '{{"form_item" | form_item: "hello there" }}'
      template.should parse_to(expected)
    end

    it "includes 'required' class" do
      expected = '<p><label>hmm<span class="required">*</span></label>h2</p>'
      template = '{{"h2" | form_item: "hmm", true }}'
      template.should parse_to(expected)
    end

    it "populates 'for' attribute dwith contents of 'id' attribute" do
      expected = "<p><label for=\"item\">nyuk</label><i id=\"item\"></p>"
      template = '{{\'<i id="item">\' | form_item: "nyuk" }}'
      template.should parse_to(expected)
    end
  end
 
  context "the set_param filter" do
    it "should let you change params on an input" do
      expected = '<input dummy="ffgg" type="password" ilse="sss" />'
      template = '{{ \'<input dummy="ffgg" type="text" ilse="sss" />\' | set_param: "type", "password" }}'
      template.should parse_to(expected)
    end

    it "should let you add params to an input" do
      expected = '<input dummy="ffgg" ilse="sss"  type="password"/>'
      template = '{{ \'<input dummy="ffgg" ilse="sss" />\' | set_param: "type", "password" }}'
      template.should parse_to(expected)
    end

    it "should work on tags that are open" do
      expected = '<input dummy="ffgg" ilse="sss"  type="password">'
      template = '{{ \'<input dummy="ffgg" ilse="sss" >\' | set_param: "type", "password" }}'
      template.should parse_to(expected)
    end      
  end
  
  context "the submit_button filter" do
    it "converts text to submit button" do
      expected = '<div class="form-submit-button"><input type="submit" value="I am here"/></div>'
      template = '{{ "I am here" | submit_button }}'
      template.should parse_to(expected)
    end

    it "it converts object with id into string 'Update'" do
      expected = '<div class="form-submit-button"><input type="submit" value="Update"/></div>'
      template = '{{ user | submit_button }}'
      user = mock_drop user_default_values
      template.should parse_with_vars_to(expected, 'user' => user)
    end

    it "it converts object without id into string 'Create'" do
      expected = '<div class="form-submit-button"><input type="submit" value="Create"/></div>'
      template = '{{ user | submit_button }}'
      user = mock_drop user_default_values
      user.stub!(:id).and_return(0)
      template.should parse_with_vars_to(expected, 'user' => user)
    end

  end
  
  context "the get_attribute_value filter" do
    specify "should return the value for the attribute of an open tag" do
      value = get_attribute_value "attribute", '<tag attribute="value">'
      value.should == "value"
    end
    specify "should return the value for the attribute of a closed tag" do
      value = get_attribute_value "attribute", '<tag attribute="value"/>'
      value.should == "value"
    end
  end

  context "the drop_class_to_table_item filter" do
    specify "should return the table item that matches the drop" do
      class DummyClassDrop
        def self.name
          "DummyClassDrop"
        end
      end
      table_item = drop_class_to_table_item DummyClassDrop
      table_item.should == "dummy_class"
    end
  end

  context "the get_id_from_name filter" do
    specify "should convert bracket form to regular form" do
      id =  get_id_from_name "a_b_c[d]"
      id.should == "a_b_c_d"
    end
  end

  context "the concat filter" do
    specify "should concatinate two strings" do
      string1 = "string1"
      string2 = "string2"
      concatted = concat(string1,string2)
      concatted.should == "string1string2"
    end
  end

  context "input_to_text translates to text area" do
      specify "converting value attribute to text contents" do
        expected = '<textarea>HELLO</textarea>'
        template = '{{ \'<input type="text" value="HELLO" />\' | input_to_text }}'
        template.should parse_to(expected)
      end

      specify "keeping other attributes" do
        expected = '<textarea name="g-luv"></textarea>'
        template = '{{ \'<input type="text" name="g-luv" />\' | input_to_text }}'
        template.should parse_to(expected)
      end

  end


  context "form_file_item filter" do
   specify "creates an item based on inputed name and ignores value" do
     item = form_file_item("item[field]", nil )
     item.should == "<input type=\"file\" id=\"item_field\" name=\"item[field]\" />"
   end
  end


 context "form_input_item filter" do
   specify "creates an item based on inputed value and name" do
     item = form_input_item("item[field]", "value", nil )
     item.should == "<input type=\"text\" id=\"item_field\" name=\"item[field]\" value=\"value\"/>"
   end

   specify "sets error class if there is an error" do
     item = form_input_item("item[field]", "value", true )
     item.should == "<input type=\"text\" id=\"item_field\" name=\"item[field]\" value=\"value\" class=\"error-item\"/>"
   end

 end

 context "the form_text_item filter" do
   specify "creates an item based on inputed value and name" do
     item = form_text_item "item[field]", "value", nil
     item.should == "<textarea id=\"item_field\" name=\"item[field]\">value</textarea>"
   end

   specify "sets error class if there is an error" do
     item = form_text_item "item[field]", "value", true
     item.should == "<textarea id=\"item_field\" name=\"item[field]\" class=\"error-item\">value</textarea>"      
   end

 end

  context "the form_select_item filter" do 
    specify "selects an item based on inputed value and name" do
      user_drop1 = mock_drop user_default_values
      user_drop2 = mock_drop user_default_values
      item = form_select_item "item[field]",  user_drop2.id, [user_drop1, user_drop2], nil
      item.should == "<select id=\"item_field\" name=\"item[field]\"><option value=\"#{user_drop1.id}\">#{user_drop1.collection_label}</option><option value=\"#{user_drop2.id}\" selected=\"true\">#{user_drop2.collection_label}</option></select>"
    end

    specify "selects an item based on inputted value and name when collection is used" do
      user_drop1 = mock_drop user_default_values
      user_drop2 = mock_drop user_default_values
      item = form_select_item "item[field]",  user_drop2.id, [user_drop1.id, user_drop2.id], nil
      item.should == "<select id=\"item_field\" name=\"item[field]\"><option value=\"#{user_drop1.id}\">#{user_drop1.id}</option><option value=\"#{user_drop2.id}\" selected=\"true\">#{user_drop2.id}</option></select>"
    end

    specify "supports blank option" do
      user_drop1 = mock_drop user_default_values
      user_drop2 = mock_drop user_default_values
      item = form_select_item "item[field]",  user_drop2.id, [user_drop1, user_drop2], nil, "blank data"
      item.should == "<select id=\"item_field\" name=\"item[field]\"><option>blank data</option><option value=\"#{user_drop1.id}\">#{user_drop1.collection_label}</option><option value=\"#{user_drop2.id}\" selected=\"true\">#{user_drop2.collection_label}</option></select>"
    end

    specify "creates an item based on inputed value and name" do
      user_drop1 = mock_drop user_default_values
      user_drop2 = mock_drop user_default_values
      item = form_select_item "item[field]", "value", [user_drop1, user_drop2], nil
      item.should == "<select id=\"item_field\" name=\"item[field]\"><option value=\"#{user_drop1.id}\">#{user_drop1.collection_label}</option><option value=\"#{user_drop2.id}\">#{user_drop2.collection_label}</option></select>"
    end

    specify "creates an item based on heterogeneous collection " do
      user_drop1 = mock_drop user_default_values
      collection = [1,"two"]
      item = form_select_item "item[field]", "value", collection, nil
      item.should == "<select id=\"item_field\" name=\"item[field]\"><option value=\"1\">1</option><option value=\"two\">two</option></select>"
    end

    specify "sets error class if there is an error" do
      user_drop1 = mock_drop user_default_values
      user_drop2 = mock_drop user_default_values
      item = form_select_item "item[field]", "value", [user_drop1, user_drop2], true
      item.should == "<select id=\"item_field\" name=\"item[field]\" class=\"error-item\"><option value=\"#{user_drop1.id}\">#{user_drop1.collection_label}</option><option value=\"#{user_drop2.id}\">#{user_drop2.collection_label}</option></select>"
    end
  end
   
end