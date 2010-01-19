begin
  require File.dirname(__FILE__) + '/../../../../spec/spec_helper'
rescue LoadError
  puts "You need to install rspec in your base app"
  exit
end

plugin_spec_dir = File.dirname(__FILE__)
ActiveRecord::Base.logger = Logger.new(plugin_spec_dir + "/debug.log")


require 'clot/url_filters'
require 'clot/no_model_form_tags'
require 'clot/model_form_tags'

class DummyDrop < Clot::BaseDrop; end
module Spec
  module Rails
    module Mocks
      def mock_drop(data = {})
        model = mock_model NilClass, data.merge(:null_object => true)
        def model.errors
          @errs ||= ActiveRecord::Errors.new Hash.new
          @errs
        end
        drop = DummyDrop.new model
        data.each_pair do |symbol,value|
          drop.instance_eval( "def #{symbol}() @source.#{symbol}; end" )
          model.instance_eval( "def #{symbol}() \"#{value}\"; end" )
          drop.liquid_attributes << symbol
        end
        drop
      end
    end
  end
end


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

    def collection_label
      "item_label"
    end

    def initialize(args = {})
   #   @source = mock_model(LiquidDemoModel)
      @source =   LiquidDemoModel.new
      @dropped_class = @source.class  # LiquidDemoModel      
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
      ["name", "id"].each do |item|
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

    def id
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




  #probably should be able to remove this shite....
      def self.self_and_descendants_from_active_record#nodoc:
        klass = self
        classes = [klass]
        while klass != klass.base_class
          classes << klass = klass.superclass
        end
        classes
      rescue  
        [self]
      end

       def self.human_name(options = {})
        defaults = self_and_descendants_from_active_record.map do |klass|
          :"#{klass.name.underscore}"
        end
        defaults << self.name.humanize
        I18n.translate(defaults.shift, {:scope => [:activerecord, :models], :count => 1, :default => defaults}.merge(options))
       end

   def self.human_attribute_name(attribute_key_name, options = {})
        defaults = self_and_descendants_from_active_record.map do |klass|
          :"#{klass.name.underscore}.#{attribute_key_name}"
        end
        defaults << options[:default] if options[:default]
        defaults.flatten!
        defaults << attribute_key_name.humanize
        options[:count] ||= 1
        I18n.translate(defaults.shift, options.merge(:default => defaults, :scope => [:activerecord, :attributes]))
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
    }

include Liquid
Spec::Matchers.define :parse_to do |expected|
  match do |template|
    expected.should == Template.parse(template).render {}
  end

  failure_message_for_should do |template|
    "expected #{template} to parse to #{expected}"
  end

  failure_message_for_should_not do |template|
    "expected #{template} to not parse to #{expected}"
  end

  description do
    "parse"
  end

end

Spec::Matchers.define :parse_with_vars_to do |expected,attributes|
  match do |template|
    expected.should == Template.parse(template).render(attributes)
  end

  failure_message_for_should do |template|
    "expected #{template} to parse to #{expected}"
  end

  failure_message_for_should_not do |template|
    "expected #{template} to not parse to #{expected}"
  end

  description do
    "parse"
  end

end

Liquid::Template.register_tag('select_tag', Clot::SelectTag)
Liquid::Template.register_tag('text_field_tag', Clot::TextFieldTag)
Liquid::Template.register_tag('hidden_field_tag', Clot::HiddenFieldTag)
Liquid::Template.register_tag('file_field_tag', Clot::FileFieldTag)
Liquid::Template.register_tag('text_area_tag', Clot::TextAreaTag)
Liquid::Template.register_tag('submit_tag', Clot::SubmitTag)
Liquid::Template.register_tag('label_tag', Clot::LabelTag)
Liquid::Template.register_tag('check_box_tag', Clot::CheckBoxTag)

Liquid::Template.register_tag('text_field', Clot::TextField)
Liquid::Template.register_tag('text_area', Clot::TextArea)

require 'clot/form_for'
require 'clot/deprecated'

Liquid::Template.register_tag('form_tag', Clot::FormTag)
