require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class StateByDefaultTest < Test::Unit::TestCase
  def setup
    @machine = StateMachine::Machine.new(Class.new)
    @state = StateMachine::State.new(@machine, 'on')
  end
  
  def test_should_have_a_machine
    assert_equal @machine, @state.machine
  end
  
  def test_should_have_a_value
    assert_equal 'on', @state.value
  end
  
  def test_should_not_have_any_methods
    expected = {}
    assert_equal expected, @state.methods
  end
  
  def test_should_not_be_initial
    assert !@state.initial
  end
end

class StateTest < Test::Unit::TestCase
  def setup
    @machine = StateMachine::Machine.new(Class.new)
  end
  
  def test_should_raise_exception_if_invalid_option_specified
    assert_raise(ArgumentError) {StateMachine::State.new(@machine, 'on', :invalid => true)}
  end
end

class StateWithNilValueTest < Test::Unit::TestCase
  def setup
    @klass = Class.new
    @machine = StateMachine::Machine.new(@klass)
    @state = StateMachine::State.new(@machine, nil)
  end
  
  def test_should_be_nil_without_object
    assert_nil @state.value
  end
  
  def test_should_be_nil_with_object
    assert_nil @state.value(@klass.new)
  end
  
  def test_should_not_redefine_nil_predicate
    object = @klass.new
    assert !object.nil?
    assert !object.respond_to?('?')
  end
end

class StateWithStringValueTest < Test::Unit::TestCase
  def setup
    @klass = Class.new
    @machine = StateMachine::Machine.new(@klass)
    @state = StateMachine::State.new(@machine, 'on')
  end
  
  def test_should_use_original_value_without_object
    assert_equal 'on', @state.value
  end
  
  def test_should_use_original_value_with_object
    assert_equal 'on', @state.value(@klass.new)
  end
  
  def test_should_define_predicate
    object = @klass.new
    assert object.respond_to?(:on?)
  end
end

class StateWithSymbolicValueTest < Test::Unit::TestCase
  def setup
    @klass = Class.new
    @machine = StateMachine::Machine.new(@klass)
    @state = StateMachine::State.new(@machine, :on)
  end
  
  def test_should_use_original_value_without_object
    assert_equal :on, @state.value
  end
  
  def test_should_use_original_value_with_object
    assert_equal :on, @state.value(@klass.new)
  end
  
  def test_should_define_predicate
    object = @klass.new
    assert object.respond_to?(:on?)
  end
end

class StateWithIntegerValueTest < Test::Unit::TestCase
  def setup
    @klass = Class.new
    @machine = StateMachine::Machine.new(@klass)
    @state = StateMachine::State.new(@machine, 1)
  end
  
  def test_should_use_original_value_without_object
    assert_equal 1, @state.value
  end
  
  def test_should_use_original_value_with_object
    assert_equal 1, @state.value(@klass.new)
  end
  
  def test_should_not_define_predicate
    object = @klass.new
    assert !object.respond_to?('1?')
  end
end

class StateWithObjectValueTest < Test::Unit::TestCase
  def setup
    @klass = Class.new
    @machine = StateMachine::Machine.new(@klass)
    @value = Object.new
    @state = StateMachine::State.new(@machine, @value)
  end
  
  def test_should_use_original_value_without_object
    assert_equal @value, @state.value
  end
  
  def test_should_use_original_value_with_object
    assert_equal @value, @state.value(@klass.new)
  end
  
  def test_should_not_define_predicate
    object = @klass.new
    assert !object.respond_to?("#{@value.inspect}?")
  end
end

class StateWithLambdaValueTest < Test::Unit::TestCase
  def setup
    @klass = Class.new
    @args = nil
    @machine = StateMachine::Machine.new(@klass)
    @value = lambda {|*args| @args = args; 'on'}
    @state = StateMachine::State.new(@machine, @value)
  end
  
  def test_should_use_original_value_without_object
    assert_equal @value, @state.value
  end
  
  def test_should_use_evaluated_value_with_object
    assert_equal 'on', @state.value(@klass.new)
  end
  
  def test_should_pass_object_in_when_evaluating_value
    object = @klass.new
    @state.value(object)
    
    assert_equal [object], @args
  end
  
  def test_should_not_define_predicate
    object = @klass.new
    assert !object.respond_to?("#{@value.inspect}?")
  end
end

class StateInitialTest < Test::Unit::TestCase
  def setup
    @machine = StateMachine::Machine.new(Class.new)
    @state = StateMachine::State.new(@machine, 'on', :initial => true)
  end
  
  def test_should_be_initial
    assert @state.initial
  end
end

class StateNotInitialTest < Test::Unit::TestCase
  def setup
    @machine = StateMachine::Machine.new(Class.new)
    @state = StateMachine::State.new(@machine, 'on', :initial => false)
  end
  
  def test_should_not_be_initial
    assert !@state.initial
  end
end

