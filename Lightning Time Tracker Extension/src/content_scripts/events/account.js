class AccountEvent extends BaseEvent {
  constructor({
    newAction = EventConstants.NEW_ACCOUNT
    , editAction = EventConstants.EDIT_ACCOUNT
    , saveAction = EventConstants.ACCOUNT_SAVE
    , cancelAction = EventConstants.ACCOUNT_CANCEL
  } = {}) {
    super({ objectPrefix: '001', newAction, editAction, saveAction, cancelAction });
  }
}

debug.info('ACCOUNT', location.pathname);

$(document).ready(function() {
  const evt = new AccountEvent();
  evt.startEventTracking();
  evt.endEventTracking();
});
