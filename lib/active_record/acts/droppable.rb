module ActiveRecord #:nodoc:
  module Acts #:nodoc:
    module Droppable
      def self.included(base)
        
        base.extend(ClassMethods)
      end

      module ClassMethods
        def acts_as_droppable(options = {})

          class_eval <<-EOV
            include ActiveRecord::Acts::Droppable::InstanceMethods

            EOV
        end
      end


      module InstanceMethods        
        def get_drop_class(class_obj)
           #drop_string.constantize
           begin 
             drop_string = class_obj.to_s + "Drop"
             drop_class = drop_string.constantize
             drop_class
           rescue
             get_drop_class class_obj.superclass
           end
        end
      
        def to_liquid
          #drop_string = self.class.to_s + "Drop"
          drop_class = get_drop_class self.class
          drop_class.new self
        end
      end
    end
  end
end