module Clot
  module TagHelper
    def split_params(params)
      params.split(",").map(&:strip)
    end

    def resolve_value(value,context)
      case value
        when /^([\[])(.*)([\]])$/: array =  $2.split " "; array.map {|item| resolve_value item, context }
        when /^(["'])(.*)\1$/: $2
        when /^(\d+)$/:value.to_i
        when /^true$/:true
        when /^false$/:false
        when /^nil$/:nil
        when /^(.+)_path$/:"/#{$1}"
        else context[value]
      end
    end    

  end
end
