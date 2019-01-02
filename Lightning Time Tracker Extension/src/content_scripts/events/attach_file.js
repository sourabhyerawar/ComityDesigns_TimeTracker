class AttachFileEvent extends BaseEvent {
  constructor({
    newAction = EventConstants.NEW_ATTACH_FILE
    , editAction = EventConstants.EDIT_ATTACH_FILE
    , saveAction = EventConstants.ATTACH_FILE_SAVE
    , cancelAction = EventConstants.ATTACH_FILE_CANCEL
  } = {}) {
    super({ objectPrefix: '00P', parentParamName: 'pid',
      newAction, editAction, saveAction, cancelAction });
  }

  newEventTracking() {
    // New [Start Event]
    if(this.action) {
      const newForm = $(`form[action^='/p/attach/NoteAttach']`);
      if (newForm && newForm.length > 0) {
        const startEvent = this.getStartEvent();
        debug.log(`STARTED: ${this.action}`, startEvent);
        this.sendMessage({ type: ExtConstants.SAVE_TIME_TRACKER, body: startEvent });
      }
    }
  }

  endEventTracking() {
    super.endEventTracking();

    // End Event on Attach File Click
    $("div[class^='genericPageBlockTable']").find("input[id^='Attach']").on('click', (e) => {
      const endEvent = this.getEndEvent();
      debug.log(`ENDED: ${this.action}`, endEvent);
      this.sendMessage({ type: ExtConstants.SAVE_TIME_TRACKER,body: endEvent });
    });
  }
}

debug.info('ATTACH FILE', location.pathname);

$(document).ready(function() {
  const evt = new AttachFileEvent();
  evt.startEventTracking();
  evt.endEventTracking();
});
