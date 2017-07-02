module ActionPresenter
  class Base
    # inheritance tracking
    PRESENTER_CLASSES = []

    def self.inherited(new_presenter_class)
      PRESENTER_CLASSES << new_presenter_class
      super
    end

    # core methods
    def initialize
    end

    PRESENTER_ATTRIBUTES = %i[ content record ]

    attr_accessor :record, :view

    def set(options)
      options.each { |method, value| send "#{method}=", value }
      self
    end

    def presenter_options
      self.class.presenter_options.dup
    end

    def extract(key, *hashes)
      hashes.compact.map do |hash|
        begin
          hash.delete(key.to_sym) || hash.delete(key.to_s)
        rescue StandardError => error
          raise ArgumentError, "#{error.class} while trying to extract key #{key.inspect} from #{hash.inspect}: #{error.message}"
        end
      end.compact.first
    end

    def extract_html(*hashes)
      html_attributes = {}
      add_classes = []
      remove_classes = []
      merge_data = {}
      reverse_merge_data = {}
      hashes.each do |hash|
        next if hash.blank?
        # custom class attributes
        add_class = extract(:add_class, hash)
        add_classes << add_class if add_class.present?
        remove_class = extract(:remove_class, hash)
        remove_classes << remove_class if remove_class.present?
        # custom data attributes
        merging_data = extract(:merge_data, hash)
        merge_data.merge!(merging_data.to_h.symbolize_keys) if merging_data.present?
        reverse_merging_data = extract(:reverse_merge_data, hash)
        reverse_merge_data.merge!(reverse_merging_data.to_h.symbolize_keys) if reverse_merging_data.present?
        # rest
        html_attributes.reverse_merge!(hash.symbolize_keys)
      end
      # custom class attributes
      if add_classes.present? || remove_classes.present?
        classes_to_a = -> (value) do
          case value
          when Symbol then classes_to_a.call(send(value))
          when Array then value.map { |v| classes_to_a.call(v) }
          else value.to_s.split(/\s/)
          end.flatten
        end
        classes = classes_to_a.call(html_attributes[:class])
        classes += classes_to_a.call(add_classes)
        classes -= classes_to_a.call(remove_classes)
        # reverse so classes appear to append in order
        html_attributes[:class] = classes.uniq.join(" ").presence
      end
      # custom data attributes
      if merge_data.present? || reverse_merge_data.present?
        html_attributes[:data] ||= {}
        html_attributes[:data].merge!(merge_data) if merge_data.present?
        html_attributes[:data].reverse_merge!(reverse_merge_data) if reverse_merge_data.present?
      end
      html_attributes.select do |html_attribute, value|
        !html_attribute.in?(PRESENTER_ATTRIBUTES)
      end
    end

    def extract_content(*hashes, &content_block)
      content = extract(:content, *hashes)
      # block has highest precedence
      content = view.capture(&content_block) if content_block.is_a?(Proc)
      content = content.to_s if content.is_a?(Numeric)
      # check for escaped HTML
      if presenter_options.verify_content && !content.is_a?(ActiveSupport::SafeBuffer)
        if content =~ /<[a-zA-Z]+( |>)/ || content =~ /&nbsp/
          warning_message = "Escaped HTML in #{self.class} content: #{content}"
          if Rails.env.production?
            Rails.logger.warn { warning_message }
          else
            raise ArgumentError, warning_message
          end
        end
      end
      content
    end

    def extract_content_block(*hashes, &content_block)
      content_block.is_a?(Proc) ? content_block : proc { extract_content(*hashes) }
    end

    def extract_record(*hashes)
      extract(:record, *hashes, record: record)
    end

    def extract_query_params(*hashes)
      extract(:query_params, *hashes, query_params: {})
    end

    class << self
      def define_extension(base_method, new_method, *extension_params)
        define_method(new_method) do |*params, &content_block|
          send(base_method, *params, *extension_params.deep_dup, &content_block)
        end
      end

      def presenter_options
        @presenter_options ||= ActiveSupport::OrderedOptions.new.merge(
          verify_content: true,
          presents: name.underscore.remove(/_presenter\z/).singularize.to_sym,
        )
      end
    end
  end
end

require "action_presenter/version"
require "action_presenter/ruby/string"
require "action_presenter/ruby/hash"
require "action_presenter/base/html"
require "action_presenter/base/form"
require "action_presenter/base/bootstrap"
require "action_presenter/railtie" if defined?(Rails)
