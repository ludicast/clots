# Clots

This project seeks to implement extensions for liquid whereby it has the power of other template libraries.

One of the big benefits of liquid is that it enforces a strict MVC paradign where the V cannot affect the M.  This is done for security reasons, but is an excellent approach to coding views in general.  Therefore, we seek to make liquid a fuller template library so it can be used for all views, not just ones that joe user can modify.

## Changes

We have changed the code to be simpler and match the form builders that Rails developers are used to.  Therefore most of the tag names changed to be consistent with the Rails conventions.

Most tags also expect as input either liquid objects, quoted strings, integers, floats, booleans, or arrays.  To simplify arrays, they are expected to be surrounded by brackets and use spaces as delimiters.  An exaple array would be

    [1 true "hello" "world"]

## Links

You now can include an intelligent navigation menu, that allows you to exclude items on-demand (for access control, etc.).  We will document this further, but for the meantime the test cases show how this may be used.

## Form Builder

Clots allows a form to be created like so

    {% error_messages_for pizza %}
    {% form_for pizza %}
        <p>
            {% label "name" %}<br />
            {% text_field "name" %}
        </p>
        <p>
            {% label "crust_type_id" %}
            {% collection_select "crust_type_id", crust_types %}
        </p>

        <p>
            {% check_box "crispy" %}
            {% label "crispy", "Extra Crispy" %}
        </p>

        <h3>Toppings</h3>

        {% for topping in toppings %}
            <p>
                {% check_box_tag 'pizza[topping_ids][]', topping.id, collection:pizza.topping_ids, member:topping.id %}
                {{ topping.name }}
            </p>
        {% endfor %}
        {% hidden_field_tag 'pizza[topping_ids][]', '' %}

        <p>{% submit_tag "Submit" %}</p>
    {% endform_for %}

And generate:

    <form method="POST" action="/pizzas/"><input name="authenticity_token" type="hidden" value="Yaq1/ZWedB7Qg21YZkPibVv9YzfVcY+J4yJRlPrT/Bk="/>
        <p>
            <label for="pizza_name">Name</label><br />
            <input id="pizza_name" name="pizza[name]" type="text" />
        </p>
        <p>
            <label for="pizza_crust_type_id">Crust type</label>
            <select id="pizza_crust_type_id" name="pizza[crust_type_id]"><option value="1">Thin</option><option value="2">Thick</option><option value="3">Deep Dish</option></select>
        </p>

        <p>
            <input name="pizza[crispy]" type="hidden" value="0" /><input id="pizza_crispy" name="pizza[crispy]" type="checkbox" value="1" />
            <label for="pizza_crispy">Extra Crispy</label>
        </p>

        <h3>Toppings</h3>
        <p>
            <input id="pizza[topping_ids][]" name="pizza[topping_ids][]" type="checkbox" value="1" />
            Pepperoni
        </p>
        <p>
            <input id="pizza[topping_ids][]" name="pizza[topping_ids][]" type="checkbox" value="2" />
            Sausage
        </p>

        <p>
            <input id="pizza[topping_ids][]" name="pizza[topping_ids][]" type="checkbox" value="3" />
            Onion
        </p>
        <input id="pizza[topping_ids][]" name="pizza[topping_ids][]" type="hidden" value="" />
        <p><input type="submit" name="commit" value="Submit" /></p>
    </form>


If there were errors, they would both appear at the top of the form and wrap the invalid form items.  You'll note also that CSRF protection is added if enabled.

Note that the interface to this changed and we are currently documenting the improvements.


## BaseDrop Class

In order for everything to work correctly, it is necessary that your drops inherit from our Clots::BaseDrop class.  BaseDrop is pretty much ripped out of the Mephisto project.

Your Drops inheriting from it can then add additional attributes, just like in Mephisto:

    class BookDrop < Clot::Base
        liquid_attributes << :title << :author_id << :genre_id
    end

would provide a drop with access to the title, author_id and genre properties of the underlying ActiveRecord.

We also added a few extra methods to the BaseDrop class (as well as taking some out that were specific to Mephisto):

    def id
      @source.id
    end

    def dropped_class
      @source.class
    end

    def errors
      @source.errors
    end 

This is necessary for having the BaseDrop and its subclasses interact properly with our form builder and filters.  You would probably be fine just adding these methods to your current drops as well - they are just useful for the form builder and other tools.

In addition, drops may have has_many and belongs_to options which create the usual association methods that delegate to your internal class.

## to_liquid added to ActiveRecord::Base

We made the to_liquid method a little DRYer, favoring convention over configuration.  to_liquid is now automatically added to the ActiveRecord::Base class, and - unless overridden - works as follows:

a) When to_liquid is called on a model, it searches for a class of the same name with "Drop" appended to it. (obviously you'd have to have a drop folder somewhere in your path)
b) In cases of Single-Table-Inheritance, it follows the inheritance chain until it finds the appropriate drop.  So if you have an Admin model that inherits from a User model, will use UserDrop if no AdminDrop exists.
c) It then instantiates the appropriate drop class, with the active record as a parameter to the drop's constructor.

We thought this would be better than explicitly throwing to_liquid into the model through my "acts_as_liquid" or explicitly adding "to_liquid" to each model.  Philosophically speaking, we don't think models should contain any code that exists only to deal with the views.

## content_for and yield tags

Tags have been defined to provide similar functionality to rail's 'content_for' and 'yield' statements.  

The 'yield' tag is similar in function to liquid's 'include' tag, however the template name is automagically prefixed with the current controller and view directories.  This means that rather than defining a content_for tag in a view, the tag should be placed in a sub-folder of the view named after the action it will be called from.  Using the yield tag without any arguments will insert the content_for_layout variable, so it can be used the same as a typical yield statement.

The if_content_for block simply checks to see if a given template file exists and then outputs its contentents if so.

In order to use either of these tags (or the include tag) something similar to this will need to be added as a before_filter on your controller

    Liquid::Template.file_system = Liquid::LocalFileSystem.new( MyController.view_paths )
  
## Filters for RESTful routes

We added some filters for restful routes.  These are contained within the url_filters directory.

## Test Cases

We have tried to write tests for all aspects of our plugin.  Reading the tests is a good way to learn about how everything works.

## Ruby Versions

We support Ruby 1.8.7 and 1.9.1

Copyright (c) 2008 Ludicast