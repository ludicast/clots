require File.dirname(__FILE__) + '/spec_helper'
require 'clot/nav_bar'

Liquid::Template.register_tag('link', Clot::LinkItem)
Liquid::Template.register_tag('links', Clot::LinksBlock)
Liquid::Template.register_tag('link_separator', Clot::LinkSeparator)

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
  GenericTagFactory[:link_filter] = lambda { |link, context|
    case link
      when /bad1/ then
        ""
      when /bad2/ then
        nil
      when /bad3/ then
        false
      else
        link
    end
  }
end

AlternativeFactory = {}

describe "when using links" do
  include Clot::UrlFilters
  include Clot::LinkFilters

  include Liquid


  before do
    @context = {}
    Clot::LinkItem.has_predecessor = false
    GenericTagFactory[:list_open_tag] = ""
    GenericTagFactory[:list_close_tag] = ""
    GenericTagFactory[:list_item_open_tag] = ""
    GenericTagFactory[:list_item_close_tag] = ""
    GenericTagFactory[:list_item_separator] = ""
    GenericTagFactory[:link_filter] = lambda{|link, context| link}
  end

  context "with alternative factory" do

    before do

      AlternativeFactory[:list_open_tag] = "<ul>"
      AlternativeFactory[:list_close_tag] = "</ul>"
      AlternativeFactory[:list_item_open_tag] = "<li>"
      AlternativeFactory[:list_item_close_tag] = "</li>"
      AlternativeFactory[:list_item_separator] = "<br/>---<br/>"
      AlternativeFactory[:link_filter] = lambda{|link, context|
        if link.match "luv" then
          false
        else
          true
        end
      }
      @links = "{% links factory_name:AlternativeFactory %}{% link luv %}{% link foo %}{% link bar %}{% link_separator %}{% endlinks %}"
    end

    it "should default to blank" do
      @links.should parse_to(
              '<ul><li><a href="/foo">foo</a></li><br/>---<br/><li><a href="/bar">bar</a></li><br/>---<br/></ul>'
      )
    end

  end


  context "for link separators" do
    before do
      @separator = "{% link_separator %}"
    end
    it "should default to blank" do
      @separator.should parse_to("")
    end
    context "when set" do
      before do
        set_separator
      end
      it "should set separator" do
        @separator.should parse_to(",")
      end
    end
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
    context "for nested resources" do

      before do
        @user_drop = get_drop user_default_values
      end
      context "when nested resource is class" do
        context "for new" do
          context "without label" do
            before do
              @links = "{% links %}{% link nested_new:user:tags %}{% endlinks %}"
            end
            it "should generate link" do
              @links.should parse_with_vars_to("<a href=\"/liquid_demo_models/#{@user_drop.id}/tags/new\">Create</a>",
                                               'user' => @user_drop)
            end
          end
          context "with assigned label" do
            before do
              @links = "{% links %}{% link nested_new:user:tags,label:foo %}{% endlinks %}"
            end
            it "should generate link with assigned label" do
              @links.should parse_with_vars_to("<a href=\"/liquid_demo_models/#{@user_drop.id}/tags/new\">foo</a>",
                                               'user' => @user_drop)
            end
          end
        end

        context "for index" do
          context "without label" do
            before do
              @links = "{% links %}{% link nested_index:user:tags %}{% endlinks %}"
            end
            it "should generate link" do
              @links.should parse_with_vars_to("<a href=\"/liquid_demo_models/#{@user_drop.id}/tags\">Index</a>",
                                               'user' => @user_drop)
            end
          end
          context "with assigned label" do
            before do
              @links = "{% links %}{% link nested_index:user:tags,label:foo %}{% endlinks %}"
            end
            it "should generate link with assigned label" do
              @links.should parse_with_vars_to("<a href=\"/liquid_demo_models/#{@user_drop.id}/tags\">foo</a>",
                                               'user' => @user_drop)
            end
          end
        end
      end
      context "when nested resource is object" do
        before do
          @tag_drop = get_drop user_default_values.merge(:id => rand(100))
        end

        context "for edit" do

          context "without label" do
            before do
              @links = "{% links %}{% link nested_edit:user:tag %}{% endlinks %}"
            end
            it "should generate link" do
              @links.should parse_with_vars_to("<a href=\"/liquid_demo_models/#{@user_drop.id}/liquid_demo_models/#{@tag_drop.id}/edit\">Edit</a>",
                                               'user' => @user_drop, 'tag' => @tag_drop)
            end
          end
          context "with assigned label" do
            before do
              @links = "{% links %}{% link nested_edit:user:tag,label:foo %}{% endlinks %}"
            end
            it "should generate link with assigned label" do
              @links.should parse_with_vars_to("<a href=\"/liquid_demo_models/#{@user_drop.id}/liquid_demo_models/#{@tag_drop.id}/edit\">foo</a>",
                                               'user' => @user_drop, 'tag' => @tag_drop)
            end
          end
        end

        context "for show" do

          context "without label" do
            before do
              @links = "{% links %}{% link nested_show:user:tag %}{% endlinks %}"
            end
            it "should generate link" do
              @links.should parse_with_vars_to("<a href=\"/liquid_demo_models/#{@user_drop.id}/liquid_demo_models/#{@tag_drop.id}\">Show</a>",
                                               'user' => @user_drop, 'tag' => @tag_drop)
            end
          end
          context "with assigned label" do
            before do
              @links = "{% links %}{% link nested_show:user:tag,label:foo %}{% endlinks %}"
            end
            it "should generate link with assigned label" do
              @links.should parse_with_vars_to("<a href=\"/liquid_demo_models/#{@user_drop.id}/liquid_demo_models/#{@tag_drop.id}\">foo</a>",
                                               'user' => @user_drop, 'tag' => @tag_drop)
            end
          end
        end

        context "for delete" do

          context "without label" do
            before do
              @links = "{% links %}{% link nested_delete:user:tag %}{% endlinks %}"
            end
            it "should generate link" do
              @links.should parse_with_vars_to("<a href=\"/liquid_demo_models/#{@user_drop.id}/liquid_demo_models/#{@tag_drop.id}\" onclick=\"#{gen_delete_onclick}\">Delete</a>",
                                               'user' => @user_drop, 'tag' => @tag_drop)
            end
          end
          context "with assigned label" do
            before do
              @links = "{% links %}{% link nested_delete:user:tag,label:foo %}{% endlinks %}"
            end
            it "should generate link with assigned label" do
              @links.should parse_with_vars_to("<a href=\"/liquid_demo_models/#{@user_drop.id}/liquid_demo_models/#{@tag_drop.id}\" onclick=\"#{gen_delete_onclick}\">foo</a>",
                                               'user' => @user_drop, 'tag' => @tag_drop)
            end
          end
        end

      end

    end

    context "for resource models" do
      before do
        @user_drop = get_drop user_default_values
      end
      context "with view param without label" do
        before do
          @links = "{% links %}{% link view:user %}{% endlinks %}"
        end
        it "should generate view parameter" do
          @links.should parse_with_vars_to("<a href=\"/liquid_demo_models/#{@user_drop.id}\">View</a>",
                                           'user' => @user_drop)
        end
      end
      context "with view param with label" do
        before do
          @links = "{% links %}{% link bads,view:user %}{% endlinks %}"
        end
        it "should generate view parameter" do
          @links.should parse_with_vars_to("<a href=\"/liquid_demo_models/#{@user_drop.id}\">bads</a>",
                                           'user' => @user_drop)
        end
      end
      context "with edit param without label" do
        before do
          @links = "{% links %}{% link edit:user %}{% endlinks %}"
        end
        it "should generate edit parameter" do
          @links.should parse_with_vars_to("<a href=\"/liquid_demo_models/#{@user_drop.id}/edit\">Edit</a>",
                                           'user' => @user_drop)
        end
      end
      context "with edit param with label" do
        before do
          @links = "{% links %}{% link bads,edit:user %}{% endlinks %}"
        end
        it "should generate edit parameter" do
          @links.should parse_with_vars_to("<a href=\"/liquid_demo_models/#{@user_drop.id}/edit\">bads</a>",
                                           'user' => @user_drop)
        end
      end

      context "with delete param without label" do
        before do
          @links = "{% links %}{% link delete:user %}{% endlinks %}"
        end
        it "should generate delte parameter" do
          @links.should parse_with_vars_to("<a href=\"/liquid_demo_models/#{@user_drop.id}\" onclick=\"#{gen_delete_onclick}\">Delete</a>",
                                           'user' => @user_drop)
        end
      end
      context "with delete param with label" do
        before do
          @links = "{% links %}{% link bads,delete:user %}{% endlinks %}"
        end
        it "should generate delete parameter" do
          @links.should parse_with_vars_to("<a href=\"/liquid_demo_models/#{@user_drop.id}\" onclick=\"#{gen_delete_onclick}\">bads</a>",
                                           'user' => @user_drop)
        end
      end
    end

  end

end


