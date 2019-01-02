// This is Content Script Index which is loaded on to all the frames.
// This is listening to the message sent form the background index.

chrome.runtime.onMessage.addListener(
	function( request, sender, sendResponse ) {
		
		// This will send the Time Tracker object to the Service class
		debug.info( 'Content Script Index Received', request );
		switch( request.type ) {
			case ExtConstants.CONSOLE_SETTINGS:
				Service.sendConsoleSettings( request.body );
				break;
			case ExtConstants.SAVE_TIME_TRACKER:
				Service.saveTimeTracker( request.body );
				break;
			case ExtConstants.NEW_RECORD_DOCUMENT_ID:
				Service.updateFocusedSecondaryTabWithNewRecordDocumentId( request.body );
				break;
			case EventConstants.TRACK_LIST_NAVIGATION:
				Service.sendTrackListNavigation( request.body);
				break;
			case EventConstants.TRACK_CHAT:
				Service.sendConsoleSettings( request.body );
				break;
			default:
				break;
		}
	}
);
