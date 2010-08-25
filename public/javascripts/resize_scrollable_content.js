
function resizeTaskBox() {
  var element = $('scrollable_content');
  var windowHeight = Utils.windowDimensions().height;
  var elementHeight = Element.getStyle(element, 'height');
  var elementTop = findPos(element)[1]
  var newHeight;
	var offset = 0;

	var is_ie/*@cc_on = {
  // quirksmode : (document.compatMode=="BackCompat"),
  version : parseFloat(navigator.appVersion.match(/MSIE (.+?);/)[1])
	}@*/;
	if (is_ie && (is_ie.version < 7)) offset = 20;

  if (element.className == 'task_scroll') {
    newHeight = (windowHeight - elementTop - 65 + offset);
  } else {
    newHeight = (windowHeight - elementTop - 30 + offset);
  }
  Element.setStyle(element, {'height' : "" + newHeight + "px"});
}

function findPos(obj) {
	var curleft = curtop = 0;
	if (obj.offsetParent) {
		curleft = obj.offsetLeft
		curtop = obj.offsetTop
		while (obj = obj.offsetParent) {
			curleft += obj.offsetLeft
			curtop += obj.offsetTop
		}
	}
	return [curleft,curtop];
}

YAHOO.util.Event.addListener(window, "load", resizeTaskBox);
YAHOO.util.Event.addListener(window, "resize", resizeTaskBox);
