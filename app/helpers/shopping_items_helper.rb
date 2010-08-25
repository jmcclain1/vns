module ShoppingItemsHelper
  include MarkabyHelper

  def shopping_list_form(show_search = false)
    markaby do
      div :id => 'shopping_list_form_box' do
        h3 "New Shopping Item"
        fieldset do
          error_messages_for :item

          script do
            text "var showing = '#{Evd::Make::ANY}';"
          end
          form_tag shopping_items_path.to_s, :id => 'shopping_list_form'
            div :class => 'field' do
              span.label "Make: "
              choices = [["Any", Evd::Make::ANY]] + Evd::Make.all.collect {|m| [ m.name, m.id ] }
              select_mab("item", "make_id", choices, {}, {:onchange => "Element.hide(showing); Element.show(this.value); showing = this.value;"})
            end
            div :id => 'model', :class => 'field' do
              span.label "Model: "
              span(:id => Evd::Make::ANY) do
                text "Any"
              end
              Evd::Make.all.each do |make|
                span(:id => make.id, :style => "display: none;") do
                  options = [["Any", Evd::Model::ANY]] + make.models.collect {|m| [ m.name, m.id ] }
                  select_mab("item", "model_id", options, {}, {:name => "#{make.id}_model"})
                end
              end
            end
            div :class => 'field' do
              span.label "Min Year: "
              text_field 'item', 'min_year', :size=>5, :value => "Any"
            end
            div :class => 'field' do
              span.label "Max Year: "
              text_field 'item', 'max_year', :size=>5, :value => "Any"
            end
            div :class => 'field' do
              span.label "Within "
              select_mab("item", "max_distance", [["Any distance", 0], ["5 miles", 5], ["10 miles", 10], ["25 miles", 25], ["100 miles", 100]])
            end
            div :class => 'field' do
              span.label " of Zip Code "
              span logged_in_user.dealership.location.postal_code
            end

            br.clear
            a(:href => "#", :id => 'show_more', :onclick => "toggleMore();") do
              text "Show more criteria"
            end
            span.more!(:style => "display: none;") do
      #        a(:href => "#", :onclick => "clearMore(); toggleMore();") do
      #          text "Clear more criteria"
      #        end
              hr
              div :class => 'field' do
                span.label "Min Price: "
                span.currency_symbol "$"
                text_field "item", "min_price", :size => 8
              end
              div :class => 'field' do
                span.label "Max Price: "
                span.currency_symbol "$"
                text_field "item", "max_price", :size => 8
              end
              div :class => 'field' do
                span.label "Min Mileage: "
                text_field "item", "min_odometer", :size => 8
                text " miles"
              end
              div :class => 'field' do
                span.label "Max Mileage: "
                text_field "item", "max_odometer", :size => 8
                text " miles"
              end
              div :class => 'field' do
                br
                span.label_check "Must be certified: "
                check_box "item", "must_be_certified"
              end
              br
            end
            br

            div :id => 'mark_submit' do
              div :class => 'field' do
                span.label_check "Mark as Priority: "
                check_box 'item', 'priority'
              end
              form_btn 'Add to Shopping List', :onclick => "$('shopping_list_form').submit();"
            end
          end_form_tag
        end
      end
    end
  end
end