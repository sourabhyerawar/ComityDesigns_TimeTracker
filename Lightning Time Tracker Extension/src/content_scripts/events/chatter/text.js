class ChatterTextPost extends BaseEvent {
  
	constructor( { caseId = null, documentId = null } = {} ) {
		
		super( { caseId, documentId, action: EventConstants.CHATTER_TEXT, endAction: EventConstants.CHATTER_TEXT_SAVE } );
	}

	getEndEvent( { action = EventConstants.CHATTER_TEXT, endAction = EventConstants.CHATTER_TEXT_SAVE } = {} ) {
		
		this.endEvent = super.getEndEvent( { action, endAction } );
	}

	onLoad() {

	}
}

if( location.pathname.length == 16 || location.pathname.length == 19 ) {
	
	let evt = new ChatterTextPost();
	const chatterPostWrapper = $( "div[id^='efpPublisherWrapper_" + evt.caseId + "']" );
	const postDiv = chatterPostWrapper.find( "div[id^='efpChatterPublisher_" + evt.caseId + "']" );
	console.log( 'postDiv', postDiv );
	
	const postDivObserver = new MutationObserver( ( mutations ) => {
		mutations.forEach( ( mutation ) => {
			
			if( mutation.attributeName != 'style' && mutation.oldValue != 'display:none;' ) { 
				return;
			}
			
			if( mutation.target.style.display != 'none') {
				const activeChatterPostDiv = chatterPostWrapper.find( "div.publisherWrapper > div.activeTemplate" );
				if ( activeChatterPostDiv.hasClass( 'TextPost' ) ) {
					chrome.runtime.sendMessage( { type: ExtConstants.SAVE_TIME_TRACKER, body: evt.startEvent } );
				}
			} 
			else {
				stopChatterPost();
			}
		});
	});
	
	postDivObserver.observe( postDiv.get(0), { attributes: true, attributeOldValue: true, attributeFilter: ['style'] } );

	const tabSelectecDiv = chatterPostWrapper.find( "div[id^='efpPublishers_" + evt.caseId + "']" );
	
	const tabSelectedObserver = new MutationObserver( ( mutations ) => {
		
		mutations.forEach( ( mutation ) => {
			
			if( mutation.attributeName != 'class' ) {
				return;
			}
			
			const oldClassArray = mutation.oldValue && mutation.oldValue.split( " " ) ? mutation.oldValue.split( " " ) : null;
			const oldClassName = oldClassArray.length > 0 ? oldClassArray[ oldClassArray.length - 1 ] : null;
			if( !oldClassName ) return;
			if( oldClassName && ( oldClassName == 'efpChatterTabs' || mutation.target.className.indexOf( oldClassName ) > 0 ) ) return;
			
			if( oldClassName == 'efpTextPost' && evt.caseId ) {
				evt.getEndEvent();
				chrome.runtime.sendMessage( { type: ExtConstants.SAVE_TIME_TRACKER, body: evt.endEvent } );
				evt = new ChatterTextPost();
			}
		});
	});
	
	tabSelectedObserver.observe( tabSelectecDiv.get(0), { attributes: true, attributeOldValue: true, attributeFilter: [ 'class' ] } );

	function stopChatterPost() {
		const activeChatterPostDiv = chatterPostWrapper.find( "div.publisherWrapper > div.activeTemplate" );
		if ( activeChatterPostDiv.hasClass( 'TextPost' ) && evt.caseId ) {
			evt.getEndEvent();
			chrome.runtime.sendMessage( { type: ExtConstants.SAVE_TIME_TRACKER, body: evt.endEvent } );
			evt = new ChatterTextPost();
		}
	}
	
	// Chatter Post Comment
	const shareChatterPost = chatterPostWrapper.find( "#publishersharebutton" );
	shareChatterPost.on( 'click', function( e ) {
		stopChatterPost();
	});

	function getUUID() {
		
		var d = ( new Date() ).getTime();
		var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function( c ) {
			var r = ( d + Math.random() * 16 ) % 16 | 0;
			d = Math.floor( d / 16 );
			return ( c=='x' ? r : ( r&0x3|0x8 ) ).toString( 16 );
		});
		return uuid;
	}
}