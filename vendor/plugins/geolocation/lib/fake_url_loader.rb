class FakeUrlLoader < UrlLoader
  def initialize(response)
    @expected_response = response
    @url = ""
  end
  attr_writer :expected_response
  def load
    raise @expected_response if @expected_response.is_a?(Exception)
    @expected_response
  end
end

