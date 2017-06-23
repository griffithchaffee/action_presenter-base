module ActionPresenter
  ActiveSupport.on_load(:action_view) do
    ::ActionView::Base.class_eval do
      # dynamic presenter initializer
      def presenter(presenter_name, *params, &block)
        instance_variable = "@#{presenter_name}_presenter"
        presenter_instance = instance_variable_get(instance_variable)
        # return presenter_instance if already initialized
        return presenter_instance if presenter_instance
        # initialize presenter instance
        presenter_class_name = "#{presenter_name.camelize}Presenter"
        presenter_class = ::ActionPresenter::Base::PRESENTER_CLASSES.find do |presenter_class|
          presenter_class.name == presenter_class_name
        end
        raise ArgumentError, "#{presenter_class_name} is not defined" if !presenter_class
        presenter = presenter_class.new.set(view: self)
        instance_variable_set(instance_variable, presenter)
      end

      # controller presenter
      def controller_presenter
        return @controller_presenter if @controller_presenter
        presenter_name = controller.presenter_options.presenter_name
        @controller_presenter = presenter(presenter_name).tap do |new_presenter|
          # attempt to auto set record
          presents = new_presenter.presenter_options.presents
          new_presenter.record ||= instance_variable_get("@#{new_presenter.presenter_options.presents}")
        end
      end

      alias_method :cp, :controller_presenter

      # local presenter
      def local_presenter
        @local_presenter || raise(ArgumentError, "local presenter [lp] must be provided")
      end

      def local_presenter=(new_local_presenter)
        @local_presenter = new_local_presenter.tap do |new_presenter|
          # attempt to auto set record
          new_presenter.record ||= instance_variable_get("@#{new_presenter.presenter_options.presents}")
        end
      end

      alias_method :lp, :local_presenter
      alias_method :lp=, :local_presenter=
    end
  end
end
