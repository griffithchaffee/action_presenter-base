module ActionPresenter
  class Base

    def html_tag(tag, *hashes, &content_block)
      view.content_tag(tag, extract_html(*hashes), &extract_content_block(*hashes, &content_block))
    end

    def inline_html_tag(tag, *hashes, &content_block)
      view.tag(tag, extract_html(*hashes), &extract_content_block(*hashes, &content_block))
    end

    # html block tags
    %w[
      body iframe
      div span p a label pre
      legend h1 h2 h3 h4 h5 h6
      ol ul li dl dd dt
      table tbody th td tr
      b strong i em small abbr
    ].each do |tag|
      define_method("#{tag}_tag") do |*hashes, &content_block|
        html_tag(tag, *hashes, &content_block)
      end
    end

    # inline html tags
    %w[ br hr input img meta ].each do |tag|
      define_method("#{tag}_tag") do |*hashes, &content_block|
        inline_html_tag(tag, *hashes, &content_block)
      end
    end

    def button_tag(*hashes, &content_block)
      default_html = { type: "button" }
      html_tag(:button, *hashes, default_html, &content_block)
    end

    def submit_tag(*hashes, &content_block)
      view.submit_tag(extract_content(*hashes, content: "Submit", &content_block), extract_html(*hashes))
    end

    def method_field(*hashes, &content_block)
      hidden_field_tag("_method", *hashes, id: nil, value: "post", &content_block)
    end

    def image_tag(name, *hashes, &content_block)
      view.image_tag(name, extract_html(*hashes), &extract_content_block(*hashes, &content_block))
    end

    def link_to(link, *hashes, &content_block)
      view.link_to(link, extract_html(*hashes), &extract_content_block(*hashes, &content_block))
    end

    # form elements
    def select_tag(name, *hashes, &content_block)
      default_html = { id: name.to_s.html_slugify, name: name, class: select_class }
      content = extract_content(*hashes, &content_block)
      if !content.is_a?(String)
        content = view.options_for_select(content, extract(:selected, *hashes, selected: view.params.dig_html(name)))
      end
      view.select_tag(name, content, extract_html(*hashes, default_html))
    end

    def text_field_tag(name, *hashes, &content_block)
      default_html = { id: name.to_s.html_slugify, name: name, class: text_field_class }
      content = extract_content(*hashes, content: view.params.dig_html(name), &content_block)
      view.text_field_tag(name, content, extract_html(*hashes, default_html))
    end

    def file_field_tag(name, *hashes, &content_block)
      default_html = { id: name.to_s.html_slugify, name: name, class: file_field_class }
      view.file_field_tag(name, extract_html(*hashes, default_html))
    end

    def hidden_field_tag(name, *hashes, &content_block)
      default_html = { id: name.to_s.html_slugify, name: name }
      content = extract_content(*hashes, content: view.params.dig_html(name), &content_block)
      view.hidden_field_tag(name, content, extract_html(*hashes, default_html))
    end

    def text_area_tag(name, *hashes, &content_block)
      default_html = { id: name.to_s.html_slugify, name: name, class: text_area_class }
      content = extract_content(*hashes, content: view.params.dig_html(name), &content_block)
      view.text_area_tag(name, content, extract_html(*hashes, default_html))
    end

    def label_for(name, *hashes, &content_block)
      default_html = { class: label_for_class }
      view.label_tag(name, extract_html(*hashes, default_html), &extract_content_block(*hashes, &content_block))
    end

    def check_box_tag(name, *hashes, &content_block)
      default_html = { id: name.to_s.html_slugify, name: name, class: check_box_class }
      check_box_html = extract_html(*hashes, default_html)
      unchecked_value = extract(:unchecked_value, *hashes, unchecked_value: "false").presence
      checked_value   = extract(:checked_value, *hashes, checked_value: "true").presence
      checked         = extract(:checked, *hashes, checked: view.params.dig_html(name).presence == checked_value).present?
      unchecked_tag = view.check_box_tag(nil, unchecked_value, true, check_box_html.merge(id: nil, class: "hidden"))
      checked_tag   = view.check_box_tag(nil, checked_value, checked, check_box_html)
      unchecked_value.present? ? unchecked_tag + checked_tag : checked_tag
    end

    def radio_button_tag(name, *hashes, &content_block)
      default_html = { id: name.to_s.html_slugify, name: name, class: radio_button_class }
      content = extract_content(*hashes, &content_block).presence || view.params.dig_html(name).presence
      checked = extract(:checked, *hashes)
      checked = checked.in?([true, false]) ? checked : checked.to_s.presence == content
      view.radio_button_tag(nil, content, checked, extract_html(*hashes, default_html))
    end

    # html classes
    {
      # core
      core_label_class:        -> { "" },
      core_select_class:       -> { "" },
      core_field_class:        -> { "" },
      core_text_area_class:    -> { "" },
      core_check_box_class:    -> { "" },
      core_radio_button_class: -> { "" },
      # labels
      label_class:     -> { core_label_class },
      label_for_class: -> { core_label_class },
      # selects
      select_class:          -> { core_select_class },
      date_select_class:     -> { core_select_class },
      datetime_select_class: -> { core_select_class },
      # fields
      text_field_class: -> { core_field_class },
      file_field_class: -> { core_field_class },
      # text_area
      text_area_class: -> { core_text_area_class },
      # check_box
      check_box_class: -> { core_check_box_class },
      # radio_button
      radio_button_class: -> { core_radio_button_class },
    }.each do |method, block|
      define_method(method, &block)
    end

    # element extensions
    define_extension(:script_tag, :javascript_script_tag, type: "text/javascript")
    define_extension(:style_tag, :css_style_tag, type: "text/css")
    define_extension(:link_to, :tab_to, target: "_blank")

  end
end