class StateWithConflictingPredicateTest < Test::Unit::TestCase
  def setup
    @klass = Class.new do
      def on?
        true
      end
    end
    @machine = StateMachine::Machine.new(@klass)
    @state = StateMachine::State.new(@machine, 'on')
    @object = @klass.new
  end
  
  def test_should_not_define_state_predicate
    assert @object.on?
  end
end

class StateWithNamespaceTest < Test::Unit::TestCase
  def setup
    @klass = Class.new do
      def on?
        true
      end
    end
    @machine = StateMachine::Machine.new(@klass, :namespace => 'switch')
    @state = StateMachine::State.new(@machine, 'on')
    @object = @klass.new
  end
  
  def test_should_namespace_predicate
    assert @object.respond_to?(:switch_on?)
  end
end

class StateAfterBeingCopiedTest < Test::Unit::TestCase
  def setup
    @machine = StateMachine::Machine.new(Class.new)
    @state = StateMachine::State.new(@machine, 'on')
    @copied_state = @state.dup
  end
  
  def test_should_not_have_the_same_collection_of_methods
    assert_not_same @state.methods, @copied_state.methods
  end
end

class StateWithContextTest < Test::Unit::TestCase
  def setup
    @klass = Class.new
    @machine = StateMachine::Machine.new(@klass)
    @ancestors = @klass.ancestors
    @state = StateMachine::State.new(@machine, 'on')
    
    color_method = nil
    glow_method = nil
    @state.context do
      def color
        'green'
      end
      color_method = instance_method(:color)
      
      def glow
        3
      end
      glow_method = instance_method(:glow)
    end
    
    @color_method = color_method
    @glow_method = glow_method
  end
  
  def test_should_include_new_module_in_owner_class
    assert_not_equal @ancestors, @klass.ancestors
    assert_equal 1, @klass.ancestors.size - @ancestors.size
  end
  
  def test_should_define_each_context_method_in_owner_class
    %w(color glow).each {|method| assert @klass.method_defined?(method)}
  end
  
  def test_should_not_use_context_methods_as_owner_class_methods
    assert_not_equal @color_method, @klass.instance_method(:color)
    assert_not_equal @glow_method, @klass.instance_method(:glow)
  end
  
  def test_should_include_context_methods_in_state_methods
    assert_equal @color_method, @state.methods[:color]
    assert_equal @glow_method, @state.methods[:glow]
  end
end

class StateWithMultipleContextsTest < Test::Unit::TestCase
  def setup
    @klass = Class.new
    @machine = StateMachine::Machine.new(@klass)
    @ancestors = @klass.ancestors
    @state = StateMachine::State.new(@machine, 'on')
    
    color_method = nil
    @state.context do
      def color
        'green'
      end
      
      color_method = instance_method(:color)
    end
    @color_method = color_method
    
    glow_method = nil
    @state.context do
      def glow
        3
      end
      
      glow_method = instance_method(:glow)
    end
    @glow_method = glow_method
  end
  
  def test_should_include_new_module_in_owner_class
    assert_not_equal @ancestors, @klass.ancestors
    assert_equal 2, @klass.ancestors.size - @ancestors.size
  end
  
  def test_should_define_each_context_method_in_owner_class
    %w(color glow).each {|method| assert @klass.method_defined?(method)}
  end
  
  def test_should_not_use_context_methods_as_owner_class_methods
    assert_not_equal @color_method, @klass.instance_method(:color)
    assert_not_equal @glow_method, @klass.instance_method(:glow)
  end
  
  def test_should_include_context_methods_in_state_methods
    assert_equal @color_method, @state.methods[:color]
    assert_equal @glow_method, @state.methods[:glow]
  end
end

class StateWithExistingContextMethodTest < Test::Unit::TestCase
  def setup
    @klass = Class.new do
      def color
        'always green'
      end
    end
    @original_color_method = @klass.instance_method(:color)
    
    @machine = StateMachine::Machine.new(@klass)
    @state = StateMachine::State.new(@machine, 'on')
    @state.context do
      def color
        'green'
      end
    end
  end
  
  def test_should_not_override_method
    assert_equal @original_color_method, @klass.instance_method(:color)
  end
end

class StateWithRedefinedContextMethodTest < Test::Unit::TestCase
  def setup
    @klass = Class.new
    @machine = StateMachine::Machine.new(@klass)
    @state = StateMachine::State.new(@machine, 'on')
    
    old_color_method = nil
    @state.context do
      def color
        'green'
      end
      old_color_method = instance_method(:color)
    end
    @old_color_method = old_color_method
    
    current_color_method = nil
    @state.context do
      def color
        'green'
      end
      current_color_method = instance_method(:color)
    end
    @current_color_method = current_color_method
  end
  
  def test_should_track_latest_defined_method
    assert_equal @current_color_method, @state.methods[:color]
  end
end

class StateWithInvalidMethodCallTest < Test::Unit::TestCase
  def setup
    @klass = Class.new
    @machine = StateMachine::Machine.new(@klass)
    @ancestors = @klass.ancestors
    @state = StateMachine::State.new(@machine, 'on')
    @state.context do
      def color
        'green'
      end
    end
    
    @object = @klass.new
  end
  
  def test_should_raise_an_exception
    assert_raise(NoMethodError) { @state.call(@object, :invalid) }
  end
