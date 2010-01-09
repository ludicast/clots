require File.dirname(__FILE__) + '/spec_helper'

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
    filter = GenericTagFactory[:link_filter] || lambda{|link| link}
    tag = filter.call link
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
Liquid::Template.register_tag('link', LinkItem)

class LinksBlock < Liquid::Block
  attr_accessor :links


  def initialize(name, params, tokens)
    super
  end

  def raw_link(link, label)
    "<a href=\"#{link}\">#{label}</a>"
  end

  def tag_generator(params)
    unless params[0].match /:/
      @label = params.shift
      @link = "/#{@link_label}"
    end
    apply_params(params)
    raw_link @link, @link_label
  end

  def link_tag(params)
    params = split_params(params)
    tag = tag_generator(params)

    filter = GenericTagFactory[:link_filter] || lambda{|link| link}
    tag = filter.call tag
    unless tag.blank? || !tag
      @link_exists ? separator = (GenericTagFactory[:list_item_separator] || "") : separator = ""
      @link_exists = true
      prefix = GenericTagFactory[:list_item_open_tag] || ""
      postfix = GenericTagFactory[:list_item_close_tag] || ""
      @nodelist << "#{separator}#{prefix}#{tag}#{postfix}"
    end
  end

  def unknown_tag(name, params, tokens)
    if name == "link"
      puts "SHOULDN'T BE HERE"

      link_tag(params)
    else
      super
    end
  end

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


Liquid::Template.register_tag('links', LinksBlock)
GenericTagFactory = {}

def set_list_tags
  GenericTagFactory[:list_open_tag] = "<foo>"
  GenericTagFactory[:list_close_tag] = "</foo>"
end

def set_list_item_tags
  GenericTagFactory[:list_item_open_tag] = "<bar>"
  GenericTagFactory[:list_item_close_tag] = "</bar>"
end

def set_separator
  GenericTagFactory[:list_item_separator] = ","
end

def set_filter
  GenericTagFactory[:link_filter] = lambda { |link|
    case link
      when /bad1/:
        ""
      when /bad2/:
        nil
      when /bad3/:
        false
      else
        link
    end
  }
end


describe "when using links" do
  include Clot::UrlFilters
  include Clot::LinkFilters

  include Liquid


  before do
    @context = {}
    LinkItem.has_predecessor = false
    GenericTagFactory[:list_open_tag] = ""
    GenericTagFactory[:list_close_tag] = ""
    GenericTagFactory[:list_item_open_tag] = ""
    GenericTagFactory[:list_item_close_tag] = ""
    GenericTagFactory[:list_item_separator] = ""
    GenericTagFactory[:link_filter] = lambda{|link| link}
  end
  context "with multiple separated that are filtered" do
    before do
      @links = "{% links %}{% link bad1 %}{% link hello %}{% link bad2 %}{% link goodbye %}{% link bad3 %}{% endlinks %}"
      set_separator
      set_filter
    end

    it "should remove filtered links" do
      @links.should parse_to("<a href=\"/hello\">hello</a>,<a href=\"/goodbye\">goodbye</a>")
    end
  end

  context "with multiple links" do
    before do
      @links = "{% links %}{% link hello %}{% link goodbye %}{% endlinks %}"
    end
    it "should put the links adjacent to them" do
      @links.should parse_to("<a href=\"/hello\">hello</a><a href=\"/goodbye\">goodbye</a>")
    end

    context "with separator" do
      before do
        set_separator
      end
      it "should apply separator" do
        @links.should parse_to("<a href=\"/hello\">hello</a>,<a href=\"/goodbye\">goodbye</a>")
      end
      context "when two link blocks are used" do
        before do
          @links += @links
        end
        it "should not use separator at beginning" do
          @links.should parse_to("<a href=\"/hello\">hello</a>,<a href=\"/goodbye\">goodbye</a><a href=\"/hello\">hello</a>,<a href=\"/goodbye\">goodbye</a>")
        end
      end
    end
  end


  context "with a single link" do
    before do
      @links = "{% links %}{% link hello %}{% endlinks %}"
    end
    it "should print out link by self" do
      @links.should parse_to("<a href=\"/hello\">hello</a>")
    end
    context "when the link modifiers are set" do
      before do
        set_list_item_tags
      end
      it "should include tags" do
        @links.should parse_to("<bar><a href=\"/hello\">hello</a></bar>")
      end
    end

  end

  context "When a link has a set label" do
    before do
      @links = "{% links %}{% link hello, label:Hi There %}{% endlinks %}"
    end

    it "should have new label" do
      @links.should parse_to("<a href=\"/hello\">Hi There</a>")
    end
  end

  context "with empty tags" do
    before do
      @links = "{% links %}{% endlinks %}"
    end

    it "should default to empty" do
      @links.should parse_to("")
    end

    context "when outer tags are set" do
      before do
        set_list_tags
      end
      it "should set outer tags" do
        @links.should parse_to("<foo></foo>")
      end
    end
  end

