require 'clot/url_filters'
require 'clot/form_for'
require 'clot/nested_form_for'
require 'clot/yield'
require 'clot/if_content_for'
require 'extras/liquid_view'


Liquid::Template.register_filter Clot::UrlFilters  
Liquid::Template.register_filter Clot::LinkFilters  
Liquid::Template.register_filter Clot::FormFilters
Liquid::Template.register_tag('formfor', Clot::LiquidFormFor)
Liquid::Template.register_tag('nested_formfor', Clot::LiquidNestedFormFor)
Liquid::Template.register_tag('yield', Clot::Yield)
Liquid::Template.register_tag('if_content_for', Clot::IfContentFor)

ActiveRecord::Base.send(:include, Clot::ActiveRecord::Droppable)

LiquidView.class_eval do 
  alias :liquid_render :render 
  
  def render(template, local_assigns = nil)
    @new_assigns = {}

    @new_assigns['controller_name'] = @view.controller.controller_name
    
    @new_assigns['action_name'] = @view.controller.action_name
    
    if @view.controller.send :protect_against_forgery?      
      @new_assigns['auth_token'] = @view.controller.send :form_authenticity_token
    end
    
    liquid_render( template, local_assigns.merge!( @new_assigns ) )
  end
end
