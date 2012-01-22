require 'integration/integration_test_helper'

describe "a trivial Kookaburra implementation" do
  setup_thingy_app

  it 'has been set up correctly' do
    assert_kind_of Thingy::UIDriver, ui
  end

  it 'can navigate to the login form' do
    ui.navigate_to(:login_form)
  end
end
