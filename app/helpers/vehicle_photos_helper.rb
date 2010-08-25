module VehiclePhotosHelper
  include ApplicationHelper

  def vehicle_photos_widget(vehicle, options = {})
    markaby do
      div(:id => 'photos_widget') do
        thumbnail_section(vehicle)
        preview_section(vehicle)
        control_section(vehicle) unless options[:read_only]
      end
    end
  end

  private

  def thumbnail_section(vehicle)
    markaby do
      div(:id => 'thumbnail_container') do
        table(:cellpadding => "0", :cellspacing => "0") do
          vehicle.photos.each_with_index do |photo, index|
            next if index % 2 == 1
            first_photo = photo
            second_photo = vehicle.photos[index + 1] if vehicle.photos.length > index + 1
            tr do
              td(:id => "thumbnail_#{index}") do
                thumbnail(first_photo, first_photo == vehicle.primary_photo)
              end
              td(:id => "thumbnail_#{index + 1}") do
                thumbnail(second_photo, second_photo == vehicle.primary_photo) unless second_photo.nil?
              end
            end
          end
        end
      end
    end
  end

  def preview_section(vehicle)
    markaby do
      div(:id => 'preview_container') do
        if vehicle.photos.empty?
          # NOTE: with Photoable, the primary photo for an empty list is the default photo ("no photo available"), for
          # which we want to make no link.
          img(:id => 'preview_photo', :src => vehicle.primary_photo.versions[:large].url)
        else
          a(:id =>'fullsize_link', :target => '_blank', :href => vehicle.primary_photo.versions[:fullsize].url, :title => "Click to enlarge") do
            img(:id => 'preview_photo', :src => vehicle.primary_photo.versions[:large].url)
          end
        end
      end
    end
  end

  def control_section(vehicle)
    markaby do
      div(:id => 'control_container') do
        form_tag({:controller => "vehicle_photos", :action => :create, :vehicle_id => vehicle.id}, {:id => 'upload_photo', :multipart => true})
          div :style => 'line-height: 2em;' do
            span "Add Photo: "
            file_field_tag('photo', {:onchange => '$("photo").style.display = "none"; $("uploading").style.display = "inline"; this.form.submit();'})
            span.uploading! :style => "display: none;" do
              text "Uploading photo..."
              img :src => '/images/spinny.gif'
            end
          end
        end_form_tag

        div do
          form_tag({:controller => "vehicle_photos", :action => :set_primary, :vehicle_id => vehicle.id}, {:id => 'make_photo_primary'})
            hidden_field_tag('primary_photo_id', vehicle.primary_photo.id)
            submit_tag("Make Primary")
          end_form_tag

          form_tag({:controller => "vehicle_photos", :action => :delete, :vehicle_id => vehicle.id}, {:id => 'delete_photo'})
            hidden_field_tag('delete_photo_id', vehicle.primary_photo.id)
            submit_tag("Delete")
          end_form_tag
        end
      end
    end
  end

  def thumbnail(photo, is_primary)
    class_name = 'thumbnail'
    class_name += ' primary_thumbnail' if is_primary

    markaby do
      onclick =<<-js
        $('fullsize_link').href = '#{photo.versions[:fullsize].url}';
        $('preview_photo').src = '#{photo.versions[:large].url}';
        var lastSelected = $('thumbnail_container').getElementsByClassName('primary_thumbnail')[0];
        lastSelected.className = lastSelected.className.replace(/primary_thumbnail/ig, '');
        this.parentNode.className += ' primary_thumbnail';
        $('primary_photo_id').value = #{photo.id};
        $('delete_photo_id').value = #{photo.id};
      js

      div(:class => class_name) do
        img(
          :src => photo.versions[:small].url,
          :onclick => onclick,
          :id => "vehicle_thumb_#{photo.id}"
        )
      end
    end
  end

end