class Field

  def initialize(property_name, title, html_options = nil)
    @property_name = property_name
    @title = title
    @html_options = html_options
  end

  attr_reader :property_name
  attr_reader :title
  attr_reader :html_options

  def editor_html(form)
    raise "Unimplemented"
  end

  def display_html(model)
    value = model.send(@property_name)
    display_html_for(value)
  end

  protected

  def display_html_for(value)
    if value.is_a? TrueClass
      "Yes"
    elsif value.is_a? FalseClass
      "No"
    else
      value.to_s
    end
  end

  def simple_form_params
    if (html_options)
      [@property_name, html_options]
    else
      [@property_name]
    end
  end

  class Text < Field
    def editor_html(form)
      form.text_field(*simple_form_params)
    end
  end

  class TextArea < Field
    def editor_html(form)
      form.text_area(*simple_form_params)
    end
  end

  class DateTime < Field
    def editor_html(form)
      form.datetime_select(*simple_form_params)
    end
  end

  class CheckBox < Field
    def editor_html(form)
      form.check_box(*simple_form_params)
    end
  end

  class YesNo < Field
    def editor_html(form)
      yes_box = radio_button(form, true, html_options)
      no_box = radio_button(form, false, html_options)
      label(yes_box, "Yes") + label(no_box, "No")
    end

    protected
    def label(*html)
      "<label>" + html.join(" ") + "</label>"
    end

    def radio_button(form, state, html_options)
      args = [@property_name, state]
      args << html_options if html_options
      form.radio_button(*args)
    end
  end

  class Color < Field
    def display_html_for(value)
      value.name
    end

    def editor_html(form)
      colors = form.object.send(@property_name.to_s.pluralize.to_sym)
      args = ["#{@property_name}_id".to_sym, colors, "id", "name"]
      args << html_options if html_options
      form.collection_select(*args)
    end
  end

  class Money < Field
    def display_html_for(value)
      value.nil? ? "" : value.to_s.to_currency
    end

    def editor_html(form)
      text_field = form.text_field(*simple_form_params)
      "<span class='currency_symbol'>$</span>#{text_field}<span class='field_example'>e.g. 12345.67</span>"
    end
  end

  class State < Field
    def display_html_for(value)
      States::US.full_name_for(value)
    end

    def editor_html(form)
      states = form.object.send(@property_name.to_s.pluralize.to_sym)
      disabled = form.object.title ? false : true

      if html_options || disabled
        options = html_options ? html_options.clone : {}
        options[:disabled] = true if disabled
        form.select(@property_name.to_sym, states, {}, options)
      else
        form.select(@property_name.to_sym, states)
      end
    end
  end


end
