class OpportunityEvent extends BaseEvent {
  constructor({
    newAction = EventConstants.NEW_OPPORTUNITY
    , editAction = EventConstants.EDIT_OPPORTUNITY
    , saveAction = EventConstants.OPPORTUNITY_SAVE
    , cancelAction = EventConstants.OPPORTUNITY_CANCEL
  } = {}) {
    super({ objectPrefix: '006', newAction, editAction, saveAction, cancelAction });
  }
}

debug.info('OPPORTUNITY', location.pathname);

$(document).ready(function() {
  const evt = new OpportunityEvent();
  evt.startEventTracking();
  evt.endEventTracking();
});
