function fireEvent(element, eventName, relatedElement) {
    if (typeof(document.fireEvent) != 'undefined') {
        // IE - should work on all events
        if (element.parentNode == null) {
          document.body.appendChild(element);
        }
        var eventObj = undefined;
        if (eventName == 'mouseout' && relatedElement != null) {
            eventObj = document.createEventObject();
            eventObj.toElement = relatedElement;
        } else if (eventName == 'mouseover' && relatedElement != null) {
            eventObj = document.createEventObject();
            eventObj.fromElement = relatedElement;
        } else if (eventName == 'click') {
            // in ie, simply firing the event will not click a checkbox. This may also happen for radios.
            if (element.type == 'checkbox') {
              element.checked = !element.checked;
              eventObj = document.createEventObject();
            }
        }
        element.fireEvent('on' + eventName, eventObj);
    } else if (BrowserDetect.browser == "Safari") {
        var event = document.createEvent("MouseEvents");
        event.initEvent(eventName, true, true);
        element.dispatchEvent(event);
    } else if (typeof(document.createEvent) != 'undefined') {
        // Mozilla - mouse events only supported right now
        var evt;
        if (eventName == 'click' || eventName == 'dblclick' || eventName == 'mousedown' || 
            eventName == 'mouseup' || eventName == 'focus' || eventName == 'blur') {
            evt = document.createEvent('MouseEvents');
            evt.initMouseEvent(eventName, true, true, document.defaultView,
                0, 0, 0, 0, 0,
                false, false, false, false, 0, element);
        } else if (eventName == 'mouseover' || eventName == 'mouseout') {
            evt = document.createEvent('MouseEvents');
            evt.initMouseEvent(eventName, true, true, document.defaultView,
                0, 0, 0, 0, 0,
                false, false, false, false, 0, relatedElement);
        } else if (eventName == 'change' || eventName == 'submit') {
            evt = document.createEvent('Events');
            evt.initEvent(eventName, true, true);
        } else {
            throw new Error("The fireEvent test helper function does not yet know what to do with eventName " + eventName + ", so define it accordingly.");
        }
        element.dispatchEvent(evt);
	    assertEquals("Element should match", element, YAHOO.util.Event.getTarget(evt));
	    //assertEquals("Related element should match", relatedElement, YAHOO.util.Event.getRelatedTarget(evt));
    } else {
      // other browsers - untested.  Wonder if camelcase or all-lowercase is better?
      if (element['on' + eventName] != null) {
        element['on' + eventName]();
      } else {
        throw new Error("Could not find method for event " + eventName);
      }
    }
};

