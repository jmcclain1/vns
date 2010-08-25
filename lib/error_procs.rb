ERROR_PROCS = {}
ERROR_PROCS[:errors_below] = Proc.new do |html_tag, instance|
  msg = instance.error_message.is_a?(Array) ? instance.error_message.join("<br />") : instance.error_message

  pre, post = '', ''
  if html_tag.include?('type="checkbox"')
    styling = "border: 1px solid #ff977a; padding: 1px;"
    pre = '<span style="background-color: #ff977a; padding: 1px; padding-top: 0; padding-bottom: 1.5px;"'
    post = '</span>'
  else
    styling = "background-color: #ff977a"
  end

  if html_tag =~ /<(input|textarea|select)[^>]+style=/
    style_attribute = html_tag =~ /style=['"]/
    html_tag.insert(style_attribute + 7, "#{styling}; ")
  elsif html_tag =~ /<(input|textarea|select)/
    first_whitespace = html_tag =~ /\s/
    html_tag[first_whitespace] = " style='#{styling}' "
  end
  pre + html_tag + post
end