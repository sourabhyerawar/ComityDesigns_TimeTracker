class MassCaseEvent_Close extends BaseEvent {
  constructor({
    newAction = EventConstants.MASS_CASE_CLOSE
    , editAction = EventConstants.MASS_CASE_CLOSE
    , saveAction = EventConstants.MASS_CASE_CLOSE_SAVE
    , cancelAction = EventConstants.MASS_CASE_CLOSE_CANCEL
  } = {}) {
    super({ newAction, editAction, saveAction, cancelAction });
  }

  startEventTracking() {
    // Start Event
    const editPageFrom = $("form[action^='/cases/caseclosemass']");
    if(editPageFrom && editPageFrom.length > 0) {
      const startEvent = this.getStartEvent();
      debug.log(`STARTED: ${this.action}`, startEvent);
      this.sendMessage({ type: ExtConstants.SAVE_TIME_TRACKER, body: startEvent });
    }
  }

}

class MassCaseEvent_ChangeOwner extends BaseEvent {
  constructor({
    newAction = EventConstants.MASS_CASE_CHANGE_OWNER
    , editAction = EventConstants.MASS_CASE_CHANGE_OWNER
    , saveAction = EventConstants.MASS_CASE_CHANGE_OWNER_SAVE
    , cancelAction = EventConstants.MASS_CASE_CHANGE_OWNER_CANCEL
  } = {}) {
    super({ newAction, editAction, saveAction, cancelAction });
  }

  startEventTracking() {
    // Start Event
    const editPageFrom = $("form[action^='/p/case/CaseMassAction']");
    if(editPageFrom && editPageFrom.length > 0) {
      const startEvent = this.getStartEvent();
      debug.log(`STARTED: ${this.action}`, startEvent);
      this.sendMessage({ type: ExtConstants.SAVE_TIME_TRACKER, body: startEvent });
    }
  }
}

class MassCaseEvent_ChangeStatus extends BaseEvent {
  //console.log('Instantiated');
  constructor({
    newAction = EventConstants.MASS_CASE_CHANGE_STATUS
    , editAction = EventConstants.MASS_CASE_CHANGE_STATUS
    , saveAction = EventConstants.MASS_CASE_CHANGE_STATUS_SAVE
    , cancelAction = EventConstants.MASS_CASE_CHANGE_STATUS_CANCEL
  } = {}) {

    super({ newAction, editAction, saveAction, cancelAction });
  }

  startEventTracking() {
    // Start Event
    const editPageFrom = $("form[action^='/cases/casechangestatusedit']");
    if(editPageFrom && editPageFrom.length > 0) {
      const startEvent = this.getStartEvent();
      debug.log(`STARTED: ${this.action}`, startEvent);
      this.sendMessage({ type: ExtConstants.SAVE_TIME_TRACKER, body: startEvent });
    }
  }

}
debug.info('MASS CASE EVENTS', location.pathname);

$(document).ready(function() {
  var massActionURL = $('form').attr('action');
  let evt = null;

  if(massActionURL!=undefined){
    if( massActionURL.indexOf('/caseclosemass') >= 0 ){
      debug.info(EventConstants.MASS_CASE_CLOSE);
      evt = new MassCaseEvent_Close();
    } else if ( massActionURL.indexOf('/CaseMassAction') >=0 ) {
      debug.info(EventConstants.MASS_CASE_CHANGE_OWNER);
      evt = new MassCaseEvent_ChangeOwner();
    } else if ( massActionURL.indexOf('/casechangestatusedit') >=0 ) {
      debug.info(EventConstants.MASS_CASE_CHANGE_STATUS);
      evt = new MassCaseEvent_ChangeStatus();
    }

    if(evt!=null){
      evt.startEventTracking();
      evt.endEventTracking();
    }
  }
});
