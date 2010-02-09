module Clot
  module Deprecated
    def unknown_tag(name, params, tokens)
      if name == "field" || name == "text" || name == "file" || name == "select"
        raise Error.new("USING DEPRECATED TAG")
      else
        super name,params,tokens
      end
    end
  end
end

class Clot::LiquidFormFor
  include Clot::Deprecated
end
