class SolutionEvent extends BaseEvent {
  constructor({
    newAction = EventConstants.NEW_SOLUTION
    , editAction = EventConstants.EDIT_SOLUTION
    , saveAction = EventConstants.SOLUTION_SAVE
    , cancelAction = EventConstants.SOLUTION_CANCEL
  } = {}) {
    super({ objectPrefix: '501', newAction, editAction, saveAction, cancelAction });
  }
}

debug.info('SOLUTION', location.pathname);

$(document).ready(function() {
  const evt = new SolutionEvent();
  evt.startEventTracking();
  evt.endEventTracking();
});