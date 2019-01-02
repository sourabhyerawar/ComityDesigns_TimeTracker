// This is the Base Event class
// All the events extend this class.
class BaseEvent {

	constructor ({
		
		objectPrefix = null, 
		objectId = null, 
		parentParamName = null, 
		parentId = null, 
		documentId = null, 
		extensionId = 'bbmcpbdcihggdbbcbcakllcdbecmkjim', 
		source = ExtConstants.EXTENSION, 
		action = null, 
		endAction = null, 
		newAction = null, 
		editAction = null, 
		saveAction = null, 
		cancelAction = null
		
	} = {} ) {
		this.objectPrefix = objectPrefix;
		this.objectId = objectId && objectId.length > 0 ? objectId : this.getObjectId();
		this.parentParamName = parentParamName;
		this.parentId = parentId && parentId.length > 0 ? parentId : this.getParentId();
		this.documentId = documentId && documentId.length > 0 ? documentId : this.getUUID();
		this.extensionId = extensionId;
		this.source = source;
		this.action = action ? action : newAction;
		this.endAction = endAction ? endAction : saveAction;

		this.newAction = newAction;
		this.editAction = editAction;
		this.saveAction = saveAction;
		this.cancelAction = cancelAction;

		this.onLoad();
	}
	
	getStartEvent({ action = null } = {}) {
		
		this.action = action ? action : this.action;
		debug.info( 'Action', this.action );
		
		const obj = {
			Activity_Time__c: ( new Date() ).getTime(),
			DocumentId__c: this.documentId,
			Action__c: this.action,
			Object_Id__c: this.to18DigitId( this.objectId ),
			Parent_Object_Id__c: this.to18DigitId( this.parentId ),
			Source__c: this.source
		};
		
		if( this.parentId ) {
			obj.Parent_Object_Id__c = this.parentId;
		}
		
		debug.info( 'Start Event Obj', obj );
		return obj;
	}

	getEndEvent({ action = null, endAction = null } = {}) {
		
		this.action = action ? action : this.action;
		this.endAction = endAction ? endAction : this.endAction;
		debug.info( 'Action', this.action );
		debug.info( 'End Action', this.endAction );
		
		const obj = {
			Activity_Time__c: ( new Date() ).getTime(),
			DocumentId__c: this.documentId,
			Action__c: this.endAction,
			Opening_Action__c: this.action,
			Object_Id__c: this.to18DigitId( this.objectId ),
			Parent_Object_Id__c: this.to18DigitId( this.parentId ),
			Source__c: this.source
		}
		
		if( this.parentId ) {
			obj.Parent_Object_Id__c = this.parentId;
		}
		
		debug.info( 'End Event Obj', obj );
		return obj;
	}

