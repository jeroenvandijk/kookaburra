require File.join(File.dirname(__FILE__), *%w[helper])

describe "RSpec (dis)integration" do
  class MeddlingComponent
    def poke_nose_into_rspec_where_it_doesnt_belong
      nil.should == nil
      raise "if you got here, something is messed up, yo"
    end

    def misguided_subcomponent
      MisguidedSubcomponent.new
    end

    class MisguidedSubcomponent
      def give_testing_layer_responsibility_it_shouldnt_have
        true.should == true
        raise "that totally should've exploded"
      end

      def itself
        self
      end
    end
  end

  def monkeypatch_all_the_things
    Kernel.module_eval do
      unless defined?(UnwantedRSpecIntrusion)
        klass = Class.new(Exception) do
          def message
            "Client code was able to successfully call RSpec's #should or #should_not.  YOU LOSE."
          end
        end
        const_set :UnwantedRSpecIntrusion, klass
      end
      def should(*_)
        raise UnwantedRSpecIntrusion
      end
      def should_not(*_)
        raise UnwantedRSpecIntrusion
      end
    end
  end

  def clean_all_the_things
    Kernel.module_eval do
      if const_defined?(:RSpecExpectationSuccessfullyCalled)
        remove_const :RSpecExpectationSuccessfullyCalled
      end
      undef_method :should
      undef_method :should_not
    end
  end

  before { monkeypatch_all_the_things }
  after { clean_all_the_things; $DEBUG=false }

  before do
    @world = cucumber_world
    def @world.meddling_component
      MeddlingComponent.new
    end
    @world.instance_eval do
      @drivers[:api_driver] = Kookaburra::RSpecRemovingProxy.new(meddling_component)
    end

    @proxied_object = @world.api
    @bare_object    = @world.meddling_component
  end

  ##### Oh, look, some tests! #####

  describe Kookaburra::RSpecRemovingProxy do
    it "tells you that it's present" do
      assert @proxied_object.filters_rspec_expectation_methods?
      refute @bare_object   .filters_rspec_expectation_methods?
    end

    it 'raises Kookaburra::RSpecIntrusion if you try to call #should inside any of its direct methods' do
      assert_raises(Kookaburra::RSpecIntrusion) do
        @proxied_object.poke_nose_into_rspec_where_it_doesnt_belong
      end
    end

    it 'wraps returned values in an RSpecRemovingProxy too' do
      child_object = @proxied_object.misguided_subcomponent
      assert_raises(Kookaburra::RSpecIntrusion) do
        child_object.give_testing_layer_responsibility_it_shouldnt_have
      end
    end

    it's turtles all the way down' do # http://chalain.livejournal.com/66798.html
      assert @proxied_object.misguided_subcomponent.itself.itself.itself.filters_rspec_expectation_methods?
    end

    it "lets you unproxy if you tell it you're a grownup" do
      refute @proxied_object.without_rspec_masking.filters_rspec_expectation_methods?

      refute_equal @proxied_object.object_id, @proxied_object.without_rspec_masking.object_id
      assert_equal @bare_object   .object_id, @proxied_object.without_rspec_masking.object_id
    end
  end

  describe Kookaburra::WorldSetup do
    it "doesn't raise Kookaburra::RSpecIntrusion if you call the naughty method on the object itself" do
      assert_raises(UnwantedRSpecIntrusion) do
        @bare_object.poke_nose_into_rspec_where_it_doesnt_belong
      end
    end

    it "doesn't raise Kookaburra::RSpecIntrusion even after calling (i.e., Kernel#should gets redefined when you're done)" do
      begin
        @proxied_object.poke_nose_into_rspec_where_it_doesnt_belong
      rescue Kookaburra::RSpecIntrusion
        # do nothing
      end

      assert_raises(UnwantedRSpecIntrusion) do
        @bare_object.poke_nose_into_rspec_where_it_doesnt_belong
      end
    end
  end
end
