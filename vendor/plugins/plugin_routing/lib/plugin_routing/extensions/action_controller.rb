module ActionController #:nodoc:
  module Layout #:nodoc:
    module ClassMethods #:nodoc:
      private
        def layout_list_with_plugin_routing
          plugin_layouts = Rails.plugins.by_precedence.map(&:layouts_path) * ','
          layout_list_without_plugin_routing + Dir["{#{plugin_layouts}}/**/*"]
        end
        alias_method_chain :layout_list, :plugin_routing
    end
  end
end