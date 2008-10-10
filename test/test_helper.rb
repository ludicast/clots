require 'rubygems'
require 'activesupport'
require 'activerecord'

require File.dirname(__FILE__) + '/../../liquid/test/helper'

#included for the actionview parts that helpers use
require File.dirname(__FILE__) + '/../../../../config/environment'

require 'clot/url_filters'

class LiquidDemoModel
  def initialize
    @saved = false
  end
  
  def errors
    @errs ||= ActiveRecord::Errors.new Hash.new
    @errs
  end
  
  def new_record?
    @saved
  end
  
  def save_record
    @saved = true
  end
end

class LiquidDemoModelDrop < Liquid::Drop
  
  attr_reader :source, :liquid_attributes
  undef :type
  
    def initialize(args = {})
      @dropped_class = LiquidDemoModel
      @source = LiquidDemoModel.new
      @liquid_attributes = [] 
            
      args.each_pair do |symbol,value|
        if value.is_a? String
          value = "\'#{value}\'"
        end
        
        @source.instance_eval( "def #{symbol}() @#{symbol} || #{value}; end" )
        @source.instance_eval( "def #{symbol}=(val) @#{symbol} = val; end" )
        @liquid_attributes << symbol
        instance_eval( "def #{symbol}() @source.#{symbol} || #{value}; end" )
        instance_eval( "def #{symbol}=(val) @source.#{symbol} = val; end" )
      end

      #throw in current properties
      ["name", "record_id"].each do |item|
        unless @liquid_attributes.include? item
          @liquid_attributes << item
        end
      end
    end
    
    def errors
      @source.errors
    end
    
    
    def name
        "My Name"
    end
    
    def record_id
      1
    end  
    
    def dropped_class
      @dropped_class 
    end
    
    def to_liquid
      self
    end
    
    def before_method(method)
      send method.to_s
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