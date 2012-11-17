module Clot
  module TagHelper
    def split_params(params)
      params.split(",").map(&:strip)
    end

    def resolve_value(value,context)
      case value
        when /^([\[])(.*)([\]])$/ then array =  $2.split " "; array.map { |item| resolve_value item, context }
        when /^(["'])(.*)\1$/ then $2
        when /^(\d+[\.]\d+)$/ then $1.to_f
        when /^(\d+)$/ then value.to_i
        when /^true$/ then true
        when /^false$/ then false
        when /^nil$/ then nil
        when /^(.+)_path$/ then "/#{$1}"
        else context[value]
      end
    end    

  end
end
