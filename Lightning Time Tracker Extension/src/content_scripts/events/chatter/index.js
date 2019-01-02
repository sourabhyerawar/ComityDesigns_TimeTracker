if( location.pathname.length == 16 || location.pathname.length == 19 ) {

	const caseId = ( location.pathname.substring( location.pathname.indexOf( '/500' ) + 1, 16 ) );

	let textPostDocumentId, emailDocumentId, logCallDocumentId, changeCaseStatusDocumentId, contentPostDocumentId, linkPostDocumentId, thankYouPostDocumentId, pollPostDocumentId, questionPostDocumentId;

	const chatterPostWrapper = $( "div[id^='efpPublisherWrapper_" + caseId + "']" );
	const postDiv = chatterPostWrapper.find( "div[id^='efpChatterPublisher_" + caseId + "']" );
	const tabSelectedDiv = chatterPostWrapper.find( "div[id^='efpPublishers_" + caseId + "']" );
	const selectedItemDiv = $( "div[id^='efpPublishers_" + caseId + "']" );
  
	function stopChatterPost() {
	
		const activeChatterPostDiv = chatterPostWrapper.find( "div.publisherWrapper > div.activeTemplate" );
		if( activeChatterPostDiv.hasClass( 'TextPost' ) && textPostDocumentId ) {
			const evt = new BaseEvent({ 
									   parentId: caseId, documentId: textPostDocumentId, 
									   action: EventConstants.CHATTER_TEXT, 
									   endAction: EventConstants.CHATTER_TEXT_SAVE 
									 });
			chrome.runtime.sendMessage( { type: ExtConstants.SAVE_TIME_TRACKER, body: evt.getEndEvent() } );
			textPostDocumentId = null;
		} 
		else if( activeChatterPostDiv.hasClass( 'ContentPost' ) && contentPostDocumentId ) {
			const evt = new BaseEvent({ 
									   parentId: caseId, documentId: contentPostDocumentId, 
									   action: EventConstants.CHATTER_FILE, 
									   endAction: EventConstants.CHATTER_FILE_SAVE 
									 });
			chrome.runtime.sendMessage( { type: ExtConstants.SAVE_TIME_TRACKER, body: evt.getEndEvent() } );
			contentPostDocumentId = null;
		} 
		else if( activeChatterPostDiv.hasClass( 'LinkPost' ) && linkPostDocumentId ) {
			const evt = new BaseEvent({ 
									   parentId: caseId, documentId: linkPostDocumentId, action: EventConstants.CHATTER_LINK, 
									   endAction: EventConstants.CHATTER_LINK_SAVE 
								     });
			chrome.runtime.sendMessage( { type: ExtConstants.SAVE_TIME_TRACKER, body: evt.getEndEvent() } );
			linkPostDocumentId = null;
		} 
		else if( activeChatterPostDiv.hasClass( 'RypplePost' ) && thankYouPostDocumentId ) {
			const evt = new BaseEvent({ 
									   parentId: caseId, documentId: thankYouPostDocumentId, 
									   action: EventConstants.CHATTER_THANK_YOU, 
									   endAction: EventConstants.CHATTER_THANK_YOU_SAVE 
								     });
			chrome.runtime.sendMessage( { type: ExtConstants.SAVE_TIME_TRACKER, body: evt.getEndEvent() } );
			thankYouPostDocumentId = null;
		} 
		else if( activeChatterPostDiv.hasClass( 'PollPost' ) && pollPostDocumentId ) {
			const evt = new BaseEvent({ 
									   parentId: caseId, documentId: pollPostDocumentId, action: EventConstants.CHATTER_POLL, 
									   endAction: EventConstants.CHATTER_POLL_SAVE 
									 });
			chrome.runtime.sendMessage( { type: ExtConstants.SAVE_TIME_TRACKER, body: evt.getEndEvent() } );
			pollPostDocumentId = null;
		} 
		else if( activeChatterPostDiv.hasClass( 'QuestionPost' ) && questionPostDocumentId ) {
			const evt = new BaseEvent({ 
									   parentId: caseId, documentId: questionPostDocumentId, 
									   action: EventConstants.CHATTER_QUESTION, 
									   endAction: EventConstants.CHATTER_QUESTION_SAVE 
									 });
			chrome.runtime.sendMessage( { type: ExtConstants.SAVE_TIME_TRACKER, body: evt.getEndEvent() } );
			questionPostDocumentId = null;
		}
	}
  
	// Chatter Post Comment
	const shareChatterPost = chatterPostWrapper.find( "#publishersharebutton" );
	if( shareChatterPost.length > 0 ) {
		shareChatterPost.on( 'click', function( e ) {
			stopChatterPost();
		});
	}

	const postDivObserver = new MutationObserver( function( mutations ) {
		
		mutations.forEach( function( mutation ) {
			
			if( mutation.attributeName != 'style' && mutation.oldValue != 'display:none;' ) {
				return;
			}
			
			if( mutation.target.style.display != 'none' ) {
				const activeChatterPostDiv = chatterPostWrapper.find( "div.publisherWrapper > div.activeTemplate" );
				
				if( activeChatterPostDiv.hasClass( 'TextPost' ) ) {
					textPostDocumentId = getUUID();
					const evt = new BaseEvent({ 
											   parentId: caseId, documentId: textPostDocumentId, 
											   action: EventConstants.CHATTER_TEXT, 
											   endAction: EventConstants.CHATTER_TEXT_SAVE 
										     });
					chrome.runtime.sendMessage( { type: ExtConstants.SAVE_TIME_TRACKER, body: evt.getStartEvent() } );
				} 
				else if( activeChatterPostDiv.hasClass( 'ContentPost' ) ) {
					contentPostDocumentId = getUUID();
					const evt = new BaseEvent({ 
											   parentId: caseId, documentId: contentPostDocumentId, 
											   action: EventConstants.CHATTER_FILE, 
											   endAction: EventConstants.CHATTER_FILE_SAVE 
										     });
					chrome.runtime.sendMessage({type: ExtConstants.SAVE_TIME_TRACKER, body: evt.getStartEvent()});
				} 
				else if( activeChatterPostDiv.hasClass( 'LinkPost' ) ) {
					linkPostDocumentId = getUUID();
					const evt = new BaseEvent({ 
											   parentId: caseId, documentId: linkPostDocumentId, 
											   action: EventConstants.CHATTER_LINK, 
											   endAction: EventConstants.CHATTER_LINK_SAVE 
										     });
					chrome.runtime.sendMessage( { type: ExtConstants.SAVE_TIME_TRACKER, body: evt.getStartEvent() } );
				} 
				else if( activeChatterPostDiv.hasClass( 'RypplePost' ) ) {
					thankYouPostDocumentId = getUUID();
					const evt = new BaseEvent({ 
											   parentId: caseId, documentId: thankYouPostDocumentId, 
											   action: EventConstants.CHATTER_THANK_YOU, 
											   endAction: EventConstants.CHATTER_THANK_YOU_SAVE 
										     });
					chrome.runtime.sendMessage( { type: ExtConstants.SAVE_TIME_TRACKER, body: evt.getStartEvent() } );
				} 
				else if( activeChatterPostDiv.hasClass( 'PollPost' ) ) {
					pollPostDocumentId = getUUID();
					const evt = new BaseEvent({ 
											   parentId: caseId, documentId: pollPostDocumentId, 
											   action: EventConstants.CHATTER_POLL, 
											   endAction: EventConstants.CHATTER_POLL_SAVE 
										     });
					chrome.runtime.sendMessage( { type: ExtConstants.SAVE_TIME_TRACKER, body: evt.getStartEvent() } );
				} 
				else if( activeChatterPostDiv.hasClass( 'QuestionPost' ) ) {
					questionPostDocumentId = getUUID();
					const evt = new BaseEvent({ 
											   parentId: caseId, documentId: questionPostDocumentId, 
											   action: EventConstants.CHATTER_QUESTION, 
											   endAction: EventConstants.CHATTER_QUESTION_SAVE 
										     });
					chrome.runtime.sendMessage( { type: ExtConstants.SAVE_TIME_TRACKER, body: evt.getStartEvent() } );
				}
			} 
			else {
				stopChatterPost();
			}
		});
	});
	
	if( postDiv.length > 0 ) {
		postDivObserver.observe( postDiv.get( 0 ), { attributes: true, attributeOldValue: true, attributeFilter: [ 'style' ] } );
	}

	const tabSelectedObserver = new MutationObserver( function( mutations ) {
		
		mutations.forEach( function( mutation ) {
			
			if( mutation.attributeName != 'class' ) {
				return;
			}
			
			const oldClassArray = mutation.oldValue && mutation.oldValue.split( " " ) ? mutation.oldValue.split( " " ) : null;
			const oldClassName = oldClassArray.length > 0 ? oldClassArray[ oldClassArray.length - 1 ] : null;
			
			if( !oldClassName ) {
				return;
			}
			
			if( oldClassName && ( oldClassName == 'efpChatterTabs' || mutation.target.className.indexOf( oldClassName ) > 0 ) ) {
				return;
			}
				
			if( oldClassName == 'efpTextPost' && textPostDocumentId ) {
				const evt = new BaseEvent({ 
										   parentId: caseId, documentId: textPostDocumentId, action: EventConstants.CHATTER_TEXT, 
										   endAction: EventConstants.CHATTER_TEXT_SAVE 
									     });
				chrome.runtime.sendMessage( { type: ExtConstants.SAVE_TIME_TRACKER, body: evt.getEndEvent() } );
				textPostDocumentId = null;
			} 
			else if( oldClassName == 'efpEmail' && emailDocumentId ) {
				const evt = new BaseEvent({ 
										   parentId: caseId, documentId: emailDocumentId, 
										   action: EventConstants.CHATTER_SEND_EMAIL, 
										   endAction: EventConstants.CHATTER_SEND_EMAIL_SAVE 
									     });
				chrome.runtime.sendMessage({type: ExtConstants.SAVE_TIME_TRACKER, body: evt.getEndEvent()});
				emailDocumentId = null;
			} 
			else if( oldClassName == 'efpLogCall' && logCallDocumentId ) {
				const evt = new BaseEvent({ 
										   parentId: caseId, documentId: logCallDocumentId, 
										   action: EventConstants.CHATTER_LOG_CALL, 
										   endAction: EventConstants.CHATTER_LOG_CALL_SAVE 
									     });
				chrome.runtime.sendMessage( { type: ExtConstants.SAVE_TIME_TRACKER, body: evt.getEndEvent() } );
				logCallDocumentId = null;
			} 
			else if( oldClassName == 'efpChangeCaseStatus' && changeCaseStatusDocumentId ) {
				const evt = new BaseEvent({ 
										   parentId: caseId, documentId: changeCaseStatusDocumentId, 
										   action: EventConstants.CHATTER_CHANGE_CASE_STATUS, 
										   endAction: EventConstants.CHATTER_CHANGE_CASE_STATUS_SAVE 
									     });
				chrome.runtime.sendMessage( { type: ExtConstants.SAVE_TIME_TRACKER, body: evt.getEndEvent() } );
				changeCaseStatusDocumentId = null;
			} 
			else if( oldClassName == 'efpContentPost' && contentPostDocumentId ) {
				const evt = new BaseEvent({ 
										   parentId: caseId, documentId: contentPostDocumentId, 
										   action: EventConstants.CHATTER_FILE, 
										   endAction: EventConstants.CHATTER_FILE_SAVE 
									     });
				chrome.runtime.sendMessage( { type: ExtConstants.SAVE_TIME_TRACKER, body: evt.getEndEvent() } );
				contentPostDocumentId = null;
			} 
			else if( oldClassName == 'efpLinkPost' && linkPostDocumentId ) {
				const evt = new BaseEvent({ 
										   parentId: caseId, documentId: linkPostDocumentId, 
										   action: EventConstants.CHATTER_LINK, 
										   endAction: EventConstants.CHATTER_LINK_SAVE 
									     });
				chrome.runtime.sendMessage( { type: ExtConstants.SAVE_TIME_TRACKER, body: evt.getEndEvent() } );
				linkPostDocumentId = null;
			} 
			else if( oldClassName == 'efpRypplePost' && thankYouPostDocumentId ) {
				const evt = new BaseEvent({ parentId: caseId, documentId: thankYouPostDocumentId, action: EventConstants.CHATTER_THANK_YOU, endAction: EventConstants.CHATTER_THANK_YOU_SAVE });
				chrome.runtime.sendMessage({type: ExtConstants.SAVE_TIME_TRACKER, body: evt.getEndEvent()});
				thankYouPostDocumentId = null;
			} 
			else if( oldClassName == 'efpPollPost' && pollPostDocumentId ) {
				const evt = new BaseEvent({ 
										   parentId: caseId, documentId: pollPostDocumentId, 
										   action: EventConstants.CHATTER_POLL, 
										   endAction: EventConstants.CHATTER_POLL_SAVE 
									     });
				chrome.runtime.sendMessage( { type: ExtConstants.SAVE_TIME_TRACKER, body: evt.getEndEvent() } );
				pollPostDocumentId = null;
			} 
			else if( oldClassName == 'efpQuestionPost' && questionPostDocumentId ) {
				const evt = new BaseEvent({ 
										   parentId: caseId, documentId: questionPostDocumentId, 
										   action: EventConstants.CHATTER_QUESTION, 
										   endAction: EventConstants.CHATTER_QUESTION_SAVE 
									     });
				chrome.runtime.sendMessage( { type: ExtConstants.SAVE_TIME_TRACKER, body: evt.getEndEvent() } );
				questionPostDocumentId = null;
			}
		});
	});

	const selectedItemObserver = new MutationObserver( function( mutations ) {
		
		mutations.forEach( function( mutation ) {
			
			if( mutation.attributeName != 'class' ) {
				return;
			}
			
			const oldClassArray = mutation.oldValue && mutation.oldValue.split( " " ) ? mutation.oldValue.split( " " ) : null;
			const oldClassName = oldClassArray.length > 0 ? oldClassArray[ oldClassArray.length - 1 ] : null;
			
			if( !oldClassName ) {
				return;
			}
			
			if( oldClassName && ( oldClassName == 'efpChatterTabs' || mutation.target.className.indexOf( oldClassName ) > 0 ) ) {
				return;
			}
			
			if( oldClassName == 'internalNoteIcon' && textPostDocumentId ) {
				const evt = new BaseEvent({ 
										   parentId: caseId, documentId: textPostDocumentId, 
										   action: EventConstants.CHATTER_TEXT, 
										   endAction: EventConstants.CHATTER_TEXT_SAVE 
									     });
				chrome.runtime.sendMessage( { type: ExtConstants.SAVE_TIME_TRACKER, body: evt.getEndEvent() } );
				textPostDocumentId = null;
			} 
			else if( oldClassName == 'efpAnswerCustomer' && emailDocumentId ) {
				const evt = new BaseEvent({ 
										   parentId: caseId, documentId: emailDocumentId, 
										   action: EventConstants.CHATTER_SEND_EMAIL, 
										   endAction: EventConstants.CHATTER_SEND_EMAIL_SAVE 
									     });
				chrome.runtime.sendMessage( { type: ExtConstants.SAVE_TIME_TRACKER, body: evt.getEndEvent() } );
				emailDocumentId = null;
			} 
			else if( oldClassName == 'efpChangeCaseStatus' && changeCaseStatusDocumentId ) {
				const evt = new BaseEvent({ 
											parentId: caseId, documentId: changeCaseStatusDocumentId, 
											action: EventConstants.CHATTER_CHANGE_CASE_STATUS, 
											endAction: EventConstants.CHATTER_CHANGE_CASE_STATUS_SAVE 
									     });
				chrome.runtime.sendMessage( { type: ExtConstants.SAVE_TIME_TRACKER, body: evt.getEndEvent() } );
				changeCaseStatusDocumentId = null;
			}
		});
	});

	if( tabSelectedDiv.length > 0 ) {
		tabSelectedObserver.observe( tabSelectedDiv.get( 0 ), { attributes: true, attributeOldValue: true, attributeFilter: [ 'class' ] } );
	} 
	else if( !( tabSelectedDiv.length > 0 ) && selectedItemDiv.length > 0 ) {
		selectedItemObserver.observe( selectedItemDiv.get( 0 ), { attributes: true, attributeOldValue: true, attributeFilter: [ 'class' ] } );
	}

	//Chatter Post Email
	const emailDiv = chatterPostWrapper.find( "div[id^='publisher_" + caseId + "Email']" );
	emailDiv.find( '#emailPublisherSubmitBtn_' + caseId ).on( 'click', function( e ) {
		
		const evt = new BaseEvent({ 
								   parentId: caseId, documentId: emailDocumentId, 
								   action: EventConstants.CHATTER_SEND_EMAIL, 
								   endAction: EventConstants.CHATTER_SEND_EMAIL_SAVE 
							      });
		chrome.runtime.sendMessage( { type: ExtConstants.SAVE_TIME_TRACKER, body: evt.getEndEvent() } );
		emailDocumentId = null;
	});
  
	const startEmailObserver = new MutationObserver(function( mutations ) {
		
		mutations.forEach( function( mutation ) {
			if( mutation.attributeName != 'style' ) {
				return;
			}
			
			if( mutation.target.style.display != 'none' ) {
				emailDocumentId = getUUID();
				const evt = new BaseEvent({ 
										   parentId: caseId, documentId: emailDocumentId, 
										   action: EventConstants.CHATTER_SEND_EMAIL, 
										   endAction: EventConstants.CHATTER_SEND_EMAIL_SAVE 
									     });
				chrome.runtime.sendMessage( { type: ExtConstants.SAVE_TIME_TRACKER, body: evt.getStartEvent() } );
			} 
			else if( mutation.oldValue == "display: none;" && mutation.target.style.display == 'none' && emailDocumentId ) {
				const evt = new BaseEvent({ 
										   parentId: caseId, documentId: emailDocumentId, 
										   action: EventConstants.CHATTER_SEND_EMAIL, 
										   endAction: EventConstants.CHATTER_SEND_EMAIL_SAVE 
									     });
				chrome.runtime.sendMessage( { type: ExtConstants.SAVE_TIME_TRACKER, body: evt.getEndEvent() } );
				emailDocumentId = null;
			}
		});
	});
  
	if( emailDiv.length > 0 ) {
		startEmailObserver.observe( emailDiv.get( 0 ), { attributes: true, attributeOldValue: true, attributeFilter: [ 'style' ] } );
	}

	//Chatter Post Log Call
	const logCallDiv = chatterPostWrapper.find( "div[id^='publisher_" + caseId + "LogCall']" );
	logCallDiv.find( '#logCallPublisherSubmitBtn_' + caseId ).on( 'click', function( e ) {
		
		const evt = new BaseEvent({ 
								   parentId: caseId, documentId: logCallDocumentId, 
								   action: EventConstants.CHATTER_LOG_CALL, 
								   endAction: EventConstants.CHATTER_LOG_CALL_SAVE 
							     });
		chrome.runtime.sendMessage( { type: ExtConstants.SAVE_TIME_TRACKER, body: evt.getEndEvent() } );
		logCallDocumentId = null;
	});
  
	const logCallObserver = new MutationObserver( function( mutations ) {
		
		mutations.forEach( function( mutation ) {
			
			if( mutation.attributeName != 'style' ) {
				return;
			}
			
			if( mutation.target.style.display != 'none' ) {
				logCallDocumentId = getUUID();
				const evt = new BaseEvent({ 
										   parentId: caseId, documentId: logCallDocumentId, 
										   action: EventConstants.CHATTER_LOG_CALL, 
										   endAction: EventConstants.CHATTER_LOG_CALL_SAVE 
									     });
				chrome.runtime.sendMessage( { type: ExtConstants.SAVE_TIME_TRACKER, body: evt.getStartEvent() } );
			} 
			else if( mutation.oldValue == "display: none;" && mutation.target.style.display == 'none' && logCallDocumentId ) {
				const evt = new BaseEvent({ 
										   parentId: caseId, documentId: logCallDocumentId, 
										   action: EventConstants.CHATTER_LOG_CALL, 
										   endAction: EventConstants.CHATTER_LOG_CALL_SAVE 
									     });
				chrome.runtime.sendMessage( { type: ExtConstants.SAVE_TIME_TRACKER, body: evt.getEndEvent() } );
				logCallDocumentId = null;
			}
		});
	});
  
	if( logCallDiv.length > 0 ) {
		logCallObserver.observe( logCallDiv.get( 0 ), { attributes: true, attributeOldValue: true, attributeFilter: [ 'style' ] } );
	}

	//Chatter Change Case Status
	const changeCaseStatusDiv = chatterPostWrapper.find( "div[id^='publisher_" + caseId + "ChangeCaseStatus']" );
	changeCaseStatusDiv.find( '#changeStatusPublisherSubmitBtn_' + caseId ).on( 'click', function( e ) {
		
		const evt = new BaseEvent({ 
								   parentId: caseId, documentId: changeCaseStatusDocumentId,
								   action: EventConstants.CHATTER_CHANGE_CASE_STATUS, 
								   endAction: EventConstants.CHATTER_CHANGE_CASE_STATUS_SAVE 
								 });
		chrome.runtime.sendMessage( { type: ExtConstants.SAVE_TIME_TRACKER, body: evt.getEndEvent() } );
		changeCaseStatusDocumentId = null;
	});
  
	const changeCaseStatusObserver = new MutationObserver( function( mutations ) {
		
		mutations.forEach( function( mutation ) {
			
			if( mutation.attributeName != 'style' ) {
				return;
			}
			
			if( mutation.target.style.display != 'none' ) {
				changeCaseStatusDocumentId = getUUID();
				const evt = new BaseEvent({ 
										   parentId: caseId, documentId: changeCaseStatusDocumentId, 
										   action: EventConstants.CHATTER_CHANGE_CASE_STATUS, 
										   endAction: EventConstants.CHATTER_CHANGE_CASE_STATUS_SAVE 
									     });
				chrome.runtime.sendMessage({ type: ExtConstants.SAVE_TIME_TRACKER, body: evt.getStartEvent() } );
			} 
			else if( mutation.oldValue == "display: none;" && mutation.target.style.display == 'none' && changeCaseStatusDocumentId ) {
				const evt = new BaseEvent({ 
										   parentId: caseId, documentId: changeCaseStatusDocumentId, 
										   action: EventConstants.CHATTER_CHANGE_CASE_STATUS, 
										   endAction: EventConstants.CHATTER_CHANGE_CASE_STATUS_SAVE 
									     });
				chrome.runtime.sendMessage( { type: ExtConstants.SAVE_TIME_TRACKER, body: evt.getEndEvent() } );
				changeCaseStatusDocumentId = null;
			}
		});
	});
  
	if( changeCaseStatusDiv.length > 0 ) {
		
		changeCaseStatusObserver.observe( changeCaseStatusDiv.get( 0 ), 
										  { attributes: true, attributeOldValue: true, attributeFilter: [ 'style' ] }
									    );
	}

	function getUUID() {
	
		let d = ( new Date() ).getTime();
		const uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function( c ) {
			const r = ( d + Math.random() * 16 ) % 16 | 0;
			d = Math.floor( d / 16 );
			return ( c == 'x' ? r : ( r&0x3|0x8 ) ).toString( 16 );
		});
		return uuid;
	}
}