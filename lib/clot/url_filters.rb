module Clot
  module UrlFilters

   # include ActionView::Helpers::TagHelper

    #get url from object
    def object_url(target, class_name = "")
      if (class_name.blank?)
        class_name = target.dropped_class.to_s.tableize
      end
      '/' + class_name + "/" + target.id.to_s
    end

    #get url from object and nested object
    def get_nested_url(target, nested_target, class_name = "", nested_class_name = "")
      child_url = (nested_target.kind_of? String) ? nested_target : object_url(nested_target, nested_class_name)
      object_url(target, class_name) + child_url
    end

    #get url from object and nested object
    def get_nested_edit_url(target, nested_target, class_name = "", nested_class_name = "")
      object_url(target, class_name) + object_url(nested_target, nested_class_name) + "/edit"
    end    

    def stylesheet_url(sheetname)
      url =  "/stylesheets/" + sheetname + ".css"
      url
    end
    
    def edit_link(obj, text="Edit")
      url = ( obj.kind_of?( Liquid::Drop ) ? object_url( obj ) : obj )
      "<a href=\"#{url}/edit\">#{text}</a>"
    end
    
    def delete_link(obj, text="Delete")
      url = ( obj.kind_of?( Liquid::Drop ) ? object_url( obj ) : obj )
      "<a href=\"#{url}/delete\">#{text}</a>"
    end
    
    def view_link(obj, text=nil)
      url = ( obj.kind_of?( Liquid::Drop ) ? object_url( obj ) : obj )
      "<a href=\"#{url}\">#{text ? text : url.capitalize}</a>"
    end
    
    def index_link(obj, text=nil)
      url = ( obj.kind_of?( Liquid::Drop ) ? object_url( obj ) : obj )
      "<a href=\"/#{url}\">#{text ? text : url.capitalize+' Index'}</a>"
    end
  end
end
