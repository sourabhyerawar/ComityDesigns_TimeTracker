class uploadFilesEvent extends BaseEvent {
  constructor({
    newAction = EventConstants.NEW_ATTACH_FILE
    , editAction = EventConstants.EDIT_ATTACH_FILE
    , saveAction = EventConstants.ATTACH_FILE_SAVE
    , cancelAction = EventConstants.ATTACH_FILE_CANCEL
  } = {}) {
    super({ objectPrefix: '00P', parentParamName: 'pid',
      newAction, editAction, saveAction, cancelAction });
    this.endEventExecuted = false;
  }

  getParentId() {
    if(location.pathname && location.pathname.lastIndexOf('/') >= 0) {
      const objectId = location.pathname.substring(location.pathname.lastIndexOf('/') + 1, 16);
      var toReturn = ((new RegExp('[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}')).test(objectId) ? objectId : null);
	  return toReturn;
    }
  }

  startEventTracking() {
    if(!this.action) return;
    const uploadFileBtn = $('input[id^="AttachmentRLNewFile"]');
    if (!uploadFileBtn || uploadFileBtn.length == 0)  return;

		$(uploadFileBtn).on('click', (e) => {
			this.documentId = this.getUUID();
			const startEvent = this.getStartEvent();
			debug.log(`STARTED: ${this.action}`, startEvent);
			this.sendMessage({ type: ExtConstants.SAVE_TIME_TRACKER, body: startEvent });
		});
  }

	endEventTracking() {
    const observer = new MutationObserver( (mutations) => {
      mutations.forEach( (mutation) => {
        if(mutation.addedNodes.length == 0) return;
        const uploadDialog = $(mutation.addedNodes).find('div[id^="chatterFilesMultiUploadDialogContent"]');
        if(uploadDialog.length == 0) return;
        const cancelBtn = $(mutation.addedNodes).find('input[id="multiUploadCancelRemainingBtn"]');
        const closeBtn = $(mutation.addedNodes).find('input[id="multiUploadCloseBtn"]');
        const closeLink = $(mutation.addedNodes).find('a[id="chatterFilesMultiUploadDialogX"]');

        if(cancelBtn.length > 0) this.bindClickEvent({ button: cancelBtn, endAction: this.cancelAction });
        if(closeBtn.length > 0) this.bindClickEvent({ button: closeBtn });
        if(closeLink.length > 0) this.bindClickEvent({ button: closeLink });
      });
    });

    const target = window && window.frameElement && window.frameElement.contentDocument && window.frameElement.contentDocument.childNodes ? window.frameElement.contentDocument.childNodes : null;
    if (target && target.length > 0) {
      observer.observe(target[1], { childList: true, subtree: true });
    }
	}

  bindClickEvent({ button = null, endAction = null } = {}) {
    endAction = endAction ? endAction : this.endAction;
    if(!button || button.length == 0) return;
    $(button).on('click', (e) => {
      if(this.endEventExecuted) return;
      const endEvent = this.getEndEvent({ endAction });
      debug.log(`ENDED: ${this.action}`, endEvent);
      this.sendMessage({ type: ExtConstants.SAVE_TIME_TRACKER,body: endEvent });
      this.endEventExecuted = true;
    });
  }
}

$(document).ready(function() {
  const evt = new uploadFilesEvent();
  if(!evt.parentId || evt.parentId.length != 15 ) return;
  debug.info('Upload FILE', location.pathname);
  evt.startEventTracking();
  evt.endEventTracking();
});
