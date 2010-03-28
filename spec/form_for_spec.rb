require File.dirname(__FILE__) + '/spec_helper'

describe "Form For" do

  include Clot::UrlFilters
  include Clot::FormFilters
  include Liquid

    before do
      @new_drop = get_drop empty_default_values
    end  

  context "edit form" do
    it "should be have hidden method of PUT" do
      text_drop = mock_drop text_content_default_values
      expected = '<form method="POST" action="' + (object_url text_drop) + '"><input type="hidden" name="_method" value="PUT"/></form>'
      template = '{% formfor text %}{% endformfor %}'
      template.should parse_with_vars_to(expected, 'text' => text_drop)
    end
  end

  context "when selecting an alternate method" do
    it "should post to that method" do
      text_drop = mock_drop text_content_default_values
      expected = '<form method="POST" action="' + (object_url text_drop) + '/no_no_no"></form>'
      template = '{% formfor text post_method:no_no_no %}{% endformfor %}'
      template.should parse_with_vars_to(expected, 'text' => text_drop)
    end
  end

  context "when putting in a parent object" do
    it "should be have hidden method of PUT" do
      user_drop = get_drop user_default_values
      text_drop = mock_drop text_content_default_values
      expected = '<form method="POST" action="' + (object_url user_drop) + (object_url text_drop) + '"><input type="hidden" name="_method" value="PUT"/></form>'
      template = '{% formfor text parent:user %}{% endformfor %}'
      template.should parse_with_vars_to(expected, 'text' => text_drop, 'user' => user_drop)
    end
  end

  context "when using a field * item" do
    it "should produce data based on form type" do
      user_drop = get_drop user_default_values
      expected = '<form method="POST" action="' + (object_url user_drop) + '"><input type="hidden" name="_method" value="PUT"/><input id="liquid_demo_model_login" name="liquid_demo_model[login]" type="text" value="' + user_drop.login + '" /></form>'
      template = '{% formfor liquid_demo_model %}{% text_field "login" %}{% endformfor %}'
      template.should parse_with_vars_to(expected, 'liquid_demo_model' => user_drop)
    end

    it "should dynamically create an input box" do

      expected = '<form method="POST" action="/liquid_demo_models/"><input id="liquid_demo_model_name" name="liquid_demo_model[name]" type="text" value="" /></form>'
      template = '{% formfor liquid_demo_model_drop %}{% text_field "name" %}{% endformfor %}'
      template.should parse_with_vars_to(expected, 'liquid_demo_model_drop' => @new_drop)
    end

    it "should set the tags appropriately" do
      expected = '<form method="POST" action="/liquid_demo_models/"><br/><input id="liquid_demo_model_name" name="liquid_demo_model[name]" type="text" value="" /><hr/></form>'
      template = '{% formfor liquid_demo_model_drop %}<br/>{% text_field "name" %}<hr/>{% endformfor %}'
      template.should parse_with_vars_to(expected, 'liquid_demo_model_drop' => @new_drop)
    end

    it "should set params on  input box" do
      expected = '<form method="POST" action="/liquid_demo_models/"><input id="liquid_demo_model_name" name="liquid_demo_model[name]" width="100" type="text" value="" /></form>'
      template = '{% formfor liquid_demo_model_drop  %}{% text_field "name", width:100 %}{% endformfor %}'
      template.should parse_with_vars_to(expected, 'liquid_demo_model_drop' => @new_drop)
    end

  end

  context "when using a file * item" do
    it "should dynamically create a file upload box" do
      expected = '<form method="POST" action="/liquid_demo_models/"><input id="liquid_demo_model_name" name="liquid_demo_model[name]" type="file" /></form>'
      template = '{% formfor drop  %}{% file_field "name" %}{% endformfor %}'
      template.should parse_with_vars_to(expected, 'drop' => @new_drop)
    end
  end

  context "when using a text * item" do
    it "should dynamically create a text box" do
      expected = '<form method="POST" action="/liquid_demo_models/"><textarea id="liquid_demo_model_name" name="liquid_demo_model[name]"></textarea></form>'
      template = '{% formfor drop %}{% text_area "name" %}{% endformfor %}'
      template.should parse_with_vars_to(expected, 'drop' => @new_drop)
    end
  end

  context "when using a select * item" do
    it "should dynamically create a select option" do
      user_drop1 = mock_drop user_default_values.merge(:friend_id => 2)
      user_drop2 = mock_drop user_default_values.merge(:id => 2)

      expected = '<form method="POST" action="/nil_classes/' + user_drop1.id.to_s + '"><input type="hidden" name="_method" value="PUT"/><select id="dummy_friend_id" name="dummy[friend_id]">'
      expected += "<option value=\"#{user_drop1.id}\">#{user_drop1.email}</option><option value=\"#{user_drop2.id}\" selected=\"selected\">#{user_drop2.email}</option></select></form>"
      template = '{% formfor user %}{% collection_select "friend_id", users, "id", "email" %}{% endformfor %}'
      template.should parse_with_vars_to(expected, 'user' => user_drop1, 'users' => [user_drop1, user_drop2])
    end

    it "should dynamically create a select based on array" do
      user_drop1 = mock_drop user_default_values.merge(:friend_id => 1)
      expected = '<form method="POST" action="/nil_classes/' + user_drop1.id.to_s + '"><input type="hidden" name="_method" value="PUT"/><select id="dummy_friend_id" name="dummy[friend_id]">'
      expected += "<option selected=\"selected\">1</option><option>two</option></select></form>"
      template = '{% formfor user %}{% collection_select "friend_id", options %}{% endformfor %}'
      template.should parse_with_vars_to(expected, 'user' => user_drop1, 'options' => [1, "two"])
    end

    it "should dynamically create a select based on resolved array" do
      user_drop1 = mock_drop user_default_values.merge(:friend_id => 1)
      expected = '<form method="POST" action="/nil_classes/' + user_drop1.id.to_s + '"><input type="hidden" name="_method" value="PUT"/><select id="dummy_friend_id" name="dummy[friend_id]">'
      expected += "<option selected=\"selected\">1</option><option>two</option></select></form>"
      template = '{% formfor user %}{% collection_select "friend_id", [1 "two"] %}{% endformfor %}'
      template.should parse_with_vars_to(expected, 'user' => user_drop1)
    end

    it "should allow a prompt" do
      user_drop1 = mock_drop user_default_values.merge(:friend_id => 2)
      user_drop2 = mock_drop user_default_values.merge(:id => 2)

      expected = '<form method="POST" action="/nil_classes/'+ user_drop1.id.to_s + '"><input type="hidden" name="_method" value="PUT"/><select id="dummy_friend_id" name="dummy[friend_id]">'
      expected += "<option value=\"\">nada to see</option>"
      expected += "<option value=\"#{user_drop1.id}\">#{user_drop1.email}</option><option value=\"#{user_drop2.id}\" selected=\"selected\">#{user_drop2.email}</option></select></form>"
      template = '{% formfor user %}{% collection_select "friend_id", users,"id","email",prompt:"nada to see" %}{% endformfor %}'
      template.should parse_with_vars_to(expected, 'user' => user_drop1, 'users' => [user_drop1, user_drop2])
    end

  end

  context "edit form" do
    it "should allow you to apply a css class" do
      user_drop = get_drop user_default_values
      expected = '<form method="POST" class="tester" action="' + (object_url user_drop) + '"><input type="hidden" name="_method" value="PUT"/></form>'
      template = '{% formfor user class:tester %}{% endformfor %}'
      template.should parse_with_vars_to(expected, 'user' => user_drop)
    end
  end

  context "when creating form items outside of the form" do
    specify "they should be out of the form's scope and raise error" do
      user_drop = get_drop user_default_values
      template = '{% formfor user class:tester %}{% endformfor %}{% field :login %}'
      lambda { Liquid::Template.parse(template).render 'user' => user_drop }.should raise_error
    end
  end



  context "when a form has errors" do
    before(:each) do
      @user_drop = get_drop user_default_values
      @user_drop.stub!(:errors).and_return(ActiveRecord::Errors.new(@user_drop))
    end

    it "should show generic error for drop" do
      @user_drop.errors.add("error")
      expected = '<div class="errorExplanation" id="errorExplanation"><h2>1 error occurred while processing information</h2><ul><li>error - is invalid</li></ul></div><form method="POST" class="tester" action="' + (object_url @user_drop) + '"><input type="hidden" name="_method" value="PUT"/></form>'
      template = '{% error_messages_for user %}{% formfor user class:tester %}{% endformfor %}'
      template.should parse_with_vars_to(expected, 'user' => @user_drop)
    end

    it "should allow different message" do
      @user_drop.errors.add("error")
      expected = '<div class="errorExplanation" id="errorExplanation"><h2>foo</h2><ul><li>error - is invalid</li></ul></div><form method="POST" class="tester" action="' + (object_url @user_drop) + '"><input type="hidden" name="_method" value="PUT"/></form>'
      template = '{% error_messages_for user,header_message:"foo" %}{% formfor user class:tester %}{% endformfor %}'
      template.should parse_with_vars_to(expected, 'user' => @user_drop)
    end

    it "should show error around relevant form item" do
      @user_drop.errors.add("login", "login already used")
      expected = '<div class="errorExplanation" id="errorExplanation"><h2>1 error occurred while processing information</h2><ul><li>login - login already used</li></ul></div><form method="POST" class="tester" action="' + (object_url @user_drop) + '"><input type="hidden" name="_method" value="PUT"/><div class="fieldWithErrors"><label for="liquid_demo_model_login">Login</label></div><div class="fieldWithErrors"><input id="liquid_demo_model_login" name="liquid_demo_model[login]" type="text" value="' + @user_drop[:login] + '" /></div></form>'
      template = '{% error_messages_for user %}{% formfor user class:tester %}{% label "login" %}{% text_field "login" %}{% endformfor %}'
      template.should parse_with_vars_to(expected, 'user' => @user_drop)
    end

    it "should show multiple errors for multiple categories" do
      @user_drop.errors.add("error")
      @user_drop.errors.add("login", "login already used")
      @user_drop.errors.add("login", "login too short")
      expected = '<div class="errorExplanation" id="errorExplanation"><h2>3 errors occurred while processing information</h2><ul><li>error - is invalid</li><li>login - login already used</li><li>login - login too short</li></ul></div><form method="POST" class="tester" action="' + (object_url @user_drop) + '"><input type="hidden" name="_method" value="PUT"/><div class="fieldWithErrors"><input id="liquid_demo_model_login" name="liquid_demo_model[login]" type="text" value="' + @user_drop[:login] + '" /></div></form>'
      template = '{% error_messages_for user %}{% formfor user class:tester %}{% text_field "login" %}{% endformfor %}'
      template.should parse_with_vars_to(expected, 'user' => @user_drop)
    end
  end

end