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
      def controller_presenter(options = {})
        return @controller_presenter if @controller_presenter
        presenter_name = controller.presenter_options.presenter_name
        @controller_presenter = presenter(presenter_name)
        # attempt to auto set record
        if @controller_presenter.presenter_options.presents
          @controller_presenter.record ||= instance_variable_get("@#{@controller_presenter.presenter_options.presents}")
        end
        @controller_presenter
      end

      attr_writer :controller_presenter
      alias_method :cp, :controller_presenter

      # local presenter
      def local_presenter(*params)
        @local_presenter || raise(ArgumentError, "local presenter [lp] has not been defined")
        # attempt to auto set record
        if @local_presenter.presenter_options.presents
          @local_presenter.record ||= instance_variable_get("@#{@local_presenter.presenter_options.presents}")
        end
        @local_presenter
      end

      attr_writer :local_presenter
      alias_method :lp, :local_presenter
      alias_method :lp=, :local_presenter=
    end
  end
end
