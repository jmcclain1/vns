namespace :db do
  desc "Loads stock photos"
  task :load_stock_photos do
    require "environment"
    photo_path = ENV['PHOTO_PATH']
    photo_type = ENV['PHOTO_TYPE']

    photo_class = photo_type.constantize
    Dir.open(photo_path) do |dir|
      dir.each do |entry|
        file_path = "#{dir.path}\\#{entry}"

        next if File.directory?(file_path)
        File.open(file_path, 'rb') do |file|

          photo = photo_class.new(:path => entry)
          photo.data = file
          photo.save!
        end
      end
    end
  end
end