VNS = {}

VNS.PageState = {}
VNS.PageState.select_tertiary_tab = function(tab_link) {
  var target_tab     = tab_link.parentNode.id;
  var target_content = target_tab.replace('content_tab', 'content');
  var tabs           = document.getElementsByClassName('tertiary_tab');

  for(var i = 0; i < tabs.length; i ++) {
    var tab_id     = tabs[i].id;
    var content_id = tab_id.replace('content_tab', 'content');

    if(Element.visible(content_id)) {
      Element.toggle(content_id);
    }

    Element.removeClassName(tab_id, 'active_tab');
  }

  Element.addClassName(target_tab, 'active_tab');
  Element.toggle(target_content);
}

VNS.PageState.select_message_row = function(row_element) {
  var target_trigger = row_element.id;
  var target_content = target_trigger.replace('content_trigger', 'content');
  var triggers       = document.getElementsByClassName('buyer_info');
  var message_forms  = document.getElementsByClassName('send_message_form');

  for(var i = 0; i < triggers.length; i ++) {
    Element.removeClassName(triggers[i].id, 'active_trigger');

		if (Element.visible($(message_forms[i].id))) {
				 VNS.FormHelper.toggle_windowshade_form($(message_forms[i].id));
		}

    var content_id = triggers[i].id.replace('content_trigger', 'content');
		
    Element.hide(content_id);
  }
	
  Element.addClassName(target_trigger, 'active_trigger');
  Element.show($(target_content).id);
}

VNS.FormHelper = {}
VNS.FormHelper.toggle_windowshade_form = function(form_container) {
  var triggers  = document.getElementsByClassName('windowshade_form_trigger');

  for(var i = 0; i < triggers.length; i ++) {
    triggers[i].toggle();
  }

  form_container.toggle();
}
