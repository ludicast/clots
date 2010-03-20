module Clot

  class LinkItem < Liquid::Tag
    include UrlFilters
    include LinkFilters
    include TagHelper

    cattr_accessor :has_predecessor

    def render(context)
      @tag_factory = context['tag_factory']
      tag_generator(@params, context)
      LinkItem.has_predecessor ||= {}
      separator = ""
      if LinkItem.has_predecessor[context['block_id']]
        separator = @tag_factory[:list_item_separator] || ""
      end

      prefix = @tag_factory[:list_item_open_tag] || ""
      postfix = @tag_factory[:list_item_close_tag] || ""
      link = separator + prefix + raw_link + postfix
      filter = @tag_factory[:link_filter] || lambda{|link,context| link}
      tag = filter.call link, context
      unless tag.blank? || !tag
        LinkItem.has_predecessor[context['block_id']] = true
        link
      end
    end

    def initialize(name, params, tokens)
      @params = split_params(params)
      super
    end

    def tag_generator(params, context)
      unless params[0].match /:/
        @label = params.shift
        @link = "/#{@label}"
      end
      apply_params(params, context)
    end

    def raw_link
      @onclick ||= ""
      "<a href=\"#{@link}\"#{@onclick}>#{@label}</a>"
    end

    def apply_params(params, context)
      params.each do |pair|
        pair_data = pair.split ":"
        case pair_data[0]
          when "label" then
            @label = pair_data[1]
          when "new" then
            @label ||= "Create"
            @link = "/#{pair_data[1]}/new"
          when "index" then
            @label ||= "Index"
            @link = "/#{pair_data[1]}"
          when "view" then
            @label ||= "View"
            obj = context[pair_data[1]]
            @link = "/#{obj.dropped_class.to_s.tableize}/#{obj.id}"
          when "nested_index" then
            @label ||= "Index"
            obj = context[pair_data[1]]
            @link = "/#{obj.dropped_class.to_s.tableize}/#{obj.id}/#{pair_data[2]}"
          when "nested_new" then
            @label ||= "Create"
            obj = context[pair_data[1]]
            @link = "/#{obj.dropped_class.to_s.tableize}/#{obj.id}/#{pair_data[2]}/new"
          when "nested_show" then
            @label ||= "Show"
            obj = context[pair_data[1]]
            obj2 = context[pair_data[2]]
            @link = "/#{obj.dropped_class.to_s.tableize}/#{obj.id}/#{obj2.dropped_class.to_s.tableize}/#{obj2.id}"
          when "nested_edit" then
            @label ||= "Edit"
            obj = context[pair_data[1]]
            obj2 = context[pair_data[2]]
            @link = "/#{obj.dropped_class.to_s.tableize}/#{obj.id}/#{obj2.dropped_class.to_s.tableize}/#{obj2.id}/edit"
          when "nested_delete" then
            @label ||= "Delete"
            obj = context[pair_data[1]]
            obj2 = context[pair_data[2]]
            @link = "/#{obj.dropped_class.to_s.tableize}/#{obj.id}/#{obj2.dropped_class.to_s.tableize}/#{obj2.id}"
            @context = context
            @onclick = " onclick=\"#{gen_delete_onclick}\""
          when "edit" then
            @label ||= "Edit"
            obj = context[pair_data[1]]
            @link = "/#{obj.dropped_class.to_s.tableize}/#{obj.id}/edit"
          when "delete" then
            @label ||= "Delete"
            obj = context[pair_data[1]]
            @link = "/#{obj.dropped_class.to_s.tableize}/#{obj.id}"
            @context = context
            @onclick = " onclick=\"#{gen_delete_onclick}\""
        end

      end
    end

  end
end


module Clot
  class LinksBlock < Liquid::Block
    include TagHelper
    cattr_accessor :link_block

    def initialize(name, params, tokens)
      @params = split_params(params)
      super
    end
    
    def get_nav_body(context)
      context.stack do
        LinksBlock.link_block ||= 1
        context['block_id'] = LinksBlock.link_block += 1
        context['tag_factory'] = @tag_factory
        render_all(@nodelist, context) * ""
      end
    end

    def render(context)
      @tag_factory = GenericTagFactory
      @params.each do |pair|
        pair_data = pair.split ":"
        case pair_data[0]
          when "factory_name" then @tag_factory = pair_data[1].constantize
        end

      end
      result = @tag_factory[:list_open_tag] || ""
      context['tag_factory'] = @tag_factory
      result += get_nav_body(context)
      result += @tag_factory[:list_close_tag] || ""
      result
    end
  end
end

module Clot
  class LinkSeparator < Liquid::Tag
    def render(context)
      factory = context['tag_factory'] || GenericTagFactory
      factory[:list_item_separator] || ""
    end
  end
end

GenericTagFactory = {}