module Clot
  class LiquidFormElementTag < Struct.new(:tag_name, :type, :params)

    include UrlFilters
    include LinkFilters
    include FormFilters

    attr_accessor :model, :class_name
    attr_accessor :prompt

    def self.shift_name(args)
      (args.shift)[/[:](.+)/, 1]
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
      [args, tag_name]
    end

    def self.load_params(tag, args)
      args.each do |param|
        param_array = param.split(/[:]/)
        if param_array[0].match /^_/
          tag.prompt = param_array[1]
        else
          tag.params << {:key => param_array[0], :value => param_array[1]}
        end
      end
    end

    def render(context)
      @model = context['form_model']
      @class_name = context['form_class_name']
      errors = @model.errors.on(tag_name)
      name_string = @class_name + "[" + tag_name.to_s + "]"
      tag_text = output_tag type, name_string, @model[tag_name], errors, context
      params.each do |param|
        tag_text = set_param tag_text, param[:key], param[:value]
      end
      if respond_to? :wrap_form_tag
        wrap_form_tag tag_text, tag_name, type, errors, @model.source.class.to_s.tableize.singularize
      else
        tag_text
      end
    end

  end


  class LiquidFieldTag < LiquidFormElementTag

    def self.get_tag(type, params)
      args, tag_name = parse_params(params)
      tag = self.new(tag_name, type, [])
      load_params(tag, args)
      tag
    end


    def output_tag(type, name, value, errors, context)
      case type
        when :field:
          form_input_item name, value, errors
        when :text:
          form_text_item name, value, errors
        when :file:
          form_file_item name, errors
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
      load_params(tag, args)
      tag
    end

    def output_tag(type, name, value, errors, context)

      case type
        when :select:
          coll = context[@collection_name]
          if @collection_name.match /\[(.*)\]/
            coll = $1.split " "
          end
          form_select_item name, value, coll, errors, @prompt
      end
    end

  end
  
  module Deprecated

    def deprecation_message(message)
      unless RAILS_ENV == 'test'
        puts message
      end
      if false #set to true to validate tests
        raise Error.new("USING DEPRECATED TAG")
      end
    end

    def unknown_tag(name, params, tokens)
      if name == "field"
        deprecation_message "deprecated...switch to other text_field tag"
        @nodelist << LiquidFieldTag.get_tag(name.to_sym, params)
      elsif name == "text" || name == "file"
        @nodelist << LiquidFieldTag.get_tag(name.to_sym, params)
      elsif name == "select"
        @nodelist << LiquidCollectionTag.get_tag(name.to_sym, params)
      else
        super
      end
    end

  end
end

class Clot::LiquidFormFor
  include Clot::Deprecated
end
