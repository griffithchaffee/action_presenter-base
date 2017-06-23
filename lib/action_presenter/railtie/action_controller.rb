module ActionPresenter
  ActiveSupport.on_load(:action_controller) do
    ::ActionController::Base.class_eval do
      def presenter_options
        @presenter_options ||= self.class.presenter_options.dup
      end

      class << self
        def presenter_options
          @presenter_options ||= ActiveSupport::OrderedOptions.new.merge(
            presenter_name: controller_name.gsub(/\W/, "_").underscore,
          )
        end
      end
    end
  end
end
