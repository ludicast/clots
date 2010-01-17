module Clot
  module TagHelper
    def split_params(params)
      params.split(",").map(&:strip)
    end
  end
end
