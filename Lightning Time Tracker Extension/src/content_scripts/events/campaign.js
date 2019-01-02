class CampaignEvent extends BaseEvent {
  constructor({
    newAction = EventConstants.NEW_CAMPAIGN
    , editAction = EventConstants.EDIT_CAMPAIGN
    , saveAction = EventConstants.CAMPAIGN_SAVE
    , cancelAction = EventConstants.CAMPAIGN_CANCEL
  } = {}) {
    super({ objectPrefix: '701', newAction, editAction, saveAction, cancelAction });
  }
}

debug.info('CAMPAIGN', location.pathname);

$(document).ready(function() {
  const evt = new CampaignEvent();
  evt.startEventTracking();
  evt.endEventTracking();
});
