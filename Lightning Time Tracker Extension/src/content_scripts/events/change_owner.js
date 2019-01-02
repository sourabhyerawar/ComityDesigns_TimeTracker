class ChangeOwnerEvent extends BaseEvent {
  constructor({
    newAction = EventConstants.CHANGE_OWNER
    , editAction = EventConstants.CHANGE_OWNER
    , saveAction = EventConstants.CHANGE_OWNER_SAVE
    , cancelAction = EventConstants.CHANGE_OWNER_CANCEL
  } = {}) {
    super({ newAction, editAction, saveAction, cancelAction });
  }

  startEventTracking() {
    // Start Event
    const editPageFrom = $("form[id^='editPage']");
    if(editPageFrom && editPageFrom.length > 0) {
      const startEvent = this.getStartEvent();
      debug.log(`STARTED: ${this.action}`, startEvent);
      this.sendMessage({ type: ExtConstants.SAVE_TIME_TRACKER, body: startEvent });
    }
  }

  getObjectId({ objectPrefix = null } = {}) {
    if(location.pathname && location.pathname.indexOf('/') >= 0) {
      const objectId = location.pathname.substring(location.pathname.indexOf('/') + 1, 16);
      return ((new RegExp('[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}')).test(objectId) ? objectId : null);
    }
    return null;
  }
}

debug.info('CHANGE OWNER', location.pathname);

$(document).ready(function() {
  const evt = new ChangeOwnerEvent();
  evt.startEventTracking();
  evt.endEventTracking();
});
