module Clot
  class LinkItem < Liquid::Tag
    include Clot::UrlFilters
    include Clot::LinkFilters

    cattr_accessor :has_predecessor

    def render(context)
      tag_generator(@params, context)
      LinkItem.has_predecessor ||= {}
      separator = ""
      if LinkItem.has_predecessor[context['block_id']]
        separator = GenericTagFactory[:list_item_separator] || ""
      end

      prefix = GenericTagFactory[:list_item_open_tag] || ""
      postfix = GenericTagFactory[:list_item_close_tag] || ""
      link = separator + prefix + raw_link + postfix
      filter = GenericTagFactory[:link_filter] || lambda{|link,context| link}
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

    def split_params(params)
      params.split(",").map(&:strip)
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
          when "label":
            @label = pair_data[1]
          when "new"
            @label ||= "Create"
            @link = "/#{pair_data[1]}/new"
          when "index"
            @label ||= "Index"
            @link = "/#{pair_data[1]}"
          when "view"
            @label ||= "View"
            obj = context[pair_data[1]]
            @link = "/#{obj.dropped_class.to_s.tableize}/#{obj.id}"
          when "nested_index"
            @label ||= "Index"
            obj = context[pair_data[1]]
            @link = "/#{obj.dropped_class.to_s.tableize}/#{obj.id}/#{pair_data[2]}"
          when "edit"
            @label ||= "Edit"
            obj = context[pair_data[1]]
            @link = "/#{obj.dropped_class.to_s.tableize}/#{obj.id}/edit"
          when "delete"
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
    def get_nav_body(context)
      context.stack do
        context['block_id'] = self.object_id
        render_all(@nodelist, context) * ""
      end
    end

    def render(context)
      result = GenericTagFactory[:list_open_tag] || ""
      result += get_nav_body(context)
      result += GenericTagFactory[:list_close_tag] || ""
      result
    end
  end
end


module Clot
  class LinkSeparator < Liquid::Tag
    def render(context)
      GenericTagFactory[:list_item_separator] || ""
    end
  end
end


GenericTagFactory = {}