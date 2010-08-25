require File.dirname(__FILE__) + '/../spec_helper'

describe Field do

  class GenericField < Field
    def editor_html(form)
      form.datetime_field(@property_name)
    end
  end

  before do
    @field = GenericField.new(:party_time, "Party Starts At", :datetime_field)
  end

  it "should ask the form for the right editor_html" do
    form = mock("Party Invitation Form")
    form.should_receive(:datetime_field).with(:party_time).once
    editor_html = @field.editor_html(form)
    # we're done!
  end
  
  it "should ask the object for the right property" do
    noon = Time.now
    object = mock("Invitation")
    object.should_receive(:party_time).once.and_return(noon)
    displayed_text = @field.display_html(object)
    displayed_text.should == noon.to_s
    # we're done!
  end

  it "should use 'Yes' and 'No' for booleans" do
    boolean_field = GenericField.new(:awesome, "Are you awesome?", :check_box)
    awesome = mock("Awesome")
    awesome.should_receive(:awesome).and_return(true)

    lame = mock("Lame")
    lame.should_receive(:awesome).and_return(false)

    boolean_field.display_html(awesome).should== "Yes"
    boolean_field.display_html(lame).should== "No"
  end

  it "receives extra html options in the 'editor_html' method"

end

describe Field::YesNo do

  it "renders the display html as 'Yes' if the value is true" do
    field = Field::YesNo.new(:likes_ice_cream, "Do you like ice cream?")
    object = mock("Child")
    object.should_receive(:likes_ice_cream).and_return(true)
    field.display_html(object).should == "Yes"
  end

  it "renders the display html as 'No' if the value is false" do
    field = Field::YesNo.new(:likes_ice_cream, "Do you like ice cream?")
    object = mock("Child")
    object.should_receive(:likes_ice_cream).and_return(false)
    field.display_html(object).should == "No"
  end

  it "renders the editor html as a yes-no radio button pair" do
    field = Field::YesNo.new(:likes_ice_cream, "Do you like ice cream?")
    form = mock("Form")
    form.should_receive(:radio_button).with(:likes_ice_cream, true).and_return("<YES BOX>")
    form.should_receive(:radio_button).with(:likes_ice_cream, false).and_return("<NO BOX>")
    field.editor_html(form).should == "<label><YES BOX> Yes</label><label><NO BOX> No</label>"
  end


end

describe Field::Color do
  before do
    @auburn = mock("Auburn")
    @auburn.stub!(:id).and_return(51)
    @auburn.stub!(:name).and_return("Auburn")

    @blonde = mock("Blonde")
    @blonde.stub!(:id).and_return(50)
    @blonde.stub!(:name).and_return("Blonde")

    @redhead = mock("Redhead")
    @redhead.stub!(:id).and_return(52)
    @redhead.stub!(:name).and_return("Redhead")

    @hair_colors = [@auburn, @blonde, @redhead]
  end
  
  it "should use color names for displaying Color fields" do
    color_field = Field::Color.new(:hair_color, "Hair Color")
    marilyn = mock("Marilyn")
    marilyn.should_receive(:hair_color).and_return(@blonde)
    color_field.display_html(marilyn).should== "Blonde"
  end

  it "should use the color list for editing Color fields" do
    hair_color_field = Field::Color.new(:hair_color, "Hair Color")
    marilyn = mock("Marilyn")
    marilyn.should_receive(:hair_colors).and_return(@hair_colors)

    form = mock("Movie Star Form")
    form.should_receive(:object).once.and_return(marilyn)
    form.should_receive(:collection_select).with(:hair_color_id, @hair_colors, "id", "name").once

    editor_html = hair_color_field.editor_html(form)
  end

end

describe Field::Money do

  before do
    @money_field = Field::Money.new(:price, "Price")
  end

  it "should display money fields with proper formatting" do
    burger = mock("Burger")
    burger.should_receive(:price).and_return(BigDecimal("1234.56"))
    @money_field.display_html(burger).should== "$1,234.56"
  end

  it "should display nil money fields as blanks (not as 0.00)" do
    burger = mock("Burger")
    burger.should_receive(:price).and_return(nil)
    @money_field.display_html(burger).should == ""
  end

  it "should display 0 money fields as $0.00" do
    burger = mock("Burger")
    burger.should_receive(:price).and_return(BigDecimal("0"))
    @money_field.display_html(burger).should == "$0.00"
  end

  it "should display money edit widgets with a $ in front" do
    form = mock("Burger Form")
    form.should_receive(:text_field).with(:price).once.and_return("<INPUT>")
    @money_field.editor_html(form).should include("<span class='currency_symbol'>$</span><INPUT>")
  end

