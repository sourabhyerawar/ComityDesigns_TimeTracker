class OrderEvent extends BaseEvent {
  constructor({
    newAction = EventConstants.NEW_ORDER
    , editAction = EventConstants.EDIT_ORDER
    , saveAction = EventConstants.ORDER_SAVE
    , cancelAction = EventConstants.ORDER_CANCEL
  } = {}) {
    super({ objectPrefix: '801', newAction, editAction, saveAction, cancelAction });
  }
}

debug.info('ORDER', location.pathname);

$(document).ready(function() {
  const evt = new OrderEvent();
  evt.startEventTracking();
  evt.endEventTracking();
});
