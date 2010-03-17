require File.dirname(__FILE__) + '/spec_helper'

describe "tags for forms that use models" do
  include Clot::UrlFilters
  include Clot::FormFilters
  include Liquid


  def parse_form_tag_to(inner_code, hash = {})
      template = "{% formfor dummy %}#{@tag}{% endformfor %}"
      expected = %{<form method="POST" action="#{object_url @user}"><input type="hidden" name="_method" value="PUT"/>#{inner_code}</form>}
      template.should parse_with_vars_to(expected, hash.merge( 'dummy' => @user))
  end

  def tag_should_parse_to(expected, hash = {})
    @tag.should parse_with_vars_to(expected, hash.merge( 'dummy' => @user ))
  end
  
  before do
    @user = mock_drop user_default_values
  end

  context "for collection_select" do
    before do
      @user_drop1 = mock_drop user_default_values
      @user_drop2 = mock_drop user_default_values
      @user_list = [@user_drop1, @user_drop2]
      @roles = ['admin','user', 2, 3.4]
    end
    context "outside of form" do
      it "should be generated for a generic collection" do
        @tag = "{% collection_select dummy,'role',roles %}"
        tag_should_parse_to('<select id="dummy_role" name="dummy[role]"><option>admin</option><option>user</option><option>2</option><option>3.4</option></select>', 'roles' => @roles)

      end

      it "should be generated with selection for a generic collection" do
        @user.instance_eval do
          @liquid['role'] = "admin"
        end
        @tag = "{% collection_select dummy,'role',roles %}"
        tag_should_parse_to('<select id="dummy_role" name="dummy[role]"><option selected="selected">admin</option><option>user</option><option>2</option><option>3.4</option></select>', 'roles' => @roles)

      end
      context "with defaults for id/name" do
        it "should work with no match" do
          @tag = "{% collection_select dummy,'friend_id',users %}"
          tag_should_parse_to(%{<select id="dummy_friend_id" name="dummy[friend_id]"><option value="#{@user_drop1.id}">#{@user_drop1.name}</option><option value="#{@user_drop2.id}">#{@user_drop2.name}</option></select>}, 'users' => @user_list)
        end
        it "should work with a match" do
          @user.instance_eval "@liquid['friend_id'] = #{@user_drop1.id}"
          @tag = "{% collection_select dummy,'friend_id',users %}"
          tag_should_parse_to(%{<select id="dummy_friend_id" name="dummy[friend_id]"><option value="#{@user_drop1.id}" selected="selected">#{@user_drop1.name}</option><option value="#{@user_drop2.id}">#{@user_drop2.name}</option></select>}, 'users' => @user_list)
        end
      end
      context "setting values for id/name" do
        before do
          @user_drop1.instance_eval "@liquid['fun_id'] = 1"
          @user_drop2.instance_eval "@liquid['fun_id'] = 2"
        end

        it "should work with no match" do
          @tag = "{% collection_select dummy,'friend_id',users,'fun_id','email' %}"
          tag_should_parse_to(%{<select id="dummy_friend_id" name="dummy[friend_id]"><option value="1">#{@user_drop1.email}</option><option value="2">#{@user_drop2.email}</option></select>}, 'users' => @user_list)
        end
        it "should take prompt" do
          @tag = "{% collection_select dummy,'friend_id',users,'fun_id','email',prompt:'Gimme Love' %}"
          tag_should_parse_to(%{<select id="dummy_friend_id" name="dummy[friend_id]"><option value="">Gimme Love</option><option value="1">#{@user_drop1.email}</option><option value="2">#{@user_drop2.email}</option></select>}, 'users' => @user_list)
        end
        it "should work with a match" do
          @user.instance_eval "@liquid['friend_id'] = 1"
          @tag = "{% collection_select dummy,'friend_id',users,'fun_id','email' %}"
          tag_should_parse_to(%{<select id="dummy_friend_id" name="dummy[friend_id]"><option value="1" selected="selected">#{@user_drop1.email}</option><option value="2">#{@user_drop2.email}</option></select>}, 'users' => @user_list)
        end
      end


    end

  end

  context "for file_field" do
    context "outside of form" do
      it "should be generated" do
        @tag = "{% file_field dummy,'email' %}"
        tag_should_parse_to('<input id="dummy_email" name="dummy[email]" type="file" />')
      end

      it "should allow accept attribute" do
        @tag = "{% file_field dummy,'email', accept:'text/html'%}"
        tag_should_parse_to('<input accept="text/html" id="dummy_email" name="dummy[email]" type="file" />')
      end

      it "should allow class to be set" do
        @tag = "{% file_field dummy,'email',class:'file_input'  %}"
        tag_should_parse_to('<input class="file_input" id="dummy_email" name="dummy[email]" type="file" />')
      end
    end
  end


  context "for checkbox" do

    context "outside of form" do 
      it "should be generated with checked" do
        @tag = "{% check_box dummy,'admin' %}"
        tag_should_parse_to('<input name="dummy[admin]" type="hidden" value="0" /><input checked="checked" id="dummy_admin" name="dummy[admin]" type="checkbox" value="1" />')
      end

      it "should be generated without checked" do
        @tag = "{% check_box dummy,'banned' %}"
        tag_should_parse_to('<input name="dummy[banned]" type="hidden" value="0" /><input id="dummy_banned" name="dummy[banned]" type="checkbox" value="1" />')
      end

      it "should have alternate labels" do
        @tag = "{% check_box dummy,'admin','yes','no' %}"
        tag_should_parse_to('<input name="dummy[admin]" type="hidden" value="no" /><input checked="checked" id="dummy_admin" name="dummy[admin]" type="checkbox" value="yes" />')
      end
    end

    context "inside form" do
      it "should be generated with checked" do
        @tag = "{% check_box 'admin' %}"
        parse_form_tag_to('<input name="dummy[admin]" type="hidden" value="0" /><input checked="checked" id="dummy_admin" name="dummy[admin]" type="checkbox" value="1" />')
      end

      it "should be generated without checked" do
        @tag = "{% check_box 'banned' %}"
        parse_form_tag_to('<input name="dummy[banned]" type="hidden" value="0" /><input id="dummy_banned" name="dummy[banned]" type="checkbox" value="1" />')
      end
      
      it "should have alternate labels" do
        @tag = "{% check_box 'admin','yes','no',class:'eula_check' %}"
        parse_form_tag_to('<input name="dummy[admin]" type="hidden" value="no" /><input class="eula_check" checked="checked" id="dummy_admin" name="dummy[admin]" type="checkbox" value="yes" />')
      end
    end
  end

  context "for password_field" do
    context "inside of form" do
      it "should generate field with size" do
        @tag = "{% password_field 'password',size:20 %}"
        parse_form_tag_to(%{<input id="dummy_password" name="dummy[password]" size="20" type="password" value="#{@user.password}" />})
      end

      it "should generate field with class" do
        @tag = "{% password_field 'password',class:'form_input' %}"
        parse_form_tag_to(%{<input class="form_input" id="dummy_password" name="dummy[password]" type="password" value="#{@user.password}" />})
      end

      it "should generate field with onchange" do
        @tag = %{{% password_field 'password',onchange:"if $('user[password]').length > 30 { alert('Your password needs to be shorter!'); }" %}}
        parse_form_tag_to(%{<input id="dummy_password" name="dummy[password]" onchange="if $('user[password]').length > 30 { alert('Your password needs to be shorter!'); }" type="password" value="#{@user.password}" />})
      end

      it "should take multiple options" do
        @tag = %{{% password_field 'password',size:20,class:'form_input' %}}
        parse_form_tag_to(%{<input class="form_input" id="dummy_password" name="dummy[password]" size="20" type="password" value="#{@user.password}" />})
      end



=begin
      password_field(:account, :pin, :size => 20, :class => 'form_input')
      # => <input type="text" id="account_pin" name="account[pin]" size="20" value="#{@account.pin}" class="form_input" />

=end


    end

    

  end


  context "for label" do
    context "outside of form" do
      it "should render label for field" do
        @tag = "{% label dummy,'name' %}"
        tag_should_parse_to %{<label for="dummy_name">Name</label>}
      end
      it "should render humanized_label for field" do
        @tag = "{% label dummy,'supervising_boss_id' %}"
        tag_should_parse_to %{<label for="dummy_supervising_boss_id">Supervising boss</label>}
      end

      it "should have alternative titles" do
        @tag = "{% label dummy,'name', 'A short title' %}"
        tag_should_parse_to %{<label for="dummy_name">A short title</label>}
      end
      it "should take class" do
        @tag = "{% label dummy,'name', 'A short title',class:'title_label' %}"
        tag_should_parse_to %{<label class="title_label" for="dummy_name">A short title</label>}
      end

      it "should take value" do
        @tag = "{% label dummy,'name', 'A short title',value:'public' %}"
        tag_should_parse_to %{<label for="dummy_name_public">A short title</label>}
      end
    end
  end

  context "for text_area" do
    context "outside of form" do
      it "should take regular cols/rows" do
        @tag = "{% text_area dummy,'name',cols:20,rows:40 %}"
        tag_should_parse_to %{<textarea cols="20" id="dummy_name" name="dummy[name]" rows="40">#{@user.name}</textarea>}
      end      
      it "should take regular size" do
        @tag = "{% text_area dummy,'name',size:'20x40' %}"
        tag_should_parse_to %{<textarea cols="20" id="dummy_name" name="dummy[name]" rows="40">#{@user.name}</textarea>}
      end
      it "should take class and disabled" do
        @tag = "{% text_area dummy,'name',class:'app_input',disabled:'disabled' %}"
        tag_should_parse_to %{<textarea disabled="disabled" class="app_input" id="dummy_name" name="dummy[name]">#{@user.name}</textarea>}
      end
    end
  end

  context "for text_field" do
    context "outside of form" do
      it "should take regular name" do
        @tag = "{% text_field dummy,'name' %}"
        tag_should_parse_to %{<input id="dummy_name" name="dummy[name]" type="text" value="#{@user.name}" />}
      end
      it "should take regular name and size attribute" do
        @tag = "{% text_field dummy,'name',size:20 %}"
        tag_should_parse_to %{<input id="dummy_name" name="dummy[name]" size="20" type="text" value="#{@user.name}" />}
      end
      it "should take regular name and class attribute" do
        @tag = "{% text_field dummy,'name',class:'create_input' %}"
        tag_should_parse_to %{<input class="create_input" id="dummy_name" name="dummy[name]" type="text" value="#{@user.name}" />}
      end
      it "should take regular name and onchange attribute" do
        @tag = "{% text_field dummy,'name',onchange:\"if $('session[user]').value == 'admin' { alert('Your login can not be admin!'); }\" %}"
        tag_should_parse_to %{<input id="dummy_name" name="dummy[name]" onchange="if $('session[user]').value == 'admin' { alert('Your login can not be admin!'); }" type="text" value="#{@user.name}" />}
      end
      it "should take multiple attributes" do
        @tag = "{% text_field dummy,'name',size:20,class:'create_input' %}"
        tag_should_parse_to %{<input class="create_input" id="dummy_name" name="dummy[name]" size="20" type="text" value="#{@user.name}" />}
      end
    end

    context "inside of form" do
      it "should take regular name" do
        @tag = "{% text_field 'name' %}"
        parse_form_tag_to %{<input id="dummy_name" name="dummy[name]" type="text" value="#{@user.name}" />}
      end
      it "should take regular name and attribute" do
        @tag = "{% text_field 'name',size:20 %}"
        parse_form_tag_to %{<input id="dummy_name" name="dummy[name]" size="20" type="text" value="#{@user.name}" />}
      end
      it "should take regular name and multiple attributes" do
        @tag = "{% text_field 'name',size:20,class:'code_input' %}"
        parse_form_tag_to %{<input class="code_input" id="dummy_name" name="dummy[name]" size="20" type="text" value="#{@user.name}" />}
      end
    end

  end



end