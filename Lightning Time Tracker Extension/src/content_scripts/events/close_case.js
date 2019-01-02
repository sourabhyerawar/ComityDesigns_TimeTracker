class CloseCaseEvent extends BaseEvent {
  constructor({
    newAction = EventConstants.CLOSE_CASE
    , editAction = EventConstants.CLOSE_CASE
    , saveAction = EventConstants.CLOSE_CASE_SAVE
    , cancelAction = EventConstants.CLOSE_CASE_CANCEL
  } = {}) {
    super({ objectPrefix: '500', newAction, editAction, saveAction, cancelAction });
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
}

debug.info('CLOSE CASE', location.pathname);

$(document).ready(function() {
  const evt = new CloseCaseEvent();
  evt.startEventTracking();
  evt.endEventTracking();
});

