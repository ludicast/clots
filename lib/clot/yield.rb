module Clot
  class Yield < Liquid::Tag
    include Liquid

    Syntax = /(#{QuotedFragment}+)(\s+(?:with|for)\s+(#{QuotedFragment}+))?/
  
    def initialize(tag_name, markup, tokens)      
      @blocks = []
      @naked_yield = false
 
      if markup =~ Syntax

        @template_name = $1 
        @variable_name = $3
        @attributes    = {}

        markup.scan(TagAttributes) do |key, value|
          @attributes[key] = value
        end
      elsif !( markup =~ /\w/ )
        @naked_yield = true        
      else
        raise SyntaxError.new("Syntax error in tag 'yield' - Valid syntax: yield '[template]' (with|for) [object|collection]")
      end

      super
    end
    
    def render(context)     
      if @naked_yield
        return context['content_for_layout']
      else
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
end