context "for restful tags" do

  include Clot::UrlFilters
  include Clot::LinkFilters

  context "with new param without label" do
    before do
      @links = "{% links %}{% link new:goods %}{% endlinks %}"
    end
    it "should generate new parameter" do
      @links.should parse_to("<a href=\"/goods/new\">Create</a>")
    end
  end
  context "with new param with label" do
    before do
      @links = "{% links %}{% link new one,new:goods %}{% endlinks %}"
    end
    it "should generate new with label" do
      @links.should parse_to("<a href=\"/goods/new\">new one</a>")
    end
  end
  context "with index param without label" do
    before do
      @links = "{% links %}{% link index:goods %}{% endlinks %}"
    end
    it "should generate index parameter" do
      @links.should parse_to("<a href=\"/goods\">Index</a>")
    end
  end
  context "with index param with label" do
    before do
      @links = "{% links %}{% link bads,index:goods %}{% endlinks %}"
    end
    it "should generate index parameter" do
      @links.should parse_to("<a href=\"/goods\">bads</a>")
    end
  end
  context "for singleton resources" do
    before do
      @user_drop = get_drop @@user_default_values
    end
    context "with view param without label" do
      before do
        @links = "{% links %}{% link view:user %}{% endlinks %}"
      end
      it "should generate view parameter" do
        @links.should parse_with_atributes_to("<a href=\"/liquid_demo_models/#{@user_drop.id}\">View</a>",
                                              'user' => @user_drop)
      end
    end
    context "with view param with label" do
      before do
        @links = "{% links %}{% link bads,view:user %}{% endlinks %}"
      end
      it "should generate view parameter" do
        @links.should parse_with_atributes_to("<a href=\"/liquid_demo_models/#{@user_drop.id}\">bads</a>",
                                              'user' => @user_drop)
      end
    end
    context "with edit param without label" do
      before do
        @links = "{% links %}{% link edit:user %}{% endlinks %}"
      end
      it "should generate edit parameter" do
        @links.should parse_with_atributes_to("<a href=\"/liquid_demo_models/#{@user_drop.id}/edit\">Edit</a>",
                                              'user' => @user_drop)
      end
    end
    context "with edit param with label" do
      before do
        @links = "{% links %}{% link bads,edit:user %}{% endlinks %}"
      end
      it "should generate edit parameter" do
        @links.should parse_with_atributes_to("<a href=\"/liquid_demo_models/#{@user_drop.id}/edit\">bads</a>",
                                              'user' => @user_drop)
      end
    end

    context "with delete param without label" do
      before do
        @links = "{% links %}{% link delete:user %}{% endlinks %}"
      end
      it "should generate delte parameter" do
        @links.should parse_with_atributes_to("<a href=\"/liquid_demo_models/#{@user_drop.id}\" onclick=\"#{gen_delete_onclick}\">Delete</a>",
                                              'user' => @user_drop)
      end
    end
    context "with delete param with label" do
      before do
        @links = "{% links %}{% link bads,delete:user %}{% endlinks %}"
      end
      it "should generate delete parameter" do
        @links.should parse_with_atributes_to("<a href=\"/liquid_demo_models/#{@user_drop.id}\" onclick=\"#{gen_delete_onclick}\">bads</a>",
                                              'user' => @user_drop)
      end
    end

  end

  end

end


