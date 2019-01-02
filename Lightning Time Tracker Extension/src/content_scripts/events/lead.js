class LeadEvent extends BaseEvent {
  constructor({
    newAction = EventConstants.NEW_LEAD
    , editAction = EventConstants.EDIT_LEAD
    , saveAction = EventConstants.LEAD_SAVE
    , cancelAction = EventConstants.LEAD_CANCEL
  } = {}) {
    super({ objectPrefix: '00Q', newAction, editAction, saveAction, cancelAction });
  }
}

debug.info('LEAD', location.pathname);

$(document).ready(function() {
  const evt = new LeadEvent();
  evt.startEventTracking();
  evt.endEventTracking();
});