	getUUID() {
		
		var d = ( new Date() ).getTime();
		var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function( c ) {
			var r = ( d + Math.random() * 16 ) % 16 | 0;
			d = Math.floor( d / 16 );
			return ( c == 'x' ? r : ( r & 0x3 | 0x8 ) ).toString( 16 );
		});
		return uuid;
	}

	to18DigitId ( id ) {
		
		if( !id || id.length != 15 ) return;

		let s = "";
		for ( let i = 0; i < 3; i++ ) {
			let f = 0;
			for ( let j = 0; j < 5; j++ ) {
				let c = id.charAt( i * 5 + j );
				if ( c >= "A" && c <= "Z" ) {
					f += 1 << j; 
				}
			}
			s += "ABCDEFGHIJKLMNOPQRSTUVWXYZ012345".charAt(f);
		}
		return id + s;
	}

	getObjectId({ objectPrefix = null } = {}) {
		
		this.objectPrefix = objectPrefix ? objectPrefix : this.objectPrefix;

		if( !this.objectPrefix ) {
			return null;
		}
		
		if( location.pathname && location.pathname.indexOf( '/' + this.objectPrefix ) >= 0 ) {
		  const objectId = location.pathname.substring( location.pathname.indexOf( '/' + this.objectPrefix ) + 1, 16 );
		  return ( ( new RegExp( '[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}' ) ).test( objectId ) ? objectId : null );
		}
	}

	getParentId({ parentParamName = null } = {}) {
		
		this.parentParamName = parentParamName ? parentParamName : this.parentParamName;

		if( !this.parentParamName ) {
			return null;
		}
		
		let queryParams = location.search;
		if( !queryParams ) {
			return null;
		}
		
		const termLength = ( this.parentParamName + '=').length;
		let parentId = queryParams.indexOf( this.parentParamName + '=' );
		parentId = ( parentId >= 0 ? queryParams.substring( parentId + termLength, parentId + termLength + 15 ) : null )

		return ( ( new RegExp('[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}' ) ).test( parentId ) ? parentId : null );
	}

	onLoad() {

	}
	
	startEventTracking() {
		
		this.newEventTracking();
		this.editEventTracking();
	}

	newEventTracking() {
		
		// New [Start Event]
		debug.info( 'Action', this.action );
		if( this.action ) {
			const newForm = $( `form[action^='/${this.objectPrefix}/e?']` );
			debug.info( 'New Form', newForm );
			if ( newForm && newForm.length > 0 ) {
				const startEvent = this.getStartEvent();
				debug.log( `STARTED: ${this.action}`, startEvent );
				this.sendMessage({ type: ExtConstants.NEW_RECORD_DOCUMENT_ID, body: startEvent });
				this.sendMessage({ type: ExtConstants.SAVE_TIME_TRACKER, body: startEvent });
			}
		}
	}

	editEventTracking() {
		
		// Edit [Start Event]
		debug.info( 'Edit Action', this.editAction );
		if( this.editAction ) {
			const editForm = $( `form[action^='/${this.objectId}/e?']` );
			debug.info( 'Edit Form', editForm );
			if ( editForm && editForm.length > 0 ) {
				const startEvent = this.getStartEvent({ action: this.editAction });
				debug.log( `STARTED: ${this.action}`, startEvent );
				this.sendMessage({ type: ExtConstants.SAVE_TIME_TRACKER, body: startEvent });
			}
		}
	}

	endEventTracking() {
		
		var self = this;
		$( "td[class^='pbButton']" ).each( ( i, ele ) => {
			// Save Buttons Click Handlers [End Event]
			debug.info( 'Save Action', self.endAction );
			
			if ( self.endAction ) {
				const $saveBtns = $( ele ).find( 'input[name^="save"]' );
				debug.info( 'Save Buttons', $saveBtns );
				$saveBtns.each( ( btnIndex, btn ) => {
					if( $( btn ).val() != 'Continue' ) {
						$( btn ).on( 'click', (e) => {
							const endEvent = self.getEndEvent();
							debug.log( `ENDED: ${self.endAction}`, endEvent );
							self.sendMessage({ type: ExtConstants.SAVE_TIME_TRACKER, body: endEvent });
						});
					}
				});
			}
			
			// Cancel Buttons Click Handlers [End Event]
			debug.info( 'Cancel Action', self.cancelAction );
			if ( self.cancelAction ) {
				const $cancelBtns = $( ele ).find( 'input[name^="cancel"]' );
				debug.info( 'Cancel Buttons', $cancelBtns );
				const $continueBtn = $( ele ).find( 'input[value^="Continue"]' );
				debug.info( 'Continue Button', $continueBtn );
				
				if ($continueBtn && $continueBtn.length > 0 ) {
					debug.info( 'Returning and Not binding the click on Cancel Buttons', $continueBtn );
					return;
				}
				
				$cancelBtns.each( ( btnIndex, btn ) => {
					$( btn ).on( 'click', ( e ) => {
						const endEvent = self.getEndEvent({ endAction: self.cancelAction });
						debug.log( `ENDED: ${self.endAction}`, endEvent );
						self.sendMessage({ type: ExtConstants.SAVE_TIME_TRACKER, body: endEvent });
					});
				});
			}
		});
	}

	sendMessage( obj ) {
		
		if( this.extensionId ) {
			chrome.runtime.sendMessage( this.extensionId, obj );
		} 
		else {
			chrome.runtime.sendMessage( obj );
		}
	}
	
	/* LIGHTNING TIME TRACKER METHODS */
	newSObjectEventTracking() {
		
		debug.info( 'Action', this.action );
		if( this.action ) {
			const startEvent = this.getStartEvent();
			debug.log( `STARTED: ${this.action}`, startEvent );
			this.sendMessage({ type: ExtConstants.NEW_RECORD_DOCUMENT_ID, body: startEvent });
			this.sendMessage({ type: ExtConstants.SAVE_TIME_TRACKER, body: startEvent });
		}
	}
	
	endSObjectEventTracking() {
		
		const endEvent = this.getEndEvent({ endAction: this.cancelAction });
		debug.log( `ENDED: ${this.endAction}`, endEvent);
		this.sendMessage({ type: ExtConstants.SAVE_TIME_TRACKER, body: endEvent });
	}
	
	/*
		@ Purpose : Sets listeners on Quick Actions ( only visible quick actions ).
	*/
	trackQuickActions() {	
		
		var self = this;
		
		// SETS LISTENERS ON UPLAOD BUTTONS.
		$( '.slds-file-selector__button' ).each( function( i, ele ) {
			$( ele ).on( 'click', function() {
				if( $( ele ).html().includes( 'Upload Files' ) ) {
					self.pushActionToLightningComponent( 'Upload Files', 'Quick Action', 'quickActionState' );
				}
			});
		});
		
		// SETS LISTENERS ON UPLAOD LINKS.
		$( '.forceActionsContainer' ).each( function( i, ele ) { 
			var uploadFileLink = $( ele ).find( 'a' );
			if( uploadFileLink && uploadFileLink.length > 0 ) {
				
				$( uploadFileLink ).on( 'click', function() {
					var title = $( uploadFileLink ).attr( 'title' );
					if( title && title.toLowerCase() == 'upload files' ) {
						self.pushActionToLightningComponent( 'Upload Files', 'Quick Action', 'quickActionState' );
					}
				});
			}
		});
	}
	
	/*
		@ Purpose : Pushes Opening Action of Quick Action and Global Action to Lightning Component.
	*/
	pushActionToLightningComponent( title, defaultMode, defaultActiveState ) {
		
		var self = this;
		
		// Avoids edit and new actions as they are handled by lightning component itself.
		if( title && title.toLowerCase() != 'new' && title.toLowerCase() != 'edit' && 
			!( title.startsWith( "Show" ) && title.endsWith( "more actions" ) ) 
		) {
			var actionEvent = { mode : defaultMode, objectLabel : null, actionName : null, activeState : defaultActiveState };
			if( title.toLowerCase().includes( 'new' ) ) {
				
				var tokens = title.split( ' ' );
				if( tokens && tokens.length > 1 && tokens[0].toLowerCase() == 'new' ) {
					tokens.splice( 0, 1 );
					actionEvent.objectLabel = tokens.join( ' ' );
					actionEvent.mode = 'New';
				}
				else {
					actionEvent.actionName = title;
				}
			}
			else {
				actionEvent.actionName = title;
			}
			var lexOrigin = window.location.protocol + '//' + window.location.hostname;
			parent.postMessage( actionEvent, lexOrigin );
			self.handleCancelActions( false );
		}
	}
	
	/*
		@ Purpose : 1. Disables Cancel/Close buttons of Modal related to Quick Actions/Global Actions 
					   so that user cannot click cancel buttons until modal is opened completely.
					2. Sets the click event on Cancel buttons once the modal is opened completely.
	*/
	handleCancelActions( setListenerOnEscKey ) {
		
		var self = this;
			
		// Pushes elements of all cancel button and close buttons in the list.
		var listOfCancelButtonElements = [];
		
		$( '.forceActionButton' ).each( ( i, ele ) => {
			if ( ele.title == 'Cancel' ) {
				listOfCancelButtonElements.push( ele );
			}
		});
		
		$( '.cuf-publisherCancelButton' ).each( ( i, ele ) => {
			if( ele.textContent == 'Cancel' ) {
				listOfCancelButtonElements.push( ele );
			}
		});
		
		listOfCancelButtonElements.push( $( '.slds-modal__close' ) );
		listOfCancelButtonElements.push( $( '.cancelButton' ) );
		
		$( '.slds-button--neutral' ).each( ( i, ele ) => {
			if( ele.textContent == 'Cancel' ) {
				listOfCancelButtonElements.push( ele );
			}
		});
		
		$( '.closeButton' ).each( ( i, ele ) => { 
			if ( ele.title == 'Close' ) {
				listOfCancelButtonElements.push( ele );
			}
		});
		
		// Disables cancel buttons
		listOfCancelButtonElements.forEach( function( cancelButtonElement ) {
			$( cancelButtonElement ).attr( 'disabled', true );
		});
		
		// Enables buttons so that user can click cancel buttons as modal is opened completely.
		setTimeout( function() {
			listOfCancelButtonElements.forEach( function( cancelButtonElement ) {
				$( cancelButtonElement ).attr( 'disabled', false );
			});
			self.cancelEventTracking( setListenerOnEscKey );
		}, 500 );
	}
	
	/*
		@ Purpose : Sets listeners on Cancel/Close buttons when Quick/Global actions are fired.
	*/
	cancelEventTracking( setListenerOnEscKey ) {
		
		var lexOrigin = window.location.protocol + '//' + window.location.hostname;		
		var closingEvent = { 'closingAction' : 'Cancel' };
		
		// Modal Cancel button.
		$( '.forceActionButton' ).each( ( i, ele ) => {
			if ( ele.title == 'Cancel' ) {
				$( ele ).on( 'click', (e) => {
					parent.postMessage( closingEvent, lexOrigin );
				});
			}
		});
		
		// Quick Actions Cancel button.
		$( '.cuf-publisherCancelButton' ).each( ( i, ele ) => {
			if( ele.textContent == 'Cancel' ) {
				$( ele ).on( 'click', (e) => {
					parent.postMessage( closingEvent, lexOrigin );
				});
			}
		});
		
		// Modal Close Button ( Top Right Corner ).
		$( '.slds-modal__close' ).each( ( i, ele ) => {
			if ( ele.title == 'Close this window' ) {
				$( ele ).on( 'click', (e) => {
					parent.postMessage( closingEvent, lexOrigin );
				});
			}
		});
		
		// Quick Actions Cancel button ( Submit For Approval Action ).
		$( '.cancelButton' ).on( 'click', (e) => {
			parent.postMessage( closingEvent, lexOrigin );
		});
		
		// Quick Actions Cancel button ( Add To Campaign, Lead Convert, etc ).
		$( '.slds-button--neutral' ).each( ( i, ele ) => {
			if( ele.textContent == 'Cancel' ) {
				$( ele ).on( 'click', (e) => {
					parent.postMessage( closingEvent, lexOrigin );
				});
			}
		});
		
		// Listener on Escape Key for Quick Actions and Edit Record Actions only.
		$( document ).keyup( function( e ) {
			if ( e.keyCode == 27 ) { 
				
				setTimeout( function() {
					var modalContainer = $('.slds-modal__container' );
					if( !modalContainer || modalContainer.length == 0 ) {
						closingEvent[ 'closingAction' ] = 'Escape';
						parent.postMessage( closingEvent, lexOrigin );
					}
				},1000);
			}
		});
		
		// Global Actions Cancel button.
		$( '.closeButton' ).each( ( i, ele ) => { 
			if ( ele.title == 'Close' ) {
				$( ele ).on( 'click', (e) => {
					parent.postMessage( closingEvent, lexOrigin );
				});
			}
		});
	}
}