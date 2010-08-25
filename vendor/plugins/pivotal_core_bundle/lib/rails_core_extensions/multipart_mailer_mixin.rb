require "action_mailer"

class ActionMailer::Base
  def multipart(template_name, assigns)
    content_type 'multipart/alternative'
    
    part :content_type => "text/plain",
   	     :body => render_message("./#{template_name}.plain.rhtml", assigns)

    part :content_type => "text/html",
  	     :body => render_message("./#{template_name}.html.rhtml", assigns)
  end
end

module MultipartMailerMixin
  def self.included(base)
    puts "MultipartMailerMixin has been deprecated.  Just remove the include, since ActionMailer has it automagically now."
  end
end