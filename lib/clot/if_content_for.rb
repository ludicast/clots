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
        raise SyntaxError.new("Syntax error in tag 'yield' - Valid syntax: content_for '[template]' (with|for) [object|collection]")
      end

      super
    end
    
    def render(context)
      @template_name
      super
    end
  end
end
