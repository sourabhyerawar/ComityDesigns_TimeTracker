/**
	@ Purpose : Tracks the time in Lightning Experience for 
				1. Chatter actions such as 'POST', 'POLL', 'QUESTION'.
				2. List Views
				3. Visualforce pages
				4. Send Email
				5. Quick Actions
				6. Global Actions
	@ Name	  : lightningTimeTracker.js
*/

class sObjectEvent extends BaseEvent {	
	
	constructor ({
		
		source = 'Custom Event',
		objectId = null,
		documentId = null,
		extensionId = 'bbmcpbdcihggdbbcbcakllcdbecmkjim',
		newAction = 'New sObject',
		editAction = 'Edit sObject',
		saveAction = 'sObject Save',
		cancelAction = 'sObject Cancel'
		
	} = {}) {
		super({
			objectPrefix: '', objectId, documentId, extensionId, newAction, editAction, saveAction, cancelAction 
		});
	}
	
	newListViewTracking() {
		
		debug.info( 'Action', this.action );
		var namespace = localStorage.getItem( 'namespace' );
		
		if( this.action ) {
			
			const startEvent = {};
			startEvent[ namespace + 'Activity_Time__c' ] = ( new Date() ).getTime();
			startEvent[ namespace + 'DocumentId__c' ] = this.documentId;
			startEvent[ namespace + 'Action__c' ] = this.action;
			startEvent[ namespace + 'Object_Id__c' ] = this.to18DigitId( this.objectId );
			startEvent[ namespace + 'Parent_Object_Id__c' ] = this.to18DigitId( this.parentId );
			startEvent[ namespace + 'Source__c' ] = this.source;
			
			
			var listViewDocumentId = localStorage.getItem( 'listViewDocumentId' );
			if( typeof(listViewDocumentId) != 'undefined' || listViewDocumentId == null || listViewDocumentId == 'null' ) {
				localStorage.setItem( 'listViewDocumentId', startEvent[ namespace + 'DocumentId__c' ] );
			}
			debug.log( `STARTED: ${this.action}`, startEvent );
			
			var lexOrigin = window.location.protocol + '//' + window.location.hostname;
			parent.postMessage( { type : 'extRecord', isDetailPageAction : false, actionClosed : false, obj : startEvent }, lexOrigin );
		}
	}
	
	endListViewTracking() {
		
		var namespace = localStorage.getItem( 'namespace' );
		
		const endEvent = {};
		endEvent[ namespace + 'Activity_Time__c' ] = ( new Date() ).getTime();
		endEvent[ namespace + 'DocumentId__c' ] = this.documentId;
		endEvent[ namespace + 'Opening_Action__c' ] = this.action;
		endEvent[ namespace + 'Action__c' ] = this.cancelAction;
		endEvent[ namespace + 'Object_Id__c' ] = this.to18DigitId( this.objectId );
		endEvent[ namespace + 'Parent_Object_Id__c' ] = this.to18DigitId( this.parentId );
		endEvent[ namespace + 'Source__c' ] = this.source;
		
		var listViewDocumentId = localStorage.getItem( 'listViewDocumentId' );
		if( listViewDocumentId ) {
			endEvent[ namespace + 'DocumentId__c' ] = listViewDocumentId;
			localStorage.setItem( 'listViewDocumentId', 'null' );
		}
		debug.log( `ENDED: ${this.cancelAction}`, endEvent);
		
		var lexOrigin = window.location.protocol + '//' + window.location.hostname;
		parent.postMessage( { type : 'extRecord', isDetailPageAction : false, actionClosed : true, obj : endEvent }, lexOrigin );
	}
}

