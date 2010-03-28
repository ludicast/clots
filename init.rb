require 'clot/url_filters'
require 'clot/form_for'
require 'clot/deprecated'
require 'clot/yield'
require 'clot/content_for'
require 'clot/no_model_form_tags'
require 'clot/model_form_tags'
require 'clot/date_tags'
require 'clot/model_date_tags'
require 'extras/liquid_view'


Liquid::Template.register_filter Clot::UrlFilters  
Liquid::Template.register_filter Clot::LinkFilters  
Liquid::Template.register_filter Clot::FormFilters

Liquid::Template.register_tag('error_messages_for', Clot::ErrorMessagesFor)
Liquid::Template.register_tag('formfor', Clot::LiquidFormFor)
Liquid::Template.register_tag('form_for', Clot::LiquidFormFor)
Liquid::Template.register_tag('yield', Clot::Yield)
Liquid::Template.register_tag('if_content_for', Clot::IfContentFor)
Liquid::Template.register_tag('form_tag', Clot::FormTag)

Liquid::Template.register_tag('select_tag', Clot::SelectTag)
Liquid::Template.register_tag('text_field_tag', Clot::TextFieldTag)
Liquid::Template.register_tag('hidden_field_tag', Clot::HiddenFieldTag)
Liquid::Template.register_tag('file_field_tag', Clot::FileFieldTag)
Liquid::Template.register_tag('text_area_tag', Clot::TextAreaTag)
Liquid::Template.register_tag('submit_tag', Clot::SubmitTag)
Liquid::Template.register_tag('label_tag', Clot::LabelTag)
Liquid::Template.register_tag('check_box_tag', Clot::CheckBoxTag)
Liquid::Template.register_tag('password_field_tag', Clot::PasswordFieldTag)

Liquid::Template.register_tag('text_field', Clot::TextField)
Liquid::Template.register_tag('text_area', Clot::TextArea)
Liquid::Template.register_tag('label', Clot::Label)
Liquid::Template.register_tag('check_box', Clot::CheckBox)
Liquid::Template.register_tag('collection_select', Clot::CollectionSelect)
Liquid::Template.register_tag('file_field', Clot::FileField)
Liquid::Template.register_tag('password_field', Clot::PasswordField)

Liquid::Template.register_tag('select_second', Clot::SelectSecond)
Liquid::Template.register_tag('select_minute', Clot::SelectMinute)
Liquid::Template.register_tag('select_hour', Clot::SelectHour)

Liquid::Template.register_tag('select_day', Clot::SelectDay)
Liquid::Template.register_tag('select_month', Clot::SelectMonth)
Liquid::Template.register_tag('select_year', Clot::SelectYear)

Liquid::Template.register_tag('select_date', Clot::SelectDate)
Liquid::Template.register_tag('select_time', Clot::SelectTime)
Liquid::Template.register_tag('select_datetime', Clot::SelectDatetime)

Liquid::Template.register_tag('date_select', Clot::DateSelect)
Liquid::Template.register_tag('time_select', Clot::TimeSelect)
Liquid::Template.register_tag('datetime_select', Clot::DatetimeSelect)

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
