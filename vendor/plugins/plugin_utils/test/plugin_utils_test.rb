dir = File.dirname(__FILE__)
require "#{dir}/test_helper"

class PluginUtilsTest < Pivotal::FrameworkPluginTestCase
  include PluginUtils
  include FlexMock::TestCase
  
  def test_plugin_path_for
    assert_equal "#{RAILS_ROOT}/vendor/plugins/routes_from_plugin", path_for_plugin("routes_from_plugin")
    assert_equal "#{RAILS_ROOT}/vendor/plugins/routes_from_plugin", path_for_plugin(:routes_from_plugin)
    assert_equal "#{RAILS_ROOT}/vendor/plugins/prerequisites/plugin_dependencies", path_for_plugin("plugin_dependencies")
  end
  
  def test_plugin_for__with_invalid_name__raises_exception
    assert_raises RuntimeError do
      path_for_plugin("non_existent_plugin")
    end
  end

  def test_migrate_plugin
    fake_plugin = "i am a plugin"
    flexstub(Rails).should_receive(:plugins).and_return({"my_plugin" => fake_plugin})
    flexstub(PluginAWeek::PluginMigrations::Migrator).should_receive(:migrate_plugin).once.with(fake_plugin, 3)

    migrate_plugin("my_plugin", 3)
    assert_equal fake_plugin, PluginAWeek::PluginMigrations::Migrator.current_plugin
  end

  def test_schema_version_equivalent_to
    fake_plugin = "i am a plugin"
    fake_migrator = flexmock("migrator")
    flexstub(Rails).should_receive(:plugins).and_return({"my_plugin" => fake_plugin})
    flexstub(PluginAWeek::PluginMigrations::Migrator).should_receive(:allocate).once.and_return(fake_migrator)
    fake_migrator.should_receive(:set_schema_version).once.with(3)

    schema_version_equivalent_to("my_plugin", 3)
    assert_equal fake_plugin, PluginAWeek::PluginMigrations::Migrator.current_plugin
  end
end
