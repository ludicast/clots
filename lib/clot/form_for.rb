require 'clot/url_filters'
require 'clot/link_filters'
require 'clot/form_filters'
require 'clot/tag_helper'

module Clot
  class LiquidForm < Liquid::Block
    include UrlFilters
    include LinkFilters
    include FormFilters
    include TagHelper

    Syntax = /([^\s]+)\s+/

    def initialize(tag_name, markup, tokens)
      if markup =~ Syntax
        @form_object = $1
        @attributes = {}
        markup.scan(Liquid::TagAttributes) do |key, value|
          @attributes[key] = value
        end
      else
        syntax_error tag_name, markup, tokens
      end
      super
    end

    def render(context)
      set_variables context
      render_form context
    end

    def render_form(context)
      result = get_form_header(context)
      result += get_form_body(context)
      result += get_form_footer
      result
    end

    def syntax_error
      raise SyntaxError.new("Syntax Error in form tag")
    end

    def get_form_body(context)
      context.stack do
        render_all(@nodelist, context) * ""
      end
    end

    def get_form_footer
      "</form>"
    end

    def set_upload
      if @attributes["uploading"] || @attributes["multipart"] == "true"
        @upload_info = ' enctype="multipart/form-data"'
      else
        @upload_info = ''
      end
    end

    def set_variables(context)
      set_controller_action
      set_form_action(context)
      set_class
      set_upload
    end

  end


  class LiquidFormFor < LiquidForm

    def get_errors(model)
      errors = []
      model.errors.each do |attr,msg|
        errors << attr
      end
      errors
    end

    def get_required_fields(model)
      source = model.source
      errors = source.errors
      had_errors = true unless errors.empty?
      required_fields = if source.valid?
          []
        else
          source.errors.to_hash.keys
        end
      source.errors.clear
      source.valid? if had_errors
      required_fields
    end

    def get_form_body(context)
      context.stack do
        context['form_model'] =  @model
        context['form_class_name'] =  @class_name
        context['form_errors'] =  get_errors @model
        return render_all(@nodelist, context)
      end
    end


    private

    def set_controller_action
      silence_warnings {
        if @model.nil? || @model.source.nil?
          @activity = "new"
        elsif @model.dropped_class == Searchlogic::Search
          @activity = "search"
        elsif @form_object.include?("_change")
          @activity = "change"
        elsif @model.source.new_record? ||  @model.source.id.nil?
          @activity = "new"
        elsif @model.dropped_class == NationSignup
          @activity = "new"
        else
          @activity = "edit"
        end
      }
    end

    def set_form_action(context)
      if @activity == "edit"
        @form_action = object_url @model
      elsif @activity == "new"
        @form_action = "/" + @model.dropped_class.to_s.tableize.pluralize
      elsif ['search', 'change'].include?(@activity)
        @form_action = ""
      else
        syntax_error
      end
      if @attributes["parent"]
        @form_action = object_url(context[@attributes["parent"]]) + @form_action
      end
      if context.registers[:controller].params[:controller].split('/').first == 'users' or @form_action == '/accounts'
        @form_action = "/users" + @form_action.gsub("/forms","")
      elsif @activity != 'change'
        @form_action = "/forms" + @form_action if not @form_action[0..5] == '/forms'
      end
      unless @attributes["post_method"].nil?
        @form_action += '/' + @attributes["post_method"]
        @activity = @attributes["post_method"]
      end

      if @tag_name == "secure_form_for"
        uri = URI.parse @form_action
        uri.host   = context['site'].nbuild_domain
        if Rails.env.production? || Rails.env.staging?
          uri.scheme = "https"
        else
          uri.scheme = "https"
        end
        @form_action = uri.to_s
      end

    end

    def set_class
      @class_string = ""
      unless @attributes["class"].nil?
        @class_string += 'class="' + @attributes["class"] + '" '
      end
      unless @attributes["autocomplete"].nil?
        @class_string += 'autocomplete="' + @attributes["autocomplete"] + '" '
      end

      @class_name = drop_class_to_table_item @model.class
    end

    def set_model(context)
      @model = context[@form_object] || nil
      if not @model
        if @form_object.include?("_search")
          search_object_name = @form_object.gsub('_search',"").classify.constantize
          search_object = search_object_name.search
          search_object_name = (search_object_name.to_s + "SearchDrop").constantize
          @model = search_object_name.new(search_object)
          @model.defaults(context)
          context[@form_object] = @model
        elsif @form_object.include?("_change")
          change_object = @form_object.gsub('_change',"").pluralize.classify.constantize
          change_object_name = (change_object.to_s + "ChangeDrop").constantize
          @model = change_object_name.new(change_object.new)
          @model.defaults(context)
          context[@form_object] = @model
        else
          @model = @form_object.classify.constantize.new.to_liquid
          if @model.source.new_record?
            @model.defaults(context)
            context[@form_object] = @model
          end
        end
      end
    end

    def get_form_header(context)
      cs = @class_name + "_form"
      # temporarily taking out 'survey_question_response' from this list because i can't figure out why the javascript
      # response on cagreens survey http://cagreens.nationbuilder.com/ga_dec2011_survey doesn't seem to work (it works everywhere else)
      if ['comment', 'survey_response', 'face_tweet', 'feedback', 'volunteer_signup', 'event_rsvp', 'event_page', 'signup',
          'password_reset', 'password', 'flag', 'nation_signup', 'blog_post_page', 'nation_signin', 'pledge', 'unsubscribe',
          'account', 'petition_signature', 'suggestion_page', 'endorsement'].include?(@class_name) # hacky thing to make ajax forms work
        cs = 'ajaxForm ' + cs
      end
      if ['endorsement', 'suggestion_page', 'petition_signature'].include?(@class_name)
        @upload_info = ' enctype="multipart/form-data"'
      end
      if ['search', 'change'].include?(@activity)
        method_type = "GET"
      else
        method_type = "POST"
      end
      result = '<form class="' + cs + '" method="' + method_type + '" ' + @class_string + 'action="' + @form_action + '"' + @upload_info + '>'
      if @activity == "edit"
        result += '<input type="hidden" name="_method" value="PUT"/>'
      end

      # this will get replaced with a real authenticity token by rake middleware
      if not ['search', 'change'].include?(@activity)
        result += '<input name="authenticity_token" type="hidden" value="__CROSS_SITE_REQUEST_FORGERY_PROTECTION_TOKEN__"/>'
      end

      # jim change... add current page
      if context['page'] and not ['search', 'change'].include?(@activity)
        result += '<input name="page_id" type="hidden" value="' + context['page'].id.to_s + '"/>'
        result += '<input name="return_to" type="hidden" value="' + context['page'].full_url + '"/>'
      end

      if context['signup'] and ['profiles'].include?(context.registers[:controller].controller_name)
        result += '<input name="signup_id" type="hidden" value="' + context['signup'].id.to_s + '"/>'
      end

      # this is a honeypot field
      unless @class_name == 'password'
        result += '<div class="email_address_form" style="display:none;">'
        result += '<p><label for "email_address">Optional email code</label><br/><input name="email_address" type="text" class="text" id="email_address" autocomplete="off"/></p>'
        result += '</div>'
      end

      result
    end

    def set_variables(context)
      set_model(context)
      super
    end

  end


  class ErrorMessagesFor < Liquid::Tag

    include TagHelper
    def initialize(name, params, tokens)
      @_params = split_params(params)
      super
    end


    def render(context)
      @params = @_params.clone
      @model = context[@params.shift]

      result = ""
      if @model and @model.errors.count > 0
        @suffix = @model.errors.count > 1 ? "s" : ""
        @default_message = @model.errors.count.to_s + " error#{@suffix} occurred while processing this form."

        @params.each do |pair|
          pair = pair.split /:/
          value = resolve_value(pair[1],context)

          case pair[0]
            when "header_message" then
              @default_message = value
          end
        end

        result += '<div class="errorExplanation" id="errorExplanation"><h2>' + @default_message + '</h2><ul>'

        @model.errors.each do |attr, msg|
          result += "<li>#{error_message(attr, msg)}</li>"
        end

        result += "</ul></div>"
      end
      result
    end

    def error_message(attr, msg)
      unless attr == :base
        #"#{attr} - #{msg}"
        @model.errors.full_message(attr, msg)
      else
        msg
      end
    end

  end

end
