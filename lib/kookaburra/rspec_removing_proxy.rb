module Kernel
  def filters_rspec_expectation_methods?
    false
  end
end

module Kookaburra
  class RSpecRemovingProxy
    instance_methods.each { |meth| undef_method(meth) unless meth =~ /^__/ }
    
    def initialize(proxied_object)
      @proxied_object = proxied_object
    end
    
    def method_missing(meth, *args, &block)
      __hide_rspec_methods(Kernel, :should, :should_not)
      ret_val = @proxied_object.send(meth, *args, &block)
      return RSpecRemovingProxy.new(ret_val)
    ensure
      __show_rspec_methods(Kernel, :should, :should_not)
    end

    def as_rspec
      @proxied_object
    end

    def filters_rspec_expectation_methods?
      true
    end

  protected
    def __hide_rspec_methods(context, *method_names)
      method_names.each do |mname|
        rspec_mname = '__evil_evil_rspec_' + mname.to_s
        context.module_eval <<-RUBY
          alias :#{rspec_mname} :#{mname}
          define_method(:#{mname}) { raise Kookaburra::RSpecIntrusion }
        RUBY
      end
    end
    
    def __show_rspec_methods(context, *method_names)
      method_names.each do |mname|
        rspec_mname = '__evil_evil_rspec_' + mname.to_s
        context.module_eval <<-RUBY
          alias :#{mname} :#{rspec_mname}
          remove_method :#{rspec_mname}
        RUBY
      end
    end
  end
end
