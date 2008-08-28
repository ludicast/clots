require 'rubygems'
require 'activesupport'
require 'activerecord'

require File.dirname(__FILE__) + '/../../liquid/test/helper'


#included for the actionview parts that helpers use
require File.dirname(__FILE__) + '/../../../../config/environment'

require 'clot/url_filters'

class LiquidDemoModel
  def errors
    @errs ||= ActiveRecord::Errors.new Hash.new
    @errs
  end
end

class LiquidDemoModelDrop < Liquid::Drop
  class_inheritable_reader :liquid_attributes
  write_inheritable_attribute :liquid_attributes, []
  
  attr_reader :source
  delegate :hash, :to => :source    
  
  undef :type

  
    def initialize(args = {})
      @dropped_class = LiquidDemoModel
      @source = LiquidDemoModel.new
      
      args.each_pair do |symbol,value|
        if value.is_a? String
          value = "\'#{value}\'"
        end
        
        @dropped_class.class_eval( "def #{symbol}() @#{symbol} || #{value}; end" )
        @dropped_class.class_eval( "def #{symbol}=(val) @#{symbol} = val; end" )
        liquid_attributes << symbol
        instance_eval( "def #{symbol}() @source.#{symbol} || #{value}; end" )
        instance_eval( "def #{symbol}=(val) @source.#{symbol} = val; end" )

      end     
      @liquid = liquid_attributes.inject({}) { |h, k| h.update k.to_s => @source.send(k) }      
    end
    
    def errors
      @source.errors
    end
    
    
    def name
        "My Name"
    end
    
    def oid
      1
    end  
    
    def dropped_class
      @dropped_class 
    end
    
    def to_liquid
      self
    end
    
    def before_method(method)
      @liquid[method.to_s]
    end
        
  end
  
def get_drop(args = {})
  LiquidDemoModelDrop.new args
end

@@text_content_default_values = {
  :name => "Basic Essay Here",
  :data => "This is a basic ipsum lorem...",
  :dropped_class => LiquidDemoModel
} 
  
@@user_default_values =
    { :login => "sDUMMY",
      :email => "sfake@fake.com",
      :password => "password",
      :password_confirmation => "password",
      :type => "User"
    } 
  