end

describe Field::State do
  before do
    @state_field = Field::State.new(:title_state, "State")
  end

  it "should use state names for displaying State fields" do
    vehicle = mock("A Vehicle")
    vehicle.should_receive(:title_state).and_return('CA')

    @state_field.display_html(vehicle).should == "California"
  end

  it "should use the state list for editing State fields" do
    vehicle = mock("A Vehicle")
    vehicle.should_receive(:title_states).and_return(States::US.all)
    vehicle.stub!(:title).and_return(false)

    form = mock("Movie Star Form")
    form.should_receive(:object).twice.and_return(vehicle)
    form.should_receive(:select).with(:title_state, States::US.all, {}, :disabled => true).once

    editor_html = @state_field.editor_html(form)
  end
end

describe Field::Text do

  before do
    @email = mock("Email")
    @subject_field = Field::Text.new(:subject, "Subject")
  end

  it "should display text fields" do
    @email.should_receive(:subject).and_return("Re: Lunch")
    @subject_field.display_html(@email).should== "Re: Lunch"
  end

  it "should display text edit widgets" do
    form = mock("Email Form")
    form.should_receive(:text_field).with(:subject).once.and_return("<INPUT>")
    @subject_field.editor_html(form).should== "<INPUT>"
  end

end

describe Field::CheckBox do

  before do
    @email = mock("Email")
    @was_read_field = Field::CheckBox.new(:was_read, "Was Read")
  end

  it "should display boolean true as Yes" do
    @email.should_receive(:was_read).and_return(true)
    @was_read_field.display_html(@email).should== "Yes"
  end

  it "should display boolean false as No" do
    @email.should_receive(:was_read).and_return(false)
    @was_read_field.display_html(@email).should== "No"
  end

  it "should display correct edit widget" do
    form = mock("Email Form")
    form.should_receive(:check_box).with(:was_read).once.and_return("<INPUT>")
    @was_read_field.editor_html(form).should== "<INPUT>"
  end

end

describe Field::TextArea do

  before do
    @body_field = Field::TextArea.new(:body, "Body")
  end

  it "should display text fields" do
    @email = mock("Email")
    @email.should_receive(:body).and_return("I'm hungry")
    @body_field.display_html(@email).should== "I'm hungry"
  end

  it "should display text edit widgets" do
    form = mock("Email Form")
    form.should_receive(:text_area).with(:body).once.and_return("<TEXTAREA>")
    @body_field.editor_html(form).should== "<TEXTAREA>"
  end

end

describe Field::DateTime do

  before do
    @sent_field = Field::DateTime.new(:sent, "Sent")
  end

  it "should display text fields" do
    now = Time.now
    @email = mock("Email")
    @email.should_receive(:sent).and_return(now)
    @sent_field.display_html(@email).should== now.to_s
  end

  it "should display text edit widgets" do
    form = mock("Email Form")
    form.should_receive(:datetime_select).with(:sent).once.and_return("<HTML>")
    @sent_field.editor_html(form).should== "<HTML>"
  end

end

### this is to automatically assure that all field types pass html_options
# to their respective form methods. It's a bit convoluted... :-)

class FakeObject
  def foo
    "bar"
  end
  def foos
    ["baz", "baf"]
  end
  def title
    "Foo"
  end
end

class FakeForm
  def initialize
    @object = FakeObject.new
  end
  def object
    @object
  end
  def method_missing(method_name, *args)
    args.each do |arg|
      return if arg == {:size => 100}
    end
    raise "Expected #{method_name} to be called with html_options"
  end
end

FIELD_TYPES = [Field::Text, Field::TextArea, Field::DateTime, Field::CheckBox, Field::YesNo, Field::Color, Field::Money, Field::State ]
FIELD_TYPES.each do |field_type|
  describe field_type do
    it "should accept html options in its constructor" do
      form = FakeForm.new
      field = field_type.new(:foo, "Foo", {:size => 100})
      field.editor_html(form)
    end
  end
end
