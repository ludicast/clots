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
        @value_string = @item[@attribute_name.to_sym].to_s
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
    def set_primary_attributes(context)
      super context
      if @params[0] && ! @params[0].match(/:/)
        @value_string = resolve_value(@params.shift,context)
      else
        @value_string = @attribute_name.capitalize
      end
    end
  end

  class CheckBox < CheckBoxTag
    include ModelTag

  end

end