require 'clot/url_filters'
require 'clot/form_builder'

require 'extras/liquid_view'


Liquid::Template.register_filter Clot::UrlFilters  
Liquid::Template.register_tag('formfor', Clot::LiquidFormBuilder)


ActiveRecord::Base.send(:include, ActiveRecord::Acts::Droppable)

module LiquidViewExtensions

  def self.included(base)
    base.extend(ClassMethods)
  end  
  
  class ActionViewProxy

    attr_accessor :proxied_action_view
    
    def initialize(action_view)
      @proxied_action_view = action_view
      @new_assigns = {}
      match = /Controller/.match @proxied_action_view.controller.class.to_s 
      @new_assigns['controller_name'] = match.pre_match
    end
    def method_missing(name, *args)
      @proxied_action_view.send(name, *args)
    end
    def respond_to?(sym)
      @proxied_action_view.respond_to(sym)
    end
    def instance_variable_get(sym)
      @proxied_action_view.instance_variable_get(sym)
    end
    def assigns
      @proxied_action_view.assigns.merge(@new_assigns)
    end
  end
  

  module ClassMethods
    def new(action_view)
      super ActionViewProxy.new action_view
    end
    
  end
end

LiquidView.send :include, LiquidViewExtensions
