require 'helper'

require 'capybara'
require 'capybara/dsl'

require 'integration/thingy/login_form'
require 'integration/thingy/ui_driver'


class MiniTest::Unit::TestCase
  ThingyRackApp = Rack::Builder.new do
    run Rack::File.new(File.join(File.dirname(__FILE__), *%w[thingy app]))
  end.to_app

  def self.setup_thingy_app
    Capybara.app = ThingyRackApp


    before do
      Kookaburra.adapter      = Capybara
      Kookaburra.ui_driver    = Thingy::UIDriver
      Kookaburra.api_driver   = nil
      Kookaburra.given_driver = nil
      Kookaburra.test_data    = nil
      extend Kookaburra
      kookaburra_reset!
    end

    after do
      Kookaburra.adapter = nil
    end
  end
end
