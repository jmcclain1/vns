require File.dirname(__FILE__) + '/../spec_helper'

include ListingsHelperMethods

describe ApplicationHelper do
  helper_name 'application'

  before do
    self.stub!(:notifications_path).and_return("#")
  end

  it "selects the tab if it's current" do
    assigns[:current_navbar_tab] = "foo"
    doc = Hpricot(tab("foo", '#'))
    doc.at("//li[@class=active]//a").inner_html.should include("foo")
  end

  it "doesn't select the tab if it's not current" do
    assigns[:current_navbar_tab] = "foo"
    doc = Hpricot(tab('bar', '#'))
    doc.at("//li[@class=active]").should == nil
  end
end


describe ApplicationHelper, "its selling link method" do
  helper_name 'application'

  before do
    self.stub!(:listings_path).and_return("/listings")
  end

  it "renders the selling link without the alert icon if no alerts are present" do
    self.stub!(:notifications_path).and_return("/messages")

    html = navbar_link(:count => 1,
                       :unseen_count => 0,
                       :label => 'selling',
                       :target => '/listings')
    doc = Hpricot(html)
    link = doc.at(:a)

    link[:class].should_not == 'alert'
  end

  it "renders the listing count as bold if unseen alerts are present" do
    self.stub!(:notifications_path).and_return("/messages")

    html = navbar_link(:count => 1,
                       :unseen_count => 1,
                       :label => 'selling',
                       :target => '/listings')
    doc = Hpricot(html)
    link = doc.at(:a)

    unbold_count = doc.at("//span[@class='count']")
    bold_count = doc.at("//span[@class='unseen_count']")

    unbold_count.should == nil
    bold_count.inner_html.should == "(1)"
  end

  it "renders the listing count as non-bold if there aren't any unseen alerts" do
    self.stub!(:notifications_path).and_return("/messages")

    html = navbar_link(:count => 1,
                       :unseen_count => 0,
                       :label => 'selling',
                       :target => '/listings')
    doc = Hpricot(html)
    link = doc.at(:a)

    unbold_count = doc.at("//span[@class='count']")
    bold_count = doc.at("//span[@class='unseen_count']")

    bold_count.should == nil
    unbold_count.inner_html.should == "(1)"
  end
end

describe ApplicationHelper, "#length_of_time_from_now" do
  helper_name 'application'

  before do
    @august_31 = Time.parse("Aug 31 2006")
    Time.stub!(:now).and_return(@august_31)
  end

  it "says 'ago' if the time is in the past" do
    length_of_time_from_now(@august_31 - 1.day).should == "1 day ago"
    length_of_time_from_now(@august_31 - 2.days).should == "2 days ago"
  end

  it "says 'from now' if the time is in the future" do
    length_of_time_from_now(@august_31 + 1.day).should == "1 day from now"
  end
end

