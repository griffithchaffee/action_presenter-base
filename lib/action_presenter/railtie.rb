module ActionPresenter
  class Railtie < Rails::Railtie
    require "action_presenter/railtie/action_controller"
    require "action_presenter/railtie/action_view"
  end
end
