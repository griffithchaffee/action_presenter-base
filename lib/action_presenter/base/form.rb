module ActionPresenter
  class Base
    attr_reader :form

    def form=(new_form)
      @form = new_form
      self.record = form.try(:object)
      @form
    end

    # form elements
    def label(name, *hashes, &content_block)
      default_html = { class: label_class }
      form.label(name, extract_html(*hashes, default_html), &extract_content_block(*hashes, &content_block))
    end

    def text_field(name, *hashes, &content_block)
      default_html = { class: text_field_class, value: extract_content(*hashes, &content_block) }
      form.text_field(name, extract_html(*hashes, default_html))
    end

    def hidden_field(name, *hashes, &content_block)
      default_html = { value: extract_content(*hashes, &content_block) }
      form.hidden_field(name, extract_html(*hashes, default_html))
    end

    def text_area(name, *hashes, &content_block)
      default_html = { class: text_area_class, value: extract_content(*hashes, &content_block) }
      form.text_area(name, extract_html(*hashes, default_html))
    end

    def select(name, *hashes, &content_block)
      default_html = { class: select_class }
      content = extract_content(*hashes, &content_block) || {}
      select_options = %i[ include_blank prompt ].map { |key| [key, extract(key, *hashes)] }.to_h
      form.select(name, content, select_options, extract_html(*hashes, default_html))
    end

    def date_select(name, *hashes)
      default_html = { class: date_select_class }
      hashes << { order: %i[ month day year ] }
      select_options = {}
      %i[
        include_blank prompt
        order default start_year end_year add_month_numbers use_short_month
      ].each { |key| select_options[key] = extract(key, *hashes) }
      form.date_select(name, select_options.compact, extract_html(*hashes, default_html))
    end

    def datetime_select(name, *hashes)
      default_html = { class: datetime_select_class }
      hashes << { order: %i[ month day year ], ampm: true }
      select_options = {}
      %i[
        include_blank prompt
        ampm order default start_year end_year
      ].each { |key| select_options[key] = extract(key, *hashes) }
      form.datetime_select(name, select_options, extract_html(*hashes, class: datetime_select_class))
    end

    def check_box(name, *hashes)
      default_html = { class: check_box_class }
      checked_value   = extract(:checked_value, *hashes, checked_value: "true")
      unchecked_value = extract(:unchecked_value, *hashes, unchecked_value: "false")
      form.check_box(name, extract_html(*hashes, default_html), checked_value, unchecked_value)
    end

    def radio_button(name, *hashes, &content_block)
      default_html = { class: radio_button_class }
      content = extract_content(*hashes, &content_block).to_s
      form.radio_button(name, content, extract_html(*hashes, default_html))
    end
  end
end
