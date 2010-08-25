class LabeledFormBuilder < ActionView::Helpers::FormBuilder
  def self.create_generic_field(method_name)
    define_method(method_name) do |label, *args|
      label_string = "#{@object_name}_#{label}"
            
      mab = Markaby::Builder.new
      mab.p do
        label label.to_s.humanize,
              :for => label_string
        tag! :br
        text(super)
      end
      return mab.to_s
    end
  end

  [:text_field, :text_area, :check_box, :password_field].each do |method_name|
    create_generic_field(method_name)
  end
end