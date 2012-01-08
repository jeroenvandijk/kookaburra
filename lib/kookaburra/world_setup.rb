# Can't use a custom World class, because cucumber-rails is already doing that
module Kookaburra
  module WorldSetup
    def ui;    @drivers[:ui_driver   ]; end
    def api;   @drivers[:api_driver  ]; end
    def given; @drivers[:given_driver]; end

    def kookaburra_world_setup
      @drivers = Kookaburra.drivers
    end

    def Verify(proxied)
      proxied.as_rspec
    end
  end
end
