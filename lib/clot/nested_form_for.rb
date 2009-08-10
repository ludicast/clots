module Clot

class LiquidNestedFormFor < LiquidFormFor
  NestedSyntax = /([^\s]+)\s+(.*)/
  def initialize(tag_name, markup, tokens)
    if markup =~ NestedSyntax
      @parent_object = $1
      remaining_markup = $2

    else
      syntax_error
    end

    super tag_name, remaining_markup, tokens
  end

  def set_variables(context)
    @parent_model = context[@parent_object]
    super
  end

  def determine_form_action
    super

    @form_action = object_url(@parent_model) + @form_action
  end

  def set_context_info(context, model, item_prefix = "form_")
    super context, model, item_prefix
    super context, @parent_model, "parent_form_"
  end

end

end
