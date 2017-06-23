module ActionPresenter
  class Base
    def self.generate_bootstrap_presenter_methods!
      %w[ xs sm md lg ].each do |size|
        define_method("col_#{size}_class") { |width| "col-#{size}-#{width}" }
        define_method("col_#{size}_offset_class") { |width| "col-#{size}-offset-#{width}" }
        define_method("col_#{size}_div") do |width, *params, &content_block|
          div_tag(*params, add_class: send("col_#{size}_class", width), &content_block)
        end
      end

      define_method(:col_div) do |size, *hashes, &content_block|
        classes = []
        %w[ xs sm md lg ].each do |col_size|
          col_width = extract("col_#{col_size}", *hashes).to_i
          if col_width
            col_width += 1 if extract("#{col_size}_expand", *hashes) == true && col_width < 11
            col_width -= 1 if extract("#{col_size}_compact", *hashes) == true && col_width > 2
            classes << send("col_#{col_size}_class", col_width)
          end
        end
        div_tag(*hashes, add_class: classes.join(" "), &content_block)
      end

      define_method(:check_box_div_label) do |*hashes, &content_block|
        check_box_div { label_tag(*hashes, &content_block) }
      end

      define_method(:label_span) do |label, *hashes, &content_block|
        span_tag(*hashes, add_class: "label label-#{label}", &content_block)
      end

      define_method(:alert_div) do |alert, *hashes, &content_block|
        div_tag(*hashes, class: "alert alert-#{alert} alert-dismissible", role: "alert" &content_block)
      end

      define_method(:alert_dismiss_button) do |*hashes|
        button_tag(*hashes, class: "close", aria_label: "Close", data: { dismiss: "alert" }) do
          span_tag(aria_hidden: "true", content: "&times;")
        end
      end

      define_method(:dropdown_toggle_btn) do |*hashes, &content_block|
        btn = extract(:btn, *hashes, btn: "default")
        button_tag(*hashes, class: "btn btn-#{btn} dropdown-toggle", data: { toggle: "dropdown" }, &content_block)
      end

      define_method(:glyphicon) do |glyphicon, *hashes, &content_block|
        span_tag(*hashes, add_class: "glyphicon glyphicon-#{glyphicon}", &content_block)
      end

      # override core classes
      {
        core_label_class:     -> { "control-label" },
        core_select_class:    -> { "form-control" },
        core_field_class:     -> { "form-control" },
        core_text_area_class: -> { "form-control" },
      }.each do |method, block|
        define_method(method, &block)
      end

      # col div
      define_html_method_extension(:col_div, :full_div, col_sm: 8, col_md: 6)
      define_html_method_extension(:col_div, :modal_full_div, col_sm: 10)
      # div
      define_html_method_extension(:div_tag, :row_div,         class: "row")
      define_html_method_extension(:div_tag, :form_group_div,  class: "form-group")
      define_html_method_extension(:div_tag, :dropdown_div,    class: "dropdown")
      define_html_method_extension(:div_tag, :check_box_div,   class: "checkbox")
      # span
      define_html_method_extension(:span_tag, :caret_span, class: "caret")
      # ul
      define_html_method_extension(:ul_tag, :dropdown_menu_ul, class: "dropdown-menu", role: "menu")
      # label
      define_html_method_extension(:label_tag, :radio_label,    class: "radio")
      define_html_method_extension(:label_tag, :check_box_label, class: "checkbox")
    end
  end
end
