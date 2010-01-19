module Clot
  class FormTag < LiquidForm

    def get_form_header(context)
      "<form action=\"#{resolve_value @form_object,context}\" method=\"#{@http_method}\"#{@upload_info}>"
    end
    def get_form_errors
      ""
    end

    def set_variables(context)
      set_method
      set_upload
      #super
    end

    def set_method
      @http_method = @attributes['method'] ||= 'post'
    end

  end


end