end

class StateWithValidMethodCallTest < Test::Unit::TestCase
  def setup
    @klass = Class.new
    @machine = StateMachine::Machine.new(@klass)
    @ancestors = @klass.ancestors
    @state = StateMachine::State.new(@machine, 'on')
    @state.context do
      def color(arg = nil)
        block_given? ? [arg, yield] : arg
      end
    end
    
    @object = @klass.new
  end
  
  def test_should_not_raise_an_exception
    assert_nothing_raised { @state.call(@object, :color) }
  end
  
  def test_should_pass_arguments_through
    assert_equal 1, @state.call(@object, :color, 1)
  end
  
  def test_should_pass_blocks_through
    assert_equal [nil, 1], @state.call(@object, :color) {1}
  end
  
  def test_should_pass_both_arguments_and_blocks_through
    assert_equal [1, 2], @state.call(@object, :color, 1) {2}
  end
end

class StateIdGeneratorTest < Test::Unit::TestCase
  def test_should_use_nil_for_nil
    assert_equal 'nil', StateMachine::State.id_for(nil)
  end
  
  def test_should_use_to_s_for_string
    assert_equal 'on', StateMachine::State.id_for('on')
  end
  
  def test_should_use_to_s_for_symbol
    assert_equal 'on', StateMachine::State.id_for(:on)
  end
  
  def test_should_use_to_s_for_number
    assert_equal '1', StateMachine::State.id_for(1)
  end
  
  def test_should_use_to_s_for_object
    class << (state = Object.new)
      def to_s
        'on'
      end
    end
    
    assert_equal 'on', StateMachine::State.id_for(state)
  end
  
  def test_should_use_lambda_id_for_proc
    state = lambda {}
    
    assert_equal "lambda#{state.object_id.abs}", StateMachine::State.id_for(state)
  end
end

begin
  # Load library
  require 'rubygems'
  require 'graphviz'
  
  class StateDrawingTest < Test::Unit::TestCase
    def setup
      @machine = StateMachine::Machine.new(Class.new)
      @state = StateMachine::State.new(@machine, 'on')
      
      graph = GraphViz.new('G')
      @node = @state.draw(graph)
    end
    
    def test_should_use_circle_shape
      assert_equal 'circle', @node['shape']
    end
    
    def test_should_enabled_fixedsize
      assert_equal 'true', @node['fixedsize']
    end
    
    def test_should_set_width_to_one
      assert_equal '1', @node['width']
    end
    
    def test_should_set_height_to_one
      assert_equal '1', @node['height']
    end
    
    def test_should_use_value_as_name
      assert_equal 'on', @node.name
    end
    
    def test_should_use_stringified_value_as_label
      assert_equal 'on', @node['label']
    end
  end
  
  class StateDrawingInitialTest < Test::Unit::TestCase
    def setup
      @machine = StateMachine::Machine.new(Class.new)
      @state = StateMachine::State.new(@machine, 'on', :initial => true)
      
      graph = GraphViz.new('G')
      @node = @state.draw(graph)
    end
    
    def test_should_use_doublecircle_as_shape
      assert_equal 'doublecircle', @node['shape']
    end
  end
  
  class StateDrawingNilTest < Test::Unit::TestCase
    def setup
      @machine = StateMachine::Machine.new(Class.new)
      @state = StateMachine::State.new(@machine, nil)
      
      graph = GraphViz.new('G')
      @node = @state.draw(graph)
    end
    
    def test_should_use_value_as_name
      assert_equal 'nil', @node.name
    end
    
    def test_should_use_stringified_value_as_label
      assert_equal 'nil', @node['label']
    end
  end
  
  class StateDrawingProcTest < Test::Unit::TestCase
    def setup
      @machine = StateMachine::Machine.new(Class.new)
      @value = lambda {}
      @state = StateMachine::State.new(@machine, @value)
      
      graph = GraphViz.new('G')
      @node = @state.draw(graph)
    end
    
    def test_should_use_lambda_id_as_name
      assert_equal "lambda#{@value.object_id.abs}", @node.name
    end
    
    def test_should_use_asterisk_as_label
      assert_equal '*', @node['label']
    end
  end
  
  class StateDrawingSymbolTest < Test::Unit::TestCase
    def setup
      @machine = StateMachine::Machine.new(Class.new)
      @state = StateMachine::State.new(@machine, :on)
      
      graph = GraphViz.new('G')
      @node = @state.draw(graph)
    end
    
    def test_should_use_stringified_value_as_name
      assert_equal 'on', @node.name
    end
    
    def test_should_use_stringified_value_as_label
      assert_equal 'on', @node['label']
    end
  end
rescue LoadError
  $stderr.puts 'Skipping GraphViz StateMachine::State tests. `gem install ruby-graphviz` and try again.'
end