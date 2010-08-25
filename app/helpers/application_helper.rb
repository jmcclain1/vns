module ApplicationHelper
  
  def tablist_add(params)
    tabs = session[:tablist] || {}

    tabs["#{session[:user_id]}_#{session[:location][:controller]}"] = { :id => params[:id],
                                                    :name => params[:name], 
                                                    :href => params[:href],
                                                    :location => session[:location][:controller]}
    session[:tablist] = tabs
  end

  def tablist_paint
    tabs = session[:tablist] || {}
    location = session[:location][:controller] != "shopping_items" ? session[:location][:controller] : "prospects"
    index = "#{session[:user_id]}_#{location}"
    markaby do
    if tab = tabs[index]
        if (request.path).index(tab[:href])
          div.tab_active :id => "tab_div_#{index}" do
            a tab[:name], :href => tab[:href]
            text link_to_remote(image_tag('tabs/tab_x.png').to_s,
                                {:url => tab_path(index).to_s,
                                :method => :delete,
                                :success => update_page{|p| p.remove("tab_div_#{index}"); p << "window.location = '/#{tab[:location]}'"}},
                                :class => 'x')
          end
        else
          div.tab :id => "tab_div_#{index}" do
            a tab[:name], :href => tab[:href]
            text link_to_remote(image_tag('tabs/tab_x.png').to_s,
                                {:url => tab_path(index).to_s,
                                :method => :delete,
                                :before => update_page{|p| p.remove("tab_div_#{index}")}},
                                :class => 'x')
          end
        end
      end
    end
  end
  
  def available_features_items(available_features)
    markaby do
      current_ecc_category = ''
      available_features.each do |available_feature|
        if available_feature.ecc_category != current_ecc_category
          current_ecc_category = available_feature.ecc_category
          label.header do
            text current_ecc_category
          end
        end
        label do
          if @checkbox_check_standard_feature == true
            checked = available_feature.standard?
          else
            checked = vehicle.has_available_feature?(available_feature)
          end
          check_box_tag 'evd_features[]', available_feature.id, checked, :id => "evd_features_id_#{available_feature.id}"
          text " "
          span available_feature.name
        end
      end
    end
  end

  def vehicle_equipment_list_controls
    markaby do
      div :id => 'vehicle_equipment_list' do
        all_available_features = vehicle.trim.available_features.find(:all, :order => 'ecc ASC')

        first_column_size = all_available_features.size.div(2)
        second_column_start_index = all_available_features.size - first_column_size

        div :class => 'left' do
          available_features_items(all_available_features[0..first_column_size])
        end
        div :class => 'right' do
          available_features_items(all_available_features[second_column_start_index..all_available_features.size])
        end
        br.clear
      end
    end
  end

  def tab(tab_name, tab_link, options = {}, link_options = {})
    options = options.merge(
      :onmouseover => "this.className += ' hover';",
      :onmouseout => "this.className = this.className.replace('hover', '');"
    )
    markaby do
      if @current_navbar_tab == tab_name
        options[:class] = 'active'
      end

      if tab_name == 'Buying'   # hack
        options[:id] = 'navbar_buying_li'
        li(options) do
            text navbar_link(:count => logged_in_user.count_for_buying_tab,
                             :unseen_count => logged_in_user.prospects_with_alerted_notifications.size,
                             :label => 'buying',
                             :target => prospects_path.to_s)
            text navbar_alert_link(:label => 'buying',
                                   :unseen_count => logged_in_user.prospects_with_alerted_notifications.size)
        end
      elsif tab_name == 'Selling'   # hack
        options[:id] = 'navbar_selling_li'
        li(options) do
            text navbar_link(:count => logged_in_user.count_for_selling_tab,
                             :unseen_count => logged_in_user.listings_with_alerted_notifications.size,
                             :label => 'selling',
                             :target => listings_path.to_s)
            text navbar_alert_link(:label => 'selling',
                                   :unseen_count => logged_in_user.listings_with_alerted_notifications.size)
        end
      else
        li(options) do
            link_to tab_name, tab_link, link_options
        end
      end
    end
  end

  def manage_subnavbar(options = {})
    active_tab = options[:active_tab]

    markaby do
      content_for(:subnav) do
        div :class => 'Home' == active_tab ? 'tab_active' : 'tab' do
          link_to 'Home', :controller => 'home'
        end
        div :class => 'Partner Manager' == active_tab ? 'tab_active' : 'tab' do
          link_to "Partner Manager", partners_path, :id => 'partner_manager_tab_link'
        end
          div :class => 'Preferences' == active_tab ? 'tab_active' : 'tab' do
          link_to "Preferences", user_path(@user), :id => 'user_preferences_tab_link'
        end
      end
    end
  end

  def transacting_subnavbar(options = {})
    active_tab = options[:active_tab]
    markaby do
      content_for(:subnav) do
        div :class => 'Pending' == active_tab ? 'tab_active' : 'tab' do
          link_to 'Pending', url_for(:controller => 'transactions', :action => :index_pending)
        end
        div :class => 'History' == active_tab ? 'tab_active' : 'tab' do
          link_to 'History', url_for(:controller => 'transactions', :action => :index)
        end
      end
    end
  end
  
  def bar
    " | "
  end

  def is_ie?
    request.env['HTTP_USER_AGENT'] =~ /MSIE/
  end

  def clear_div
    "<div class='clear' />"
  end

  def clear_floats
    clear_div
  end

  def stylesheet(filename)
    if File.exist?("#{RAILS_ROOT}/public/stylesheets/#{filename}.css")
      stylesheet_link_tag(filename)
    elsif RAILS_ENV=='development'
      "\n<!-- missing stylesheet #{filename} -->"
    end
  end

  def navbar_link(options)
    link_text = options[:label].capitalize
    count_class = options[:unseen_count] > 0 ? "unseen_count" : "count"
    link_text += " <span class='#{count_class}'>(#{options[:count]})</span>" if options[:count] > 0
    link_options = { :class => 'inbox' }
    link_path = options[:target]
    return link_to(link_text, link_path, link_options)
  end

  def navbar_alert_link(options)
    popup_link = ''
    if options[:unseen_count] > 0
      link_text = '&nbsp;'
      link_options = { :id => "#{options[:label]}_alert_link",
                       :class => 'alert',
                       :onclick => "#{options[:label]}_popup_alerter.toggle();" }
      popup_link = link_to(link_text, '#', link_options)
    end
    s = javascript_tag "#{options[:label]}_popup_alerter = new Alerter('#{options[:label]}_popup', '#{options[:label]}_alert_link', '#{notifications_path(:tab => options[:label])}')"
    return s + popup_link
  end

  def render_error_messages(show_header = true)
    messages = flash[:notice]
    return '' if messages.blank?

    markaby do
      div.flash_notice do
        if show_header
          text "Please correct the errors below"
        end
        ul do
          messages.each do |message|
            li message
          end
        end
      end
    end
  end

  def property_row(id, title, value, readonly = true)
    markaby do
      tr do
        td(:class => 'label_col', :id => "#{id}_label") do
          label(:for => id) do
            text "#{title}:"
          end
        end
        td(:class => readonly ? 'field_value' : 'field_editor', :id => id) do
          text value
        end
      end
    end
  end

  def field_row(form_object, field, id, form, readonly = false)
    markaby do
      value = readonly ? field.display_html(form_object) : field.editor_html(form)
      property_row(field.property_name, field.title, value, readonly)
    end
  end

  def fields_list(form_object, list, id, form, readonly = false)
    markaby do
      list.each do |field|
        field_row(form_object, field, id, form, readonly)
      end
    end
  end

  def form_btn(title, options = {})
    options[:class] = (options[:class].nil? ? 'button' : 'button ' + options[:class])
    options[:href] ||= '#'
    options[:title] = title

    markaby do
      a options do
        span title;
      end
    end
  end

  def task_box(markaby)
    content_for(:css) do
      stylesheet "tasks"
    end
    markaby.div :class => 'task_box' do
      div :id => 'scrollable_content', :class => 'task_scroll' do
        table :id => 'task_table' do
          tr do
            yield
          end
        end
      end
    end
  end

  def partners_table(partners, show_checkboxes = true)
    markaby do
      table.partners do
        tr do
          th "Trusted Partner"
          th "Dealership Name"
          th "Status"
          th "Distance"
          th ""
        end
        partners.each do |user|
          tr do
            td do
              label do
                if show_checkboxes
                  check_box_tag("user[]", user.to_param, (listing.recipients.include?(user)))
                  text " "
                end
                text user.full_name
              end
            end
            td user.dealership.name
            td "Partner"
            td "%.2f miles" % user.distance_from(logged_in_user)
            td ""
          end
        end
      end
    end
  end

  # to remove deprecation warnings
  def end_form_tag
    "</form>"
  end

  def length_of_time_from_now(time)
    modifier = (time >= Time.now) ? "from now" : "ago"
    "#{distance_of_time_in_words_to_now(time)} #{modifier}"
  end

  def page_state_includes?(state_type, possibility, is_default)
    selected_state = params[state_type]
    (selected_state.nil? && is_default) || (selected_state == possibility)
  end

  def tertiary_tab(section, is_default = false)
    markaby do
      class_value  = 'tertiary_tab'
      class_value << ' active_tab' if @helpers.page_state_includes?(:tertiary_tab, section, is_default)

      div(:id => "#{section}_content_tab", :class => class_value) do
        link_to_function(section.titleize, 'VNS.PageState.select_tertiary_tab(this)')
      end
    end
  end

  def tertiary_tab_content(builder, section, is_default = false, &block)
    style_value = (page_state_includes?(:tertiary_tab, section, is_default) ? 'display: block;' : 'display: none;')

    builder.div(:id => "#{section}_content", :style => style_value) do
      builder.instance_eval(&block)
    end
  end

  def edit_popup(options = {}, &block)
    redraw = options[:redraw] || false

    markaby do
      if redraw
        edit_popup_content(options, &block)
      else
        div(:id => "edit_#{options[:aspect]}_popup", :style => 'display: none', :class => 'edit_popup') do
          edit_popup_content(options, &block)
        end
      end
    end
  end

  def vehicle_details_edit_controls(vehicle, form)
    markaby do
      table do
        fields_list(vehicle, VehicleField::EDITABLE, 'details_fields', form)
      end
      p "Note: Comments will be visible to all potential buyers."
    end
  end

  private

  def edit_popup_content(options, &block)
    target_aspect = options[:aspect]
    target        = options[:target]
    target_class  = target.class.to_s.underscore
    target_symbol = target_class.to_sym
    target_path   = @controller.send("#{target_class}_path", target).to_s

    markaby do
      h3 "Edit #{target_aspect.titleize}"

      remote_form_for(target_symbol, target,
                      :url => target_path,
                      :update => "edit_#{target_aspect}_popup",
                      :method => :put,
                      :html => {:id => "edit_#{target_aspect}_form"}) do |form|
        div(:class => "popup_content") do
          render_error_messages
          self.instance_exec(form, &block)
        end

        div(:class => "popup_footer") do
          page_reload = options[:page_reload]

          if page_reload
            script "location.reload(true);"
          else
            div(:id => "edit_#{target_aspect}_popup_buttons") do
                          
              # form_btn("Cancel", :id => "edit_#{target_aspect}_popup_button_cancel", 
              #                     :onclick => update_page{|page|
              #                                    page["edit_#{target_aspect}_form"].reset
              #                                    page["edit_#{target_aspect}_popup"].toggle
              #                                    page["edit_#{target_aspect}_display"].toggle})   
              #  
              #  form_btn("Submit Changes", :id => "edit_#{target_aspect}_popup_button_submit",
              #                             :onclick => "new Ajax.Request('', {
              #                                          method: 'get',
              #                                          onSuccess: $('edit_#{target_aspect}_popup_buttons').style.display = 'none'; 
              #                                                     $('edit_#{target_aspect}_popup_progress').style.display = 'inline';
              #                                          });")
              #                             
                                         
              
              submit_tag("Submit Changes",
                         :id      => "edit_#{target_aspect}_popup_button_submit",
                         :onclick => "$('edit_#{target_aspect}_popup_buttons').style.display = 'none'; $('edit_#{target_aspect}_popup_progress').style.display = 'inline';")
              button_to_function("Cancel", :id => "edit_#{target_aspect}_popup_button_cancel") do |page|
                page["edit_#{target_aspect}_form"].reset
                page["edit_#{target_aspect}_popup"].toggle
                page["edit_#{target_aspect}_display"].toggle
              end      

              br.clear
            end
          end
          image_tag("progress_bar2.gif", :id => "edit_#{target_aspect}_popup_progress", :class => 'progress_indicator', :style => (page_reload ? 'display: inline;' : 'display: none;'))
        end
      end
    end
  end
end
