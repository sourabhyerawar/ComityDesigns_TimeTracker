class LogCallEvent extends BaseEvent {
  constructor({
    newAction = EventConstants.LOG_CALL
    , editAction = EventConstants.LOG_CALL
    , saveAction = EventConstants.LOG_CALL_SAVE
    , cancelAction = EventConstants.LOG_CALL_CANCEL
  } = {}) {
    super({ objectPrefix: '00T', parentParamName: 'what_id',
      newAction, editAction, saveAction, cancelAction });
  }

  getParentId() {
    // New Task
    let parentId = super.getParentId();
    if (parentId) return parentId;

    // Edit Task
    parentId = $('input[id^="tsk3_lkid"]');
    if(parentId && parentId.length > 0) {
      return parentId.val();
    }
  }
}

debug.info('LOG A CALL', location.pathname);

$(document).ready(function() {
  const evt = new LogCallEvent();
  evt.startEventTracking();
  evt.endEventTracking();
});
