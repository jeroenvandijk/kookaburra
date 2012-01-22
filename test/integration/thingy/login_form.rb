module Thingy
  class UIDriver < Kookaburra::UIDriver
    class LoginForm < Kookaburra::UIDriver::UIComponent
      component_path '/login_form.html'
      component_locator '#login_form'
    end
  end
end
