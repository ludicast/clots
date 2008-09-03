module Clot
  module ActiveRecord #:nodoc:
    module Droppable
      
      def get_drop_class(class_obj)
        begin 
          drop_string = class_obj.to_s + "Drop"
          drop_class = drop_string.constantize
          drop_class
        rescue
          get_drop_class class_obj.superclass
        end
      end
      
      def to_liquid
        drop_class = get_drop_class self.class
        drop_class.new self
      end
      
    end
  end
end