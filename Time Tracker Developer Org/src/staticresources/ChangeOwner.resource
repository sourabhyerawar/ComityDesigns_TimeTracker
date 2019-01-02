class ChangeOwnerEvent extends BaseEvent {
  constructor({
    objectId = null,
    documentId = null,
    source = 'Custom Event',
    newAction = 'Change Owner',
    editAction = 'Change Owner',
    saveAction = 'Change Owner Save',
    cancelAction = 'Change Owner Cancel'
  } = {}) {
    super({
      objectPrefix: '500',
      parentParamName: 'id',
      objectId,
      documentId,
      source,
      newAction,
      editAction,
      saveAction,
      cancelAction
    });
    this.isStarted = false;
  }

  startEventTracking() {
	          console.log('all-set to insert');
			  this.documentId = this.getUUID();
              const startEvent = this.getStartEvent();
			  chrome.runtime.sendMessage('bbmcpbdcihggdbbcbcakllcdbecmkjim', { type: 'SAVE_TIME_TRACKER', body: startEvent });
			  console.log('Check if record inserted');
  }
  endEventTracking() {
    $("div[class^='pbBottomButtons']").each((i, ele) => {
      const $btns = $(ele).find('input[type^="submit"]');
      $btns.each((btnIndex, btn) => {
        if ($(btn).val().indexOf('Save') >= 0) {
          $(btn).on('click', (e) => { // Save Event
            const endEvent = this.getEndEvent();
            console.log(`ENDED ${this.endAction} :`, endEvent);
            chrome.runtime.sendMessage('bbmcpbdcihggdbbcbcakllcdbecmkjim', { type: 'SAVE_TIME_TRACKER', body: endEvent });
          });
        } else if ($(btn).val().indexOf('Cancel') >= 0) { // Cancel Event
          $(btn).on('click', (e) => {
            const endEvent = this.getEndEvent({ endAction: this.cancelAction });
            console.log(`ENDED ${this.endAction} :`, endEvent);
            chrome.runtime.sendMessage('bbmcpbdcihggdbbcbcakllcdbecmkjim', { type: 'SAVE_TIME_TRACKER', body: endEvent });
          });
        }
      });
    });
  }
}

console.log('Change Owner : location.pathname', location.pathname);

$(document).ready(function() {
	console.log('Change Owner initialized');
  const evt = new ChangeOwnerEvent();
  evt.startEventTracking();
  evt.endEventTracking();
});
