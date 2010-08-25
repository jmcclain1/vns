require File.dirname(__FILE__) + "/selenium_helper"
require "uri"

class AlertTest < VnsSeleniumTestCase

  def setup
    super

    # create a bunch of Events (which cause Notifications to be created)
    alice   = users(:alice)
    bob     = users(:bob)
    charlie = users(:charlie)
    prospect_1 = prospects(:charlies_interested_in_bobs_listing_1)
    AskEvent.create(:originator => charlie, :prospect => prospect_1, :comment => "Is that a VW?")
    AskEvent.create(:originator => charlie, :prospect => prospect_1, :comment => "Is that green?")
    ReplyEvent.create(:originator => bob,   :prospect => prospect_1, :comment => "Re - Is that a VW?")
    ReplyEvent.create(:originator => bob,   :prospect => prospect_1, :comment => "Re - Is that green?")
    prospect_2 = prospects(:charlies_interested_in_alices_listing_1)
    AskEvent.create(:originator => charlie, :prospect => prospect_2, :comment => "To alice from charlie?")
    ReplyEvent.create(:originator => alice, :prospect => prospect_2, :comment => "Re - To alice from charlie?")

    open "/"
    login users(:bob)
  end

  def teardown
    super
    click_and_wait "id=log_out"
  end

  def test_selling_alert_popup
    assert_not_visible "id=selling_popup"

    assert_selling_alert_popup_can_be_shown_and_hidden
    make_new_ask_event_and_verify_notification_is_shown
  end

  def test_buying_alert_popup
    message = "Hey Bob!"
    create_ask_event_and_reply_event(message)

    assert_not_visible "id=buying_popup"
    assert_reply_msg_is_added
    show_buying_popup
    hide_buying_popup

    show_buying_popup
    follow_new_prospect_link
    assert_text_present message
  end

  protected
  ### Selling popup
  def assert_selling_alert_popup_can_be_shown_and_hidden
    do_command('storeEval', ["this.page().findElement('selling_alert_link').onclick()", 'aClick'])
    assert_visible "id=selling_popup"

    do_command('storeEval', ["this.page().findElement('selling_alert_link').onclick()", 'aClick'])
    assert_not_visible "id=selling_popup"
  end

  def make_new_ask_event_and_verify_notification_is_shown
    event = AskEvent.create(:originator => users(:charlie),
                            :prospect => prospects(:charlies_interested_in_bobs_listing_1),
                            :comment => 'Hello Ms Bell')
    assert_text_present(event.prospect.listing.vehicle.display_name, nil, :timeout => 20)
  end

  ### Buying popup
  def show_buying_popup
    do_command('storeEval', ["this.page().findElement('buying_alert_link').onclick()", 'aClick'])
    assert_visible "id=buying_popup"
  end

  def hide_buying_popup
    do_command('storeEval', ["this.page().findElement('buying_alert_link').onclick()", 'aClick'])
    assert_not_visible "id=buying_popup"
  end

  def create_ask_event_and_reply_event(message)
    prospect    = Prospect.create!(   :dealership => users(:bob).dealership,
                                      :prospector => users(:bob),
                                      :listing    => listings(:jetta_listing_2))
    ask_event   = AskEvent.create!(   :originator => users(:bob),
                                      :prospect   => prospect,
                                      :comment    => 'Hey Charlie')
    reply_event = ReplyEvent.create!( :originator => users(:charlie),
                                      :prospect   => prospect,
                                      :comment    => message)
  end

  def assert_reply_msg_is_added
    assert_text_present("1 listing with new messages", nil,
                        :timeout => 20)
  end

  def follow_new_prospect_link
    click_and_wait "xpath=id('buying_alert_box')//a[1]"
  end
end
