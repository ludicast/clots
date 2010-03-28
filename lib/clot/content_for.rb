module Clot
  class IfContentFor < Liquid::Block
    include Liquid

    Syntax = /(#{QuotedFragment}+)(\s+(?:with|for)\s+(#{QuotedFragment}+))?/
  
    def initialize(tag_name, markup, tokens)      
      @blocks = []
 
      if markup =~ Syntax

        @template_name = $1 
        @variable_name = $3
        @attributes    = {}

        markup.scan(TagAttributes) do |key, value|
          @attributes[key] = value
        end

      else
        raise SyntaxError.new("Syntax error in tag 'content_for' - Valid syntax: content_for '[template]' (with|for) [object|collection]")
      end

      super
    end
    
    def render(context)
      if Liquid::Template.file_system.template_file_exists?( "#{context['controller_name']}/#{context['action_name']}/#{@template_name}")
        super
      else
        "#{context['controller_name']}/#{context['action_name']}/#{@template_name}"
      end
    end
  end
end