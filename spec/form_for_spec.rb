require File.dirname(__FILE__) + '/spec_helper'

describe "Form For" do

  include Clot::UrlFilters
  include Clot::FormFilters
  include Liquid

  before(:each) do
    @context = {}    
  end


  context "edit form" do
    it "should be have hidden method of PUT" do
      text_drop = mock_drop @@text_content_default_values
      expected = '<form method="POST" action="' + (object_url text_drop) + '"><input type="hidden" name="_method" value="PUT"/></form>'
      template = '{% formfor text %}{% endformfor %}'
      template.should parse_with_atributes_to(expected, 'text' => text_drop)
    end
  end

  context "when selecting an alternate method" do
    it "should post to that method" do
      text_drop = mock_drop @@text_content_default_values
      expected = '<form method="POST" action="' + (object_url text_drop) + '/no_no_no"></form>'
      template = '{% formfor text post_method:no_no_no %}{% endformfor %}'
      template.should parse_with_atributes_to(expected, 'text' => text_drop)
    end
  end


  context "when using a field * item" do
    it "should produce data based on form type" do
      user_drop = get_drop @@user_default_values
      expected = '<form method="POST" action="' + (object_url user_drop) + '"><input type="hidden" name="_method" value="PUT"/><input type="text" id="liquid_demo_model_login" name="liquid_demo_model[login]" value="' + user_drop.login + '"/></form>'
      template = '{% formfor liquid_demo_model %}{% field :login %}{% endformfor %}'
      template.should parse_with_atributes_to(expected, 'liquid_demo_model' => user_drop)
    end

    it "should dynamically create an input box" do
      expected = '<form method="POST" action="/liquid_demo_model_drops/"><input type="text" id="liquid_demo_model_drop_name" name="liquid_demo_model_drop[name]" value="My Name"/></form>'
      template = '{% formfor liquid_demo_model_drop obj_class:liquid_demo_model_drops %}{% field :name %}{% endformfor %}'
      template.should parse_to(expected)
    end    

    it "should set the tags appropriately" do
      expected = '<form method="POST" action="/liquid_demo_model_drops/"><br/><input type="text" id="liquid_demo_model_drop_name" name="liquid_demo_model_drop[name]" value="My Name"/><hr/></form>'
      template = '{% formfor liquid_demo_model_drop obj_class:liquid_demo_model_drops %}<br/>{% field :name %}<hr/>{% endformfor %}'
      template.should parse_to(expected)
    end

    it "should set params on  input box" do
      expected = '<form method="POST" action="/liquid_demo_model_drops/"><input type="text" id="liquid_demo_model_drop_name" name="liquid_demo_model_drop[name]" value="My Name" width="100"/></form>'
      template = '{% formfor liquid_demo_model_drop obj_class:liquid_demo_model_drops %}{% field :name, width:100 %}{% endformfor %}'
      template.should parse_to(expected)
    end

  end

  context "when using a file * item" do
    it "should dynamically create a file upload box" do
      expected = '<form method="POST" action="/liquid_demo_model_drops/"><input type="file" id="liquid_demo_model_drop_name" name="liquid_demo_model_drop[name]" /></form>'
      template = '{% formfor liquid_demo_model_drop obj_class:liquid_demo_model_drops %}{% file :name %}{% endformfor %}'
      template.should parse_to(expected)
    end
  end

  context "when using a text * item" do
    it "should dynamically create a text box" do
      expected = '<form method="POST" action="/liquid_demo_model_drops/"><textarea id="liquid_demo_model_drop_name" name="liquid_demo_model_drop[name]">My Name</textarea></form>'
      template = '{% formfor liquid_demo_model_drop obj_class:liquid_demo_model_drops %}{% text :name %}{% endformfor %}'
      template.should parse_to(expected)
    end
  end

  context "when using a select * item" do
    it "should dynamically create a select option" do
      class LiquidDemoModelDrop
        def friend_id
          1
        end
      end

      user_drop1 = get_drop @@user_default_values
      user_drop2 = get_drop @@user_default_values.merge(:id => 2)
      expected = '<form method="POST" action="/liquid_demo_model_drops/"><select id="liquid_demo_model_drop_friend_id" name="liquid_demo_model_drop[friend_id]">'
      expected += "<option value=\"#{user_drop1.id}\" selected=\"true\">#{user_drop1.collection_label}</option><option value=\"#{user_drop2.id}\">#{user_drop2.collection_label}</option></select></form>"
      template = '{% formfor liquid_demo_model_drop obj_class:liquid_demo_model_drops %}{% select :friend_id, :users %}{% endformfor %}'
      template.should parse_with_atributes_to(expected, 'user' => user_drop1, 'users' => [user_drop1, user_drop2])
    end
  end

  context "edit form" do
    it "should allow you to apply a css class" do
      user_drop = get_drop @@user_default_values
      expected = '<form method="POST" class="tester" action="' + (object_url user_drop) + '"><input type="hidden" name="_method" value="PUT"/></form>'
      template = '{% formfor user class:tester %}{% endformfor %}'
      template.should parse_with_atributes_to(expected, 'user' => user_drop)
    end
  end

  context "when creating form items outside of the form" do
    specify "they should be out of the form's scope and raise error" do
      user_drop = get_drop @@user_default_values
      template = '{% formfor user class:tester %}{% endformfor %}{% field :login %}'
      lambda { Liquid::Template.parse(template).render 'user' => user_drop }.should raise_error
    end
  end



  context "when a form has errors" do
    before(:each) do
      @user_drop = get_drop @@user_default_values
      @user_drop.stub!(:errors).and_return(ActiveRecord::Errors.new(@user_drop))
    end

    it "should show generic error for drop" do
      @user_drop.errors.add("error")
      expected = '<form method="POST" class="tester" action="' + (object_url @user_drop) + '"><input type="hidden" name="_method" value="PUT"/><div id="error-explanation"><h2>1 error(s) occurred while processing information</h2><ul><li>error - is invalid</li></ul></div></form>'
      template = '{% formfor user class:tester %}{% endformfor %}'
      template.should parse_with_atributes_to(expected, 'user' => @user_drop)
    end

    it "should show error around relevant form item" do
      @user_drop.errors.add("login", "login already used")
      expected = '<form method="POST" class="tester" action="' + (object_url @user_drop) + '"><input type="hidden" name="_method" value="PUT"/><div id="error-explanation"><h2>1 error(s) occurred while processing information</h2><ul><li>login - login already used</li></ul></div><input type="text" id="liquid_demo_model_login" name="liquid_demo_model[login]" value="' + @user_drop[:login] + '" class="error-item"/></form>'
      template = '{% formfor user class:tester %}{% field :login %}{% endformfor %}'
      template.should parse_with_atributes_to(expected, 'user' => @user_drop)
    end

    it "should show multiple errors for multiple categories" do
      @user_drop.errors.add("error")
      @user_drop.errors.add("login", "login already used")
      @user_drop.errors.add("login", "login too short")
      expected = '<form method="POST" class="tester" action="' + (object_url @user_drop) + '"><input type="hidden" name="_method" value="PUT"/><div id="error-explanation"><h2>3 error(s) occurred while processing information</h2><ul><li>login - login already used</li><li>login - login too short</li><li>error - is invalid</li></ul></div><input type="text" id="liquid_demo_model_login" name="liquid_demo_model[login]" value="' + @user_drop[:login] + '" class="error-item"/></form>'
      template = '{% formfor user class:tester %}{% field :login %}{% endformfor %}'
      template.should parse_with_atributes_to(expected, 'user' => @user_drop)
    end
  end

end