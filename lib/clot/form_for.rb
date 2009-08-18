module Clot
  class LiquidFormTag < Liquid::Block
    include Clot::UrlFilters
    include Clot::LinkFilters
    include Clot::FormFilters

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

  end

  class LiquidFormElementTag < Struct.new(:tag_name, :type, :params)
    include Clot::UrlFilters
    include Clot::LinkFilters
    include Clot::FormFilters

    attr_accessor :model, :class_name

    def self.shift_name(args)
      (args.shift)[/[:](.+)/,1]
    end

    def self.split_params(params)
      params.split(",").map(&:strip)
    end

    def self.parse_params(params)
      args = split_params(params)
      if args.length == 0
        raise SyntaxError.new "Need to have fieldname inputted"
      end
      unless tag_name = shift_name(args)
        raise SyntaxError.new "need to have fieldname in form of :field_name"
      end
      [args,tag_name]
    end

    def self.load_params(tag, args)
      args.each do |param|
        param_array = param.split(/[:]/)
        tag.params << {:key => param_array[0], :value => param_array[1]}
      end
    end
    
    def render(context)
      errors = @model.errors.on(tag_name)
      name_string = @class_name  + "[" + tag_name.to_s + "]"
      tag_text = output_tag type, name_string, @model[tag_name], errors, context
      params.each do |param|
        tag_text = set_param tag_text, param[:key], param[:value]
      end
      if respond_to? :wrap_form_tag
        wrap_form_tag tag_text, tag_name, type, errors
      else
        tag_text
      end
    end

  end


  class LiquidFieldTag < LiquidFormElementTag

    def self.get_tag(type, params)
      args, tag_name = parse_params(params)
      tag = self.new(tag_name, type, [])
      load_params(tag,args)
      tag
    end
    

    def output_tag(type, name, value, errors, context)
      case type
        when :field:  form_input_item name, value, errors
        when :text:   form_text_item name, value, errors
      end
    end

  end

  class LiquidCollectionTag < LiquidFormElementTag
    attr_accessor :collection_name

    def self.get_tag(type, params)
      args, tag_name = parse_params(params)
      tag = self.new(tag_name, type, [])
      unless tag.collection_name = shift_name(args)
        raise SyntaxError.new "need to have collection in form of :collection_name"
      end

      load_params(tag,args)
      tag
    end

    def output_tag(type, name, value, errors, context)
      case type
        when :select: form_select_item name, value, context[@collection_name], errors
      end
    end

  end

  class LiquidFormFor < LiquidFormTag

    def roll_tags(context)
      @nodelist.each do |node|
        if (node.respond_to? :model=)
          node.model = @model
        end
        if (node.respond_to? :class_name=)        
          node.class_name = @class_name
        end
      end
    end

    def unknown_tag(name, params, tokens)
      if name == "field" || name == "text"
        @nodelist << LiquidFieldTag.get_tag(name.to_sym, params)
      elsif name == "select"
        @nodelist << LiquidCollectionTag.get_tag(name.to_sym, params)
      else
        super
      end
    end


    private 

    def set_method
      if @model.nil? || @model.source.nil? || @model.source.new_record?
        @activity = "new"
      else
        @activity = "edit"
      end
    end
    
    def set_form_action
      if @activity == "edit"
        if @attributes["obj_class"]
          @form_action = object_url @model, @attributes["obj_class"]
        else
          @form_action = object_url @model
        end
      elsif @activity == "new"
        if @model.nil?
          @model = @attributes["obj_class"].classify.constantize.new.to_liquid
        end
        @form_action = "/" + @attributes["obj_class"] + "/"
      else
        syntax_error
      end
      unless @attributes["post_method"].nil?
        @form_action += '/' + @attributes["post_method"]
        @activity = @attributes["post_method"]
      end
      
    end

    def set_class
      @class_string = ""
      unless @attributes["class"].nil?
        @class_string = 'class="' + @attributes["class"] + '" '
      end

      if @attributes["obj_class"]
        @class_name = @attributes["obj_class"].chop
      else
        @class_name = drop_class_to_table_item @model.class
      end
            
    end

    def set_upload
      if @attributes["uploading"]
        @upload_info = ' enctype="multipart/form-data"'
      else
        @upload_info = ''
      end      
    end

    def set_model(context)
      @model = context[@form_object] || nil
    end

    def set_variables(context)
      set_model(context)
      set_method
      set_form_action      
      set_class
      set_upload
    end

    def get_form_header(context)
      result = '<form method="POST" ' + @class_string + 'action="' + @form_action + '"' + @upload_info + '>'
      if @activity == "edit"
        result += '<input type="hidden" name="_method" value="PUT"/>'
      end

      if context.has_key? 'auth_token'
        result += '<input name="authenticity_token" type="hidden" value="' + context['auth_token'] + '"/>'
      end
      result
    end

    def get_form_errors
      result = ""
      if @model and @model.errors.count > 0
        result += '<div id="error-explanation"><h2>' + @model.errors.count.to_s + ' error(s) occurred while processing information</h2><ul>'

        @model.errors.each do |attr,msg|
          result += "<li>"
          result += attr + " - " + msg.to_s
          result += "</li>"
        end
        result += "</ul></div>"
      end
      result
    end

    def get_form_body(context)
      context.stack do
        roll_tags(context)
        render_all(@nodelist, context) * ""
      end
    end

    def get_form_footer
      "</form>"
    end

    def render_form(context)
      result = get_form_header(context)
      result += get_form_errors
      result += get_form_body(context)
      result += get_form_footer
      result      
    end
    
    def syntax_error
      raise SyntaxError.new("Syntax Error in 'formfor' - Valid syntax: formfor [object]")
    end  
    
  end
end