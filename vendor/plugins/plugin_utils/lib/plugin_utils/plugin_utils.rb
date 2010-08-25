module PluginUtils
  def migrate_plugin(plugin_name, version)
    begin
      plugin = lookup_plugin(plugin_name)
    rescue => e
      puts e
      return
    end
    PluginAWeek::PluginMigrations::Migrator.current_plugin = plugin
    PluginAWeek::PluginMigrations::Migrator.migrate_plugin(plugin, version)
  end

  def schema_version_equivalent_to(plugin_name, version)
    plugin = lookup_plugin(plugin_name)
    PluginAWeek::PluginMigrations::Migrator.current_plugin = plugin
    PluginAWeek::PluginMigrations::Migrator.allocate.set_schema_version(version)
  end

  def path_for_plugin(plugin_name)
    lookup_plugin(plugin_name).root
  end

  private
  def lookup_plugin(plugin_name)
    plugin = Rails.plugins[plugin_name.to_s]
    if plugin.nil?
      raise "No plugin found named #{plugin_name}"
    else
      plugin
    end
  end
end