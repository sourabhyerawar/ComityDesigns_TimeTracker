// Listen to the Save Time Tracker from the Events
chrome.runtime.onMessage.addListener(

	function( request, sender, sendResponse ) {
		
		switch( request.type ) {
			
			case ExtConstants.CONSOLE_SETTINGS:
				console.log( 'Backgroud Received Console Settings Request:', request );
				if( !request.body ) {
					chrome.tabs.sendMessage( sender.tab.id, { type: ExtConstants.SPLIT_VIEW } );
				}
				else {
					chrome.tabs.sendMessage( sender.tab.id, request );
				}
				break;
				
			case ExtConstants.SAVE_TIME_TRACKER:
				console.log( 'Backgroud Received Save Time Tracker Request:', request );
				chrome.tabs.sendMessage( sender.tab.id, request );
				break;
				
			case ExtConstants.NEW_RECORD_DOCUMENT_ID:
				console.log( 'Backgroud Received New Record Document Id Send Request:', request );
				chrome.tabs.sendMessage( sender.tab.id, request );
				break;
				
			case EventConstants.TRACK_LIST_NAVIGATION:
				console.log( 'Backgroud Received Navigation Request:', request );
				chrome.tabs.sendMessage( sender.tab.id, request );
				break;
				
			case EventConstants.TRACK_CHAT:
				console.log( 'Backgroud Received Track Chat Request:', request );
				chrome.tabs.sendMessage( sender.tab.id, request );
				break;
				
			case ExtConstants.SETTINGS:
				console.log( 'Backgroud Received Settings:', request.body );
				if( request.body != null ) 
					storeSettingsForTheTab( sender.tab.id.toString(), request.body );
				break;
				
			case ExtConstants.GET_TAB_ID:
				console.log( 'Backgroud Received Get Tab Id Request:', sender.tab.id );
				sendResponse( sender.tab.id.toString() );
				break;
				
			case ExtConstants.SHOW_ERROR:
				console.log( 'Backgroud Received Show Error Request:', sender.tab.id );
				chrome.notifications.create( null, request.body, function(){} );
				break;
				
			default:
				break;
		}
	}
);

// Listen to the Save Time Tracker from the Events
chrome.runtime.onMessageExternal.addListener(

	function( request, sender, sendResponse ) {
		
		switch( request.type ) {
			case ExtConstants.SAVE_TIME_TRACKER:
				console.log( 'Backgroud Received Save Time Tracker Request:', request );
				chrome.tabs.sendMessage( sender.tab.id, request );
				break;
			case ExtConstants.NEW_RECORD_DOCUMENT_ID:
				console.log( 'Backgroud Received New Record Document Id Send Request:', request );
				chrome.tabs.sendMessage( sender.tab.id, request );
				break;
			default:
				break;
		}
	}
);

function storeSettingsForTheTab( tabId, body ) {
	
	const data = { }
	data[ tabId ] = body;
	console.log( 'Saving the settings to storage ', data );
	chrome.storage.local.set( data );
}

chrome.tabs.onRemoved.addListener( function ( tabId, info ) {
	
	if( info.isWindowClosing ) {
		chrome.storage.local.clear();
		return;
	}
	chrome.storage.local.get( tabId.toString(), function( obj ) {
		if( obj ) {
		  chrome.storage.local.remove( tabId.toString() );
		}
	});
});