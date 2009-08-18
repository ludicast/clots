module Clot
# Taken from mephisto
  
  class BaseDrop < Liquid::Drop
    
    class_inheritable_reader :liquid_attributes
    write_inheritable_attribute :liquid_attributes, [:created_at]
    write_inheritable_attribute :liquid_attributes, [:updated_at]  
    attr_reader :source
    delegate :hash, :to => :source
    
    def initialize(source)
      @source = source
      @liquid = liquid_attributes.inject({}) { |h, k| h.update k.to_s => @source.send(k) }
    end
    
    def before_method(method)
      @liquid[method.to_s]
    end
    
    def eql?(comparison_object)
      self == (comparison_object)
    end
    
    def ==(comparison_object)
      self.source == (comparison_object.is_a?(self.class) ? comparison_object.source : comparison_object)
    end
    
    # converts an array of records to an array of liquid drops, and assigns the given context to each of them
    def self.liquify(current_context, *records, &block)
      i = -1
      records = 
      records.inject [] do |all, r|
        i+=1
        attrs = (block && block.arity == 1) ? [r] : [r, i]
        all << (block ? block.call(*attrs) : r.to_liquid)
        all.last.context = current_context if all.last.is_a?(Liquid::Drop)
        all
      end
      records.compact!
      records
    end
 
 
    def id
      @source.id
    end
    
    def dropped_class
      @source.class
    end
    
    def errors
      @source.errors
    end

    def collection_label
      "label field"
    end 

  protected

    def liquify(*records, &block)
      self.class.liquify(@context, *records, &block)
    end
    
  end  
end