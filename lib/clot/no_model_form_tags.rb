module Clot
  module AttributeSetter
    def set_primary_attributes(context)
      @id_string = @name_string = resolve_value(@params.shift,context)
      if @params[0] && ! @params[0].match(/:/)
        @value_string = resolve_value(@params.shift,context)
      end
    end

    def personal_attributes(name,value)
      
    end


    def set_attributes(context)
      set_primary_attributes(context)
      
      @params.each do |pair|
        pair = pair.split /:/
        value = resolve_value(pair[1],context)
        if personal_attributes(pair[0], value)
          next
        end

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
        end
      end
    end
  end

  class ClotTag < Liquid::Tag
    include AttributeSetter
    include TagHelper
    def initialize(name, params, tokens)
      @_params = split_params(params)
      super
    end

    def render(context)
      instance_variables.each do |var|
        unless ["@_params", "@markup", "@tag_name"].include? var
          instance_variable_set var.to_sym, nil  #this is because the same parse tag is re-rendered
        end
      end
      @params = @_params.clone
      set_attributes(context)
      render_string
    end

  end


  class InputTag < ClotTag

    def personal_attributes(name,value)
      case name
        when "size"
          @size_string = %{size="#{value}" }
        when "width"
          @size_string = %{width="#{value}" }
      end
    end

    def render_string
      unless @value_string.nil?
        @value_string = %{value="#{@value_string}" }
      end
      %{<input #{@accept_string}#{@disabled_string}#{@class_string}id="#{@id_string}" #{@max_length_string}name="#{@name_string}" #{@size_string}#{@onchange_string}type="#{@type}" #{@value_string}/>}
    end
  end

  class HiddenFieldTag < InputTag

    def render_string
      @type = "hidden"
      super
    end
  end

  class TextFieldTag < InputTag

    def render_string
      @type = "text"
      super
    end
  end

  class FileFieldTag < InputTag

    def render_string
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

    def render_string
      %{<textarea #{@disabled_string}#{@class_string}#{@col_string}id="#{@id_string}" name="#{@name_string}"#{@row_string}>#{@value_string}</textarea>}
    end
  end

  class SubmitTag < ClotTag

    def personal_attributes(name,value)
      case name
        when "name"
          if value.nil? then @commit_name_string = '' end
        when "disable_with"
          @onclick_string = %{onclick="this.disabled=true;this.value='#{value}';this.form.submit();" }
      end
    end

    def set_primary_attributes(context)
      @value_string = "Save changes"
      @commit_name_string = 'name="commit" '
      if @params[0] && ! @params[0].match(/:/)
        @value_string = resolve_value @params.shift, context
      end
    end

    def render_string
      %{<input #{@class_string}#{@onclick_string}#{@disabled_string}type="submit" #{@commit_name_string}value="#{@value_string}" />}
    end

  end

  class SelectTag < ClotTag

    def personal_attributes(name,value)
      case name
        when 'multiple'
          @multiple_string = %{multiple="#{value == "true" ? "multiple" : ""}" }
        when 'prompt'
          @prompt_option = %{<option value="">#{value}</option>}
      end
    end

    def render_string
      %{<select #{@disabled_string}#{@class_string}id="#{@id_string}" #{@multiple_string}name="#{@name_string}#{unless @multiple_string.nil? then '[]' end}">#{@prompt_option}#{@value_string}</select>}
    end

  end


  class LabelTag < ClotTag
    def render_string
      @value_string ||= @name_string.humanize
      %{<label #{@class_string}for="#{@id_string}">#{@value_string}</label>}
    end

    def personal_attributes(name,value)
      case name
        when 'value'
          @id_string << "_#{value}"
      end
    end

  end

  class CheckBoxTag < ClotTag
    def personal_attributes(name,value)
      case name
        when 'collection'
          @checkbox_collection = value
        when 'member'
          @checkbox_member = value
          if (! @checkbox_collection.nil?) && @checkbox_collection.include?(@checkbox_member)
            @checked_value = %{checked="checked" }            
          end
      end
    end


    def set_primary_attributes(context)
      super context
      if @params[0] && ! @params[0].match(/:/)
        checked = resolve_value @params.shift, context
        if checked
          @checked_value = %{checked="checked" }
        end
      end
    end

    def render_string
      @value_string ||= 1
      %{<input #{@disabled_string}#{@class_string}#{@checked_value}id="#{@id_string}" name="#{@name_string}" type="checkbox" value="#{@value_string}" />}
    end
  end


end