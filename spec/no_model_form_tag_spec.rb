require File.dirname(__FILE__) + '/spec_helper'

describe "tags for forms that don't use models" do
  context "for submit_tag" do
    it "should work without label" do
      tag = "{% submit_tag %}"
      tag.should parse_to('<input type="submit" name="commit" value="Save changes" />')
    end

    it "should take label" do
      tag = "{% submit_tag 'Save' %}"
      tag.should parse_to('<input type="submit" name="commit" value="Save" />')
    end

    it "should take parse information from environment" do
      user = get_drop user_default_values
      tag = "{% submit_tag user.name %}"
      tag.should parse_with_vars_to(%{<input type="submit" name="commit" value="#{user.name}" />}, 'user' => user)
    end

    it "should take name of nil" do
      tag = "{% submit_tag 'Save',name:nil %}"
      tag.should parse_to('<input type="submit" value="Save" />')
    end

    it "should take label from variable" do
      tag = "{% submit_tag save_var %}"
      tag.should parse_with_vars_to('<input type="submit" name="commit" value="Save Me!" />', 'save_var' => 'Save Me!')
    end

    it "should be able to be disabled" do
      tag = "{% submit_tag 'Save edits',disabled:true %}"
      tag.should parse_to('<input disabled="disabled" type="submit" name="commit" value="Save edits" />')
    end

    it "should be able to have class applied" do
      tag = "{% submit_tag '',class:'form_submit' %}"
      tag.should parse_to('<input class="form_submit" type="submit" name="commit" value="" />')
    end

    it "should support disable_with" do
      tag = "{% submit_tag 'Edit',disable_with:'Editing...',class:'edit-button' %}"
      tag.should parse_to(%{<input class="edit-button" onclick="this.disabled=true;this.value='Editing...';this.form.submit();" type="submit" name="commit" value="Edit" />})
    end

  end

  context "for hidden_field_tag" do
    it "generates basic tag" do
      tag = "{% hidden_field_tag 'tags_list' %}"
      tag.should parse_to('<input id="tags_list" name="tags_list" type="hidden" />')
    end

    it "generates basic tag with value" do
      tag = "{% hidden_field_tag 'token','VUBJKB23UIVI1UU1VOBVI@' %}"
      tag.should parse_to('<input id="token" name="token" type="hidden" value="VUBJKB23UIVI1UU1VOBVI@" />')
    end

    it "trims whitespace near commas" do
      tag = "{% hidden_field_tag \"token\" , \"VUBJKB23UIVI1UU1VOBVI@\" %}"
      tag.should parse_to('<input id="token" name="token" type="hidden" value="VUBJKB23UIVI1UU1VOBVI@" />')
    end

    it "can have onchange attribute" do
      tag = "{% hidden_field_tag 'collected_input','',onchange:\"alert('Input collected!')\" %}"
      tag.should parse_to(%{<input id="collected_input" name="collected_input" onchange="alert('Input collected!')" type="hidden" value="" />})
    end
  
  end

  context "for select_tag" do
    it "should use single option" do
      tag = "{% select_tag 'people','<option>David</option>' %}"
      tag.should parse_to('<select id="people" name="people"><option>David</option></select>');
    end

    it "should take prompt" do
      tag = "{% select_tag 'people','<option>David</option>', prompt:'Gimme love' %}"
      tag.should parse_to('<select id="people" name="people"><option value="">Gimme love</option><option>David</option></select>');
    end
    

    it "should use multiple options" do
      tag = "{% select_tag 'count','<option>1</option><option>2</option><option>3</option><option>4</option>' %}"
      tag.should parse_to('<select id="count" name="count"><option>1</option><option>2</option><option>3</option><option>4</option></select>');
    end

    it "should allow multiple selections" do
      tag = "{% select_tag 'colors','<option>Red</option><option>Green</option><option>Blue</option>',multiple:'true' %}"
      tag.should parse_to('<select id="colors" multiple="multiple" name="colors[]"><option>Red</option><option>Green</option><option>Blue</option></select>');

    end

    it "should have selected options" do
      tag = %{{% select_tag 'locations','<option>Home</option><option selected="selected">Work</option><option>Out</option>' %}}
      tag.should parse_to(%{<select id="locations" name="locations"><option>Home</option><option selected="selected">Work</option><option>Out</option></select>})
    end

    it "should allow the setting of classes and multiple selections" do
      tag = %{{% select_tag 'access','<option>Read</option><option>Write</option>',multiple:'true',class:'form_input' %}}
      tag.should parse_to('<select class="form_input" id="access" multiple="multiple" name="access[]"><option>Read</option><option>Write</option></select>')
    end

    it "should allow disabled" do
      tag = "{% select_tag 'destination','<option>NYC</option><option>Paris</option><option>Rome</option>',disabled:true %}"
      tag.should parse_to('<select disabled="disabled" id="destination" name="destination"><option>NYC</option><option>Paris</option><option>Rome</option></select>')
    end
    
  end

  context "for text_area_tag" do

    it "should create text area" do
      tag = "{% text_area_tag 'post' %}"
      tag.should parse_to('<textarea id="post" name="post"></textarea>')
    end


    it "should create text area with input" do
      tag = "{% text_area_tag 'bio','This is my biography.' %}"
      tag.should parse_to('<textarea id="bio" name="bio">This is my biography.</textarea>')
    end

    it "should create text area with will cols and rows" do
      tag = "{% text_area_tag 'body',rows:10,cols:25 %}"
      tag.should parse_to('<textarea cols="25" id="body" name="body" rows="10"></textarea>')
    end

    it "should create text area with input" do
      tag = "{% text_area_tag 'body',size:'25x10' %}"
      tag.should parse_to('<textarea cols="25" id="body" name="body" rows="10"></textarea>')
    end    

    it "should set disabled" do
      tag = "{% text_area_tag 'description','Description goes here.',disabled:true %}"
      tag.should parse_to('<textarea disabled="disabled" id="description" name="description">Description goes here.</textarea>')
    end
    it "should set css class" do
      tag = "{% text_area_tag 'comment',class:'comment_input' %}"
      tag.should parse_to('<textarea class="comment_input" id="comment" name="comment"></textarea>')
    end
  end


  context "for file_field_tag" do
    it "should have generic name" do
      tag = "{% file_field_tag 'attachment' %}"
      tag.should parse_to('<input id="attachment" name="attachment" type="file" />')      
    end
    it "should have take css class" do
      tag = "{% file_field_tag 'avatar',class:'profile-input' %}"
      tag.should parse_to('<input class="profile-input" id="avatar" name="avatar" type="file" />')
    end
    it "should be able to be disabled" do
      tag = "{% file_field_tag 'picture',disabled:true %}"
      tag.should parse_to('<input disabled="disabled" id="picture" name="picture" type="file" />')
    end
    it "should be able to have values set" do
      tag = "{% file_field_tag 'resume',value:'~/resume.doc' %}"
      tag.should parse_to('<input id="resume" name="resume" type="file" value="~/resume.doc" />')
    end

    it "should take accept value" do
      tag = "{% file_field_tag 'user_pic',accept:'image/png%2Cimage/gif%2Cimage/jpeg' %}"
      tag.should parse_to('<input accept="image/png,image/gif,image/jpeg" id="user_pic" name="user_pic" type="file" />')
    end

    it "should take multiple values" do
      tag = "{% file_field_tag 'file',accept:'text/html',class:'upload',value:'index.html' %}"
      tag.should parse_to('<input accept="text/html" class="upload" id="file" name="file" type="file" value="index.html" />')
    end 
  end

  context "for text_field_tag" do
    it "should take regular name" do
      tag = "{% text_field_tag 'name' %}"
      tag.should parse_to('<input id="name" name="name" type="text" />')
    end

    it "should take other value" do
      tag = "{% text_field_tag 'query','Enter your search query here' %}"
      tag.should parse_to('<input id="query" name="query" type="text" value="Enter your search query here" />')
    end

    it "can take css class and leave off value" do
      tag = "{% text_field_tag 'request',class:'special_input' %}"
      tag.should parse_to('<input class="special_input" id="request" name="request" type="text" />')
    end

    it "can take size parameter and blank value" do
      tag = "{% text_field_tag 'address','',size:75 %}"
      tag.should parse_to('<input id="address" name="address" size="75" type="text" value="" />')
    end

    it "can take maxlength" do
      tag = "{% text_field_tag 'zip',maxlength:5 %}"
      tag.should parse_to('<input id="zip" maxlength="5" name="zip" type="text" />')
    end

    it "can take disabled option" do
      tag = "{% text_field_tag 'payment_amount','$0.00',disabled:true %}"
      tag.should parse_to('<input disabled="disabled" id="payment_amount" name="payment_amount" type="text" value="$0.00" />')      
    end

    it "can take multiple options" do
      tag = "{% text_field_tag 'ip','0.0.0.0',maxlength:15,size:20,class:'ip-input' %}"
      tag.should parse_to('<input class="ip-input" id="ip" maxlength="15" name="ip" size="20" type="text" value="0.0.0.0" />')
    end
    
  end

  context "for password_field_tag" do
    it "should generate regular password tag" do
      tag = "{% password_field_tag 'pass' %}"
      tag.should parse_to('<input id="pass" name="pass" type="password" />')
    end

    it "should have alernate value" do
      tag = "{% password_field_tag 'secret', 'Your secret here' %}"
      tag.should parse_to('<input id="secret" name="secret" type="password" value="Your secret here" />')
    end

    it "should take class" do
      tag = "{% password_field_tag 'masked', class:'masked_input_field' %}"
      tag.should parse_to('<input class="masked_input_field" id="masked" name="masked" type="password" />')
    end

    it "should take size" do
      tag = "{% password_field_tag 'token','', size:15 %}"
      tag.should parse_to('<input id="token" name="token" size="15" type="password" value="" />')
    end

    it "should take maxlength" do
      tag = "{% password_field_tag 'key', maxlength:16 %}"
      tag.should parse_to('<input id="key" maxlength="16" name="key" type="password" />')
    end


    it "should take disabled option" do
      tag = "{% password_field_tag 'confirm_pass', disabled:true %}"
      tag.should parse_to('<input disabled="disabled" id="confirm_pass" name="confirm_pass" type="password" />')
    end

    it "should take multiple options" do
      tag = "{% password_field_tag 'pin', '1234',maxlength:4,size:6, class:'pin-input' %}"
      tag.should parse_to('<input class="pin-input" id="pin" maxlength="4" name="pin" size="6" type="password" value="1234" />')
    end
      
  end

  context "for label_tag" do
    it "assigns default value" do
      tag = "{% label_tag 'name' %}"
      tag.should parse_to('<label for="name">Name</label>')
    end
    it "assigns humanized default value" do
      tag = "{% label_tag 'supervising_boss_id' %}"
      tag.should parse_to('<label for="supervising_boss_id">Supervising boss</label>')
    end
    it "allows alternative value" do
      tag = "{% label_tag 'name', 'Your Name' %}"
      tag.should parse_to('<label for="name">Your Name</label>')
    end
    it "allows class to be assigned" do
      tag = "{% label_tag 'name',class:'small_label' %}"
      tag.should parse_to('<label class="small_label" for="name">Name</label>')
    end
  end

  context "for check_box_tag" do

    it "should generate basic checkbox" do
      tag = "{% check_box_tag 'accept' %}"
      tag.should parse_to('<input id="accept" name="accept" type="checkbox" value="1" />')
    end

    it "should take alternate values" do
      tag = "{% check_box_tag 'rock', 'rock music' %}"
      tag.should parse_to('<input id="rock" name="rock" type="checkbox" value="rock music" />')
    end
    
    it "should take parameter for checked" do
      tag = "{% check_box_tag 'receive_email', 'yes', true %}"
      tag.should parse_to('<input checked="checked" id="receive_email" name="receive_email" type="checkbox" value="yes" />')
    end

    it "should take class" do
      tag = "{% check_box_tag 'tos','yes',false,class:'accept_tos' %}"
      tag.should parse_to('<input class="accept_tos" id="tos" name="tos" type="checkbox" value="yes" />')
    end

    it "should let leave off checked param" do
      tag = "{% check_box_tag 'tos','yes',class:'accept_tos' %}"
      tag.should parse_to('<input class="accept_tos" id="tos" name="tos" type="checkbox" value="yes" />')
    end

    it "should let be disabled" do
      tag = "{% check_box_tag 'eula','accepted',disabled:true %}"
      tag.should parse_to('<input disabled="disabled" id="eula" name="eula" type="checkbox" value="accepted" />')
    end

    context "when based on bare inclusions" do
      before do
        @tag = "{% check_box_tag 'hi', collection:array,member:2 %}"
      end

      it "should check if included" do
        array = [1,2,3]
        @tag.should parse_with_vars_to('<input checked="checked" id="hi" name="hi" type="checkbox" value="1" />',
                                      'array' => array)
      end
      it "should not check if not included" do
        array = [1,3]
        @tag.should parse_with_vars_to('<input id="hi" name="hi" type="checkbox" value="1" />',
                                      'array' => array)
      end
    end

    context "when multiple tags are listed" do
      it "should behave with them like a group" do
        @tag = "{% check_box_tag 'hi', collection:array,member:1 %}{% check_box_tag 'hi', collection:array,member:2 %}{% check_box_tag 'hi', collection:array,member:3 %}"
        array = [1,3]
        @tag.should parse_with_vars_to('<input checked="checked" id="hi" name="hi" type="checkbox" value="1" /><input id="hi" name="hi" type="checkbox" value="1" /><input checked="checked" id="hi" name="hi" type="checkbox" value="1" />',
                                      'array' => array)
      end


    end


  end

end