describe ApplicationHelper, "#edit_popup" do
  helper_name 'application'

  before :each do
    @popup_aspect = 'test_content'
    @popup_doc = Hpricot(edit_popup(:aspect => @popup_aspect, :target => create_mock_vehicle) do
      content_block
    end)
    @popup_container = @popup_doc.at("//div[@id=edit_#{@popup_aspect}_popup]")
    @popup_content = @popup_container.at("div[@class=popup_content]")
  end

  it "should default to hidden" do
    @popup_container[:style].should == 'display: none'
  end

  it "should use the :id argument to generate an id on the container and a pretty title" do
    @popup_container.should_not be_nil
    @popup_container.at("h3").innerText.should == "Edit #{@popup_aspect.titleize}"
  end

  it "should wrap the content (presented as a block) with the popup frame" do
    @popup_content.innerHTML.should == content_block
  end
  
  it "should generate an AJAX-erated form" do
    form = @popup_container.at("//form[@id=edit_#{@popup_aspect}_form]")
    form.should_not be_nil
    form[:onsubmit].should_not be_nil
    form[:onsubmit].should match(/^new Ajax\.Updater\(/)
  end

  it "should include a submit in the footer" do
    button = @popup_container.at("//input[@id=edit_#{@popup_aspect}_popup_button_submit]")
    button.should_not be_nil
    button[:value].should == "Submit Changes"
  end

  it "should include a cancel in the footer" do
    button = @popup_container.at("//input[@id=edit_#{@popup_aspect}_popup_button_cancel]")
    button.should_not be_nil
    button[:value].should == "Cancel"
    # @popup_container.at("//a[@id=edit_#{@popup_aspect}_popup_button_cancel]/span").innerText.should == "Cancel"
  end

  it "should include a close button in the header"

  def content_block
    return "<content>I am CONTENT!</content>"
  end
end

describe ApplicationHelper, "#tertiary_tab" do
  helper_name 'application'

  before :each do
    tab_section = 'selected_section'
    params[:tertiary_tab] = tab_section

    tab_doc      = Hpricot(tertiary_tab(tab_section))
    @tab_element = tab_doc.at("div[@id='#{tab_section}_content_tab']")
    @tab_link    = @tab_element.at("a")
  end

  it "should render the tab with an id derived from the 'section' argument" do
    @tab_element.should_not be_nil
  end

  it "should label the tab with text derived from the 'section' argument" do
    @tab_link.inner_text.should == 'Selected Section'
  end

  it "should apply the tab-switching javascript logic appropriate for the particular tab" do
    @tab_link[:onclick].should == "VNS.PageState.select_tertiary_tab(this); return false;"
  end

  it "should indicate whether the tab is selected based on the 'section' argument and 'selected_tab' assigns attribute" do
    @tab_element[:class].should match(/tertiary_tab/)
    @tab_element[:class].should match(/active_tab/)

    unselected_tab     = Hpricot(tertiary_tab('unselected_section'))
    unselected_element = unselected_tab.at("div[@id='unselected_section_content_tab']")
    unselected_element[:class].should     match(/tertiary_tab/)
    unselected_element[:class].should_not match(/active_tab/)
  end

  it "should fall back on the default tab if the 'page_state' hash doesn't have a :tertiary_tab key" do
    params[:tertiary_tab] = nil

    tab_01 = Hpricot(tertiary_tab('section_01'))
    tab_02 = Hpricot(tertiary_tab('section_02', true))
    tab_03 = Hpricot(tertiary_tab('section_03'))

    tab_01.at("div[@id='section_01_content_tab']")[:class].should_not match(/active_tab/)
    tab_02.at("div[@id='section_02_content_tab']")[:class].should     match(/active_tab/)
    tab_03.at("div[@id='section_03_content_tab']")[:class].should_not match(/active_tab/)
  end
end

describe ApplicationHelper, '#tertiary_tab_content' do
  helper_name 'application'

  # TODO: Activate the tests below.
  #       The logic is complete, but we currently need to pass a Markaby builder instance to the helper
  #       (something to do with having render :partial as the &block) and that's not easy to do from here.

#  before :each do
#    tab_section = 'selected_section'
#    params[:page_state] = {:tertiary_tab => tab_section}
#
#    @content_doc     = Hpricot(tertiary_tab_content(tab_section) { content_body })
#    @content_element = @content_doc.at("div[@id='#{tab_section}_content']")
#  end

  it "should render a content div containing the block argument"
#  it "should render a content div containing the block argument" do
#    @content_element.inner_html.should == content_body
#  end

  it "should render the content for the active tab as 'display: block'"
#  it "should render the content for the active tab as 'display: block'" do
#    @content_element[:style].should == 'display: block;'
#  end

  it "should render the content for inactive tabs as 'display: none'"
#  it "should render the content for inactive tabs as 'display: none'" do
#    content        = "HIDDEN"
#    hidden_doc     = Hpricot(tertiary_tab_content('hidden_section') { content })
#    hidden_element = hidden_doc.at("div[@id='hidden_section_content']")
#
#    hidden_element.inner_html.should == content
#    hidden_element[:style].should == 'display: none;'
#  end

  it "should fall back on the default content if the params hash doesn't have a :tertiary_tab key"
#  it "should fall back on the default content if the 'page_state' hash doesn't have a :tertiary_tab key" do
#    params[:page_state] = {}
#
#    content_01 = Hpricot(tertiary_tab_content('section_01')      { content_body })
#    content_02 = Hpricot(tertiary_tab_content('section_02', true){ content_body })
#    content_03 = Hpricot(tertiary_tab_content('section_03')      { content_body })
#
#    content_01.at("div[@id='section_01_content']")[:style].should == 'display: none;'
#    content_02.at("div[@id='section_02_content']")[:style].should == 'display: block;'
#    content_03.at("div[@id='section_03_content']")[:style].should == 'display: none;'
#  end

  def content_body
    "<content>CONTENT BLOCK</content>"
  end
end

describe ApplicationHelper, '#vehicle_equipment_list_controls' do
  helper_name 'application'

  it "renders a checkbox and description for every feature for a given vehicle" do
    fixture_vehicle = vehicles(:jetta_vehicle_1)
    self.stub!(:vehicle).and_return(fixture_vehicle)

    doc = Hpricot(vehicle_equipment_list_controls)
    feature_checkboxes = doc.search('input[@type="checkbox"]').collect {|element| element[:value]}

    for feature in fixture_vehicle.trim.available_features.find(:all) do
      feature_checkboxes.should include(feature.id)
    end
  end

  it "does check the checkbox if the feature is standard for a given vehicle AND IF 'checkbox_check_standard_feature' parameter IS SET" do
    fixture_vehicle = vehicles(:jetta_vehicle_1)
    self.stub!(:vehicle).and_return(fixture_vehicle)
    fixture_vehicle_features = fixture_vehicle.trim.available_features.find(:all)

    assigns[:checkbox_check_standard_feature] = true
    doc = Hpricot(vehicle_equipment_list_controls)
    feature_checkboxes = doc.search('input[@type="checkbox"]').collect {|element| {:id => element[:value], :checked => element[:checked]}}

    for feature in feature_checkboxes do
      corresponding_fixture_feature = fixture_vehicle_features.select{|f| f.id == feature[:id]}.first
      checked = (feature[:checked] == 'checked')
      checked.should == corresponding_fixture_feature.standard?
    end
  end

  it "does NOT modify the checked state if 'checkbox_check_standard_feature' parameter is NOT set" do
    fixture_vehicle = vehicles(:jetta_vehicle_1)
    fixture_vehicle_feature = fixture_vehicle.trim.available_features.find(:first)
    fixture_vehicle.add_available_feature(fixture_vehicle_feature)

    self.stub!(:vehicle).and_return(fixture_vehicle)
    self.stub!(:checkbox_check_standard_feature).and_return(false)

    doc = Hpricot(vehicle_equipment_list_controls)
    feature_checkboxes = doc.search('input[@type="checkbox"]').collect {|element| {:id => element[:value], :checked => element[:checked]}}

    for feature in feature_checkboxes do
      checked = (feature[:checked] == 'checked')
      is_actual_vehicle_feature = (fixture_vehicle.features.map{|f| f.evd_feature_id}.include?(feature[:id]))
      checked.should == is_actual_vehicle_feature
    end
  end
end

describe ApplicationHelper, "vehicles tablist" do
  
  before :each do
    log_in(users(:bob))
    session[:tablist] = {}
    request = mock("request")
    request.stub!(:path).and_return("/vehicles/13")
    self.stub!(:request).and_return(request)
    self.stub!(:session).and_return({})
    self.stub!(:tab_path).and_return('#')
    
    session[:location] = {}
    session[:location][:controller] = "vehicles"
    session[:user_id] = 1
  end

  it "can add a new tab to its list" do
    tablist_add(:id => 12, :name => "Vehicle 12", :href => "/vehicles/12")

    tablist_paint.should include("Vehicle 12")

    session[:tablist].delete("1_vehicles")
    session[:tablist].size.should == 0
  end

  it "only keeps 0 or 1 tabs in its list" do
    tablist_add(:id => 12, :name => "Vehicle 12", :href => "/vehicles/12")
    tablist_add(:id => 13, :name => "Vehicle 13", :href => "/vehicles/13")
    tablist_add(:id => 11, :name => "Vehicle 11", :href => "/vehicles/11")

    doc = Hpricot(tablist_paint)

    doc.search('//div[@class="tab"]').size.should == 1
    doc.search('//div[@class="tab_active"]').should be_empty
  end

  it "does not allow duplicate tabs to be added" do
    tablist_add(:id => 12, :name => "Vehicle 12", :href => "/vehicles/12")
    tablist_add(:id => 12, :name => "Vehicle 12", :href => "/vehicles/12")

    doc = Hpricot(tablist_paint)

    doc.search('//div[@class="tab"]').size.should == 1
  end

  it "can render an html string of all its tabs" do
    add_tab

    doc = Hpricot(tablist_paint)

    doc.search("a")[0].inner_html.should == "Vehicle 12"
    doc.search("a")[0][:href].should == "/vehicles/12"
  end

  it "renders a link to close a given tab with every tab" do
    add_tab

    doc = Hpricot(tablist_paint)

    doc.search("a")[1][:onclick].should include("tab_div_1_vehicles")
  end

  it "activates the tab that corresponds to the page the user is seeing, and deactivates all others" do
    tablist_add(:id => 1, :name => "Vehicle 13", :href => "/vehicles/13")

    doc = Hpricot(tablist_paint)

    doc.at('//div[@class="tab_active"]').at('a')[:href].should == "/vehicles/13"
    doc.search('//div[@class="tab_active"]').size.should == 1
  end

  private
  def add_tab
    tablist_add(:id => 1, :name => "Vehicle 12", :href => "/vehicles/12")
  end
end