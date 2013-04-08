module Clot
  module ModelTag
    def set_primary_attributes(context)
      @item = context['form_model']
      if @item

        @attribute_name =  resolve_value(@params.shift,context)
        @first_attr = context['form_class_name']
      else
        @first_attr =  @params.shift

        if @params[0] && ! @params[0].match(/:/)
          @attribute_name =  resolve_value(@params.shift,context)
        end
        @item = context[@first_attr]
      end
      attribute_names = @attribute_name.split('.')

      unless @item.source.respond_to?(:"#{attribute_names[0]}=")
        raise "#{attribute_names[0]} is not a valid form field for #{@first_attr.camelize}."
      end

      if attribute_names.size == 3
        @name_string = @first_attr + "[" + attribute_names[0].to_s + "_attributes][" + attribute_names[1].to_s + "_attributes][" + attribute_names[2].to_s + "]"
        @id_string = @first_attr + "_" + attribute_names[0].to_s + "_attributes_" + attribute_names[1].to_s + "_" + attribute_names[2].to_s
        @value_string = ""
        if @item
          @subitem = @item[attribute_names[0]][attribute_names[1]]
          if @subitem
            @value_string = @subitem[attribute_names[2].to_sym]
          end
        end
      elsif attribute_names.size == 2
        @name_string = @first_attr + "[" + attribute_names[0].to_s + "_attributes][" + attribute_names[1].to_s + "]"
        @id_string = @first_attr + "_" + attribute_names.join('_')
        @value_string = ""
        if @item
          @subitem = @item[attribute_names[0]]
          if @subitem
            @value_string = @subitem[attribute_names[1].to_sym]
          end
        end
      else
        @id_string = "#{@first_attr}_#{@attribute_name}"
        @name_string = "#{@first_attr}[#{@attribute_name}]"
        @value_string = @item[@attribute_name.to_sym]
      end
      @errors = context['form_errors'] || []

      model = @item.source
      unless model.valid?
        if model.errors[@attribute_name.to_sym].present?
          @required = true
        end
      end



    end

    def render(context)
      result = super(context)
      #if @errors.include? @attribute_name
      #  result = "<div class=\"fieldWithErrors\">#{result}</div>"
      #end
      result
    end
  end

 class FileField < FileFieldTag
   include ModelTag

   def render_string
     @value_string = nil
     super
   end
 end

  class PasswordField < PasswordFieldTag
    include ModelTag
  end

  class TextField < TextFieldTag
    include ModelTag
  end

  class EmailField < EmailFieldTag
    include ModelTag
  end

  class PhoneField < PhoneFieldTag
    include ModelTag
  end

  class NumberField < NumberFieldTag
    include ModelTag
  end

  class TextArea < TextAreaTag
    include ModelTag
  end

  class Label < LabelTag
    include ModelTag

    def get_label_for(label)
      label.humanize
    end

    def set_primary_attributes(context)
      super context
      if @params[0] && ! @params[0].match(/:/)
        @value_string = resolve_value(@params.shift,context)
      else
        @value_string = get_label_for(@attribute_name)
      end
    end
  end

  class CollectionSelect < ClotTag
    include ModelTag
    def set_primary_attributes(context)
      super context
      if @params[0] && ! @params[0].match(/:/)
         @collection = resolve_value(@params.shift,context)
      end
      @default_id = 'id'
      @default_name = 'name'
      if @params[0] && ! @params[0].match(/:/)
         @default_id = resolve_value(@params.shift,context)
      end
      if @params[0] && ! @params[0].match(/:/)
         @default_name = resolve_value(@params.shift,context)
      end
    end

    def gen_option(item)
      selection_string = ""
      item_string = item
      value_string = ""

      # this line below is for BSON::ObjectId which doesn't respond to :id, but does :_id
      @default_id = "_id" if @default_id == 'id' and item.respond_to?(:_id)

      # @item = NationSignupDrop
      # item = NationPlan

      attribute_names = @attribute_name.split('.')

      if item.is_a?(String) || item.is_a?(Fixnum) || item.is_a?(Float)
        if (@item[@attribute_name.to_sym].to_s == item.to_s) || (@item.respond_to?(@attribute_name.to_sym) && @item.send(@attribute_name.to_sym).to_s == item.to_s)
          selection_string = ' selected="selected"'
        end
      else
        item_string = item[@default_name.to_sym] || (@item.respond_to?(@attribute_name.to_sym) && @item.send(@default_name.to_sym))
        value_string = %{ value="#{item[@default_id.to_sym]}"}
        if @item.class.to_s == "NationSignupDrop" and attribute_names.size == 3 and attribute_names[0] == 'payment_profile' # this is a special case just for 3dna nation signup mongo stuff
          if attribute_names[1] == 'billing_address'
            if item[@default_id.to_sym].to_s == @item.source.payment_profile.billing_address[attribute_names[2].to_sym].to_s
              selection_string = ' selected="selected"'
            end
          else
            if item[@default_id.to_sym].to_s == @item.source.payment_profile[attribute_names[1].to_sym][attribute_names[2].to_sym].to_s
              selection_string = ' selected="selected"'
            end
          end
        elsif attribute_names.size == 3
          if item[@default_id.to_sym].to_s == @item[attribute_names[0].to_sym][attribute_names[1].to_sym][attribute_names[2].to_sym].to_s
            selection_string = ' selected="selected"'
          end
        elsif attribute_names.size == 2
          if item[@default_id.to_sym].to_s == @item[attribute_names.first.to_sym][attribute_names.last.to_sym].to_s
            selection_string = ' selected="selected"'
          end
        else
          if item[@default_id.to_sym].to_s == @item[@attribute_name.to_sym].to_s
            selection_string = ' selected="selected"'
          end
        end
      end

      "<option#{value_string}#{selection_string}>#{item_string}</option>"
    end

    def personal_attributes(name,value)
      case name
        when 'prompt' then
          @prompt_option = %{<option value="">#{value}</option>}
      end
    end

    def render_string
      @option_string = "#{@prompt_option}"
      @collection.each do |item|
        @option_string << gen_option(item)
      end

      %{<select id="#{@id_string}" name="#{@name_string}">#{@option_string}</select>}
    end
  end

  class CheckBox < ClotTag
    include ModelTag

    def set_primary_attributes(context)
      super(context)
      if @params.length > 1 && ! @params[0].match(/:/) && ! @params[1].match(/:/)
        @true_val = resolve_value(@params.shift,context)
        @false_val = resolve_value(@params.shift,context)
      else
        @true_val = 1
        @false_val = 0
      end
    end

    def render_string
      if @item[@attribute_name.to_sym]
        @checked_value = %{checked="checked" }
      end
      %{<input name="#{@name_string}" type="hidden" value="#{@false_val}" />} + %{<input #{@disabled_string}#{@class_string}#{@checked_value}id="#{@id_string}" name="#{@name_string}" type="checkbox" value="#{@true_val}" />}
    end
  end

end
