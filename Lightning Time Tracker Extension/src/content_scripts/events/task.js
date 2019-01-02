class TaskEvent extends BaseEvent {
  constructor({
    newAction = EventConstants.NEW_TASK
    , editAction = EventConstants.EDIT_TASK
    , saveAction = EventConstants.TASK_SAVE
    , cancelAction = EventConstants.TASK_CANCEL
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

debug.info('TASK', location.pathname);

$(document).ready(function() {
  const evt = new TaskEvent();
  evt.startEventTracking();
  evt.endEventTracking();
});
