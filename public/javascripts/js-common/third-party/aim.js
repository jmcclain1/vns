/**
 *
 *  AJAX IFRAME METHOD (AIM)
 *  http://www.webtoolkit.info/
 *  Based on code from http://www.webtoolkit.info/ajax-file-upload.html
 *
 **/

AIM = {

  submit : function(form, iFrameName, callbacks) {
    AIM._form(form, AIM._frame(iFrameName, callbacks));
    if (callbacks && typeof(callbacks.onStart) == 'function') {
      return callbacks.onStart();
    } else {
      return true;
    }
  },
  
  _frame : function(iFrameName, callbacks) {
    var iFrameContainerName = iFrameName + "_container";
    var div = $(iFrameContainerName);
    if(!div) {
      div = document.createElement('DIV');
      div.id = iFrameContainerName;
      document.body.appendChild(div);
    }
    div.innerHTML = '<iframe style="display:none" src="about:blank" id="' + iFrameName + '" name="' + iFrameName + '" onload="AIM.loaded(\'' + iFrameName + '\')"></iframe>';

    var iFrame = document.getElementById(iFrameName);
    if (callbacks && typeof(callbacks.onComplete) == 'function') {
      iFrame.onComplete = callbacks.onComplete;
    }

    return iFrameName;
  },

  _form : function(form, name) {
    form.setAttribute('target', name);
  },

  loaded : function(iFrameName) {
    var iFrame = $(iFrameName);
    if (iFrame.contentDocument) {
      var document = iFrame.contentDocument;
    } else if (iFrame.contentWindow) {
      var document = iFrame.contentWindow.document;
    } else {
      var document = window.frames[iFrameName].document;
    }
    if (document.location.href == "about:blank") {
      return;
    }

    if (typeof(iFrame.onComplete) == 'function') {
      iFrame.onComplete(document.body.innerHTML);
    }
  },

  formatJavascript: function(content) {
    content = content.gsub(/<pre>/i, '');
    content = content.gsub(/<\/pre>/i, '');
    content = content.gsub('&lt;', "<");
    content = content.gsub('&gt;', ">");
    return content;
  }
}
