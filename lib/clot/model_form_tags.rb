module Clot
  module ModelTag
    def set_primary_attributes(context)
      @first_attr =  @params.shift

      if @params[0] && ! @params[0].match(/:/)
        @second_attr = @params.shift
      end
      @item = context[@first_attr]

      @id_string = "#{@first_attr}_#{@second_attr}"
      @name_string = "#{@first_attr}[#{@second_attr}]"
      @value_string = @item[@second_attr.to_sym].to_s
    end
  end


  class TextField < TextFieldTag
    include ModelTag

  end
end