$( document ).ready(function() {
	
	// Set Local Storage Values
	localStorage.setItem( 'listViewDocumentId', 'null' );
	
	localStorage.setItem( 'isMutationSetForLV', 'false' );
	
	localStorage.setItem( 'namespace', '' );
	
	chrome.storage.local.set({ 'doneTypingInterval' : 30000 });
	
	let typingTimer;   
	let caseNumberAndCaseIdMap = new Map();
	let previousChatterAction = [];
	let startActionTimeStampMap = new Map();
	let endActionTimeStampMap = new Map();
	let totalChatterDurationMap = new Map();
	let caseIdAndPostDocId = new Map();
	let caseIdAndPollDocId = new Map();
	let caseIdAndQuestionsDocId = new Map();
	let caseIdAndEmailDocId = new Map();
	let configSettting;
	let lexOrigin = window.location.protocol + '//' + window.location.hostname;
	
	/*
		@ Purpose : 1. Receives user settings and namespace details from lightning component.
	*/
	document.addEventListener( 'PostingSettings', function( result ) {
		
		if( result && result.detail && result.detail.mode ) {
			localStorage.setItem( 'configSettings', result.detail.mode );
			
			configSettting = JSON.parse( result.detail.mode );
			if( configSettting ) {
				debug.info( 'settings to local storage', configSettting );
				
				if( configSettting.Namespace ) {
					localStorage.setItem( 'namespace', configSettting.Namespace );
				}
				setTypingInterval();
			}
		}
	});
	
	function setTypingInterval() {
		
		const ChatterTypingInterval = configSettting.Namespace ? configSettting.Namespace + '__' + 'ChatterTypingInterval__c' : 'ChatterTypingInterval__c';
		if( configSettting.UserSettings[ ChatterTypingInterval ] ) {
			chrome.storage.local.set({ 'doneTypingInterval' : configSettting.UserSettings[ ChatterTypingInterval ] * 1000 });
		} 
		else {
			chrome.storage.local.set({ 'doneTypingInterval' : 30000 });
		}
	}
	
	/*
		@ Purpose : Starts tracking of list view by creating/pushing an opening Time Tracker record to Salesforce.
	*/
	document.addEventListener( 'ListViewTracking', function( result ) {
		
		const evt = new sObjectEvent
						({ 
							newAction : JSON.stringify($('.slds-context-bar__label-action.slds-p-left--xx-small ')['0'].title).replace(/['"]+/g, '') +' List View',
							cancelAction : JSON.stringify($('.slds-context-bar__label-action.slds-p-left--xx-small ')['0'].title).replace(/['"]+/g, '') +' List View End'
						});
		evt.newListViewTracking();
		selectedObj = JSON.stringify($('.slds-context-bar__label-action.slds-p-left--xx-small ')['0'].title).replace(/['"]+/g, '');
		
		$('.navMenu.slds-context-bar__item--divider-right.uiMenu.oneAppNavMenu').each( (i, ele) => {
			$(ele).on('click', (e) => {
				trackObjectNavigation();
			});
		});
	});
	
	/*
		@ Purpose : Ends tracking of list view by creating/pushing a closing Time Tracker record to Salesforce.
	*/
	document.addEventListener( 'EndListViewTracking', function( result ) {
		
		const evt = new sObjectEvent
						({ 
							newAction : JSON.stringify($('.slds-context-bar__label-action.slds-p-left--xx-small ')['0'].title).replace(/['"]+/g, '') +' List View',
							cancelAction : JSON.stringify($('.slds-context-bar__label-action.slds-p-left--xx-small ')['0'].title).replace(/['"]+/g, '') +' List View End'
						});
		evt.endListViewTracking();
	});
	
	/*
		@ Purpose : 1. Detects the change in list view ( when list view's object is changed ).
					2. Pushes closing time tracker to end the list view tracking of previously selected object.
					3. Pushes an opening time tracker record to start the list view tracking on currently selected object.
	*/
	function trackObjectNavigation(){
		
		var isMutationSetForLV = localStorage.getItem( 'isMutationSetForLV' );
		if( isMutationSetForLV == 'false' ) {
			
			var observer = new MutationObserver( function( mutations ) {
				mutations.forEach( function( mutation ) {
					if ( mutation.type == 'attributes' && mutation.attributeName == 'title' ) {
						
						var newlySelectedObj = JSON.stringify($('.slds-context-bar__label-action.slds-p-left--xx-small ')['0'].title).replace(/['"]+/g, '');
						if( selectedObj != newlySelectedObj ) {
							
							var listViewDocumentId = localStorage.getItem( 'listViewDocumentId' );
							if( listViewDocumentId != 'null' ) {
								
								var evt = new sObjectEvent
											({ 
												newAction : selectedObj +' List View',
												cancelAction : selectedObj +' List View End'
											});
								evt.endListViewTracking();
									
								selectedObj = newlySelectedObj;
								evt = new sObjectEvent
										  ({ 
											newAction : selectedObj +' List View',
											cancelAction : selectedObj +' List View End'
										  });
								evt.newListViewTracking();
							}
						}
					}
				});   
			});
		
			var observerConfig = {
				attributes: true
			};

			// Listen to all changes to body and child nodes
			var targetNode = $('.slds-context-bar__label-action.slds-p-left--xx-small');
			observer.observe( targetNode[0], observerConfig );
			localStorage.setItem( 'isMutationSetForLV', 'true' );
		}
	}
	
	/*
		@ Purpose : 1. Sets listener on 'Save' button when record is being created or edited.
					2. Sets listener on 'Cancel' button when record is being edited.
	*/
	document.addEventListener( 'OpenRecordModalEvent', function( result ) {
		
		const evt = new sObjectEvent();
		if( result && result.detail && result.detail.mode ) {
			evt.handleCancelActions( true );
		}
	});
	
	/*
		@ Purpose : 1. This event is fired by lightning component when record's detail page is opened.
					2. Sets listener on 'Quick Action' buttons which are visible by default.
	*/
	document.addEventListener( 'TrackQuickActionsEvent', function( result ) {
		
		setTimeout( function() {
			const quickActionEvent = new sObjectEvent();
			quickActionEvent.trackQuickActions();
		},500);
	});
	
	document.addEventListener( 'TabSwitchEvent', function( result ) {
		
		if( result && result.detail ) {
			var eventRecord = result.detail.mode;
			if( eventRecord ) {
				localStorage.setItem( 'caseId', eventRecord.recordId );
			}
		}
	});
	
	/*
	 @ Purpose : Checks for previous chatter action which is not closed.
	 			 If any such unclosed chatter action is present then close that action.
	 
	*/
	function closePreviousAction() {
		
		if( previousChatterAction.length ) {
			
			var namespace = localStorage.getItem( 'namespace' );
			
			const endEvent = {};
			endEvent[ namespace + 'Activity_Time__c' ] = ( new Date() ).getTime();
			endEvent[ namespace + 'DocumentId__c' ] = previousChatterAction[0].documentId;
			endEvent[ namespace + 'Opening_Action__c' ] = previousChatterAction[0].action;
			endEvent[ namespace + 'Action__c' ] = previousChatterAction[0].endAction;
			endEvent[ namespace + 'Object_Id__c' ] = previousChatterAction[0].objectId;
			endEvent[ namespace + 'Parent_Object_Id__c' ] = previousChatterAction[0].parentId;
			endEvent[ namespace + 'Source__c' ] = previousChatterAction[0].source;
			
			debug.log( `ENDED: ${previousChatterAction[0].endAction}`, endEvent );
			parent.postMessage( { type : 'chatterRecord', isDetailPageAction : true, actionClosed : true, obj : endEvent }, lexOrigin );
			endActionTimeStampMap.set( previousChatterAction[0].parentId, endEvent[ namespace + 'Activity_Time__c' ] );
			
			var totalTimeOnChatter = 0;
			if( typeof( totalChatterDurationMap.get( previousChatterAction[ 0 ].parentId ) ) ==='undefined' ) {
				totalTimeOnChatter = ( endActionTimeStampMap.get( previousChatterAction[ 0 ].parentId ) - startActionTimeStampMap.get( previousChatterAction[ 0 ].parentId ) )* 0.001;
			} 
			else {
				totalTimeOnChatter = totalChatterDurationMap.get( previousChatterAction[ 0 ].parentId ) + ( endActionTimeStampMap.get( previousChatterAction[ 0 ].parentId ) - startActionTimeStampMap.get( previousChatterAction[ 0 ].parentId ) )* 0.001;
			}
			
			endActionTimeStampMap.set( previousChatterAction[ 0 ].parentId, null );
			startActionTimeStampMap.set( previousChatterAction[0].parentId, null );
			previousChatterAction[ 0 ].caseIdAndActionDocId.delete( localStorage.getItem( 'caseId' ) );
			totalChatterDurationMap.set( previousChatterAction[ 0 ].parentId, totalTimeOnChatter );
			localStorage.setItem( previousChatterAction[ 0 ].startActionFlag, 'start' );
			previousChatterAction = [];
		}
	}
	
	function startChatterQuestion() {
	
		const $sendBtns = $( '.qe-questionPostDesktop' );
		if( $sendBtns.length == 0 ) {
			
			setTimeout( function() {
				startChatterQuestion();
			}, 1000 );
		}
		else {
			$( $sendBtns ).on( 'click', ( e ) => {
										
				var recordId = localStorage.getItem( 'caseId' );
				if( caseIdAndQuestionsDocId.has( recordId ) ) {
					
					var namespace = localStorage.getItem( 'namespace' );
					
					const endEvent = {};
					endEvent[ namespace + 'Activity_Time__c' ] = ( new Date() ).getTime();
					endEvent[ namespace + 'DocumentId__c' ] = caseIdAndQuestionsDocId.get( recordId );
					endEvent[ namespace + 'Opening_Action__c' ] = 'Chatter Question';
					endEvent[ namespace + 'Action__c' ] = 'Chatter Question Save';
					endEvent[ namespace + 'Object_Id__c' ] = null;
					endEvent[ namespace + 'Parent_Object_Id__c' ] = recordId;
					endEvent[ namespace + 'Source__c' ] = ExtConstants.EXTENSION;
					
					debug.log( `ENDED: ${endEvent[ namespace + 'Action__c' ]}`, endEvent );
					parent.postMessage( { type : 'chatterRecord', isDetailPageAction : true, actionClosed : true, obj : endEvent }, lexOrigin );
					
					const evt = new BaseEvent
								({ 
									newAction : 'Chatter Question',
									editAction : 'Chatter Question Save',
									saveAction : 'Chatter Question Save',
									cancelAction : 'Chatter Question Save',
									documentId : caseIdAndQuestionsDocId.get( recordId ),
									parentId : recordId
								});
					
					localStorage.setItem( 'chatterQuestion', 'start' );
					caseIdAndQuestionsDocId.delete( recordId );
					previousChatterAction = [];
					
					endActionTimeStampMap.set( recordId, endEvent[ namespace + 'Activity_Time__c' ] );
					var totalTimeOnChatter = 0;
					
					if( typeof( totalChatterDurationMap.get( recordId ) ) === 'undefined' ) {
						totalTimeOnChatter = ( endActionTimeStampMap.get( recordId ) - startActionTimeStampMap.get( recordId ) ) * 0.001;
					} 
					else {
						totalTimeOnChatter = totalChatterDurationMap.get( recordId ) + ( endActionTimeStampMap.get( recordId ) - startActionTimeStampMap.get( recordId ) ) * 0.001;
					}
					
					totalChatterDurationMap.set( recordId, totalTimeOnChatter );
					endActionTimeStampMap.set( recordId, null );
					startActionTimeStampMap.set( recordId, null );
				}
			});
		}
	}
	
	function getActionIndexFromUiItems( listOfActiveUiItems, actionName ) {
		
		var actionIndex = -1;
		if( listOfActiveUiItems && listOfActiveUiItems.length > 0 && actionName ) {
			for( var index = 0; index < listOfActiveUiItems.length; index ++ ) {
				if( listOfActiveUiItems[ index ].textContent == actionName ) {
					actionIndex = index;
				}
			}
		}
		return actionIndex;
	}
	
	function nodeInsertedCallback( event ) {
		
		/*
			Chatter Post :-
						* Whenever User click on chatter post then it creates DOM with class forceChatterTextPostDesktop so user is on chatter post.
						* Update localStorage "chatterPost" value to start which indicate we can start chatter post start action.
						* we can detect save button & add listener to it , whenever user click on Save button then fire chatter Post End action
						* On chatter post click, it shows text area where user can write post. Detect that text area & add KeyUp listener & whenever user
						  type in that Text area start Chatter post action.
		*/
		if( $( event.target ).hasClass( 'forceChatterTextPostDesktop' ) ) {
			localStorage.setItem( 'chatterPost', 'start' );
			if( $( '.qe-textPostDesktop' ).length > 0 ) {
				
				const $sendBtns = $( '.qe-textPostDesktop' );
				$( $sendBtns ).on( 'click', ( e ) => {
					
					var recordId = localStorage.getItem( 'caseId' );
					if( caseIdAndPostDocId.has( recordId ) ) {
						
						var namespace = localStorage.getItem( 'namespace' );
						
						const endEvent = {};
						endEvent[ namespace + 'Activity_Time__c' ] = ( new Date() ).getTime();
						endEvent[ namespace + 'DocumentId__c' ] = caseIdAndPostDocId.get( recordId );
						endEvent[ namespace + 'Opening_Action__c' ] = 'Chatter Text';
						endEvent[ namespace + 'Action__c' ] = 'Chatter Text Save';
						endEvent[ namespace + 'Object_Id__c' ] = null;
						endEvent[ namespace + 'Parent_Object_Id__c' ] = recordId;
						endEvent[ namespace + 'Source__c' ] = ExtConstants.EXTENSION;
						
						debug.log( `ENDED: ${endEvent[ namespace + 'Action__c' ]}`, endEvent );
						parent.postMessage( { type : 'chatterRecord', isDetailPageAction : true, actionClosed : true, obj : endEvent }, lexOrigin );
						
						localStorage.setItem( 'chatterPost', 'start' );
						caseIdAndPostDocId.delete( recordId );
						
						endActionTimeStampMap.set( recordId, endEvent[ namespace + 'Activity_Time__c' ] );
						var totalTimeOnChatter = 0;
						if( typeof( totalChatterDurationMap.get( recordId ) ) === 'undefined' ) {
							totalTimeOnChatter = ( endActionTimeStampMap.get( recordId ) - startActionTimeStampMap.get( recordId ) ) * 0.001;
						} 
						else {
							totalTimeOnChatter = totalChatterDurationMap.get( recordId ) + ( endActionTimeStampMap.get( recordId ) - startActionTimeStampMap.get( recordId ) )* 0.001;
						}
						
						totalChatterDurationMap.set( recordId, totalTimeOnChatter );
						endActionTimeStampMap.set( recordId, null);
						startActionTimeStampMap.set( recordId, null);
						previousChatterAction = [];
					}
				});
			}
		}
		
		if( $( '.tabs__item.active.uiTabItem' ).length > 0 ) {
			const $uiTabItems = $( '.tabs__item.active.uiTabItem' );
			
			$uiTabItems.each( ( tabItemIndex, tabItem ) => {
				if( tabItem.textContent == 'Post' ) {
					
					var postTextElement = $( '.ql-editor.slds-rich-text-area__content.slds-text-color_weak.slds-grow.ql-blank' );
					if( postTextElement.length > 0 ) {
						
						$( postTextElement ).on( 'keyup', ( e ) => {
							
							var activeUiTabItems = $( '.tabs__item.active.uiTabItem' );
							if( activeUiTabItems && activeUiTabItems.length > 0 ) {
								
								var actionIndex = getActionIndexFromUiItems( activeUiTabItems, 'Post' );
								if( actionIndex != -1 ) {
									chrome.storage.local.get( 'doneTypingInterval', function ( result ) {
										clearTimeout(typingTimer);
										typingTimer = setTimeout(closePreviousAction, result.doneTypingInterval);
										
										if( localStorage.getItem( 'chatterPost' ) === 'start' ) {
											
											closePreviousAction();
											var recordId = localStorage.getItem( 'caseId' );
											caseIdAndPostDocId.set( recordId, getUUID() );
											
											const evt = new BaseEvent
														({ 
															newAction : 'Chatter Text',
															editAction : 'Chatter Text Save',
															saveAction : 'Chatter Text Save',
															cancelAction : 'Chatter Text Cancel',
															documentId : caseIdAndPostDocId.get( recordId ),
															parentId: recordId
														});
											
											var namespace = localStorage.getItem( 'namespace' );
								
											const startEvent = {};
											startEvent[ namespace + 'Activity_Time__c' ] = ( new Date() ).getTime();
											startEvent[ namespace + 'DocumentId__c' ] = evt.documentId;
											startEvent[ namespace + 'Action__c' ] = evt.newAction;
											startEvent[ namespace + 'Object_Id__c' ] = evt.objectId;
											startEvent[ namespace + 'Parent_Object_Id__c' ] = evt.parentId;
											startEvent[ namespace + 'Source__c' ] = evt.source;
											
											debug.log( `STARTED: ${evt.newAction}`, startEvent );
											parent.postMessage( { type : 'chatterRecord', isDetailPageAction : true, actionClosed : false, obj : startEvent }, lexOrigin );
											
											startActionTimeStampMap.set( recordId, startEvent[ namespace + 'Activity_Time__c' ] );
											localStorage.setItem( 'chatterPost', 'stop' );
											
											var evtCloned = JSON.parse( JSON.stringify( evt ) );
											evtCloned[ 'caseIdAndActionDocId' ] = caseIdAndPostDocId;
											evtCloned[ 'startActionFlag' ] = 'chatterPost';
											previousChatterAction.push( evtCloned );
										}
									});
								}
							}
						});
						
						$( postTextElement ).on( 'keydown', ( e ) => {
							clearTimeout( typingTimer );
						});
					}
				}
			});
		}
		
		/*
			Chatter Poll :-
						* Whenever User click on any tab, it creates DOM with class tabs__content active uiTab. check selected tab is Poll or not.
						* Update localStorage "chatterPoll" value to start which indicate we can start chatter Poll start action.
						* we can detect save button & add listener to it , whenever user click on Save button then fire chatter Post End action
						* On chatter poll click, it shows text area where user can write question for poll. 
						  Detect that text area & add KeyUp listener & whenever user type in that Text area start Chatter post action.
		*/
		
		if( $( event.target ).hasClass( 'tabs__content active uiTab' ) ) {
			const $sendBtns = $( '.tabs__item.active.uiTabItem' );
			$sendBtns.each( ( btnIndex, btn ) => {
				
				if( btn.textContent === 'Poll' ) {
					localStorage.setItem( 'chatterPoll', 'start' );
					
					setTimeout( function() {
						if( $( '.qe-pollPostDesktop' ).length > 0 ) {
							const $sendBtns = $( '.qe-pollPostDesktop' );
							$( $sendBtns ).on( 'click', ( e ) => {
								
								var recordId = localStorage.getItem( 'caseId' );
								if( caseIdAndPollDocId.has( recordId ) ) {
									
									var namespace = localStorage.getItem( 'namespace' );
									
									const endEvent = {};
									endEvent[ namespace + 'Activity_Time__c' ] = ( new Date() ).getTime();
									endEvent[ namespace + 'DocumentId__c' ] = caseIdAndPollDocId.get( recordId );
									endEvent[ namespace + 'Opening_Action__c' ] = 'Chatter Poll';
									endEvent[ namespace + 'Action__c' ] = 'Chatter Poll Save';
									endEvent[ namespace + 'Object_Id__c' ] = null;
									endEvent[ namespace + 'Parent_Object_Id__c' ] = recordId;
									endEvent[ namespace + 'Source__c' ] = ExtConstants.EXTENSION;
									
									debug.log( `ENDED: ${endEvent[ namespace + 'Action__c' ]}`, endEvent );
									parent.postMessage( { type : 'chatterRecord', isDetailPageAction : true, actionClosed : true, obj : endEvent }, lexOrigin );
									
									localStorage.setItem( 'chatterPoll', 'start' );
									caseIdAndPollDocId.delete( recordId );
									previousChatterAction = [];
									
									endActionTimeStampMap.set( recordId, endEvent[ namespace + 'Activity_Time__c' ] );
									var totalTimeOnChatter = 0;
									
									if( typeof( totalChatterDurationMap.get( recordId ) ) === 'undefined' ) {
										totalTimeOnChatter = ( endActionTimeStampMap.get( recordId ) - startActionTimeStampMap.get( recordId ) )* 0.001;
									} 
									else {
										totalTimeOnChatter = totalChatterDurationMap.get( recordId ) + ( endActionTimeStampMap.get( recordId ) - startActionTimeStampMap.get( recordId ) ) * 0.001;
									}
									totalChatterDurationMap.set( recordId, totalTimeOnChatter );
						
									endActionTimeStampMap.set( recordId, null );
									startActionTimeStampMap.set( recordId, null );
								}
							});
						}
					}, 500 );
				} 
				else if( btn.textContent === 'Question' ) {
					localStorage.setItem( 'chatterQuestion', 'start' );
					
					setTimeout( function() {
						startChatterQuestion();
					}, 2000 );
				}
			});
		}
		
		if( $( '.inputTextArea.cuf-publisherTextArea.inputTextArea.cuf-messageTextArea.textareaclass.textarea' ).length > 0 ) {
			const $pollText = $( '.inputTextArea.cuf-publisherTextArea.inputTextArea.cuf-messageTextArea.textareaclass.textarea' );
			const $pollQuestionFld = $( '.inputField.cuf-pollChoiceField.input' );
			
			$( $pollText ).add( $pollQuestionFld ).on( 'keyup', ( e ) => {
				chrome.storage.local.get( 'doneTypingInterval', function ( result ) {
					
					clearTimeout( typingTimer );
					typingTimer = setTimeout( closePreviousAction, result.doneTypingInterval );
					
					if( localStorage.getItem( 'chatterPoll' ) === 'start' ) {
						closePreviousAction();
						
						var recordId = localStorage.getItem( 'caseId' );
						caseIdAndPollDocId.set( recordId, getUUID() );
						
						const evt = new BaseEvent
									({ 
										newAction : 'Chatter Poll',
										editAction : 'Chatter Poll Save',
										saveAction : 'Chatter Poll Save',
										cancelAction : 'Chatter Poll Savel',
										documentId : caseIdAndPollDocId.get( recordId ),
										parentId: recordId
									});
						
						var namespace = localStorage.getItem( 'namespace' );
			
						const startEvent = {};
						startEvent[ namespace + 'Activity_Time__c' ] = ( new Date() ).getTime();
						startEvent[ namespace + 'DocumentId__c' ] = evt.documentId;
						startEvent[ namespace + 'Action__c' ] = evt.newAction;
						startEvent[ namespace + 'Object_Id__c' ] = evt.objectId;
						startEvent[ namespace + 'Parent_Object_Id__c' ] = evt.parentId;
						startEvent[ namespace + 'Source__c' ] = evt.source;
						
						debug.log( `STARTED: ${evt.newAction}`, startEvent );
						parent.postMessage( { type : 'chatterRecord', isDetailPageAction : true, actionClosed : false, obj : startEvent }, lexOrigin );
									
						startActionTimeStampMap.set( recordId, startEvent[ namespace + 'Activity_Time__c' ] );
						localStorage.setItem( 'chatterPoll', 'stop' );
						
						var evtCloned = JSON.parse( JSON.stringify( evt ) );
						evtCloned[ 'caseIdAndActionDocId' ] = caseIdAndPollDocId;
						evtCloned[ 'startActionFlag' ] = 'chatterPoll';
						previousChatterAction.push( evtCloned );
					}
				});
			});
				
			$( $pollText ).add( $pollQuestionFld ).on( 'keydown', ( e ) => {
				clearTimeout( typingTimer );
			});
		}
		
		if( $( '.cuf-questionTitleField.textarea' ).length > 0 ) {
			
			const $activeTab = $( '.tabs__item.active.uiTabItem' );
			const $QuestionText = $( '.ql-editor.slds-rich-text-area__content.slds-text-color--weak.slds-grow.ql-blank' );
			const $answerText = $( '.forceChatterMessageBodyInput' );
			const $sendBtns = $( '.cuf-questionTitleField.textarea' );
			
			$( '.cuf-questionTitleField.textarea, .forceChatterMessageBodyInput' ).on( 'keyup', ( e ) => {
				
				var activeUiTabItems = $( '.tabs__item.active.uiTabItem' );
				if( activeUiTabItems && activeUiTabItems.length > 0 ) {
					
					var actionIndex = getActionIndexFromUiItems( activeUiTabItems, 'Question' );
					if( actionIndex != -1 ) {
						chrome.storage.local.get( 'doneTypingInterval', function ( result ) {
							
							clearTimeout( typingTimer );
							typingTimer = setTimeout( closePreviousAction, result.doneTypingInterval );
							
							if( localStorage.getItem( 'chatterQuestion' ) === 'start' ) {
								closePreviousAction();
								
								var recordId = localStorage.getItem( 'caseId' );
								caseIdAndQuestionsDocId.set( recordId, getUUID() );
								
								const evt = new BaseEvent
											({ 
												newAction : 'Chatter Question',
												editAction : 'Chatter Question Save',
												saveAction : 'Chatter Question Save',
												cancelAction : 'Chatter Question Savel',
												documentId : caseIdAndQuestionsDocId.get( recordId ),
												parentId: recordId
											});
								
								var namespace = localStorage.getItem( 'namespace' );
					
								const startEvent = {};
								startEvent[ namespace + 'Activity_Time__c' ] = ( new Date() ).getTime();
								startEvent[ namespace + 'DocumentId__c' ] = evt.documentId;
								startEvent[ namespace + 'Action__c' ] = evt.newAction;
								startEvent[ namespace + 'Object_Id__c' ] = evt.objectId;
								startEvent[ namespace + 'Parent_Object_Id__c' ] = evt.parentId;
								startEvent[ namespace + 'Source__c' ] = evt.source;
								
								debug.log( `STARTED: ${evt.newAction}`, startEvent );
								parent.postMessage( { type : 'chatterRecord', isDetailPageAction : true, actionClosed : false, obj : startEvent }, lexOrigin );
								
								startActionTimeStampMap.set( recordId, startEvent[ namespace + 'Activity_Time__c' ] );
								localStorage.setItem( 'chatterQuestion', 'stop' );
								
								var evtCloned = JSON.parse( JSON.stringify( evt ) );
								evtCloned[ 'caseIdAndActionDocId' ] = caseIdAndQuestionsDocId;
								evtCloned[ 'startActionFlag' ] = 'chatterQuestion';
								previousChatterAction.push( evtCloned );
							}
						});
					}
				}
			});
			
			$( '.cuf-questionTitleField.textarea, .forceChatterMessageBodyInput' ).on( 'keydown', ( e ) => {
				clearTimeout( typingTimer );
			});
		}
		
		// RECORD EDIT MODAL CONTAINER
		if( $( event.target ).hasClass( 'full forcePageBlock forceRecordLayout' ) ) {
			new sObjectEvent().handleCancelActions( true );
		}
		
		// GLOBAL ACTIONS MODAL
		var globalActionDock = $( event.target );
		if( globalActionDock && globalActionDock.length > 0 ) {
			var dockClassName = globalActionDock.attr( 'class' );
			
			if( dockClassName && dockClassName.includes( 'forceDockingPanel--dockableAction' ) ) {
				var panelElement = globalActionDock.find( '.panelTitle' );
				if( panelElement && panelElement.length > 0 ) {
					
					var globalActionTitle = panelElement.attr( 'title' );
					if( globalActionTitle ) {
						new sObjectEvent().pushActionToLightningComponent( globalActionTitle, 'Global Action', 'globalActionState' );
					}
				}
			}
		}
		
		// QUICK ACTIONS
		if( $( event.target ).hasClass( 'DESKTOP uiModal' ) || $( event.target ).hasClass( 'DESKTOP uiModal--fullBleed uiModal' ) ) {
			var header = $( '.slds-modal__header' ).find( '.slds-text-heading--medium' );
			if( header && header.length > 0  ) {
				
				var title = header.html();
				if( title ) {
					var lowerCaseTitle = title.toLowerCase();
					if( ( !lowerCaseTitle.startsWith( 'edit' ) || lowerCaseTitle == 'edit comments' ) &&
						lowerCaseTitle != 'address search'
					) {
						if( lowerCaseTitle.startsWith( 'assign article' ) ) {
							title = 'Assign Article';
						}
						new sObjectEvent().pushActionToLightningComponent( title, 'Quick Action', 'quickActionState' );
					}
				}
			}
		}
		
		// CLONE QUICK ACTION AND LEAD CONVERT ACTION
		if( $( event.target ).hasClass( 'DESKTOP uiModal--medium uiModal forceModal' ) || 
			$( event.target ).hasClass( 'DESKTOP uiModal--leadConvert uiModal' )
		) {
			setTimeout( function() {
				var header = $( '.slds-modal__header' ).find( '.slds-text-heading--medium' );
				
				if( header && header.length > 0  ) {
					var title = header.html();
					if( title && !title.toLowerCase().startsWith( 'edit' ) ) {
						new sObjectEvent().pushActionToLightningComponent( title, 'Quick Action', 'quickActionState' );
					}
				}
			},1000);
		}
		
		// EDIT ALL PRODUCTS
		if( $( event.target ).hasClass( 'DESKTOP uiModal--large uiModal--multiEdit uiModal forceModal' ) ||
			$( event.target ).hasClass( 'DESKTOP uiModal--medium uiModal--multiEdit uiModal forceModal' )
		) {
			setTimeout( function() {
				var header = $( '.slds-modal__header' ).find( 'h2' );
				
				if( header && header.length > 0  ) {
					var title = header.html();
					if( title ) {
						new sObjectEvent().pushActionToLightningComponent( title, 'Quick Action', 'quickActionState' );
					}
				}
			},1000);
		}
		
		// ADD PRODUCTS AND SEND LIST EMAIL AND MANAGE CONTACT ROLES
		if( $( event.target ).hasClass( 'DESKTOP uiModal--large uiModal--multiAdd uiModal forceModal' ) ||
			$( event.target ).hasClass( 'DESKTOP uiModal--medium uiModal' )
		) {
			setTimeout( function() {
				var header = $( '.slds-modal__header' ).find( 'h2' );
				if( header && header.length > 0  ) {
					
					var title = header.html();
					if( title && !title.toLowerCase().startsWith( 'edit' ) ) {
						new sObjectEvent().pushActionToLightningComponent( title, 'Quick Action', 'quickActionState' );
						
						// WHEN CLICKED ON NEXT BUTTON, SET LISTENERS ON NEWLY DISPLAYED CANCEL BUTTONS.
						$( '.forceActionButton' ).each( function( index, ele ) {
							if( $(ele).attr( 'title' ) == 'Next' ) {
								$(ele).on( 'click', function() {
									setTimeout( function() {
										new sObjectEvent().handleCancelActions( true );
									}, 500 );
								});
							}
						});
					}
				}
			},1000);
		}
		
		// SHARE ATTACHMENTS AND FILES
		if( $( event.target ).hasClass( 'DESKTOP uiModal--fullBleed uiModal--clipHeader uiModal' ) ) {
			setTimeout( function() {
				var header = $( '.slds-modal__header' ).find( 'h2' );
				if( header && header.length > 0  ) {
					
					var title = header.html();
					if( title ) {
						title = title.toLowerCase();
						if( title.startsWith( 'share' ) ) {
							new sObjectEvent().pushActionToLightningComponent( 'Share', 'Quick Action', 'quickActionState' );
						}
					}
				}
			},1000);
		}
		
		// ATTACHMENT PREVIEW
		if( $( event.target ).hasClass( 'DESKTOP uiModal--modalPreview uiModal' ) ) {
			
		}
	}
	
	document.addEventListener( 'DOMNodeInserted', nodeInsertedCallback );
	
});

function getUUID() {
	
    let d = ( new Date() ).getTime();
    const uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function( c ) {
		const r = ( d + Math.random() * 16 )%16 | 0;
		d = Math.floor( d/16 );
		return( c=='x' ? r : ( r&0x3|0x8 ) ).toString( 16 );
    });
    return uuid;
}