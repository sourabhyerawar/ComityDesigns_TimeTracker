chrome.runtime.sendMessage( { type: ExtConstants.GET_TAB_ID, body: {} }, function( tabId ) {
	
	if( !tabId ) return;
	chrome.storage.local.get( tabId, ( items ) => {
		getResourceUrls( items[ tabId ] );
	});
});

function getFieldName( name, settings ) {
	
	if( !name ) return;
	return( settings.Namespace ? settings.Namespace + '__' + name : name );
}

function getResourceUrls( settings ) {
  
	if( !settings || ( settings && !settings.ConfigSettings ) ) return;
	let customEvents = [];

	Object.keys( settings.ConfigSettings ).map( ( key, index ) => {
		let fieldName = getFieldName( 'Type__c', settings );
		if( settings.ConfigSettings[ key ][ fieldName ] == "Custom Event" ) {
			customEvents.push( settings.ConfigSettings[ key ] );
		}
	});

	if( !customEvents || customEvents.length == 0 ) return;

	let urls = [];
	customEvents.forEach( function( evt ) {
		
		const code1 = getFieldName( 'Code1__c', settings );
		const code2 = getFieldName( 'Code2__c', settings );
		const text1 = getFieldName( 'Text1__c', settings );
		const text2 = getFieldName( 'Text2__c', settings );
		
		if(!evt[code1]) return;

		if( ( new RegExp( evt[ code1 ] ) ).test( location.pathname ) &&
			( ( evt[ code2 ] && !( new RegExp( evt[ code2 ] ) ).test( location.pathname ) ) || !evt[ code2 ] ) 
		) {
			const url = settings.ResourceURLs && settings.ResourceURLs[ evt[ text1 ] ] ? settings.ResourceURLs[ evt[ text1 ] ] : null;
			if( url ) {
				urls.push( settings.BaseUrl + url + ( evt[ text2 ] ? evt[ text2 ] : '' ) );
			}
		}
	});

	if( urls.length == 0 ) return;
	
	const defaultScripts = [ 'src/lib/jquery.min.js', 'src/constants.js', 'src/logger_external.js', 'src/content_scripts/events/index.js' ];
	let defaultLoadIndex = 0;
	
	defaultScripts.forEach( ( script, index, scripts ) => {
		
		debug.info( 'Injecting Script: to', location.origin, location.pathname, script );
		var s = document.createElement( 'script' );
		s.src = chrome.extension.getURL( script );
		s.onload =  () => {
			defaultLoadIndex++ ;
			verifyAndLoadCustomScript( defaultLoadIndex, scripts, urls );
		};
		( document.head || document.documentElement ).appendChild( s );
	});
}

function verifyAndLoadCustomScript( defaultLoadIndex, scripts, urls ) {
	
	if( defaultLoadIndex == scripts.length - 1 ) {
		urls.forEach( inject );
	}
}

const inject = function (script, index, scripts) {
	
	var ssrc = document.createElement( "script" );
	ssrc.setAttribute( "src", script );
	document.body.appendChild( ssrc );
}