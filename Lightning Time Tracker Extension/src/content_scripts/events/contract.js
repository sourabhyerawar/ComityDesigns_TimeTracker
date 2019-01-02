class ContractEvent extends BaseEvent {
  constructor({
    newAction = EventConstants.NEW_CONTRACT
    , editAction = EventConstants.EDIT_CONTRACT
    , saveAction = EventConstants.CONTRACT_SAVE
    , cancelAction = EventConstants.CONTRACT_CANCEL
  } = {}) {
    super({ objectPrefix: '800', newAction, editAction, saveAction, cancelAction });
  }
}

debug.info('CONTRACT', location.pathname);

$(document).ready(function() {
  const evt = new ContractEvent();
  evt.startEventTracking();
  evt.endEventTracking();
});