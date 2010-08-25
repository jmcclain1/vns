# Monkey patch to fix fixture_file_upload as per http://dev.rubyonrails.org/changeset/7478

module ActionController #:nodoc:
  class TestUploadedFile
    def initialize(path, content_type = Mime::TEXT, binary = false)
      raise "#{path} file does not exist" unless File.exist?(path)
      @content_type = content_type
      @original_filename = path.sub(/^.*#{File::SEPARATOR}([^#{File::SEPARATOR}]+)$/) { $1 }
      @tempfile = Tempfile.new(@original_filename)
      @tempfile.binmode if binary
      FileUtils.copy_file(path, @tempfile.path)
    end
  end

  module TestProcess
    def fixture_file_upload(path, mime_type = nil, binary = false)
      ActionController::TestUploadedFile.new(
        Test::Unit::TestCase.respond_to?(:fixture_path) ? Test::Unit::TestCase.fixture_path + path : path,
        mime_type,
        binary
      )
    end
  end
end

# Monkey patch to make "select" helper available to markaby templates

module ActionView::Helpers::FormOptionsHelper
  alias select_mab select
end
