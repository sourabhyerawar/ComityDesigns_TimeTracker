class ContactEvent extends BaseEvent {
  constructor({
    newAction = EventConstants.NEW_CONTACT
    , editAction = EventConstants.EDIT_CONTACT
    , saveAction = EventConstants.CONTACT_SAVE
    , cancelAction = EventConstants.CONTACT_CANCEL
  } = {}) {
    super({ objectPrefix: '003', newAction, editAction, saveAction, cancelAction });
  }
}

debug.info('CONTACT', location.pathname);

$(document).ready(function() {
  const evt = new ContactEvent();
  evt.startEventTracking();
  evt.endEventTracking();
});
