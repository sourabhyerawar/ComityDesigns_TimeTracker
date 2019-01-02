class CaseCommentEvent extends BaseEvent {
  constructor({
    newAction = EventConstants.NEW_CASE_COMMENT
    , editAction = EventConstants.EDIT_CASE_COMMENT
    , saveAction = EventConstants.CASE_COMMENT_SAVE
    , cancelAction = EventConstants.CASE_COMMENT_CANCEL
  } = {}) {
    super({ objectPrefix: '00a', parentParamName: 'parent_id',
      newAction, editAction, saveAction, cancelAction });
  }
}

debug.info('CASE COMMENT', location.pathname);

$(document).ready(function() {
  const evt = new CaseCommentEvent();
  evt.startEventTracking();
  evt.endEventTracking();
});

