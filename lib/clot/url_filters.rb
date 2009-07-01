module Clot
  module UrlFilters
    include ActionView::Helpers::TagHelper

    #get url from object
    def object_url(object, class_name = "")
      if (class_name.blank?)
        class_name = object.dropped_class.to_s.tableize
      end
      '/' + class_name + "/" + object.record_id.to_s
    end

    #get url from either object or string
    def get_url(target, class_name = "")
      if target.is_a? String
        target
      else
        object_url target, class_name
      end    
    end
    
    #get url from object and nested object
    def get_nested_url(target, nested_target, class_name = "", nested_class_name = "")
      get_url(target, class_name) + get_url(nested_target, nested_class_name)
    end

    #get url from object and nested object
    def get_nested_edit_url(target, nested_target, class_name = "", nested_class_name = "")
      get_url(target, class_name) + get_url(nested_target, nested_class_name) + "/edit"
    end    

    def index_url(class_name, message = "Index")
      content_tag :a, message, :href => "/" + class_name.tableize
    end
    
    def stylesheet_url(sheetname)
      stylesheet_url =  "/stylesheets/" + sheetname
      stylesheet_url
    end
    
  end
end
