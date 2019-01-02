if( !window.debug ) {
	window.debug = {};
}
window.debug.info = window.debug.log = window.debug.error  = function() {}
setDebugLogWrapper();

chrome.runtime.sendMessage( { type: ExtConstants.GET_TAB_ID, body: {} }, function( tabId ) {
	
	if( !tabId ) {
		return;
	}
	chrome.storage.local.get( tabId, ( items ) => {
		setLogger( items[ tabId ] );
	});
});

function setLogger( settings ) {
	
	if( !settings ) {
		return;
	}
	
	const clientDebugLevelFieldName = getFieldName( 'ClientDebugLevel__c',  settings );
	const debugLevel = settings.UserSettings[ clientDebugLevelFieldName ];
	
	let methods = [];
	switch( debugLevel ) {
		case 'INFO':
			methods = [ '' ];
			break;
		case 'DEBUG':
			methods = [ 'info' ];
			break;
		case 'ERROR':
			methods = [ 'info', 'log' ];
			break;
		default:
			methods = [ 'info', 'log', 'error' ];
			break;
	}
	
	if( !window.console ) {
		window.console = {};
	}
	
	methods.map( function( method ) {
		console[ method ] = function(){};
	});
}

function setDebugLogWrapper(){
	
	window.debug.info = function() {
		
		let args = Array.prototype.slice.call( arguments );
		const el = '%cExt%c' + args.shift();
		args.unshift( el, ExtConstants.CONSOLE_EXT_STYLE, ExtConstants.CONSOLE_INFO_STYLE );
		console.info.apply( window.console, args );
	}
	
	window.debug.log = function() {
		
		let args = Array.prototype.slice.call( arguments );
		const el = '%cExt%c' + args.shift();
		args.unshift( el, ExtConstants.CONSOLE_EXT_STYLE, ExtConstants.CONSOLE_LOG_STYLE );
		console.log.apply( window.console, args );
	}
	
	window.debug.error = function() {
		
		let args = Array.prototype.slice.call( arguments );
		const el = '%cExt%c' + args.shift();
		args.unshift( el, ExtConstants.CONSOLE_EXT_STYLE, ExtConstants.CONSOLE_ERROR_STYLE );
		console.error.apply( window.console, args );
	}
}

function getFieldName( name, settings ) {
	
	if( !name || !settings ) {
		return;
	}
	return( settings.Namespace ? settings.Namespace + '__' + name : name );
}