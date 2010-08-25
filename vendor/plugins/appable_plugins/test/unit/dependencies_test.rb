require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

module Dependencies
  public  :find_main_app_file,
          :find_main_app_directories,
          :find_plugin_load_paths,
          :find_app_path,
          :find_load_path_for,
          :find_in_load_path,
          :full_file_path_for,
          :use_strict_file_names?
end

class DependenciesTest < Test::Unit::TestCase
  def setup
    Dependencies.remove_unloadable_constants!
    [
      'Actor',
      'ActorsController',
      'ActorsHelpers',
      'ActorMailer',
      'Actress',
      'ApplicationController',
      'Manager',
      'Movie'
    ].each {|klass| Dependencies.send(:remove_constant, klass)}
    
    @history = Dependencies.history.clone
  end
  
  def test_load_path
    # Don't expect plugin_dependencies since it's in a subfolder
    expected = [
      "#{plugins_root}/third_actor_skeleton/app",
      "#{plugins_root}/third_actor_skeleton/app/models",
      "#{plugins_root}/third_actor_skeleton/lib",
      "#{plugins_root}/second_manager_skeleton/app",
      "#{plugins_root}/second_manager_skeleton/app/models",
      "#{plugins_root}/second_agent_skeleton/app",
      "#{plugins_root}/second_agent_skeleton/app/models",
      "#{plugins_root}/second_actor_skeleton/app",
      "#{plugins_root}/second_actor_skeleton/app/helpers",
      "#{plugins_root}/second_actor_skeleton/app/models",
      "#{plugins_root}/second_actor_skeleton/lib",
      "#{plugins_root}/plugins_dependent_plugin/app",
      "#{plugins_root}/plugins_dependent_plugin/app/models",
      "#{plugins_root}/plugins_dependent_plugin/lib",
      "#{plugins_root}/plugin_with_dependencies/app",
      "#{plugins_root}/plugin_with_dependencies/app/models",
      "#{plugins_root}/plugin_with_dependencies/lib",
      "#{plugins_root}/manager_skeleton/app",
      "#{plugins_root}/manager_skeleton/app/models",
      "#{plugins_root}/mailer_skeleton/app",
      "#{plugins_root}/mailer_skeleton/app/mailers",
      "#{plugins_root}/mailer_skeleton/lib",
      "#{plugins_root}/agent_skeleton/app",
      "#{plugins_root}/agent_skeleton/app/models",
      "#{plugins_root}/actress_skeleton/app",
      "#{plugins_root}/actress_skeleton/app/controllers",
      "#{plugins_root}/actress_skeleton/app/models",
      "#{plugins_root}/actress_skeleton/lib",
      "#{plugins_root}/actor_skeleton/app",
      "#{plugins_root}/actor_skeleton/app/controllers",
      "#{plugins_root}/actor_skeleton/app/models",
      "#{plugins_root}/actor_skeleton/lib"
    ]
    lib_index = $LOAD_PATH.index("#{RAILS_ROOT}/lib")
    
    assert_equal expected, $LOAD_PATH[lib_index + 1..lib_index + expected.size]
  end
  
  def test_load_paths
    expected = [
      "#{RAILS_ROOT}/test/mocks/#{RAILS_ENV}",
      "#{app_root}/controllers",
      "#{app_root}",
      "#{app_root}/models",
      "#{app_root}/controllers",
      "#{RAILS_ROOT}/config",
      "#{RAILS_ROOT}/lib",
      "#{RAILS_ROOT}/vendor",
      "#{app_root}/models/fake_namespace",
      "#{app_root}/mailers",
      "#{RAILS_ROOT}/../../lib",
      "#{plugins_root}/actor_skeleton/app",
      "#{plugins_root}/actor_skeleton/app/controllers",
      "#{plugins_root}/actor_skeleton/app/models",
      "#{plugins_root}/actor_skeleton/lib",
      "#{plugins_root}/actress_skeleton/app",
      "#{plugins_root}/actress_skeleton/app/controllers",
      "#{plugins_root}/actress_skeleton/app/models",
      "#{plugins_root}/actress_skeleton/lib",
      "#{plugins_root}/agent_skeleton/app",
      "#{plugins_root}/agent_skeleton/app/models",
      "#{plugins_root}/mailer_skeleton/app",
      "#{plugins_root}/mailer_skeleton/app/mailers",
      "#{plugins_root}/mailer_skeleton/lib",
      "#{plugins_root}/manager_skeleton/app",
      "#{plugins_root}/manager_skeleton/app/models",
      "#{plugins_root}/plugin_with_dependencies/app",
      "#{plugins_root}/plugin_with_dependencies/app/models",
      "#{plugins_root}/plugin_with_dependencies/lib",
      "#{plugins_root}/plugins_dependent_plugin/app",
      "#{plugins_root}/plugins_dependent_plugin/app/models",
      "#{plugins_root}/plugins_dependent_plugin/lib",
      "#{plugins_root}/second_actor_skeleton/app",
      "#{plugins_root}/second_actor_skeleton/app/helpers",
      "#{plugins_root}/second_actor_skeleton/app/models",
      "#{plugins_root}/second_actor_skeleton/lib",
      "#{plugins_root}/second_agent_skeleton/app",
      "#{plugins_root}/second_agent_skeleton/app/models",
      "#{plugins_root}/second_manager_skeleton/app",
      "#{plugins_root}/second_manager_skeleton/app/models",
      "#{plugins_root}/third_actor_skeleton/app",
      "#{plugins_root}/third_actor_skeleton/app/models",
      "#{plugins_root}/third_actor_skeleton/lib"
    ]
    
    assert_equal expected, Dependencies.load_paths.collect {|path| path.ends_with?('/') ? path.chop : path}
  end
  
  def test_use_strict_file_names?
    assert !Dependencies.use_strict_file_names?(:require)
    assert Dependencies.use_strict_file_names?(:load)
    assert Dependencies.use_strict_file_names?(:load_without_new_constant_marking)
  end
  
  # full_file_path_for
  
  def test_full_file_path_for_require_without_extension
    assert_equal 'actor.rb', Dependencies.full_file_path_for('actor', :require)
  end
  
  def test_full_file_path_for_require_with_extension
    assert_equal 'actor.rb', Dependencies.full_file_path_for('actor.rb', :require)
  end
  
  def test_full_file_path_for_load_without_extension
    assert_equal 'actor', Dependencies.full_file_path_for('actor', :load)
  end
  
  def test_full_file_path_for_load_with_extension
    assert_equal 'actor.rb', Dependencies.full_file_path_for('actor.rb', :load)
  end
  
  def test_full_file_path_for_namespace
    assert_equal 'movie/actor.rb', Dependencies.full_file_path_for('movie/actor', :require)
  end
  
  # find_in_load_path
  
  def test_find_in_load_path_exists
    transaction do
      path = File.expand_path("#{app_root}/models/actor.rb")
      assert_equal path, Dependencies.find_in_load_path('actor.rb')
      expected = {
        'actor.rb' => path
      }
      assert_equal expected, Dependencies.load_path_cache
    end
  end
  
  def test_find_in_load_path_with_model_namespace
    transaction do
      path = File.expand_path("#{app_root}/models/movie/actor.rb")
      assert_equal path, Dependencies.find_in_load_path('movie/actor.rb')
    end
  end
  
  def test_find_in_load_path_with_controller_namespace
    transaction do
      path = File.expand_path("#{app_root}/controllers/admin/actors_controller.rb")
      assert_equal path, Dependencies.find_in_load_path('admin/actors_controller.rb')
    end
  end
  
  def test_find_in_load_path_nonexistent
    transaction do
      assert_nil Dependencies.find_in_load_path('invalid.rb')
      assert_equal ({}), Dependencies.load_path_cache
    end
  end
  
  # find_load_path_for
  
  def test_find_load_path_for
    path = File.expand_path("#{plugins_root}/actor_skeleton/app/models")
    assert_equal path, Dependencies.find_load_path_for("#{path}/actor.rb")
  end
  
  def test_find_load_path_for_with_model_namespace
    path = File.expand_path("#{plugins_root}/actor_skeleton/app/models")
    assert_equal path, Dependencies.find_load_path_for("#{path}/movie/actor.rb")
  end
  
  def test_find_load_path_for_with_controller_namespace
    path = File.expand_path("#{plugins_root}/actor_skeleton/app/controllers")
    assert_equal path, Dependencies.find_load_path_for("#{path}/admin/actors_controller.rb")
  end
  
  # find_app_path
  
  def test_find_app_path_invalid
    assert_nil Dependencies.find_app_path('actor_skeleton')
  end
  
  def test_find_app_path_model
    assert_equal 'models/actor.rb', Dependencies.find_app_path(File.expand_path("#{plugins_root}/actor_skeleton/app/models/actor.rb"))
  end
  
  def test_find_app_path_controller
    assert_equal 'controllers/actors_controller.rb', Dependencies.find_app_path(File.expand_path("#{plugins(:actor_skeleton).controllers_path}/actors_controller.rb"))
  end
  
  def test_find_app_path_helper
    assert_equal 'helpers/actors_helper.rb', Dependencies.find_app_path(File.expand_path("#{plugins(:second_actor_skeleton).app_path}/helpers/actors_helper.rb"))
  end
  
  def test_find_app_path_non_standard
    assert_equal 'mailers/actor_mailer.rb', Dependencies.find_app_path(File.expand_path("#{plugins_root}/mailer_skeleton/app/mailers/actor_mailer.rb"))
  end
  
  def test_find_app_path_with_namespace
    assert_equal 'models/movie/actor.rb', Dependencies.find_app_path(File.expand_path("#{plugins_root}/actor_skeleton/app/models/movie/actor.rb"))
  end
  
  def test_find_app_path_with_controller_namespace
    assert_equal 'controllers/admin/actors_controller.rb', Dependencies.find_app_path(File.expand_path("#{plugins_root}/actor_skeleton/app/controllers/admin/actors_controller.rb"))
  end
  
  def test_find_app_path_unsupported_type
    # transaction removes mailers from mixable_app_types
    transaction do
      assert_nil Dependencies.find_app_path(File.expand_path("#{plugins_root}/mailer_skeleton/app/mailers/actor_mailer.rb"))
    end
  end
  
  def test_find_app_path_without_extension
    assert_equal 'models/actor', Dependencies.find_app_path(File.expand_path("#{plugins_root}/third_actor_skeleton/app/models/actor"))
  end
  
  def test_find_app_path_absolute_invalid
    assert_nil Dependencies.find_app_path(File.expand_path('invalid.rb'))
  end
  
  # find_plugin_load_paths
  
  def test_find_plugin_load_paths_none
    assert_equal [], Dependencies.find_plugin_load_paths('models/invalid.rb')
  end
  
  def test_find_plugin_load_paths_some
    expected = [
      "#{plugins_root}/actor_skeleton/app/models/actor.rb",
      "#{plugins_root}/second_actor_skeleton/app/models/actor.rb"
    ].collect! {|path| File.expand_path(path)}
    assert_equal expected, Dependencies.find_plugin_load_paths('models/actor.rb')
  end
  
  def test_find_plugin_load_paths_with_namespace
    expected = [
      "#{plugins_root}/actor_skeleton/app/models/movie/actor.rb"
    ].collect! {|path| File.expand_path(path)}
    assert_equal expected, Dependencies.find_plugin_load_paths('models/movie/actor.rb')
  end
  
  def test_find_plugin_load_paths_with_controller_namespace
    expected = [
      "#{plugins_root}/actor_skeleton/app/controllers/admin/actors_controller.rb"
    ].collect! {|path| File.expand_path(path)}
    assert_equal expected, Dependencies.find_plugin_load_paths('controllers/admin/actors_controller.rb')
  end
  
  # find_main_app_file
  
  def test_find_main_app_file_exists
    assert_equal File.expand_path("#{app_root}/models/actor.rb"), Dependencies.find_main_app_file('models/actor.rb')
  end
  
  def test_find_main_app_file_exists_with_namespace
    assert_equal File.expand_path("#{app_root}/models/movie/actor.rb"), Dependencies.find_main_app_file('models/movie/actor.rb')
  end
  
  def test_find_main_app_file_exists_with_controller_namespace
    assert_equal File.expand_path("#{app_root}/controllers/admin/actors_controller.rb"), Dependencies.find_main_app_file('controllers/admin/actors_controller.rb')
  end
  
  def test_find_main_app_file_in_fake_namespace
    assert_equal File.expand_path("#{app_root}/models/fake_namespace/actress.rb"), Dependencies.find_main_app_file('models/fake_namespace/actress.rb')
  end
  
  def test_find_main_app_file_nonexistent
    assert_nil Dependencies.find_main_app_file('models/invalid.rb')
  end
  
  # find_main_app_directories
  
  def test_find_main_app_directories_all
    expected = [
      "#{app_root}/controllers",
      "#{app_root}/models",
      "#{app_root}/models/fake_namespace",
      "#{app_root}/mailers",
    ]
    assert_equal expected, Dependencies.find_main_app_directories
  end
  
  def test_find_main_app_directories_models
    expected = [
      "#{app_root}/models",
      "#{app_root}/models/fake_namespace"
    ]
    assert_equal expected, Dependencies.find_main_app_directories('models')
  end
  
  def test_find_main_app_directories_controllers
    assert_equal ["#{app_root}/controllers"], Dependencies.find_main_app_directories('controllers')
  end
  
  def test_find_main_app_directories_helpers
    assert_equal [], Dependencies.find_main_app_directories('helpers')
  end
  
  # load_from_plugins
  
  def test_load_from_plugins_nonexistent
    assert !Dependencies.load_from_plugins('invalid')
  end
  
  def test_load_from_plugins_load_no_extension_nonexistent
    assert !Dependencies.load_from_plugins('actress', :load)
    assert !defined?(Actress)
  end
  
  def test_load_from_plugins_load_no_extension
    assert Dependencies.load_from_plugins('actor', :load)
    assert defined?(Actor)
  end
  
  def test_load_from_plugins_load_extension_nonexistent
    assert !Dependencies.load_from_plugins('invalid.rb', :load)
  end
  
  def test_load_from_plugins_load_extension
    assert Dependencies.load_from_plugins('actor.rb', :load)
    assert defined?(Actor)
  end
  
  def test_load_from_plugins_require_no_extension
    assert Dependencies.load_from_plugins('actor_mailer', :require)
    assert defined?(ActorMailer)
  end
  
  def test_load_from_plugins_require_extension
    assert Dependencies.load_from_plugins('actors_helper.rb', :require)
    assert defined?(ActorsHelper)
  end
  
  def test_load_from_plugins_only_in_app
    assert !Dependencies.load_from_plugins('producer.rb')
  end
  
  def test_load_from_plugins_no_extension
    assert Dependencies.load_from_plugins('actor')
    assert Actor.in_third_actor_skeleton?
    assert !Actor.respond_to?(:in_actor_skeleton?)
    assert !Actor.respond_to?(:in_second_skeleton?)
    assert !Actor.respond_to?(:in_actor?)
  end
  
  def test_load_absolute_plugin_path
    Dependencies.load_from_plugins(File.expand_path("#{plugins_root}/actor_skeleton/app/models/actor.rb"))
    assert_equal actor_load_order, Actor.load_order
  end
  
  def test_load_absolute_app_path
    Dependencies.load_from_plugins(File.expand_path("#{app_root}/models/actor.rb"))
    assert_equal actor_load_order, Actor.load_order
  end
  
  def test_load_absolute_plugin_path_but_not_expanded
    Dependencies.load_from_plugins(File.expand_path("#{plugins_root}/actor_skeleton/app/models/actor.rb").sub('models', 'models/../models'))
    assert_equal actor_load_order, Actor.load_order
  end
  
  def test_load_absolute_app_path_but_not_expanded
    Dependencies.load_from_plugins(File.expand_path("#{app_root}/models/actor.rb").sub('models', 'models/../models'))
    assert_equal actor_load_order, Actor.load_order
  end
  
  def test_load_from_plugins_from_fake_namespace
    assert Dependencies.load_from_plugins('fake_namespace/actress.rb')
    assert_not_nil Actress
    assert Actress.in_actress?
    assert Actress.in_actress_skeleton?
  end
  
  def test_load_from_plugins_application_controller
    assert Dependencies.load_from_plugins('application.rb')
    assert_not_nil ApplicationController
    assert ApplicationController.in_application?
    assert ApplicationController.in_actor_skeleton?
  end
  
  def test_load_from_plugins_model_but_not_first_in_load_path
    assert !Dependencies.load_from_plugins('node.rb')
    assert !defined?(Node)
  end
  
  def test_load_from_plugins_with_namespace
    assert Dependencies.load_from_plugins('movie/actor.rb')
    assert Movie::Actor.respond_to?(:in_actor_skeleton?)
    assert Movie::Actor.respond_to?(:in_movie_actor?)
  end
  
  def test_load_from_plugins_with_controller_namespace
    load 'application.rb'
    
    assert Dependencies.load_from_plugins('admin/actors_controller.rb')
    assert Admin::ActorsController.respond_to?(:in_actor_skeleton?)
    assert Admin::ActorsController.respond_to?(:in_actors_controller?)
  end
  
  # require_or_load
  
  def test_require_or_load
    expected = Dependencies.mechanism == :load ? true : ['Manager']
    assert_equal expected, require_or_load('manager')
    assert Manager.in_manager?
    assert Manager.in_manager_skeleton?
    assert Manager.in_second_manager_skeleton?
    
    assert_nil require_or_load('manager')
  end
  
  # load_missing_constant
  
  def test_load_missing_constant
    assert Actor.in_actor?
    assert Actor.in_actor_skeleton?
    assert Actor.in_second_actor_skeleton?
    
    expected_load_order = [
      :actor_skeleton,
      :second_actor_skeleton,
      :actor
    ]
    assert_equal expected_load_order, Actor.load_order
    
    # Simulate application restarting
    Dependencies.clear
    if Dependencies.mechanism == :load
      assert !defined?(Actor)
    else
      assert defined?(Actor)
    end
    
    assert Actor.in_actor?
    assert Actor.in_actor_skeleton?
    assert Actor.in_second_actor_skeleton?
    
    expected_load_order = [
      :actor_skeleton,
      :second_actor_skeleton,
      :actor
    ]
    assert_equal expected_load_order, Actor.load_order
  end
  
  def test_load_missing_constant_not_app_file
    assert_not_nil NonAppModel
  end
  
  def test_load_missing_constant_only_in_plugin
    assert_not_nil Movie
  end
  
  def test_load_missing_constant_from_namespaced_model
    assert_not_nil Admin::Actor
  end
  
  def test_load_missing_constant_from_unconventional_path
    assert_not_nil ApplicationMailer
    assert ApplicationMailer.in_application_mailer?
    assert ApplicationMailer.in_mailer_skeleton?
  end
  
  def test_load_missing_constant_from_fake_namespace
    assert_not_nil Actress
    assert Actress.in_actress?
    assert Actress.in_actress_skeleton?
  end
  
  def test_load_missing_constant_normal_controller
    load 'application.rb'
    
    assert_not_nil ActressesController
    assert ActressesController.in_actresses_controller?
    assert ActressesController.in_actresses_skeleton?
  end
  
  def test_load_missing_constant_namespaced_controller
    load 'application.rb'
    
    assert_not_nil Admin::ActorsController
    assert Admin::ActorsController.in_actor_skeleton?
    assert Admin::ActorsController.in_actors_controller?
  end
  
  def teardown
    Dependencies.history = @history
  end
  
  private
  def actor_load_order
    [
      :actor_skeleton,
      :second_actor_skeleton,
      :actor
    ]
  end
end