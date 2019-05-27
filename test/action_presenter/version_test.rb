require "test_helper"

class ActionPresenter::Test < Minitest::Test

  def test_version
    refute_nil(::ActionPresenter::VERSION)
  end

end
