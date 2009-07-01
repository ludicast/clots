module Clot
  class LiquidFormBuilder < ::Liquid::Block
    include Clot::UrlFilters
    include Clot::FormFilters
  
    Syntax = /([^\s]+)\s+/
    def initialize(tag_name, markup, tokens)
      if markup =~ Syntax
        @form_object = $1
        @attributes = {}
        markup.scan(Liquid::TagAttributes) do |key, value|
          @attributes[key] = value
        end
      else
        syntax_error
      end
      
      super tag_name, markup, tokens
    end
    
    def render(context)
      set_variables context
      render_form context
    end    
    
    private 

    def get_method
#      if @attributes.has_key?("activity")
#        @activity = @attributes["activity"]
#      end
      if @model.nil? || @model.source.nil? || @model.source.new_record?
        @activity = "new"
      else
        @activity = "edit"
      end
    end
    
    def determine_form_action
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
    end
    
    def set_variables(context)
      @model = context[@form_object]
      @form_helper = @attributes["form_helper"] || "simple_form_helper"
     
      
      @activity = get_method
      determine_form_action      
      unless @attributes["post_method"].nil?
        @form_action += '/' + @attributes["post_method"]
        @activity = @attributes["post_method"]
      end
      
      

      @class_string = ""
      unless @attributes["class"].nil?
        @class_string = 'class="' + @attributes["class"] + '" '
      end
      
      if @attributes["obj_class"]
        @class_name = @attributes["obj_class"].chop
      else
        @class_name = drop_class_to_table_item @model.class
      end
      
      if @attributes["uploading"]
        @upload_info = ' enctype="multipart/form-data"'
      else
        @upload_info = ''
      end

    end
 
    def set_context_info(context, model, item_prefix = "form_")
        model.liquid_attributes.each { |value|
          value_string = ""
          
          unless model[value].nil?
            value_string = model[value].to_s
          end
          
          errors = model.errors.on(value)
          name_string = @class_name  + "[" + value.to_s + "]"
          contents = send @form_helper.to_sym, name_string, value_string, errors

          context[item_prefix + value.to_s] = contents 
        }      
    end
    
    def render_form(context)

      # need to settle context issues here ...
      
      result = '<form method="POST" ' + @class_string + 'action="' + @form_action + '"' + @upload_info + '>'
      if @activity == "edit"
        result += '<input type="hidden" name="_method" value="PUT"/>'
      end
      
      if context.has_key? 'auth_token'
        result += '<input name="authenticity_token" type="hidden" value="' + context['auth_token'] + '"/>'
      end
  #  see if need to be outside of builder
  #  result += "#{auth_token}"
      
      errors = ""
      
      
      if @model.errors.count > 0     
        result += '<div id="error-explanation"><h2>' + @model.errors.count.to_s + ' error(s) occurred while processing information</h2><ul>'  
        
        @model.errors.each{ |attr,msg| 
          result += "<li>"
          result += attr + " - " + msg.to_s
          result += "</li>"
        }
        
        result += "</ul></div>"
      end   
      
      context.stack do
        set_context_info(context, @model)
        results = render_all(@nodelist, context)
        result += (results * "")
      end
      
      result += "</form>"
      result      
    end
    
    
    def syntax_error
      raise SyntaxError.new("Syntax Error in 'formfor' - Valid syntax: formfor [object]")      
    end
    
  end
  
  class LiquidNestedFormBuilder < LiquidFormBuilder
    NestedSyntax = /([^\s]+)\s+(.*)/
    def initialize(tag_name, markup, tokens)
      if markup =~ NestedSyntax
        @parent_object = $1
        remaining_markup = $2
        
      else
        syntax_error
      end    
      
      super tag_name, remaining_markup, tokens
    end

    def set_variables(context)
      @parent_model = context[@parent_object]
      super
    end

    def determine_form_action
      super

      @form_action = object_url(@parent_model) + @form_action
    end
 
    def set_context_info(context, model, item_prefix = "form_")
      super context, model, item_prefix
      super context, @parent_model, "parent_form_"
    end
    
  end
  
  
end