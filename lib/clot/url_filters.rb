module Clot
  module UrlFilters
    include ActionView::Helpers::TagHelper
    
    def edit_link(target, message = "Edit", class_name = nil)
      url = get_url target, class_name    
      content_tag :a, message, :href => url + "/edit"
    end
    
    def object_url(object, class_name = nil)
      if (class_name.nil?)
        class_name = object.dropped_class.to_s.tableize
      end
    '/' + class_name + "/" + object.oid.to_s    
    end
    
    def get_url(target, class_name = nil)
      if target.is_a? String
        target
      else
        object_url target, class_name
      end    
    end
    
    def view_link(target, message = "View", class_name = nil)
      url = get_url target, class_name
      content_tag :a, message, :href => url
    end
    
    def index_url(class_name, message = "Index")
      content_tag :a, message, :href => "/" + class_name.tableize
    end
    
    def delete_link(target, message = "Delete", class_name = nil)
      url = get_url target, class_name
      at = "" #    TODO - add the security for xss security "var s = document.createElement('input'); s.setAttribute('type', 'hidden'); s.setAttribute('name', 'authenticity_token'); s.setAttribute('value', '" + token + "') ;f.appendChild(s);"
      content_tag :a, message, :href => url, :onclick => "if (confirm('Are you sure?')) { var f = document.createElement('form'); f.style.display = 'none'; this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;var m = document.createElement('input'); m.setAttribute('type', 'hidden'); m.setAttribute('name', '_method'); m.setAttribute('value', 'delete'); f.appendChild(m);" + at + "f.submit(); };return false;"
    end
    
    def stylesheet_url(sheetname)
      stylesheet_url =  "/stylesheets/" + sheetname
      stylesheet_url
    end
    
    def stylesheet_link(url)
    '<link href="'+ url +'"  media="screen" rel="stylesheet" type="text/css" />'
    end
    
    def index_link(controller, message = nil)
      if message.blank?
        controller_array = controller.split("_")
        controller_array.map! {|item| item.capitalize }
        message = controller_array.join(" ") + " Index"      
      end
    '<a href="/' + controller +'">' + message + '</a>'
    end
    
    def new_link(controller, message = nil)
      if message.blank?
        controller_array = controller.split("_")
        controller_array.map! {|item| item.capitalize }
        message = "New "  + controller_array.join(" ")
        message.chomp!("s")
      end
    '<a href="/' + controller +'/new">' + message + '</a>'
    end
    
    def drop_class_to_table_item(clazz)
      match = /_drops/.match clazz.to_s.tableize
      match.pre_match
    end
    
    def error_messages(object)
      return unless object.is_a? Liquid::Drop
      if object.errors.count > 0
        "HAS ERROR"
      end
    end
    
    def form_item(tag, message, required = false)
      tag_id = get_tag_prop("id", tag)
      
      form_string = ""
      if tag_id 
        form_string = " for=\"#{tag_id}\""
      end
      
      if required
        required_string = "<span class=\"required\">*</span>"
      else
        required_string = ""
      end
      
      "<p><label#{form_string}>#{message}#{required_string}</label>#{tag}</p>"
    end
    
    def set_param(tag, key, value)
      match = /#{key}="[^"]*"/.match tag
      if match
        return match.pre_match + "#{key}=\"#{value}\"" + match.post_match
      end
      
      match = /(\/>|>)/.match tag
      if match
        match.pre_match + " #{key}=\"#{value}\"" + match.to_s + match.post_match
      else
        tag
      end  
    end
    
    def submit_button(message)
        '<div class="form-submit-button"><input type="submit" value="' + message + '"/></div>'      
    end
    
    def input_to_select(input, data_class, sort_field="name")
      
      value_match = /value="([^"]*)"/.match input
      if value_match
        value_text = value_match[1]
      else
        value_text = ""
      end
      
      name_match = /name="[^"]*"/.match input
      if name_match
        name_text = " #{name_match[0]}"
      else
        name_text = ""
      end
      
      retval = "<select#{name_text}>"
      
      if data_class == "users"        
        users = get_regular_users
      elsif data_class == "projects"
        users = get_projects
      end
      
      users.each do | user |
        if (user.id.to_s == value_text)
          select_string = "selected=\"selected\""   
        end
        retval += "<option value=\"#{user.id}\" #{select_string}>" + user[sort_field] + "</option>"
      end
      
      retval += "</select>"      
      
      retval
    end
    
    #note - must reconstruct from scratch...
    def input_to_text(input)
      
      value_match = /value="([^"]*)"/.match input
      if value_match
        value_text = value_match[1]
      else
        value_text = ""
      end
      
      name_match = /name="[^"]*"/.match input
      if name_match
        name_text = " #{name_match[0]}"
      else
        name_text = ""
      end
      
      "<textarea#{name_text}>#{value_text}</textarea>"
    end
    
    def input_to_checkbox(input)
      
      value_match = /value="([^"]*)"/.match input
      if value_match
        value_text = value_match[1]
      else
        value_text = ""
      end
      
      name_match = /name="[^"]*"/.match input
      if name_match
        name_text = " #{name_match[0]}"
      else
        name_text = ""
      end
      
      "<input type=\"checkbox\" value=\"true\" #{name_text} #{value_text == 'true' ? 'checked' : ''} />"
    end    
    
    
    def concat(string1, string2)
      "#{string1}#{string2}"
    end
    
    def simple_form_helper(name, value, errors )
      error_string = ""
      unless errors.blank?
        error_string = ' class="error-item"'
      end
      
      input = "<input type=\"text\" id=\"#{name}\" name=\"#{name}\" value=\"#{value}\"#{error_string}/>"
      
      input
    end
    
    def page_link_for(url, page, message)
      "<a href=\"" + url + "?page=" + page.to_s + "\">" + message + "</a>" 
    end
    
    def will_paginate(collection, url)
      total = collection.total_pages
      
      if total <= 1
        return ""
      end
      
      links = '<div class="pagination-links">'
      current = collection.current_page
      if current > 1
        links += page_link_for(url,1, "&lt;&lt;")  + " "
        links += page_link_for(url,current - 1, "&lt;")  + " "
      end     
      
       (1..(total)).each do |index|
        if index != 1
          links += " | "
        end
        
        if index == current
          links += index.to_s
        else
          links += page_link_for(url,index,index.to_s)
        end
      end
      
      if current < total
        links += " " + page_link_for(url, current + 1, "&gt;")
        links += " " + page_link_for(url, total, "&gt;&gt;")
      end           
      
      links += "</div>"
    end
    
    def get_by_id(class_name, id, name_field)
      obj = class_name.constantize.send :find, id
      obj[:name_field]
    end  
    
    def escape_html(html)
      html_escape(html)
    end
    
    def get_tag_prop(prop, input)
      prop_match = /#{prop}="([^"]*)"/.match input
      if prop_match
        prop_match[1]
      end
    end
    
  end
end
