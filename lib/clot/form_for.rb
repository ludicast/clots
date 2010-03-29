module Clot
  class LiquidForm < Liquid::Block
    include UrlFilters
    include LinkFilters
    include FormFilters
    include TagHelper

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
      set_form_action(context)
      set_class
      set_upload
    end

  end


  class LiquidFormFor < LiquidForm

    def get_errors(model)
      errors = []
      model.errors.each do |attr,msg|
        errors << attr
      end
      errors

    end


    def get_form_body(context)
      context.stack do
        context['form_model'] =  @model
        context['form_class_name'] =  @class_name
        context['form_errors'] =  get_errors @model
        render_all(@nodelist, context) * ""
      end
    end


    private

    def set_controller_action
      silence_warnings {
        if @model.nil? || @model.source.nil? || @model.source.new_record? ||  @model.source.id.nil?
          @activity = "new"
        else
          @activity = "edit"
        end
      }
    end

    def set_form_action(context)
      if @activity == "edit"
        @form_action = object_url @model
      elsif @activity == "new"
        @form_action = "/" + @model.dropped_class.to_s.tableize.pluralize + "/"
      else
        syntax_error
      end
      if @attributes["parent"]
        @form_action = object_url(context[@attributes["parent"]]) + @form_action
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

      @class_name = drop_class_to_table_item @model.class
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



    def set_variables(context)
      set_model(context)
      super
    end

  end


  class ErrorMessagesFor < Liquid::Tag

    include TagHelper
    def initialize(name, params, tokens)
      @_params = split_params(params)
      super
    end


    def render(context)
      @params = @_params.clone
      @model = context[@params.shift]

      result = ""
      if @model and @model.errors.count > 0
        @suffix = @model.errors.count > 1 ? "s" : ""
        @default_message = @model.errors.count.to_s + " error#{@suffix} occurred while processing information"

        @params.each do |pair|
          pair = pair.split /:/
          value = resolve_value(pair[1],context)

          case pair[0]
            when "header_message" then
              @default_message = value
          end
        end

        result += '<div class="errorExplanation" id="errorExplanation"><h2>' + @default_message + '</h2><ul>'

        @model.errors.each do |attr, msg|
          result += "<li>"
          result += attr + " - " + msg.to_s
          result += "</li>"
        end
        result += "</ul></div>"
      end
      result
    end    
  end

end