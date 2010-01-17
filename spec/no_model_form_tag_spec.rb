require File.dirname(__FILE__) + '/spec_helper'

module Clot
  class TextFieldTag < Liquid::Tag
    include TagHelper

    def render(context)
      value_string = ""
      class_string = ""
      size_string = ""
      max_length_string = ""
      disabled_string = ""
      id_string = name_string = @params.shift

      if @params[0] && ! @params[0].match(/:/) 
        value_string = %{value="#{@params.shift}" }
      end
      @params.each do |pair|
        pair = pair.split /:/
        case pair[0]
          when "class"
            class_string = %{class="#{pair[1]}" }
          when "size"
            size_string = %{size="#{pair[1]}" }
          when "maxlength"
            max_length_string = %{maxlength="#{pair[1]}" }
          when "disabled"
            disabled_string = %{disabled="#{if (pair[1] == "true") then 'disabled' end}" }
        end

      end



      %{<input #{disabled_string}#{class_string}id="#{id_string}" #{max_length_string}name="#{name_string}" #{size_string}type="text" #{value_string}/>}
    end

    def initialize(name, params, tokens)
      @params = split_params(params)
      super
    end


  end



end


Liquid::Template.register_tag('text_field_tag', Clot::TextFieldTag)

describe "tags for forms that don't use models" do
  context "for text_field_tag" do
    it "should take regular name" do
      tag = "{% text_field_tag name %}"
      tag.should parse_to('<input id="name" name="name" type="text" />')
    end

    it "should take other value" do
      tag = "{% text_field_tag query,Enter your search query here %}"
      tag.should parse_to('<input id="query" name="query" type="text" value="Enter your search query here" />')
    end

    it "can take css class and leave off value" do
      tag = "{% text_field_tag request,class:special_input %}"
      tag.should parse_to('<input class="special_input" id="request" name="request" type="text" />')
    end

    it "can take size parameter and blank value" do
      tag = "{% text_field_tag address,,size:75 %}"
      tag.should parse_to('<input id="address" name="address" size="75" type="text" value="" />')
    end

    it "can take maxlength" do
      tag = "{% text_field_tag zip,maxlength:5 %}"
      tag.should parse_to('<input id="zip" maxlength="5" name="zip" type="text" />')
    end

    it "can take disabled option" do
      tag = "{% text_field_tag payment_amount,$0.00,disabled:true %}"
      tag.should parse_to('<input disabled="disabled" id="payment_amount" name="payment_amount" type="text" value="$0.00" />')      
    end

    it do
      tag = "{% text_field_tag ip,0.0.0.0,maxlength:15,size:20,class:ip-input %}"
      tag.should parse_to('<input class="ip-input" id="ip" maxlength="15" name="ip" size="20" type="text" value="0.0.0.0" />')
    end
  end
end