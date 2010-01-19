module Clot
  class LiquidForm < Liquid::Block
    include UrlFilters
    include LinkFilters
    include FormFilters

    Syntax = /([^\s]+)\s+/

    def initialize(tag_name, markup, tokens)
      if markup =~ Syntax
        @form_object = $1
        @attributes = {}
        markup.scan(Liquid::TagAttributes) do |key, value|
          @attributes[key] = value
        end
      else
        syntax_error tag_name, markup, tokens
      end
      super
    end

    def render(context)
      set_variables context
      render_form context
    end

    def render_form(context)
      result = get_form_header(context)
      result += get_form_errors
      result += get_form_body(context)
      result += get_form_footer
      result
    end

    def syntax_error
      raise SyntaxError.new("Syntax Error in form tag")
    end

    def get_form_body(context)
      context.stack do
        render_all(@nodelist, context) * ""
      end
    end

    def get_form_footer
      "</form>"
    end

    def set_upload
      if @attributes["uploading"] || @attributes["multipart"] == "true"
        @upload_info = ' enctype="multipart/form-data"'
      else
        @upload_info = ''
      end
    end

    def set_variables(context)
      set_controller_action
      set_form_action
      set_class
      set_upload
    end

  end


  class LiquidFormFor < LiquidForm

    def get_form_body(context)
      context.stack do
        context['form_model'] =  @model
        context['form_class_name'] =  @class_name
        render_all(@nodelist, context) * ""
      end
    end


    private

    def set_controller_action
      if @model.nil? || @model.source.nil? || @model.source.new_record?
        @activity = "new"
      else
        @activity = "edit"
      end
    end

    def set_form_action
      if @activity == "edit"
        if @attributes["obj_class"]
          @form_action = object_url @model, @attributes["obj_class"]
        else
          @form_action = object_url @model
        end
      elsif @activity == "new"
        if @model.nil?
          @model = @attributes["obj_class"].classify.constantize.new.to_liquid
        end
        @form_action = "/" + @attributes["obj_class"] + "/"
      else
        syntax_error
      end
      unless @attributes["post_method"].nil?
        @form_action += '/' + @attributes["post_method"]
        @activity = @attributes["post_method"]
      end

    end

    def set_class
      @class_string = ""
      unless @attributes["class"].nil?
        @class_string = 'class="' + @attributes["class"] + '" '
      end

      if @attributes["obj_class"]
        @class_name = @attributes["obj_class"].chop
      else
        @class_name = drop_class_to_table_item @model.class
      end

    end

    def set_model(context)
      @model = context[@form_object] || nil
    end

    def get_form_header(context)
      result = '<form method="POST" ' + @class_string + 'action="' + @form_action + '"' + @upload_info + '>'
      if @activity == "edit"
        result += '<input type="hidden" name="_method" value="PUT"/>'
      end

      if context.has_key? 'auth_token'
        result += '<input name="authenticity_token" type="hidden" value="' + context['auth_token'] + '"/>'
      end
      result
    end

    def get_form_errors
      result = ""
      if @model and @model.errors.count > 0
        result += '<div id="error-explanation"><h2>' + @model.errors.count.to_s + ' error(s) occurred while processing information</h2><ul>'

        @model.errors.each do |attr, msg|
          result += "<li>"
          result += attr + " - " + msg.to_s
          result += "</li>"
        end
        result += "</ul></div>"
      end
      result
    end

    def set_variables(context)
      set_model(context)
      super
    end

  end
end