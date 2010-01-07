require File.dirname(__FILE__) + '/spec_helper'

class LinksBlock < Liquid::Block
  attr_accessor :links

  def split_params(params)
    params.split(",").map(&:strip)
  end

  def initialize(name, params, tokens)
    @links = []
    super
  end

  def link_tag(params)
    params = split_params(params)
    link_label = link = params[0][1..-1]
    link = "/#{link}"
    @link_exists ? separator = (GenericTagFactory[:list_item_separator] || "") : separator = ""
    @link_exists = true
    prefix = GenericTagFactory[:list_item_open_tag] || ""
    postfix = GenericTagFactory[:list_item_close_tag] || ""    
    @nodelist << "#{separator}#{prefix}<a href=\"#{link}\">#{link_label}</a>#{postfix}"
  end

  def unknown_tag(name, params, tokens)
    if name == "link"
      link_tag(params)
    else
      super
    end
  end

  def get_nav_body(context)
    context.stack do
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


describe "when using links" do
  include Clot::UrlFilters
  include Clot::LinkFilters

  include Liquid  


  before do
    @context = {}
    GenericTagFactory[:list_open_tag] = ""
    GenericTagFactory[:list_close_tag] = ""
    GenericTagFactory[:list_item_open_tag] = ""
    GenericTagFactory[:list_item_close_tag] = ""
    GenericTagFactory[:list_item_separator] = ""  
  end
  context "with multiple links" do
    before do
      @links = "{% links %}{% link :hello %}{% link :goodbye %}{% endlinks %}"
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
    end
  end

  context "with a single link" do
    before do
      @links = "{% links %}{% link :hello %}{% endlinks %}"
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
end