module Clot


  module AttributeSetter

    def set_primary_attributes(context)
      @id_string = @name_string = resolve_value(@params.shift,context)
      if @params[0] && ! @params[0].match(/:/)
        @value_string = resolve_value(@params.shift,context)
      end
    end


    def set_attributes(context)
      set_primary_attributes(context)
      
      @params.each do |pair|
        pair = pair.split /:/
        value = resolve_value(pair[1],context)
        case pair[0]
          when "value"
            @value_string = value
          when "accept"
            @accept_string = %{accept="#{CGI::unescape value}" }
          when "class"
            @class_string = %{class="#{value}" }
          when "onchange"
            @onchange_string = %{onchange="#{value}" }
          when "maxlength"
            @max_length_string = %{maxlength="#{value}" }
          when "disabled"
            @disabled_string = %{disabled="#{if (value == true || value == "disabled") then 'disabled' end}" }
          else
            personal_attributes(pair[0], value)
        end
      end
    end
  end

  class ClotTag < Liquid::Tag
    include AttributeSetter
    include TagHelper
    def initialize(name, params, tokens)
      @params = split_params(params)
      super
    end

    def render(context)
      set_attributes(context)
      render_string(context)
    end

  end


  class InputTag < ClotTag

    def personal_attributes(name,value)
      case name
        when "size"
          @size_string = %{size="#{value}" }
      end
    end

    def render_string(context)
      unless @value_string.nil?
        @value_string = %{value="#{@value_string}" }
      end
      %{<input #{@accept_string}#{@disabled_string}#{@class_string}id="#{@id_string}" #{@max_length_string}name="#{@name_string}" #{@size_string}#{@onchange_string}type="#{@type}" #{@value_string}/>}
    end
  end

  class HiddenFieldTag < InputTag

    def initialize(name, params, tokens)
      @type = "hidden"
      super
    end
  end

  class TextFieldTag < InputTag

    def initialize(name, params, tokens)
      @type = "text"
      super
    end
  end

  class FileFieldTag < InputTag

    def initialize(name, params, tokens)
      @type = "file"
      super
    end
  end

  class TextAreaTag < ClotTag
    def personal_attributes(name,value)

      case name
        when "cols"
          @col_string = %{cols="#{value}" }
        when "rows"
          @row_string = %{ rows="#{value}"}
        when "size"
          size_array = value.split /x/
          @col_string = %{cols="#{size_array[0]}" }
          @row_string = %{ rows="#{size_array[1]}"}
      end
    end

    def render_string(context)
      %{<textarea #{@disabled_string}#{@class_string}#{@col_string}id="#{@id_string}" name="#{@name_string}"#{@row_string}>#{@value_string}</textarea>}
    end
  end

  class SubmitTag < ClotTag

    def personal_attributes(name,value)
      case name
        when "name": if value.nil? then @commit_name_string = '' end
      end
    end

    def set_primary_attributes(context)
      if @params[0] && ! @params[0].match(/:/)
        @value_string = resolve_value @params.shift, context
      end
    end

    def render_string(context)

      %{<input #{@class_string}#{@disabled_string}type="submit" #{@commit_name_string}value="#{@value_string}" />}
    end

    def initialize(name, params, tokens)
      @value_string = "Save changes"
      @commit_name_string = 'name="commit" '
      super
    end
  end

  class SelectTag < ClotTag

    def personal_attributes(name,value)
      case name
        when 'multiple'
          @multiple_string = %{multiple="#{value == "true" ? "multiple" : ""}" }
      end
    end

    def render_string(context)
      %{<select #{@disabled_string}#{@class_string}id="#{@id_string}" #{@multiple_string}name="#{@name_string}#{unless @multiple_string.nil? then '[]' end}">#{@value_string}</select>}
    end

  end


  class LabelTag < ClotTag
    def render_string(context)
      @value_string ||= @name_string.capitalize
      %{<label #{@class_string}for="#{@name_string}">#{@value_string}</label>}
    end
  end

  class CheckBoxTag < ClotTag
    def set_primary_attributes(context)
      super context
      if @params[0] && ! @params[0].match(/:/)
        @checked_value = %{checked="#{resolve_value(@params.shift,context) ? 'checked' : ''}" }
      end
    end

    def render_string(context)
      @value_string ||= 1
      %{<input #{@checked_value}id="#{@name_string}" name="#{@name_string}" type="checkbox" value="#{@value_string}" />}
    end
  end


end