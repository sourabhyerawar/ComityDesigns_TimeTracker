class EmailEvent extends BaseEvent {
  constructor({
    newAction = EventConstants.SEND_EMAIL
    , editAction = EventConstants.SEND_EMAIL
    , saveAction = EventConstants.SEND_EMAIL_SAVE
    , cancelAction = EventConstants.SEND_EMAIL_CANCEL
  } = {}) {
    super({ parentParamName: 'p3_lkid', newAction, editAction, saveAction, cancelAction });
  }

  startEventTracking() {
    // Start Event
    const editPageFrom = $("form[id^='editPage']");
    if(editPageFrom && editPageFrom.length > 0) {
      const startEvent = this.getStartEvent();
      debug.log(`STARTED: ${this.action}`, startEvent);
      this.sendMessage({ type: ExtConstants.SAVE_TIME_TRACKER, body: startEvent });
    }
  }

  endEventTracking() {
    // Send Button Clicks
    $("td[class^='pbButton']").each((i, ele) => {
      const $sendBtns = $(ele).find('input[name^="send"]');
      $sendBtns.each((btnIndex, btn) => {
        $(btn).on('click', (e) => {
          const endEvent = this.getEndEvent();
          debug.log(`ENDED: ${this.endAction}`, endEvent);
          this.sendMessage({ type: ExtConstants.SAVE_TIME_TRACKER, body: endEvent });
        });
      });

      // Cancel Button Clicks
      const $cancelBtns = $(ele).find('input[name^="cancel"]');
      $cancelBtns.each((btnIndex, btn) => {
        $(btn).on('click', (e) => {
          const endEvent = this.getEndEvent({ endAction: this.cancelAction });
          debug.log(`ENDED: ${this.endAction}`, endEvent);
          this.sendMessage({ type: ExtConstants.SAVE_TIME_TRACKER, body: endEvent });
        });
      });
    });
  }
}

debug.info('SEND EMAIL', location.pathname);

$(document).ready(function() {
  const evt = new EmailEvent();
  evt.startEventTracking();
  evt.endEventTracking();
});
