require 'helper'

describe Kookaburra do
  describe 'as a mixin' do
    let(:mixer_class) do
      Class.new do
        include Kookaburra
      end
    end

    let(:mixer) do
      mixer_class.new.tap do |m|
        m.kookaburra_adapter = adapter
      end
    end

    let(:mixer2) do
      mixer_class.new.tap do |m|
        m.kookaburra_adapter = adapter
      end
    end

    let(:adapter) do
      capybara_like_thing = Class.new do
        def app
          :an_application
        end

        def current_session
          :a_current_session
        end
      end

      capybara_like_thing.new
    end

    describe '#kookaburra_adapter' do
      it 'is a read/write attribute' do
        mixer.kookaburra_adapter = :probably_Capybara
        assert_equal :probably_Capybara, mixer.kookaburra_adapter
      end

      it 'defaults to the value of Kookaburra.adapter' do
        begin
          old_adapter = Kookaburra.adapter
          Kookaburra.adapter = :global_adapter
          mixer = mixer_class.new
          assert_equal :global_adapter, mixer.kookaburra_adapter
        ensure
          Kookaburra.adapter = old_adapter
        end
      end
    end

    describe '#api' do
      it 'is an instance of Kookaburra.api_driver' do
        klass = Class.new(Kookaburra::APIDriver)
        Kookaburra.api_driver = klass
        assert_kind_of(klass, mixer.api)
      end

      it 'only creates a new one once for an instance of the including class' do
        assert_same(mixer.api, mixer.api)
      end

      it 'is a different instance of APIDriver for each instance of the including class' do
        refute_same mixer.api, mixer2.api
      end
    end

    describe '#given' do
      it 'is an instance of Kookaburra.given_driver' do
        klass = Class.new(Kookaburra::GivenDriver)
        Kookaburra.given_driver = klass
        assert_kind_of(klass, mixer.given)
      end

      it 'only creates a new one once for an instance of the including class' do
        assert_same(mixer.given, mixer.given)
      end

      it 'is a different instance of GivenDriver for each instance of the including class' do
        refute_same mixer.given, mixer2.given
      end
    end

    describe '#ui' do
      it 'is an instance of Kookaburra.ui_driver' do
        klass = Class.new(Kookaburra::UIDriver)
        Kookaburra.ui_driver = klass
        assert_kind_of(klass, mixer.ui)
      end

      it 'only creates a new one once for an instance of the including class' do
        assert_same(mixer.ui, mixer.ui)
      end

      it 'is a different instance of UIDriver for each instance of the including class' do
        refute_same mixer.ui, mixer2.ui
      end
    end

    describe '#kookaburra_reset!' do
      it 'resets the api driver' do
        api = mixer.api
        mixer.kookaburra_reset!
        api2 = mixer.api
        refute_same api, api2
      end

      it 'resets the given driver' do
        given = mixer.given
        mixer.kookaburra_reset!
        given2 = mixer.given
        refute_same given, given2
      end

      it 'resets the ui driver' do
        ui = mixer.ui
        mixer.kookaburra_reset!
        ui2 = mixer.ui
        refute_same ui, ui2
      end
    end
    end

  describe 'methods on the Kookaburra object' do
    describe '#adapter' do
      it 'is a read/write attribute' do
        assert_nil Kookaburra.adapter
        Kookaburra.adapter = :probably_Capybara
        assert_equal :probably_Capybara, Kookaburra.adapter
      end
    end

    describe '#api_driver' do
      it 'is a read/write attribute' do
        Kookaburra.api_driver = :an_api_driver
        assert_equal :an_api_driver, Kookaburra.api_driver
      end

      it 'defaults to Kookaburra::APIDriver' do
        Kookaburra.api_driver = nil
        assert_equal Kookaburra::APIDriver, Kookaburra.api_driver
      end
    end

    describe '#given_driver' do
      it 'is a read/write attribute' do
        Kookaburra.given_driver = :a_given_driver
        assert_equal :a_given_driver, Kookaburra.given_driver
      end

      it 'defaults to Kookaburra::GivenDriver' do
        Kookaburra.given_driver = nil
        assert_equal Kookaburra::GivenDriver, Kookaburra.given_driver
      end
    end

    describe '#ui_driver' do
      it 'is a read/write attribute' do
        Kookaburra.ui_driver = :a_ui_driver
        # TODO: add Kookaburra.reset_drivers! for use in test cleanup.  This state sticks around and affects other tests.
        assert_equal :a_ui_driver, Kookaburra.ui_driver
      end

      it 'defaults to Kookaburra::UIDriver' do
        Kookaburra.ui_driver = nil
        assert_equal Kookaburra::UIDriver, Kookaburra.ui_driver
      end
    end

    describe '#test_data' do
      it 'is a read/write attribute' do
        Kookaburra.test_data = :a_test_data
        assert_equal :a_test_data, Kookaburra.test_data
      end

      it 'defaults to Kookaburra::TestData' do
        Kookaburra.test_data = nil
        assert_equal Kookaburra::TestData, Kookaburra.test_data
      end
    end
  end
end
