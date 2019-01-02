let listNavigationLabel;

$( document ).ready( function() {
	
	const navigationBtn = $( 'div.support-servicedesk-navigator' ).find( 'em.x-btn-split button.x-btn-text' );
	const isSplitView = getSplitView();
	const trackIrrespectiveOfPrimaryTabs = !isSplitView;

	listNavigationLabel = navigationBtn.find( 'span' ).text().trim();

	navigationBtn.on( 'DOMSubtreeModified', function() {
		
		const currentlistNavigationLabel = $( this ).find( 'span' ).text().trim();
		if( !currentlistNavigationLabel || !listNavigationLabel || listNavigationLabel.length == 0 ||
			currentlistNavigationLabel.length == 0 || listNavigationLabel == currentlistNavigationLabel
		) {
			return;
		}
		chrome.runtime.sendMessage( { type: EventConstants.TRACK_LIST_NAVIGATION, body: { trackIrrespectiveOfPrimaryTabs } } );
		listNavigationLabel = currentlistNavigationLabel;
	});

	if( !isSplitView ) {
		
		navigationBtn.on('click',function() {
			
			const currentlistNavigationLabel = $( this ).find( 'span' ).text().trim();
			if( !currentlistNavigationLabel || !listNavigationLabel ||
				listNavigationLabel.length == 0 || currentlistNavigationLabel.length == 0 
			) {
				return;
			}
			chrome.runtime.sendMessage( { type: EventConstants.TRACK_LIST_NAVIGATION, body: { trackIrrespectiveOfPrimaryTabs } } );
			listNavigationLabel = currentlistNavigationLabel;
		});
	}
});

function getSplitView() {
	return ( $( 'div.miniviewtab_enabled' ).length > 0 ) ? true : false;
}

chrome.runtime.onMessage.addListener(

	function( request, sender, sendResponse ) {
		debug.info('Content Script Index Received', request);
		switch( request.type ) {
			case ExtConstants.SPLIT_VIEW:
				chrome.runtime.sendMessage( { type: ExtConstants.CONSOLE_SETTINGS, body: { isSplitView: getSplitView() } } );
				break;
			default:
				break;
		}
	}
);