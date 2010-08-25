require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class ObjectTest < Test::Unit::TestCase
  def setup
    Dependencies.remove_unloadable_constants!
    Dependencies.send(:remove_constant, 'Actor')
    Dependencies.send(:remove_constant, 'Agent')
    @history = Dependencies.history.clone
  end
  
  def test_load
    assert_equal ['Actor'], load('actor')
    assert Actor.in_third_actor_skeleton?
    assert !Actor.respond_to?(:in_actor_skeleton?)
    assert !Actor.respond_to?(:in_second_skeleton?)
    assert !Actor.respond_to?(:in_actor?)
    
    assert_equal [], load('actor')
  end
  
  def test_load_nonexistent
    assert_raise(MissingSourceFile) {load('invalid')}
  end
  
  def test_require
    assert_equal ['Agent'], require('agent')
    assert Agent.in_agent?
    assert Agent.in_agent_skeleton?
    assert Agent.in_second_agent_skeleton?
    
    assert_equal [], require('agent')
  end
  
  def test_require_nonexistent
    assert_raise(MissingSourceFile) {require('invalid')}
  end
  
  def teardown
    Dependencies.history = @history
  end
end