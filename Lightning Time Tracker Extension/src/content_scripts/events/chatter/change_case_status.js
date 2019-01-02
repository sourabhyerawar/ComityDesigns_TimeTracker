class ChatterChangeCaseStatus extends BaseEvent {
  
	constructor( { caseId = null, documentId = null } = {} ) {
		super( { caseId, documentId, action: EventConstants.CHATTER_CHANGE_CASE_STATUS, endAction: EventConstants.CHATTER_CHANGE_CASE_STATUS_SAVE } );
	}

	getEndEvent( { action = EventConstants.CHATTER_CHANGE_CASE_STATUS, endAction = EventConstants.CHATTER_CHANGE_CASE_STATUS_SAVE } = {} ) {
		this.endEvent = super.getEndEvent( { action, endAction } );
	}

	onLoad() {
		chrome.runtime.sendMessage( { type: ExtConstants.SAVE_TIME_TRACKER, body: this.startEvent } );

		var saveTopBtn = $( '#topButtonRow' ).find( "input[name='save']" );
		var cancelTopBtn = $( '#topButtonRow' ).find( "input[name='cancel']" );
		var saveBtmBtn = $( '#bottomButtonRow' ).find( "input[name='save']" );
		var cancelBtmBtn = $( '#bottomButtonRow' ).find( "input[name='cancel']" );

		// End Event
		saveTopBtn.add( saveBtmBtn ).on( 'click', ( e ) => {
			this.getEndEvent( { endAction: EventConstants.CHATTER_CHANGE_CASE_STATUS_SAVE } );
			chrome.runtime.sendMessage( { type: ExtConstants.SAVE_TIME_TRACKER, body: this.endEvent } );
		});
	}
}
const evt = new ChatterChangeCaseStatus();