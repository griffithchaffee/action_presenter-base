module ActionPresenter
  class Base
    BOOTSTRAP_SIZES = %w[ xs sm md lg ]
    def self.generate_bootstrap_presenter_methods!
      ["", "offset"].each do |namespace|
        define_method("col_#{namespace}_class".squeeze("_")) do |*hashes, &content_block|
          classes = []
          BOOTSTRAP_SIZES.each do |col_size|
            col_width = extract("col_#{col_size}", *hashes).to_i.nonzero?
            if col_width
              col_width += 1 if extract("#{col_size}_expand", *hashes) == true && col_width < 11
              col_width -= 1 if extract("#{col_size}_compact", *hashes) == true && col_width > 2
              raise ArgumentError, "col_width must be between 1 and 12" if !col_width.between?(1,12)
              # col-sm-3
              classes << "col-#{col_size}-#{namespace}-#{col_width}".squeeze("-")
            end
          end
          [extract_html(*hashes)[:class], *classes].join(" ")
        end
      end

      define_method(:col_div) do |*hashes, &content_block|
        classes = []
        BOOTSTRAP_SIZES.each do |col_size|
          col_width = extract("col_#{col_size}", *hashes).to_i.nonzero?
          col_offset_width = extract("col_#{col_size}_offset", *hashes).to_i.nonzero?
          if col_width
            col_width += 1 if extract("#{col_size}_expand", *hashes) == true && col_width < 11
            col_width -= 1 if extract("#{col_size}_compact", *hashes) == true && col_width > 2
            classes << col_class("col_#{col_size}" => col_width)
          end
          if col_offset_width
            col_offset_width += 1 if extract("#{col_size}_offset_expand", *hashes) == true && col_offset_width < 11
            col_offset_width -= 1 if extract("#{col_size}_offset_compact", *hashes) == true && col_offset_width > 2
            raise ArgumentError, "col_width must be between 1 and 12" if !col_offset_width.between?(1,12)
            classes << col_offset_class("col_#{col_size}" => col_offset_width)
          end
        end
        div_tag(*hashes, add_class: classes.join(" "), &content_block)
      end

      define_method(:check_box_div_label) do |*hashes, &content_block|
        content = extract_content(*hashes, &content_block)
        check_box_div(*hashes) { label_tag(content: content) }
      end

      define_method(:label_span) do |label, *hashes, &content_block|
        span_tag(*hashes, add_class: "label label-#{label}", &content_block)
      end

      define_method(:alert_div) do |alert, *hashes, &content_block|
        div_tag(*hashes, class: "alert alert-#{alert} alert-dismissible", role: "alert", &content_block)
      end

      define_method(:dismiss_button) do |target, *hashes, &content_block|
        button_tag(*hashes, "aria-label" => "Dismiss", data: { dismiss: target.to_s }, &content_block)
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

      # div
      define_extension(:div_tag, :row_div,         class: "row")
      define_extension(:div_tag, :form_group_div,  class: "form-group")
      define_extension(:div_tag, :dropdown_div,    class: "dropdown")
      define_extension(:div_tag, :check_box_div,   class: "checkbox")
      # span
      define_extension(:span_tag, :caret_span, class: "caret")
      # ul
      define_extension(:ul_tag, :dropdown_menu_ul, class: "dropdown-menu", role: "menu")
      # label
      define_extension(:label_tag, :radio_label,    class: "radio")
      define_extension(:label_tag, :check_box_label, class: "checkbox")
    end
  end
end
