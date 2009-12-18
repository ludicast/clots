require 'clot/url_filters'
require 'clot/form_for'
require 'clot/nested_form_for'
require 'extras/liquid_view'


Liquid::Template.register_filter Clot::UrlFilters  
Liquid::Template.register_filter Clot::LinkFilters  
Liquid::Template.register_filter Clot::FormFilters
Liquid::Template.register_tag('formfor', Clot::LiquidFormFor)
Liquid::Template.register_tag('nested_formfor', Clot::LiquidNestedFormFor)

ActiveRecord::Base.send(:include, Clot::ActiveRecord::Droppable)

LiquidView.class_eval do 
  alias :liquid_render :render 
  
  def render(template, local_assigns = nil)
    @new_assigns = {}
    
    match = /Controller/.match @view.controller.class.to_s 
    @new_assigns['controller_name'] = match.pre_match
    
    if @view.controller.send :protect_against_forgery?      
      @new_assigns['auth_token'] = @view.controller.send :form_authenticity_token
    end
    
    liquid_render( template, local_assigns.merge!( @new_assigns ) )
  end
end
