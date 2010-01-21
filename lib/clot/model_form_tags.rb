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

  class CollectionSelect < ClotTag
    include ModelTag
    def set_primary_attributes(context)
      super context
      if @params[0] && ! @params[0].match(/:/)
         @collection = resolve_value(@params.shift,context)
      end
    end



    def render_string
      @option_string = ""
      @collection.each do |item|
        @option_string << "<option>#{item}</option>"
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