module Clot
  module ModelTag
    def set_primary_attributes(context)
      @item = context['form_model']
      if @item
        @attribute_name = @params.shift
        @first_attr = context['form_class_name']
      else
        @first_attr =  @params.shift

        if @params[0] && ! @params[0].match(/:/)
          @attribute_name = @params.shift
        end
        @item = context[@first_attr]
      end
        @id_string = "#{@first_attr}_#{@attribute_name}"
        @name_string = "#{@first_attr}[#{@attribute_name}]"
        @value_string = @item[@attribute_name.to_sym]
    end
  end

  class TextField < TextFieldTag
    include ModelTag
  end
  class TextArea < TextAreaTag
    include ModelTag
  end
  
  class Label < LabelTag
    include ModelTag

    def get_label_for(label)
      label.capitalize
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
         @default_id = @params.shift
      end
      if @params[0] && ! @params[0].match(/:/)
         @default_name = @params.shift
      end
    end

    def gen_option(item)
      selection_string = ""
      item_string = item
      value_string = ""

      if item.is_a?(String)
        if @item[@attribute_name.to_sym] == item
          selection_string = ' selected="selected"'
        end
      else
        item_string = item[@default_name.to_sym]
        value_string = %{ value="#{item[@default_id.to_sym]}"}
        if item[@default_id.to_sym].to_s == @value_string.to_s
          selection_string = ' selected="selected"'
        end
      end


      "<option#{value_string}#{selection_string}>#{item_string}</option>"
    end

    def render_string
      @option_string = ""
      @collection.each do |item|
        @option_string << gen_option(item) 
      end

      %{<select name="#{@name_string}">#{@option_string}</select>}
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