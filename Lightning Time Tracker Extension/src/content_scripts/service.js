// Service to Interact with the HiddenTimeTrackerPage.
// This Class is used to retrieve and push information to Salesforce.

class Service {
	
	static saveTimeTracker( data ) {
		if( !data ) return;
		debug.info( 'SAVE_TIME_TRACKER Service', data );
		this.postMessage( ExtConstants.SAVE_TIME_TRACKER, data );
	}

	static updateFocusedSecondaryTabWithNewRecordDocumentId( data ) {
		if( !data ) return;
		debug.info( 'NEW_RECORD_DOCUMENT_ID Service', data );
		this.postMessage( ExtConstants.NEW_RECORD_DOCUMENT_ID, data );
	}

	static sendTrackListNavigation( data ) {
		if( !data ) return;
		debug.info( 'TRACK_LIST_NAVIGATION Service', data );
		this.postMessage( EventConstants.TRACK_LIST_NAVIGATION, data );
	}

	static sendTrackChat( data ) {
		if( !data ) return;
		debug.info( 'TRACK_CHAT Service:', data );
		this.postMessage( EventConstants.TRACK_CHAT, data );
	}

	static sendConsoleSettings( data ) {
		if( !data ) return;
		debug.info( 'CONSOLE_SETTINGS Service:', data );
		this.postMessage( ExtConstants.CONSOLE_SETTINGS, data );
	}

	static postMessage( type, data ) {
		const body = { type: type, body: data }
		debug.info( 'Posting Message to SF', body );
		window.postMessage( body, location.origin );
	}
}

// Listening to the post message from the HiddenTimeTrackerPage
window.addEventListener( "message", function( event ) {
	
	if( event.source != window && event.origin != location.origin && event.data.type )
		return;

	switch( event.data.type ) {
		case ExtConstants.SETTINGS:
			chrome.runtime.sendMessage( {type: ExtConstants.SETTINGS, body: event.data.body } );
			chrome.runtime.sendMessage( { type: ExtConstants.CONSOLE_SETTINGS, body: null } );
			parent.postMessage( 'settingPostedToExtension', '*' );

			break;
		case ExtConstants.SHOW_ERROR:
			chrome.runtime.sendMessage( { type: ExtConstants.SHOW_ERROR, body: event.data.body } );
			break;
		default:
			break;
	}
}, false );

const onErrorHandler = function( msg, url, lineNo, columnNo, error ) {
	
	chrome.runtime.sendMessage
	({
		type: ExtConstants.SHOW_ERROR, 
		body: { type : "basic",
				title : ExtConstants.ERROR_TITLE,
				message : ExtConstants.ERROR_MESSAGE,
				appIconMaskUrl : ExtConstants.APP_ICON_URL,
				iconUrl : ExtConstants.ERROR_ICON_URL
			  } 
	});
};

window.onerror = onErrorHandler;