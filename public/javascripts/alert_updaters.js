var Alerter = Class.create();
Alerter.updaters = {};
Alerter.prototype = {
  initialize: function(popup_id, link_id, updater_path) {
    if (Alerter.updaters[updater_path]) {
      this.updater = Alerter.updaters[updater_path];
    } else {
      Alerter.updaters[updater_path] = new AlertUpdater(updater_path);
      this.updater = Alerter.updaters[updater_path];
    }
    this.popup_id = popup_id;
    this.link_id = link_id;
  },

  toggle: function() {
    if (this.popupClicked) {
      this.popupClicked = false;
      return;
    } else if ($(this.popup_id).visible()) {
      $(this.link_id).className =  $(this.link_id).className.replace('_on', '');
      this.updater.start();
      $(this.popup_id).hide();
      document.body.onclick = this.existingBodyOnClick;
    } else {
      $(this.link_id).className += '_on';
      this.updater.stop();
      $(this.popup_id).show();
      this.existingBodyOnClick = document.body.onclick;
      setTimeout(this.setCloseFunction.bind(this), 100);
    }
  },

  setCloseFunction: function() {
    $(this.popup_id).onclick = function() {
      this.popupClicked = true
    }.bind(this);
    document.body.onclick = this.toggle.bind(this);
  }
}

var AlertUpdater = Class.create();
AlertUpdater.TIME_BETWEEN_PINGS = 5; // in sec
AlertUpdater.prototype = {
  initialize: function(path) {
    this.path = path;
    this.updater = new PeriodicalExecuter(function() {new Ajax.Request(path, {asynchronous:true, evalScripts:true, method:'get'})}, AlertUpdater.TIME_BETWEEN_PINGS);
  },

  start: function() {
    this.updater.currentlyExecuting = false;
  },

  stop: function() {
    this.updater.currentlyExecuting = true;
  }
}