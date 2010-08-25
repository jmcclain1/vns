require 'socket'

module JsunitRunner
  class << self
    def application
      @application ||= JsunitRunner::Application.new
    end
  end

  class Application
    attr_accessor :browser_cmd, :app_host, :app_port, :test_page
    def run
      puts "Starting Jsunit Runner:"
      puts "  JSUNIT_BROWSER_CMD=#{@browser_cmd}"
      puts "  JSUNIT_APP_HOST=#{@app_host}"
      puts "  JSUNIT_APP_PORT=#{@app_port}"
      puts "  JSUNIT_TEST_PAGE=#{@test_page}"

      check_for_server        
    
      jsunit_cmd = "#{@browser_cmd} http://#{@app_host}:#{@app_port}/javascripts/js-common/jsunit/testRunner.html?testPage=#{@test_page}%26autorun=true"
      retbuf = execute(jsunit_cmd)
      puts retbuf unless retbuf.nil?
    end
    
    def check_for_server
      begin
        TCPSocket.new(@app_host, @app_port);
      rescue
         raise "There is no server running on #{@app_host}:#{@app_port}!  You need to start the rails app before running jsunit."
      end
    end

    def execute(cmd)
      puts "Executing command '#{cmd}'"
      exec = open("|" + cmd)
      retbuf = exec.read
      exec.close
    end
  end
end