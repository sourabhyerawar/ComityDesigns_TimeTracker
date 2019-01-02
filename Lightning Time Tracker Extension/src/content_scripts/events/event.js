class Event extends BaseEvent {
  constructor({
    newAction = EventConstants.NEW_EVENT
    , editAction = EventConstants.EDIT_EVENT
    , saveAction = EventConstants.EVENT_SAVE
    , cancelAction = EventConstants.EVENT_CANCEL
  } = {}) {
    super({ objectPrefix: '00U', parentParamName: 'what_id',
      newAction, editAction, saveAction, cancelAction });
  }

  getParentId() {
    // New Event
    let parentId = super.getParentId();
    if (parentId) return parentId;

    // Edit Event
    parentId = $('input[id^="tsk3_lkid"]');
    if(parentId && parentId.length > 0) {
      return parentId.val();
    }
  }
}

debug.info('EVENT', location.pathname);

$(document).ready(function() {
  const evt = new Event();
  evt.startEventTracking();
  evt.endEventTracking();
});


