class CaseEvent extends BaseEvent {
  constructor({
    newAction = EventConstants.NEW_CASE
    , editAction = EventConstants.EDIT_CASE
    , saveAction = EventConstants.CASE_SAVE
    , cancelAction = EventConstants.CASE_CANCEL
  } = {}) {
    super({ objectPrefix: '500', newAction, editAction, saveAction, cancelAction });
  }
}

debug.info('CASE', location.pathname);

$(document).ready(function() {
  const evt = new CaseEvent();
  evt.startEventTracking();
  evt.endEventTracking();
});
