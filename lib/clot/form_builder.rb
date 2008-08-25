module Clot
  class LiquidFormBuilder < ::Liquid::Block
    include Clot::UrlFilters
    
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

    def set_variables(context)
      @model = context[@form_object]
      @form_helper = @attributes["form_helper"] || "simple_form_helper"
      @activity = @attributes["activity"] 
      
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
    
    def render_form(context)
      #    need to settle contecxt issues here..
      
      result = '<form method="POST" ' + @class_string + 'action="' + @form_action + '"' + @upload_info + '>'
      if @activity == "edit"
        result += '<input type="hidden" name="_method" value="PUT"/>'
      end
      
      result += "#{auth_token}"
      
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
        @model.liquid_attributes.each { |value|
          value_string = ""
          
          unless @model[value].nil?
            value_string = @model[value].to_s
          end

          errors = @model.errors.on(value)
          
          name_string = @class_name  + "[" + value.to_s + "]"
          contents = send @form_helper.to_sym, name_string, value_string, errors
       
          context["form_" + value.to_s] = contents    
        }
        
        results = render_all(@nodelist, context)
        result += (results * "")

      end
      
      result += "</form>"
      result      
    end

     
    def syntax_error
      raise SyntaxError.new("Syntax Error in 'formfor' - Valid syntax: formfor [object] activity:(edit|new)")      
    end
    
  end
end