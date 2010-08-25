module ApplicationHelper
  def ajax_login_javascript_functions
    <<-EOF
      function login_successful() {
        window.location.href = unescape(window.location.pathname)
      }

      function login_unsuccessful() {
        $('login_message').innerHTML = 'Login Unsuccessful';
      }

      function login_unvalidated() {
        $('login_message').innerHTML = 'Email address not yet validated.';
      }
    EOF
  end
end
