class AddNextActionDateEvent extends BaseEvent {
  constructor({
    objectId = null,
    documentId = null,
    source = 'Custom Event',
    newAction = 'Add Next Action Date',
    editAction = 'Add Next Action Date',
    saveAction = 'Add Next Action Date Save',
    cancelAction = 'Add Next Action Date Save'
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
    const elem = $("form[action*='/AddNextActionDate?id=" + this.parentId + "']");
    const docElem = document;
    if(elem && elem.length > 0) {
      var dataInputField = $(elem).find('span.dateInput');
      if(dataInputField && dataInputField.length > 0) {
        $(docElem).on('click', dataInputField[0], (e) => {
          if(e.target && (e.target.nodeName == 'INPUT' || e.target.nodeName == 'A') ) {
            if($(dataInputField).attr('data-open-action') != undefined){
              return false;
            } else {
      		  this.documentId = this.getUUID();
              const startEvent = this.getStartEvent();
      		  chrome.runtime.sendMessage('dejnmkjmdelinkoaoikmpphejhdniecg', { type: 'SAVE_TIME_TRACKER', body: startEvent });
              $(dataInputField).attr('data-open-action', 'AddNextActionDate');
            }
          }
        });

        // Add Next Action Date Save button
        var addNextActionDateSaveBtn = $(elem).parent().find('#cpbutton');
        if(addNextActionDateSaveBtn && addNextActionDateSaveBtn.length > 0) {
          $(addNextActionDateSaveBtn).on('click', (e) => {
            if($(dataInputField).val() != undefined || $(dataInputField).val().length > 0) {
              const endEvent = this.getEndEvent();
      		  chrome.runtime.sendMessage('dejnmkjmdelinkoaoikmpphejhdniecg', { type: 'SAVE_TIME_TRACKER', body: endEvent });
              $(dataInputField).removeAttr('data-open-action');
            }
          });
        }
      }
    }
  }
}

console.log('ADD NEXT ACTION DATE : location.pathname', location.pathname);

$(document).ready(function() {
  const evt = new AddNextActionDateEvent();
  evt.startEventTracking();
});
