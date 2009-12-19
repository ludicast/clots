module Clot
  class ContentFor < Liquid::Block
    include Liquid

    Syntax = /(#{QuotedFragment}+)(\s+(?:with|for)\s+(#{QuotedFragment}+))?/
  
    def initialize(tag_name, markup, tokens)      
      #Liquid::Template.file_system = Liquid::LocalFileSystem.new( ActionController::Base.view_paths )

      if markup =~ Syntax

        @template_name = $1        
        @variable_name = $3
        @attributes    = {}

        markup.scan(TagAttributes) do |key, value|
          @attributes[key] = value
        end

      else
        raise SyntaxError.new("Error in tag 'content_for' - Valid syntax: include '[template]' (with|for) [object|collection]")
      end

      super
    end
  
    def parse(tokens)      
    end
    
    def unknown_tag(tag, markup, tokens)
      @nodelist = []
      case tag
      when 'yield'
        render_yield
      else
        super
      end
    end
    
    def render(context)     
      render_yield context
      #if tag
      #  render_yield
      #else
      #  super
      #end
      
    end
    private
    
    def render_yield( context )
      source  = Liquid::Template.file_system.read_template_file( "#{context['controller_name']}/#{context['action_name']}/#{@template_name}")      
      partial = Liquid::Template.parse(source)      
      
      variable = context[@variable_name || @template_name[1..-2]]
      
      context.stack do
        @attributes.each do |key, value|
          context[key] = context[value]
        end

        if variable.is_a?(Array)
          
          variable.collect do |variable|            
            context[@template_name[1..-2]] = variable
            partial.render(context)
          end

        else
                    
          context[@template_name[1..-2]] = variable
          partial.render(context)
          
        end
      end
    end
  end
end