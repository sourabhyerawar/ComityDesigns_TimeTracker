/*
  	@ PURPOSE : PROVIDES SERVICE TO THE LIGHTNING COMPONENT CONTROLLER --> TimeTrackerComponentController.js
	@ NAME 	  : TimeTrackerComponentHelper.js
*/
({	
    /******************************* ACTIONS INVOKED BY CONTROLLER *******************************/
    
    /*
    	@ PURPOSE : 1. INITIALIZES ALL UNDEFINED ATTRIBUTES OF A COMPONENT WITH DEFAULT VALUES.
					2. INVOKES METHODS TO FETCH OBJECT DETAILS AND CUSTOM SETTINGS FROM SERVER.
					3. SETS THE EVENT LISTENERS TO CATCH THE EVENTS FIRED FROM CHROME EXTENSION.
    */
    initializeFooterComponent : function( component, helper ) {
        
		// INITIALIZES CONSOLESTATE ATTRIBUTE DEFAULT VALUES.
        helper.resetConsoleState( component, helper );
        
		// SETS THE DEBUG ATTRIBUTE OF WINDOW.
        if( !window[ "debug" ] ) {
                window[ "debug" ] = {};
        }
        window.debug[ "info" ] = window.debug[ "log" ] = window.debug[ "error" ]  = function() {};
        
        // FETCHES ALL SETTINGS AND OBJECT DETAILS.
        helper.fetchAndSetObjectDetails( component, helper );
		
		// SETS THE EVENT LISTENERS TO CATCH THE EVENTS FIRED FROM CHROME EXTENSION.
        helper.receiveMessagesFromExtension( component, helper );
    },
    
    /*
    	@ PURPOSE : INVOKES WHENEVER A NEW TAB IS OPENED/CREATED.
    */
    handleTabCreated : function( component, helper ) {
        
        var workspaceAPI = component.find( "workspace" );
		if( workspaceAPI ) {
			workspaceAPI.getFocusedTabInfo().then( function( openedConsoleTab ) {
				
				if( openedConsoleTab.tabId ) {
					
					// ADDS TAB DETAILS TO CONSOLE STATE ATTRIBUTE.
					helper.addTabForTracking( component, helper, openedConsoleTab );
					
					// HANDLES TIME STAMP DETAILS OF CURRENT AND PREVIOUSLY ACTIVE TAB.
					helper.handleTabFocused( component, helper, openedConsoleTab.tabId );
				}
				else {
					/* 
					SOMETIMES WHEN TAB IS OPENED/CREATED OR WHENEVER PAGE IS LOADED WITH SOME TABS ALREADY OPENED,
					TAB ID IS NOT AVAILABLE. 
					THEREFORE, TRAVERSES OVER ALL TABS AND TRACKS THE TABS WHICH MISSED EARLIER.
					*/
					helper.handleExistingTabs( component, helper, false );
				}
			});
		}
    },
	
    /*
    	@ PURPOSE : INVOKES WHENEVER A TAB IS OPENED/SWITCHED/CLOSED.
    */
    handleTabFocused : function( component, helper, currentTabId ) {
        
        var consoleState = helper.getJsonComponentState( component, helper, "v.jsonConsoleState" );
        //console.log( 'handleTabFocused-console state', JSON.stringify( consoleState ) );
        if( consoleState && currentTabId ) {
			
			var tabRecord = helper.getRecordDetails( component, helper, 
                                                     consoleState.listOfTabs, "tabId", 
                                                     currentTabId, false 
                                                   );
            if( tabRecord ) { 
			
				// PUSHES THE OPENING TIME TRACKER RECORD FOR THE TAB IF NOT PUSHED EARLIER.
                helper.addAndPushTTRecord( component, helper, consoleState, tabRecord );
				
				// RESUMES TRACKING OF CURRENT TAB AND PAUSES FOR LAST ACTIVE TAB.
                helper.handleTabSwitch( component, helper, consoleState, tabRecord );
            }
			else {
				/*
				PARENT TAB WAS NOT ADDED TO CONSOLE STATE WHEN CHILD TAB WAS OPENED DIRECTLY.
				ADDS PARENT TAB NOW AND START TRACKING FOR IT.
				*/
				helper.handleTabCreated( component, helper );
			}
        } 
    },
    
    /*
    	@ PURPOSE : 1. THIS METHOD IS INVOKED WHENEVER A TAB IS CLOSED.
        			2. PUSHES INACTIVE TIME STAMPS FOR CLOSED TAB AND PUSHES CLOSING TIME TRACKER RECORDS.
                    3. PUSHES ACTIVE TIME STAMPS FOR NEWLY FOCUSED TAB.
    */
    handleTabClosed : function( component, helper, closedTabId ) {
        
		if( closedTabId ) {
			var consoleState = helper.getJsonComponentState( component, helper, "v.jsonConsoleState" );
			if( consoleState ) {
				consoleState.activeState = "listOfTabs";
				helper.setJsonComponentState( component, helper, "v.jsonConsoleState", consoleState );
            }
			
			var workspaceAPI = component.find( "workspace" );
			if( workspaceAPI ) {
				workspaceAPI.getFocusedTabInfo().then( function( autoFocusedConsoleTab ) {
						
					consoleState = helper.getJsonComponentState( component, helper, "v.jsonConsoleState" );
					if( consoleState ) {
						
						// IT HOLDS A TAB RECORD WHICH GETS AUTOMATICALLY FOCUSED WHEN ANY TAB IS CLOSED.
						var autoFocusedTabRecord = helper.getRecordDetails
														  ( 
														   component, helper, 
														   consoleState.listOfTabs, "tabId", 
														   autoFocusedConsoleTab.tabId, false 
														  );
														  
						// RESUMES TRACKING OF CURRENT TAB AND PAUSES FOR LAST ACTIVE TAB.
						helper.handleTabSwitch( component, helper, consoleState, autoFocusedTabRecord );
						
						var namespace = component.get( "v.namespace" );
		
						// IT HOLDS JUST CLOSED TAB RECORD.
						var closedTabRecord = helper.getRecordDetails
													 ( 
													  component, helper, 
													  consoleState.listOfTabs, "tabId", 
													  closedTabId, false 
													 );
														  
						// CLOSES OPENING CHATTER ACTIONS IF ANY AVAILABLE RELATED TO CLOSED TAB AND UPDATES EXCLUDE REVIEW TIME ON TAB RECORD.
						if( closedTabRecord && closedTabRecord.tabState && closedTabRecord.tabState.recordId &&
							consoleState.chatterRecord && consoleState.chatterRecord.ttRecord.tt &&
							( consoleState.chatterRecord.ttRecord.tt[ namespace + "Parent_Object_Id__c" ] || 
							  consoleState.chatterRecord.ttRecord.tt[ namespace + "Object_Id__c" ]
							)
						) {
							
							// COMPARES RECORD ID OF CLOSED TAB WITH CHATTER ACTIONS OPENING RECORD ( OBJECT ID OR PARENT ID ).
							if( closedTabRecord.tabState.recordId == consoleState.chatterRecord.ttRecord.tt[ namespace + "Parent_Object_Id__c" ] ||
								closedTabRecord.tabState.recordId == consoleState.chatterRecord.ttRecord.tt[ namespace + "Object_Id__c" ]
							) {
								// CREATES CLOSING RECORD FROM OPENING CHATTER RECORD.
								var endChatterRecord = consoleState.chatterRecord.ttRecord.tt;
								endChatterRecord[ namespace + "Opening_Action__c" ] = endChatterRecord[ namespace + "Action__c" ];
								endChatterRecord[ namespace + "Opening_Activity_Time__c" ] = endChatterRecord[ namespace + "Activity_Time__c" ];
								
								endChatterRecord[ namespace + "Action__c" ] += " Save";
								endChatterRecord[ namespace + "Activity_Time__c" ] = ( new Date() ).getTime();
								
								helper.updateExcludeTime( component, helper, consoleState, endChatterRecord );
								helper.pushTimeTracker( component, helper, endChatterRecord );
								helper.resetActionState( component, helper, consoleState.chatterRecord );
							}
						}
						
						// PUSHES CLOSING TIME TRACKER RECORD FOR CLOSED TAB AND REMOVE ITS INSTANCE FROM CONSOLE STATE.
						helper.removeAndPushTTRecord( component, helper, consoleState, closedTabId, true );
					}
				});
			}
        }
    },
    
	/*
    	@ PURPOSE : 1. THIS METHOD IS INVOKED WHENEVER A RECORD IS EDITED.
        			2. RESUMES TRACKING OF EDIT ACTION AND 
						2.1 PAUSES FOR REVIEW ACTION.
							OR
						2.2 PAUSES FOR LIST VIEW ACTION IF RECORD WAS EDITED FROM THE LIST VIEW DIRECTLY.
    */
    handleEditRecord : function( component, event, helper, tabMode, extensionEvent, objectLabel ) {
         
        var consoleState = helper.getJsonComponentState( component, helper, "v.jsonConsoleState" );
        if( consoleState ) {
			
			// CLOSES EXISTING ORPHAN RECORDS RELATED TO QUICK ACTION, EDIT RECORD ACTION FROM TAB OR LIST VIEW.
			helper.closeOrphanActions( component, helper, consoleState, consoleState.activeTabId );
			
			// IF RECORD IS EDITED FROM THE DETAIL PAGE.
			if( consoleState.activeTabId ) {
				var editedTabRecord = helper.getRecordDetails
											 ( 
											  component, helper, 
											  consoleState.listOfTabs, "tabId", 
											  consoleState.activeTabId, false 
											 );
				if( editedTabRecord && editedTabRecord.tabState ) {
					var namespace = component.get( "v.namespace" );
					editedTabRecord.tabState.mode = tabMode;
					
					// FIRES AN EVENT TO EXTENSION TO SET A LISTENER OF 'CANCEL' BUTTON.
					helper.dispatchEventToExtension( component, helper, extensionEvent, 
                                                     editedTabRecord.tabState.mode 
                                                   );
					
					editedTabRecord.ttRecord.tt = {};
					var currentTimeStamp = ( new Date() ).getTime();
					var actualEditedRecordId = event.getParam( "recordId" );
					
					// PAUSES TRACKING ITS REVIEW RECORD ACTION.
					if( editedTabRecord.reviewState.inactiveTimeStamps.length == editedTabRecord.reviewState.activeTimeStamps.length - 1 ) {
						editedTabRecord.reviewState.inactiveTimeStamps.push( currentTimeStamp );
					} 
					
					// RESUMES TRACKING ITS EDIT RECORD ACTION.
					if( editedTabRecord.ttRecord.inactiveTimeStamps.length == editedTabRecord.ttRecord.activeTimeStamps.length ) {
						editedTabRecord.ttRecord.activeTimeStamps.push( currentTimeStamp );
					}  
					
					// IF RECORD HAS ITS OWN TAB ( DETAIL PAGE )
					if( editedTabRecord.tabState.recordId == actualEditedRecordId ) {
						helper.addAndPushTTRecord( component, helper, consoleState, editedTabRecord );
					}
					else {
						/*
						IF RECORD IS EDITED FROM RELATED LIST SECTION OF ITS PARENT RECORD.
						THIS RECORD DOES NOT HAVE ITS OWN TAB.
						*/
						helper.handleChildRecord( component, helper, consoleState, editedTabRecord, 
												  actualEditedRecordId, objectLabel, tabMode 
												);
					}
				}
			}
			else if( consoleState.listViewState ) {
				
				// IF RECORD IS EDITED FROM A LIST VIEW DIRECTLY.
				var listViewState = consoleState.listViewState;
				listViewState.tabState.mode = tabMode;
				
				// FIRES AN EVENT TO EXTENSION TO SET A LISTENER OF 'CANCEL' BUTTON.
				helper.dispatchEventToExtension( component, helper, extensionEvent, listViewState.tabState.mode );
				listViewState.tabState.recordId = event.getParam( "recordId" );
				
				if( listViewState.tabState.recordId ) {
					
					// SETS LIST VIEW MODE.
					consoleState.activeState = "listViewState";
					var listOfObjectWrappers = helper.getJsonComponentState( component, helper, 
                                                                             "v.jsonListOfObjectWrappers" 
                                                                           );
					if( listOfObjectWrappers ) {
                
						// RECEIVES THE OBJECT STATE FOR A RECORD EDITED FROM DIRECTLY LIST VIEW.
						listViewState.tabState.objectState =  helper.getRecordDetails
															  ( 
															   component, helper, listOfObjectWrappers, 
															   "objectKeyPrefix", 
															   listViewState.tabState.recordId.substring(0,3), 
															   false
															  );

						// PUSHES THE OPENING TIME TRACKER RECORD FOR EDIT ACTION IF NOT PUSHED EARLIER.
						helper.addAndPushTTRecord( component, helper, consoleState, listViewState );
                        
                        // PAUSES TRACKING OF LIST VIEW ACTION.
						helper.handleListViewTracking( component, helper, consoleState, false );	
					}
				}
			}
        }
        console.log( 'handleEditRecord-consoleState', JSON.stringify( consoleState ) );
    },
    
	/*
    	@ PURPOSE : 1. THIS METHOD IS INVOKED WHENEVER A QUICK ACTION OR A GLOBAL ACTION IS INVOKED.
        			2. PAUSES TRACKING OF
						2.1 LIST VIEWS.
						2.2 AND OTHER CONSOLE TABS.
					3. IF CURRENT ACTION IS 'QUICK ACTION', IT PAUSES TRACKING OF 'GLOBAL ACTION' 
                       IF IT WAS RUNNING EARLIER.
    */
	handleQuickOrGlobalAction : function( component, helper, extensionResponse ) {
		
		if( extensionResponse ) {
			var objectLabel = "";
			var action = "";
			
			// IF OBJECT LABEL IS PRESENT; IT MEANS NEW OBJECT CREATION.
			if( extensionResponse.objectLabel ) {
				objectLabel = extensionResponse.objectLabel.trim();
				
				// EXTENSION MODE IS BY DEFAULT 'NEW' FOR NEW OBJECT CREATIONS.
				action = extensionResponse.mode + " ";
			}
			else if( extensionResponse.actionName ) {
				// OTHERWISE IT MEANS GENERAL ACTIONS SUCH AS 'LOG A CALL','CHANGE OWNER', ETC.
				objectLabel = extensionResponse.actionName.trim();
			}
								
			if( objectLabel ) {
				action += objectLabel;
				var consoleState = helper.getJsonComponentState( component, helper, "v.jsonConsoleState" );
				if( consoleState ) {
					var namespace = component.get( "v.namespace" );
					
					// EXTENSIONRESPONSE.ACTIVESTATE COULD BE 'QUICKACTIONSTATE' OR 'GLOBALACTIONSTATE'.
					var actionState = consoleState[ extensionResponse.activeState ];
					
					// VALIDATES ACTION STATE
					if( actionState.ttRecord && actionState.tabState ) {
						
						/*
						THERE IS A USE CASE WHERE CLOSING ACTION MAY NOT FIRE.
						IF AGENT CANCELS/CLOSES QUICK/GLOBAL ACTION BEFORE THE DOM GETS LOADED
						DUE TO WHICH CANCEL BUTTON'S CLICK DOES NOT GET FIRED.
						
						HENCE, WE END UP WITH HAVING ORPHAN OPENING TIME TRACKER IN CONSOLE STATE 
						WHICH BLOCKS FURTHER ACTIONS.
						THEREFORE, CHECK IF CURRENT ACTION IS DIFFERENT FROM EXISTING ACTION, 
						THEN CLOSES THE EXISTING BLOCKED ACTION AND PUSH NEW ACTION.
						
						IF THE SAME ACTION IS INVOKED FOR WHICH ALREADY ONE OPENING ORPHAN RECORD FIRED/PRESENT 
						THEN AVOIDS PUSHING NEW ONE.
						*/
						
						if( ( !actionState.ttRecord.tt || !actionState.ttRecord.tt[ namespace + "Action__c" ] ) ||
							( actionState.ttRecord.tt[ namespace + "Action__c" ] &&
							  actionState.ttRecord.tt[ namespace + "Action__c" ].toLowerCase() != action.toLowerCase()
							)
						) {
							// IF GLOBAL ACTION IS OPENED/INVOKED.
							if( extensionResponse.activeState == "globalActionState" ) {
								
								// CLOSES EXISTING ORPHAN RECORDS RELATED TO QUICK ACTION, EDIT RECORD ACTION FROM TAB OR LIST VIEW.
								helper.closeOrphanActions( component, helper, consoleState, consoleState.activeTabId );
							}
							
							/*
							CLOSES THE EXISTING ORPHAN OPENING TIME TRACKER RECORD 
							WHOSE CLOSING EVENT WAS NOT DETECTED.
							*/
							if( actionState.ttRecord.tt && actionState.ttRecord.tt[ namespace + "Action__c" ] &&
								actionState.ttRecord.tt[ namespace + "Action__c" ].toLowerCase() != action.toLowerCase()
							) {
								helper.handleShowToast( component, helper, "success", "Cancel", null );
							}
							
							actionState.tabState.mode = extensionResponse.activeState;
							var listOfObjectWrappers = helper.getJsonComponentState( component, helper, 
																					 "v.jsonListOfObjectWrappers" 
																				   );
							actionState.tabState.objectState = helper.getRecordDetails
                                                                      ( 
                                                                       component, helper, listOfObjectWrappers, 
                                                                       "objectLabel", objectLabel, false
                                                                      );
                            
							/*
							IF OBJECT LABEL IS NOT FOUND IN LIST OF OBJECT WRAPPERS; 
							IT MEANS, IT'S NOT OBJECT CREATION ACTION BUT 'LOG A CALL','CHANGE OWNER',ETC.
							*/
							if( !actionState.tabState.objectState ) {
								actionState.tabState.objectState = {
																    "objectLabel" : objectLabel
																   };
							}
							
							actionState.ttRecord.tt = helper.getStartTTRecord( component, helper, actionState );
							if( actionState.ttRecord.tt ) {
								
								// SETS MODE IN CONSOLE STATE ( LISTVIEWSTATE/LISTOFTABS/QUICKACTIONSTATE/GLOBALACTIONSTATE ).
								consoleState.activeState = extensionResponse.activeState;
								helper.resumeTabTracking( component, helper, actionState );
								
								// PUSHES INACTIVE TIME STAMP TO CURRENT TAB.
								var currentTabRecord = helper.getRecordDetails( component, helper, 
																				consoleState.listOfTabs, 
																				"tabId", consoleState.activeTabId, 
                                                                                false 
																			  );
								helper.pauseTabTracking( component, helper, currentTabRecord );
								
								// PUSHES INACTIVE TIME STAMP TO LIST VIEW STATE.
								helper.pauseTabTracking( component, helper, consoleState.listViewState );
								
								// PUSHES INACTIVE TIME STAMP TO GLOBAL ACTION STATE.
								if( extensionResponse.activeState == "quickActionState" ) {
									helper.pauseTabTracking( component, helper, consoleState.globalActionState );
									
									// RELATES QUICK ACTION WITH ITS CURENT TAB'S RECORD.
									if( currentTabRecord && currentTabRecord.tabState && 
                                        currentTabRecord.tabState.recordId 
                                    ) {
										actionState.ttRecord.tt[ namespace + "Parent_Object_Id__c" ] = currentTabRecord.tabState.recordId;
									}
								}
								
								/*
								CLOSES LIST VIEW TRACKING IF IT WAS TRACKING EARLIER ON INVOKING OF 
								'QUICK' OR 'GLOBAL' ACTION.
								*/
								if( consoleState.listViewState.documentId ) {
									helper.handleListViewTracking( component, helper, consoleState, false );
								}
								
								// PUSHES OPENING TIME TRACKER RECORD OF QUICK ACTION TO SALESFORCE SERVER.
								helper.pushTimeTracker( component, helper, actionState.ttRecord.tt );
								
								// FIRES AN EVENT TO EXTENSION TO SET A LISTENER OF 'CANCEL' BUTTON.
								helper.dispatchEventToExtension( component, helper, "OpenRecordModalEvent", 
																 actionState.tabState.mode 
															   );
							}
						}
					}
					helper.setJsonComponentState( component, helper, "v.jsonConsoleState", consoleState );
				}
			}
		}
	},
	
	/*
    	@ PURPOSE : 1. THIS METHOD IS INVOKED WHENEVER TOASTMESSAGE IS FIRED.
        			2. PAUSES TRACKING OF NEW/EDIT ACTION AND
						2.1 RESUMES TRACKING OF REVIEW ACTION.
							OR
						2.2 RESUMES FOR LIST VIEW ACTION IF RECORD WAS EDITED FROM THE LIST VIEW DIRECTLY.
    */
    handleShowToast : function( component, helper, toastMessageType, mode, savedRecordId ) {
		
		var constants = JSON.parse( JSON.stringify( component.get( "v.constants" ) ) );
		if( constants ) {
				
			// ENSURES RECORD IS SAVED SUCCESSFULLY.
			if( toastMessageType && mode ) {            
				var consoleState = helper.getJsonComponentState( component, helper, "v.jsonConsoleState" );
				if( consoleState ) {
					var namespace = component.get( "v.namespace" );
					
					// IF RECORD IS SAVED SUCCESSFULLY WHEN CREATED OR EDITED FROM THE DETAIL PAGE.
					if( consoleState.activeState == "listOfTabs" && consoleState.activeTabId ) {
						
						var savedTabRecord = helper.getRecordDetails
													( 
													 component, helper, 
													 consoleState.listOfTabs, "tabId", 
													 consoleState.activeTabId, false 
													);
						if( savedTabRecord && savedTabRecord.tabState ) {
							savedTabRecord.tabState.mode = mode;

							// IF RECORD'S ID IS AVAILABLE.
							if(	savedRecordId ) {
								
								// ENSURES OPENING TIME TRACKER IS AVAILABLE.
								if( savedTabRecord.ttRecord && savedTabRecord.ttRecord.tt ) {
									
									// ADDS RECORD ID TO OPENING TIME TRACKER RECORD OF CONSOLE STATE.
									savedTabRecord.ttRecord.tt[ namespace + "Object_Id__c" ] = savedRecordId;
									
									/*
									POPULATES RECORD ID ON THIS CONSOLE TAB FOR REVIEW ACTION IN NEAR FUTURE
									WHEN CHILD RECORD FROM SECONDARY TAB IS SAVED.
									*/
									if( !savedTabRecord.tabState.recordId ) {
										savedTabRecord.tabState.recordId = savedRecordId;
									}
									
									/*
									PUSHES CLOSING TIME TRACKER RECORD FROM ITS OPENING TIME TRACKER RECORD 
									FROM CONSOLE STATE.
									*/
									helper.removeAndPushTTRecord( component, helper, consoleState, 
																  consoleState.activeTabId, false 
																);
									setTimeout( function() {
										// FIRES AN EVENT TO EXTENSION TO SET LISTENERS ON QUICK ACTION BUTTONS/LINKS.
										helper.dispatchEventToExtension( component, helper, 
																		 "TrackQuickActionsEvent", null 
																	   );
									}, 1000 );
								}
								else {
									debug.error( constants.ERR_Opening_Time_Tracker_Missing );
								}
							}
							else {	
								/*
								OTHERWISE FETCHES FROM CONSOLE TAB USING WORKSPACE API.
								PROVIDES SOME DELAY TO GET FULL DETAILS OF THE CONSOLE TAB.
								*/
								setTimeout( function() {
									var workspaceAPI = component.find( "workspace" );
									if( workspaceAPI ) {
										workspaceAPI.getFocusedTabInfo().then( function( autoFocusedConsoleTab ) {
											if( autoFocusedConsoleTab ) {
												
												/*
												WHEN SAME EVENT SUCH AS 'CANCEL' IS FIRED MULTIPLE TIMES FROM EXTENSION, 
												DUPLICATE TIME TRACKERS ARE CREATED.
												TO AVOID THIS, FETCHES RECENT DATA AND VERIFIES BEFORE INVOKING THIS METHOD 
												MULTIPLE TIMES IN A ROW.
												*/
												consoleState = helper.getJsonComponentState( component, helper, 
																							 "v.jsonConsoleState" 
																						   );
												if( consoleState ) {
													savedTabRecord = helper.getRecordDetails
																			( 
																			 component, helper, 
																			 consoleState.listOfTabs, "tabId", 
																			 consoleState.activeTabId, false 
																			);
													if( savedTabRecord && savedTabRecord.tabState && 
														savedTabRecord.ttRecord && savedTabRecord.ttRecord.tt && 
														savedTabRecord.ttRecord.tt[ namespace + "Action__c" ] 
													) {
															
														// ADDS RECORD ID TO OPENING TIME TRACKER RECORD OF CONSOLE STATE.
														savedTabRecord.tabState.mode = mode;
														if( autoFocusedConsoleTab.recordId ) {
															savedTabRecord.tabState.recordId = autoFocusedConsoleTab.recordId;
														}
														else if( !savedTabRecord.tabState.recordId ) {
															savedTabRecord.tabState.recordId = savedTabRecord.ttRecord.tt[ namespace + "Object_Id__c" ];
														}
														
														/*
														PUSHES CLOSING TIME TRACKER RECORD FROM ITS 
														OPENING TIME TRACKER RECORD FROM CONSOLE STATE.
														*/
														helper.removeAndPushTTRecord( component, helper, consoleState, 
																					  consoleState.activeTabId, false 
																					);
														setTimeout( function() {
															/*
															FIRES AN EVENT TO EXTENSION TO SET LISTENERS ON 
															QUICK ACTION BUTTONS/LINKS.
															*/
															helper.dispatchEventToExtension( component, helper, 
																							 "TrackQuickActionsEvent", null 
																						   );
														}, 1000 );
													}
												}
											}
										});
									}
								}, 500 );
							}
						}
					}
					else {
						/*
						IF RECORD IS SAVED WHEN EDITED FROM LIST VIEW DIRECTLY.
						OR IF RECORD IS SAVED WHEN OPENED FROM A QUICK ACTION OR GLOBAL ACTION.
						*/
						var activeState = consoleState[ consoleState.activeState ];
						if( activeState && activeState.tabState ) {
							activeState.tabState.mode = mode;
							activeState.tabState.recordId = savedRecordId;
							
							/*
							PUSHES CLOSING TIME TRACKER RECORD WHEN MODAL IS CLOSED AND 
							REMOVES ITS INSTANCE FROM CONSOLE STATE.
							*/
							helper.removeAndPushTTRecord( component, helper, consoleState, 
														  consoleState.activeTabId, false 
														);
						}
					}
				}
			}
			else {
				debug.error( constants.ERR_Invalid_Mode + " ", mode );
			}
		}
    },
    
    /******************************* ACTIONS INVOKED BY HELPER *******************************/
	
    /*
    	@ PURPOSE : 1. FETCHES THE DETAILS OF THE EXISTING TABS.
        			2. ADDS THESE TABS TO CONSOLE STATE.
                    3. PUSHES ACTIVE TIME STAMP FOR FOCUSED TAB.
    */
    handleExistingTabs : function( component, helper, trackListView ) {
    	
		// DELAY IS PROVIDED HERE TO MAKE SURE THAT CUSTOM SETTINGS ARE LOADED.
        setTimeout( function() {
            var workspaceAPI = component.find( "workspace" );
			if( workspaceAPI ) {
				workspaceAPI.getAllTabInfo().then( function( listOfAllTabs ) {
					
					if( listOfAllTabs.length > 0 ) {
						var focusedPrimaryConsoleTabId, focusedSecondaryConsoleTabId;
						
						// ITERATES OVER ALL PRIMARY TABS.
						listOfAllTabs.forEach( function( primaryConsoleTab ) {
							
							// ADDS ALL PRIMARY TABS TO THE CONSOLE STATE.
							helper.addTabForTracking( component, helper, primaryConsoleTab );
							if( primaryConsoleTab.focused ) {
								
								// FETCHES ID OF THE FOCUSED PRIMARY TAB.
								focusedPrimaryConsoleTabId = primaryConsoleTab.tabId;
							}
							
							// ITERATES OVER ALL SECONDARY TABS OF EACH PRIMARY TAB.
							primaryConsoleTab.subtabs.forEach( function( secondaryConsoleTab ) {
								
								// ADDS ALL SECONDARY TABS TO THE CONSOLE STATE.
								helper.addTabForTracking( component, helper, secondaryConsoleTab );
								if( secondaryConsoleTab.focused ) {
									
									// FETCHES ID OF THE FOCUSED SECONDARY TAB.
									focusedSecondaryConsoleTabId = secondaryConsoleTab.tabId;
								}
							});
						});
						
						var consoleState = helper.getJsonComponentState( component, helper, "v.jsonConsoleState" );
						if( consoleState ) {
							var validTabId;
							
							// PREFERS FOCUSED SECONDARY TAB TO FOCUSED PRIMARY TAB FOR TRACKING.
							if( focusedSecondaryConsoleTabId ) {
								validTabId = focusedSecondaryConsoleTabId;
							}
							else {
								validTabId = focusedPrimaryConsoleTabId;
							}
							
							if( validTabId ) {
								var tabRecord = helper.getRecordDetails
													   ( 
														component, helper, 
														consoleState.listOfTabs, "tabId", 
														validTabId, false 
													   );
								// RESUMES TRACKING OF CURRENTLY FOCUSED TAB.
								helper.handleTabSwitch( component, helper, consoleState, tabRecord );
							}
						}
					}
					else if( trackListView ) {
						
						// STARTS TRACKING OF LIST VIEW IF NO TAB IS OPENED. 
						var consoleState = helper.getJsonComponentState( component, helper, "v.jsonConsoleState" );
						helper.handleListViewTracking( component, helper, consoleState, true );
					}
					
					/*
					PROVIDES MORE DELAY AS, ON LOAD OF CONSOLE APP, WHEN EXISTING TABS ARE OPENED; 
					IT TAKES MORE TIME THAN USUAL TO LOAD QUICK ACTIONS PALETTE.
					*/
					setTimeout( function() {
						
						// FIRES AN EVENT TO EXTENSION TO SET LISTENERS ON QUICK ACTION BUTTONS/LINKS.
						helper.dispatchEventToExtension( component, helper, "TrackQuickActionsEvent", null );
					}, 1000 );
				});
			}
        }, 1000 );
    },
    
	/*
		@ PURPOSE : ADDS TAB DETAILS TO CONSOLE STATE FOR TRACKING.
	*/
    addTabForTracking : function( component, helper, consoleTab ) {
        
        if( consoleTab && consoleTab.tabId ) {
            //console.log('consoleTab:::'+ JSON.stringify( consoleTab ));
            var tabState = helper.getTabState( component, helper, JSON.parse( JSON.stringify( consoleTab ) ) );
            if( tabState ) {
                //console.log('tabState:::'+ JSON.stringify( tabState ));
                tabState[ "consoleTab" ] = consoleTab;
                //console.log('tabState:::'+ JSON.stringify( tabState ));
                var consoleState = helper.getJsonComponentState( component, helper, "v.jsonConsoleState" );                
                
                //console.log('consoleState:::'+ JSON.stringify( consoleState ));
                
                if( consoleState ) {
                    var tabRecord = helper.getRecordDetails( component, helper, 
                                                             consoleState.listOfTabs, "tabId", 
                                                             tabState.consoleTab.tabId, false 
                                                           );
                    if( !tabRecord ) {
                        tabRecord = { 
                                     tabId : tabState.consoleTab.tabId,
                                     tabState : tabState,
                                     ttRecord : 
                                               {
                                                tt : {},
                                                activeTimeStamps : [],
                                                inactiveTimeStamps : []
                                               },
                                     reviewState :
                                                  { 
                                                   excludeReviewTime : 0,
                                                   activeTimeStamps : [],
                                                   inactiveTimeStamps : []
                                                  }
                                    };
                        consoleState.listOfTabs.push( tabRecord );
                        //console.log('consoleState after pushing tab ::' + JSON.stringify(consoleState));
                        helper.setJsonComponentState( component, helper, "v.jsonConsoleState", consoleState );
                    }
            	}
            }
        }
    },
    
	/*
		@ PURPOSE : 1. CREATES AN OPENING TIME TRACKER RECORD FROM CONSOLE TAB DETAILS.
					2. INVOKES A METHOD TO PUSH THIS RECORD TO SERVER.
	*/
    addAndPushTTRecord : function( component, helper, consoleState, tabRecord ) {
        
        if( consoleState && tabRecord ) {
            if( tabRecord.tabState.mode != "view" && tabRecord.ttRecord ) {
                
                var namespace = component.get( "v.namespace" );
            	var actionFieldName = namespace + "Action__c";
                
				// ENSURES IF AN OPENING TIME TRACKER IS NOT PUSHED EARLIER FOR THIS TAB.
                if( !tabRecord.ttRecord.tt || !tabRecord.ttRecord.tt[ actionFieldName ] ) {
                    tabRecord.ttRecord.tt = helper.getStartTTRecord( component, helper, tabRecord );
                    if( tabRecord.ttRecord.tt && tabRecord.ttRecord.tt[ actionFieldName ] ) {
                        helper.pushTimeTracker( component, helper, tabRecord.ttRecord.tt );
                        helper.setJsonComponentState( component, helper, "v.jsonConsoleState", consoleState );
                    }
                }
            }
        }
    },
    
    /*
    	@ PURPOSE : THIS METHOD INVOKES WHENEVER ANY TAB IS OPENED, CLOSED, OR SWITCHED.
    */
    handleTabSwitch : function( component, helper, consoleState, focusedTabRecord ) {
        
        if( consoleState ) {
            var namespace = component.get( "v.namespace" );
			
            if( consoleState.lastActiveTabId != consoleState.activeTabId ) {
                // PREVIOUSLY FOCUSED TAB SHOULD BECOMES LAST ACTIVE TAB.
				consoleState.lastActiveTabId = consoleState.activeTabId;
            }
            
            if( focusedTabRecord ) {
				// NEWLY FOCUSED TAB BECOMES ACTIVE TAB.
                consoleState.activeTabId = focusedTabRecord.tabId;
            }
            else {
                consoleState.activeTabId = null;
            }
                
            // PUSHES INACTIVE TIME STAMP TO LAST TAB.
            var lastTabRecord = helper.getRecordDetails( component, helper, 
                                                         consoleState.listOfTabs, 
                                                         "tabId", consoleState.lastActiveTabId, false 
                                                       );
            helper.pauseTabTracking( component, helper, lastTabRecord );
			
            // PUSHES ACTIVE TIME STAMP TO CURRENT TAB.
            var currentTabRecord = helper.getRecordDetails( component, helper, 
                                                            consoleState.listOfTabs, 
                                                            "tabId", consoleState.activeTabId, false 
                                                          );
			/*
			WHEN USER SWITCHES TAB; JUST PAUSEES THE TRACKING OF AN OLD TAB.
			IF GLOBAL ACTION IS NOT RUNNING EARLIER THEN ONLY RESUMES THE TRACKING OF A NEW TAB.
			*/
			if( consoleState.globalActionState && consoleState.globalActionState.ttRecord && 
				( !consoleState.globalActionState.ttRecord.tt || 
				  !consoleState.globalActionState.ttRecord.tt[ namespace + "Action__c" ]
				)
			) {
				if( consoleState.activeTabId ) {
					helper.resumeTabTracking( component, helper, currentTabRecord );
					consoleState.activeState = "listOfTabs";
				}
            }
            
			// WHEN USER SWITCHES TAB; MAKE SURE, QUICK ACTION OR LIST VIEW EDIT ACTION AND EDIT ACTION OF RECORD GETS CLOSED.
			helper.closeOrphanActions( component, helper, consoleState, consoleState.lastActiveTabId );
			
			helper.setJsonComponentState( component, helper, "v.jsonConsoleState", consoleState );
			
            // PASSES CURRENT TAB'S RECORD ID TO EXTENSION.
            var eventRecord = { recordId : null, objectName : null };
            if( currentTabRecord && currentTabRecord.tabState ) {
                eventRecord.recordId = currentTabRecord.tabState.recordId;
                if( currentTabRecord.tabState.objectState ) {
                    eventRecord.objectName = currentTabRecord.tabState.objectState.objectName;
                }
            }
            helper.dispatchEventToExtension( component, helper, "TabSwitchEvent", eventRecord );
        }
    },
	
	/*
    	@ PURPOSE : PUSHES INACTIVE TIME STAMP TO / PAUSES THE TRACKING OF THE CURRENT STATE.
    */
	pauseTabTracking : function( component, helper, tabRecord ) {
		
		if( tabRecord ) {
			var currentTimeStamp = ( new Date() ).getTime();
            			
			// IF REVIEW ACTION WAS BEING PERFORMED ON THE TAB THEN PUSHES INACTIVE TIME STAMP.
			if( tabRecord.reviewState &&
				tabRecord.reviewState.inactiveTimeStamps.length == ( tabRecord.reviewState.activeTimeStamps.length - 1 ) 
			  ) {
				tabRecord.reviewState.inactiveTimeStamps.push( currentTimeStamp );
			}
			else if( tabRecord.ttRecord &&
					 tabRecord.ttRecord.inactiveTimeStamps.length == ( tabRecord.ttRecord.activeTimeStamps.length - 1 ) 
			) {
				// IF NEW/EDIT ACTION WAS BEING PERFORMED ON THE TAB THEN PUSHES INACTIVE TIME STAMP.
				tabRecord.ttRecord.inactiveTimeStamps.push( currentTimeStamp );
			}
		}
	},
	
	/*
    	@ PURPOSE : PUSHES ACTIVE TIME STAMP TO / RESUMES THE TRACKING OF THE CURRENT STATE.
    */
	resumeTabTracking : function( component, helper, tabRecord ) {
		
		if( tabRecord ) {
            var currentTimeStamp = ( new Date() ).getTime();
                
			// IF REVIEW ACTION IS BEING PERFORMED ON THE TAB THEN PUSHES ACTIVE TIME STAMP.
			if( tabRecord.tabState.mode == "view" && tabRecord.reviewState &&
				tabRecord.reviewState.activeTimeStamps.length == tabRecord.reviewState.inactiveTimeStamps.length 
			) {
				tabRecord.reviewState.activeTimeStamps.push( currentTimeStamp );
				
				setTimeout( function() {
					// FIRES AN EVENT TO EXTENSION TO SET LISTENERS ON QUICK ACTION BUTTONS/LINKS.
					helper.dispatchEventToExtension( component, helper, "TrackQuickActionsEvent", null );
				}, 1000 );
			}
			else if( tabRecord.ttRecord &&
					 tabRecord.ttRecord.activeTimeStamps.length == tabRecord.ttRecord.inactiveTimeStamps.length 
			) {
				// IF NEW/EDIT ACTION IS BEING PERFORMED ON THE TAB THEN PUSHES ACTIVE TIME STAMP.
				tabRecord.ttRecord.activeTimeStamps.push( currentTimeStamp );
			}
		}
	},
	
	/*
    	@ PURPOSE : ADDS CHILD'S RECORD DETAILS TO 'tt' ATTRIBUTE OF THE CURRENTLY ACTIVE TAB RECORD.
    */
    handleChildRecord : function ( component, helper, consoleState, parentTabRecord, childRecordId, 
                                   childObjectLabel, tabMode ) { 
								   
        if( consoleState && parentTabRecord && tabMode && ( childRecordId || childObjectLabel ) ) {
            
			var namespace = component.get( "v.namespace" );
				
            // CLONES THE CURRENTLY ACTIVE TAB RECORD.
            var childTabRecord = JSON.parse( JSON.stringify( parentTabRecord ) );
            
            // SETS THE DETAILS OF CHILD'S RECORD.
            childTabRecord.tabState.mode = tabMode;
			
			var attributeName, attributeValue;
			if( childRecordId ) {
				childTabRecord.tabState.recordId = childRecordId;
				attributeName = "objectKeyPrefix";
				attributeValue = childRecordId.substring(0,3);
            }
			else {
				attributeName = "objectLabel";
				attributeValue = childObjectLabel;
			}
			
			
            var listOfObjectWrappers = helper.getJsonComponentState( component, helper, 
                                                                     "v.jsonListOfObjectWrappers" 
                                                                   );
            if( listOfObjectWrappers ) {
                
                // RECEIVES THE OBJECT STATE FOR CHILD RECORD.
                childTabRecord.tabState.objectState = helper.getRecordDetails
													  ( 
													   component, helper, listOfObjectWrappers, 
													   attributeName, attributeValue, false
													  );
				
				if( !childTabRecord.tabState.objectState ) {
					
					/*
					OBJECT STATE IS NOT FOUND, IT MAY BE DUE TO QUICK ACTION OR
					SEARCH ACTION AND ITS RELATED OBJECT DETAILS IN STRATEGY SETTINGS INSTEAD.
					*/
					var strategySetting = helper.getStrategySetting
												 ( 
												  component, helper, 
												  namespace + "Text1__c", childObjectLabel
												 );
					if( strategySetting && strategySetting[ namespace + "Text4__c" ] ) {
						childTabRecord.tabState.objectState = helper.getRecordDetails
															  ( 
															   component, helper, listOfObjectWrappers, 
															   "objectLabel", 
                            								   strategySetting[ namespace + "Text4__c" ], 
															   false
															  );
						if( childTabRecord.tabState.objectState ) {
							childTabRecord.tabState.objectState.objectLabel = childObjectLabel;
						}
					}
				}
				
                // ASSIGNS THE CHILD'S EDIT TIME TRACKER RECORD TO 'TT' ATTRIBUTE OF PARENT TAB RECORD.
                parentTabRecord.ttRecord.tt = helper.getStartTTRecord( component, helper, childTabRecord );
                var actionFieldName = namespace + "Action__c";
                if( parentTabRecord.ttRecord.tt && parentTabRecord.ttRecord.tt[ actionFieldName ] ) {
					
					/*
					ASSIGNS CURRENT TAB'S RECORD ID AS A PARENT OBJECT ID ON TIME TRACKER RECORD
					WHEN CHILD RECORDS ARE EDITED FROM RELATED LIST.
					*/
					if( parentTabRecord.tabState && parentTabRecord.tabState.recordId ) {
						parentTabRecord.ttRecord.tt[ namespace + "Parent_Object_Id__c" ] = parentTabRecord.tabState.recordId;
                    }
					
					helper.pushTimeTracker( component, helper, parentTabRecord.ttRecord.tt );
                    helper.setJsonComponentState( component, helper, "v.jsonConsoleState", consoleState );
                }
            }
        }
    },
	
	/*
    	@ PURPOSE : 1. CREATES A CLOSING TIME TRACKER RECORD FROM OPENING RECORD OF
					   I. CONSOLE TAB.
					   II. QUICK ACTION.
					   III. GLOBAL ACTION.
					   IV. EDIT RECORD FROM LIST VIEW.
					2. PUSHES CLOSING TIME TRACKER TO SERVER.
					3. REMOVES THIS TAB FROM CONSOLE STATE IF TAB IS CLOSED.
					4. RESETS THE LISTVIEWSTATE, QUICKACTIONSTATE, GLOBALACTIONSTATE ATTRIBUTES OF 
					   CONSOLE STATE BASED ON CLOSED ACTIVITY.
    */
    removeAndPushTTRecord : function( component, helper, consoleState, tabId, isTabToBeRemoved ) {
        
        if( consoleState ) {
			var currentTimeStamp = ( new Date() ).getTime();
			var namespace = component.get( "v.namespace" );
			
			if( consoleState.activeState == "listOfTabs" && tabId ) {
				var tabRecord = helper.getRecordDetails( component, helper, 
														 consoleState.listOfTabs, 
														 "tabId", tabId, isTabToBeRemoved 
													   );
													   
				if( tabRecord && tabRecord.tabState ) {
					if( tabRecord.tabState.mode == "view" ) {
						if( tabRecord.reviewState &&
							tabRecord.reviewState.inactiveTimeStamps.length == ( tabRecord.reviewState.activeTimeStamps.length - 1 ) 
						) {
							/*
							IF MODE IS 'VIEW' THEN TAB MUST BE CLOSED 
							SO PUSHES INACTIVE TIME STAMP FOR REVIEW ACTION.
							*/
							tabRecord.reviewState.inactiveTimeStamps.push( currentTimeStamp );
						}
						// IF MODE IS 'VIEW' THEN TAB MUST BE CLOSED SO PUSHES REVIEW TIME TRACKER RECORD TO SERVER.
						helper.pushReviewTTRecord( component, helper, tabRecord );
					} 
					else {
						if( tabRecord.ttRecord &&
							tabRecord.ttRecord.inactiveTimeStamps.length == ( tabRecord.ttRecord.activeTimeStamps.length - 1 ) 
						) {
							// IF NEW/EDIT ACTION WAS BEING PERFORMED ON LAST TAB THEN PUSH INACTIVE TIME STAMP.
							tabRecord.ttRecord.inactiveTimeStamps.push( currentTimeStamp );
						}
						
						if( isTabToBeRemoved ) {
							// SETS MODE TO 'CANCEL' IF IT'S NOT 'VIEW' MODE AND TAB IS CLOSED.
							tabRecord.tabState.mode = "Cancel";
						}
						else {
							if( tabRecord.reviewState &&
								tabRecord.reviewState.inactiveTimeStamps.length == tabRecord.reviewState.activeTimeStamps.length
							) {
								/*
								PUSHES ACTIVE TIME STAMP TO REVIEW ACTION IF TAB IS NOT CLOSED AND 
								NEW/EDIT ACTION IS CLOSED.
								*/
								tabRecord.reviewState.activeTimeStamps.push( currentTimeStamp );
							}
						}
						var endTTRecord = helper.getEndTTRecord( component, helper, tabRecord );
						if( endTTRecord ) {
							
							// PUSHES CLOSING TIME TRACKER RECORD.
							helper.pushTimeTracker( component, helper, endTTRecord );
						}
						
						// RESETS DETAILS OF NEW/EDIT ACTIONS WHEN SUCH ACTIVITY IS CLOSED.
						if( !isTabToBeRemoved ) {
							tabRecord.ttRecord.tt = null;
							tabRecord.ttRecord.activeTimeStamps = [];
							tabRecord.ttRecord.inactiveTimeStamps = [];
							tabRecord.tabState.mode = "view";
						}
					}
				}
			}
			else {
				
				//IF EDIT ACTION IS DONE FROM LIST VIEW DIRECTLY OR IF QUICK ACTION OR GLOBAL ACTION IS DONE.
				var activeState = consoleState[ consoleState.activeState ];
				if( activeState.ttRecord &&
					activeState.ttRecord.inactiveTimeStamps.length == activeState.ttRecord.activeTimeStamps.length - 1 
				) {
					// IF EDIT ACTION WAS BEING PERFORMED ON THIS TAB THEN PUSHES INACTIVE TIME STAMP.
					activeState.ttRecord.inactiveTimeStamps.push( currentTimeStamp );
				}
                
				var endTTRecord = helper.getEndTTRecord( component, helper, activeState );
				if( endTTRecord ) {
					
					/*
					WHEN QUICK ACTION/GLOBAL ACTION CANCELS THEN POPULATES CURRENT TAB RECORD'S ID ON
					NOT ONLY PARENT RECORD ID FIELD BUT ALSO OBJECT ID FIELD
					SO THAT LOOK UP FIELDS WILL BE POPULATED.
					*/
					if( endTTRecord[ namespace + "Parent_Object_Id__c" ] && !endTTRecord[ namespace + "Object_Id__c" ] ) {
						endTTRecord[ namespace + "Object_Id__c" ] = endTTRecord[ namespace + "Parent_Object_Id__c" ];
					}
					
					// PUSHES CLOSING TIME TRACKER RECORD.
					helper.pushTimeTracker( component, helper, endTTRecord );
                    
					/*
					RESETS THE LIST VIEW STATE WHEN ACTION DONE FROM LIST VIEW DIRECTLY
					OR RESETS THE QUICK ACTION OR GLOBAL ACTION WHEN ACTION IS DONE.
					*/
                    helper.resetActionState( component, helper, activeState );
						
					var currentTabRecord = helper.getRecordDetails( component, helper, 
																	consoleState.listOfTabs, 
																	"tabId", consoleState.activeTabId, false 
																  );
					
					// IF CLOSED ACTION WAS A QUICK ACTION.
					if( consoleState.activeState == "quickActionState" ) {
						
						// RESUMES GLOBAL ACTION IF IT WAS RUNNING EARLIER.
						if( consoleState.globalActionState && consoleState.globalActionState.ttRecord &&
							consoleState.globalActionState.ttRecord.tt 
						) {
							consoleState.activeState = "globalActionState";
							helper.resumeTabTracking( component, helper, consoleState.globalActionState );
						}
						else if( consoleState.activeTabId && consoleState.listOfTabs.length > 0 ) {
							
							// CHECKS IF ANY TABS ARE OPENED AND RESUMES TRACKING OF CONSOLE TABS.
							consoleState.activeState = "listOfTabs";
							helper.resumeTabTracking( component, helper, currentTabRecord );
						}
						else {
							// OTHERWISE, STARTS TRACKING OF LIST VIEW.
							helper.handleListViewTracking( component, helper, consoleState, true );
						}
					}
					else if( consoleState.activeState == "listViewState" ) {
						// IF CLOSED ACTION WAS A LIST VIEW ACTION ( EDIT RECORD FROM LIST VIEW ).
					
						// RESUMES GLOBAL ACTION IF IT WAS RUNNING EARLIER.
						if( consoleState.globalActionState && consoleState.globalActionState.ttRecord &&
							consoleState.globalActionState.ttRecord.tt 
						) {
							consoleState.activeState = "globalActionState";
							helper.resumeTabTracking( component, helper, consoleState.globalActionState );
						}
						else if( !consoleState.listViewState.documentId ) {
							
							// OTHERWISE, RESUMES TRACKING OF LIST VIEW ACTION.
							helper.handleListViewTracking( component, helper, consoleState, true );
						}
					}
					else if( consoleState.activeState == "globalActionState" ) {
						// IF CLOSED ACTION WAS A GLOBAL ACTION.
					
						// RESUMES TRACKING OF LIST VIEW ACTION IF IT WAS RUNNING EARLIER.
						if( consoleState.listViewState && !consoleState.listViewState.documentId &&
							consoleState.listOfTabs.length == 0
						) {
							helper.handleListViewTracking( component, helper, consoleState, true );
						}
						else {
							// OTHERWISE, RESUMES TRACKING OF CONSOLE TABS.
							consoleState.activeState = "listOfTabs";
							helper.resumeTabTracking( component, helper, currentTabRecord );
							setTimeout( function() {
								// FIRES AN EVENT TO EXTENSION TO SET LISTENERS ON QUICK ACTION BUTTONS/LINKS.
								helper.dispatchEventToExtension( component, helper, 
																 "TrackQuickActionsEvent", null 
															   );
							}, 1000 );
						}
					}
				}				
			}
			
			// RESUMES TRACKING OF GLOBAL ACTION IF IT WAS RUNNING BEFORE CLOSING THE TAB.
			if( isTabToBeRemoved && consoleState.globalActionState && consoleState.globalActionState.ttRecord &&
				consoleState.globalActionState.ttRecord.tt && 
				consoleState.globalActionState.ttRecord.tt[ namespace + "Action__c" ]
			) { 
				consoleState.activeState = "globalActionState";
			}
			helper.setJsonComponentState( component, helper, "v.jsonConsoleState", consoleState );
        }
    },
    
	/*
    	@ PURPOSE : 1. FETCHES THE CLOSING REVIEW TIME TRACKER RECORD BASED ON THE TAB DETAILS.
        			2. PUSHES IT TO SALESFORCE SERVER.
    */
	pushReviewTTRecord : function( component, helper, tabRecord ) {
        
        if( tabRecord ) {
            var reviewRecord = helper.getReviewRecord( component, helper, tabRecord );
            if( reviewRecord ) {
                helper.pushTimeTracker( component, helper, reviewRecord );
            }
        }
    },
    
	/*
		@ PURPOSE : 1. CLOSES ORPHAN ACTIONS WHERE ( CANCEL BUTTON CLICK WAS NOT DETECTED ).
						I. QUICK ACTION.
						II. EDIT RECORD FROM LIST VIEW.
						III. EDIT RECORD FROM LAST TAB.
					2. WHENEVER TAB IS CREATED, SWITCHED, CLOSED THEN CHECK IF ORPHAN RECORDS ARE PRESENT AND CLOSE THEM.
	*/
	closeOrphanActions : function( component, helper, consoleState, tabId ) {
		
		if( consoleState ) {
			
			helper.closeInvalidRecord( component, helper, consoleState, consoleState.listViewState );
			helper.closeInvalidRecord( component, helper, consoleState, consoleState.quickActionState );
			
			if( tabId ) {
				var tabRecord = helper.getRecordDetails( component, helper, 
														 consoleState.listOfTabs, 
													     "tabId", tabId, false 
													   );
				helper.closeInvalidRecord( component, helper, consoleState, tabRecord );
			}
		}
	},
	
	/*
		@ PURPOSE : CLOSES ORPHAN RECORD WITH DEFAULT CLOSING ACTION IS 'CANCEL'.
	*/
	closeInvalidRecord : function( component, helper, consoleState, record ) {
		
		if( record && record.tabState && record.ttRecord ) {
			var namespace = component.get( "v.namespace" );
			if( record.ttRecord.tt && record.ttRecord.tt[ namespace + "Action__c" ] &&
				( !record.tabId || record.ttRecord.tt[ namespace + "Action__c" ].startsWith( "Edit" ) )
			) {
				helper.pauseTabTracking( component, helper, record );
				record.tabState.mode = "Cancel";
				var endTTRecord = helper.getEndTTRecord( component, helper, record );
				if( endTTRecord ) {
					
					helper.pushTimeTracker( component, helper, endTTRecord );
					helper.resetActionState( component, helper, record );
				}
			}
		}
	},
	
	/*
		@ PURPOSE : 1. UPDATES EXCLUDEREVIEWTIME FIELD WHENEVER CHATTER ACTIONS ARE PERFORMED/CLOSED.
					2. REMOVES THIS TIME FROM RECORD REVIEW TIME WHEN DETAIL PAGE TAB IS CLOSED.
	*/
	updateExcludeTime : function( component, helper, consoleState, obj ) {
		
		var namespace = component.get( "v.namespace" );
		if( consoleState && consoleState.listOfTabs && consoleState.listOfTabs.length > 0 &&
			obj && obj[ namespace + "Activity_Time__c" ] && obj[ namespace + "Opening_Activity_Time__c" ]
		) {	
			
			// MATCHES CHATTER RECORD'S PARENT ID OR OBJECT ID TO FIND THE TAB OF CONSOLE STATE.
			var recordId;
			if( obj[ namespace + "Parent_Object_Id__c" ] ) {
				recordId = obj[ namespace + "Parent_Object_Id__c" ];
			}
			else {
				recordId = obj[ namespace + "Object_Id__c" ];
			}
			
			var matchedRecordIndex = consoleState.listOfTabs.map( function( record ) {
				return record[ "tabState" ][ "recordId" ];
			}).indexOf( recordId );
			
			// ADDS THE TIME TO EXCLUDEREVIEWTIME FIELD WHENEVER CHATTER ACTIONS ARE CLOSED.		
			if( matchedRecordIndex != -1 ) {
				var matchedRecord = consoleState.listOfTabs[ matchedRecordIndex ];
				if( matchedRecord && matchedRecord.reviewState ) {
					var duration = obj[ namespace + "Activity_Time__c" ] - obj[ namespace + "Opening_Activity_Time__c" ];
					duration *= 0.001;
					matchedRecord.reviewState.excludeReviewTime += duration;
				}
			}
		}
	},
	
	/*
		@ PURPOSE : FETCHES MISCELLANEOUS SETTINGS FROM SALESFORCE AND SETS VALUES/STYLES TO DEBUG STATEMENTS.
	*/
    beautifyDebugStatements : function( component, helper ) {
    	
        var namespace = component.get( "v.namespace" );
        var loggedInUserSettings = helper.getJsonComponentState( component, helper, "v.jsonLoggedInUserSettings" );
        if( loggedInUserSettings && loggedInUserSettings[ namespace + "ClientDebugLevel__c" ] &&
            ( loggedInUserSettings[ namespace + "ClientDebugLevel__c" ].toUpperCase() == "INFO" ||
			  loggedInUserSettings[ namespace + "ClientDebugLevel__c" ].toUpperCase() == "DEBUG"
			)
        ) {
			// FETCHES OBJECT WITH DEFAULT STYLING APPLIED.
			var debugTypeToStyle = helper.getDebugTypeToStyle( component, helper );
			
			// FETCHES MISCELLANEOUS SETTINGS TO OVERRIDE THE DEFAULT STYLE OF DEBUG STATEMENTS.
			var listOfMiscellaneousSettings = helper.getJsonComponentState( component, helper, 
                                                                            "v.jsonListOfMiscellaneousSettings" 
                                                                          );
			if( listOfMiscellaneousSettings && listOfMiscellaneousSettings.length > 0 ) {
				
				for( var debugTypeAsSettingName in debugTypeToStyle ) {
					var miscellaneousSetting = helper.getRecordDetails( component, helper, 
                                                                        listOfMiscellaneousSettings, 
																		"Name", debugTypeAsSettingName,
                                                                        false
																	  );
					if( miscellaneousSetting && miscellaneousSetting[ namespace + "Code1__c" ] ) {
						debugTypeToStyle[ debugTypeAsSettingName ] = miscellaneousSetting[ namespace + "Code1__c" ];
					}
				}				
			}
			
            window.debug.info = function() {
                
                var args = Array.prototype.slice.call( arguments );
                var el = "%cLightning%c" + args.shift();
                args.unshift( el, debugTypeToStyle[ "MISCELLANEOUS_JS_ConsoleSF" ], 
                              debugTypeToStyle[ "MISCELLANEOUS_JS_ConsoleInfo" ] 
                            );
                console.info.apply( window.console, args );
            }
            
            window.debug.log = function() {
                
                var args = Array.prototype.slice.call( arguments );
                var el = "%cLightning%c" + args.shift();
                args.unshift( el, debugTypeToStyle[ "MISCELLANEOUS_JS_ConsoleSF" ], 
                              debugTypeToStyle[ "MISCELLANEOUS_JS_ConsoleLog" ] 
                            );
                console.log.apply( console, args );
            }
            
            window.debug.error = function() {
                
                var args = Array.prototype.slice.call( arguments );
                var el = "%cLightning%c" + args.shift();
                args.unshift( el, debugTypeToStyle[ "MISCELLANEOUS_JS_ConsoleSF" ], 
                              debugTypeToStyle[ "MISCELLANEOUS_JS_ConsoleError" ] 
                            );
                console.log.apply( console, args );
            }
    	}
    },
	
    /*
    	@ PURPOSE 	 : FETCHES THE OBJECT DETAILS FROM THE OBJECT NAME IN THE URL.
        @ PARAMETERS : CONSOLETAB [ CONSOLE TAB ] 
        			   A. FOR NEW RECORD - /SOBJECT/CASE/NEW?COUNT=5 ]
                       B. FOR REVIEW RECORD - /SOBJECT/5003600000OFMZQAAF/VIEW
    */
    getTabState	: function( component, helper, consoleTab ) {
    	
		var constants = JSON.parse( JSON.stringify( component.get( "v.constants" ) ) );
		if( constants ) {
			
			var tabState = { mode : null, recordId : null, objectState : null };
			if( consoleTab && consoleTab.url ) {
				
				var namespace = component.get( "v.namespace" );
				var oneAppKeywordIndex = 0;
				
				if( consoleTab.url.includes( "?") ) {
					consoleTab.url = consoleTab.url.substring( 0, consoleTab.url.indexOf( "?" ) );
				}
					
				if( !consoleTab.url.includes( "one/one.app" ) ) {
					oneAppKeywordIndex = 1;
				}
				
				var actionType = "standard";
				tabState.mode = "view"
				
				if( consoleTab.url.includes( "new" ) ) {
					
					// NEW RECORD CREATION URL.
					tabState.mode = "new";
				}
				else if( consoleTab.url.includes( "/n/" ) ) {
					
					// LIGHTNING PAGE VIEW URL.
					actionType = "lightning_page";
				}
				else if( consoleTab.url.includes( "/rlName/" ) || consoleTab.url.includes( "/related/" ) ) {
					
					// URL OF VIEW ALL RECORDS FROM RELATED LIST.
					actionType = "rlName";
				}
				else if( consoleTab.url.includes( "/home" ) ) {
					
					// HOME PAGE URL.
					actionType = "home";
				}
				else if( consoleTab.url.includes( "ContentDocument" ) ) {
					actionType = "ContentDocument";
				}
				
				var tokens = consoleTab.url.split( "/" );
				var noOfTokens = tokens.length;
				var tokenIndex = tokens.map( function( token ) {
					return token;
				}).indexOf( tabState.mode );
				
				if( ( actionType == "standard" && tokenIndex > 1 ) || 
					actionType == "ContentDocument" 
				) {
					var attributeName, attributeValue;
					
					if( actionType == "standard" && 
						( tokens[ tokenIndex - 2 ] == "sObject" || tokens[ tokenIndex - 2 ] == "o" || 
						  oneAppKeywordIndex > 0 
						) 
					) {
						if( tabState.mode == "new" ) {
							attributeName = "objectName";
							attributeValue = tokens[ tokenIndex - 1 ];                        
						} 
						else if( tabState.mode == "view" ) {
							attributeName = "objectKeyPrefix";
							attributeValue = tokens[ tokenIndex - 1 ].substring( 0, 3 );
							tabState.recordId = tokens[ tokenIndex - 1 ];
						}
					}
					else if( actionType == "ContentDocument" ) {
						attributeName = "objectName";
						attributeValue = tokens[ noOfTokens - oneAppKeywordIndex - 2 ];
						tabState.recordId = tokens[ noOfTokens - oneAppKeywordIndex - 1 ];
					}
					
					var listOfObjectWrappers = helper.getJsonComponentState( component, helper, 
																			 "v.jsonListOfObjectWrappers" 
																		   );
					tabState.objectState = helper.getRecordDetails( component, 
																	helper, 
																	listOfObjectWrappers,
																	attributeName, 
																	attributeValue,
																	false
																   );
					if( !tabState.objectState ) {
						debug.error( constants.ERR_Object_Details_Not_Found );
					}
				}
				else {
					var listOfStrategySettings = helper.getJsonComponentState( component, helper, 
																			   "v.jsonListOfStrategySettings" 
																			 );
					if( listOfStrategySettings && listOfStrategySettings.length > 0 ) {
						var actionTitle = "";
						
						if( actionType == "lightning_page" && noOfTokens >= 1 ) {
							actionTitle = tokens[ noOfTokens - 1 ];
						}
						else if( actionType == "home" ) {
							actionTitle = "home";
						}
						else if( actionType == "rlName" && noOfTokens >= 4 ) {
							tabState.recordId = tokens[ noOfTokens - 4 ];
							actionTitle = tokens[ noOfTokens - 2 ];
						}
						else if( consoleTab.icon && consoleTab.icon.endsWith( ":search" ) && consoleTab.title &&
								 consoleTab.title.includes( "- Search" ) 
						) {
							actionTitle = "Global Search";
						}
						else {
							actionTitle = consoleTab.title;
						}
						
						var strategyRecord = helper.getRecordDetails( component, helper, 
																	  listOfStrategySettings, 
																	  namespace + "Text4__c", actionTitle 
																	);
						if( strategyRecord ) {
							tabState.objectState = { objectName : actionTitle, 
													 objectLabelPlural : strategyRecord[ namespace + "Text1__c" ],
													 objectLabel : strategyRecord[ namespace + "Text1__c" ], 
													 objectKeyPrefix : null
												   };
						}
						else {
							debug.error( constants.ERR_Setting_Missing_For_An_Activity + " => " + actionTitle );
						}
					}
					else {
						debug.error( constants.ERR_Strategy_Settings_Missing );
					}
				}
			}
		}
		return tabState;
    },
    
	/*
		@ PURPOSE : FETCHES SALESFORCE RECORD ID OF PARENT/PRIMARY CONSOLE TAB USING CHILD/SECONDARY CONSOLE TAB.
	*/
	getParentTabRecordId : function( component, helper, tabRecord ) {
		
		var parentTabRecordId = null;
		
		// CHECKS IF THIS IS A SUB TAB.
		if( tabRecord && tabRecord.tabState && 
			tabRecord.tabState.consoleTab && tabRecord.tabState.consoleTab.parentTabId 
		) {
			var consoleState = helper.getJsonComponentState( component, helper, "v.jsonConsoleState" );                
			if( consoleState ) {
				
				// FETCHES PARENT TAB'S RECORD FROM CONSOLE STATE.
				var parentTabRecord = helper.getRecordDetails
											 ( component, helper, consoleState.listOfTabs, 
											   "tabId", tabRecord.tabState.consoleTab.parentTabId
											 );
				if( parentTabRecord && parentTabRecord.tabState && parentTabRecord.tabState.recordId ) {
					 parentTabRecordId = parentTabRecord.tabState.recordId;
				}
				else {
					/*
					IT IS POSSIBLE THAT PARENT TAB IS NOT ADDED TO CONSOLE STATE YET 
					( WHEN SUB TAB IS OPENED DIRECTLY ).
					FETCHES PARENT TAB'S RECORD ID FROM CHROME TAB'S URL ITSELF.
					*/
					var tabState = helper.getTabState( component, helper, { url : window.location.href } );
					if( tabState ) {
						parentTabRecordId = tabState.recordId;
					}
				}
			}
		}
		return parentTabRecordId;
	},
	
    /*
    	@ PURPOSE : FETCHES AN OPENING TIME TRACKER RECORD BASED ON THE TAB DETAILS.
    */
	getStartTTRecord : function( component, helper, tabRecord ) {
        
        var startTTRecord;
		var constants = JSON.parse( JSON.stringify( component.get( "v.constants" ) ) );
		if( constants ) {
			
			if( tabRecord && tabRecord.tabState ) {
				var actionName = helper.getActionNameFromTabDetails( component, helper, tabRecord.tabState );
				if( actionName ) {
					var currentTimeStamp = ( new Date() ).getTime();
					var namespace = component.get( "v.namespace" );
					startTTRecord = {};
					
					startTTRecord[ namespace + "Activity_Time__c" ] = currentTimeStamp;
					startTTRecord[ namespace + "DocumentId__c" ] = helper.getDocumentId( component, helper );
					startTTRecord[ namespace + "Action__c" ] = actionName;
					startTTRecord[ namespace + "Source__c" ] = "Lightning Component";
					startTTRecord[ namespace + "Object_Name__c" ] = tabRecord.tabState.objectState.objectName;
					startTTRecord[ namespace + "Parent_Object_Id__c" ] = helper.getParentTabRecordId
																				( component, helper, 
																				  tabRecord 
																				);
					
					if( !actionName.toLowerCase().startsWith( "new" ) ) {
						startTTRecord[ namespace + "Object_Id__c" ] = tabRecord.tabState.recordId;
					}
				}
				else {
					debug.error( constants.ERR_Action_Name_Missing );
				}
			}
			else {
				debug.error( constants.ERR_Tab_Details_Missing + " ", tabRecord );
			}
		}
		return startTTRecord;
    },
				
    /*
    	@ PURPOSE : FETCHES THE REVIEW ( CLOSING ) TIME TRACKER RECORD BASED ON ITS TIME STAMPS AND TAB DETAILS.
    */
	getReviewRecord : function( component, helper, tabRecord ) {
        
        var reviewRecord;
        if( tabRecord && tabRecord.tabState ) {
            var actionName = helper.getActionNameFromTabDetails( component, helper, tabRecord.tabState );
            if( actionName ) {
                
                if( tabRecord.reviewState ) {
                    if( tabRecord.reviewState.activeTimeStamps && 
                        tabRecord.reviewState.activeTimeStamps.length > 0 
                    ) {
						var duration = helper.getDuration
											  ( 
											   component, helper, 
											   tabRecord.reviewState.activeTimeStamps, 
											   tabRecord.reviewState.inactiveTimeStamps 
											  );
											  
						if( duration && tabRecord.reviewState.excludeReviewTime > 0 ) {
							duration -= tabRecord.reviewState.excludeReviewTime;
						}
						
						if( duration && duration >= 1 ) {
							var namespace = component.get( "v.namespace" );
							reviewRecord = {};
							reviewRecord[ namespace + "Action_Closed__c" ] = true;
							reviewRecord[ namespace + "Action__c" ] = actionName;
							reviewRecord[ namespace + "Duration__c" ] = duration;
							reviewRecord[ namespace + "Opening_Action__c" ] = actionName;
							reviewRecord[ namespace + "Object_Id__c" ] = tabRecord.tabState.recordId;
							reviewRecord[ namespace + "Source__c" ] = "Lightning Component";
							
							reviewRecord[ namespace + "Parent_Object_Id__c" ] = helper.getParentTabRecordId
																					   ( component, helper, 
																						 tabRecord 
																					   );
																					   
							reviewRecord[ namespace + "Activity_Time__c" ] = tabRecord.reviewState.inactiveTimeStamps[ tabRecord.reviewState.inactiveTimeStamps.length - 1 ];
                        }
                    }
                }
            }
        }
		return reviewRecord;
    },
	
    /*
    	@ PURPOSE : CREATES THE CLOSING TIME TRACKER RECORD BASED ON THE OPENING 
        			TIME TRACKER RECORD OF CURRENT TAB.
    */
    getEndTTRecord : function( component, helper, tabRecord ) {
        
        var endTTRecord;
        var namespace = component.get( "v.namespace" );
        if( tabRecord && tabRecord.ttRecord && 
            tabRecord.ttRecord.tt && tabRecord.ttRecord.tt[ namespace + "Action__c" ]
          ) {
            
			var listOfObjectWrappers = helper.getJsonComponentState( component, helper, 
																	 "v.jsonListOfObjectWrappers" 
																   );	   
            var currentTimeStamp = ( new Date() ).getTime();
        
            endTTRecord = {};
            endTTRecord[ namespace + "Opening_Activity_Time__c" ] = tabRecord.ttRecord.tt[ namespace + "Activity_Time__c" ];
            endTTRecord[ namespace + "DocumentId__c" ] = tabRecord.ttRecord.tt[ namespace + "DocumentId__c" ];
            endTTRecord[ namespace + "Opening_Action__c" ] = tabRecord.ttRecord.tt[ namespace + "Action__c" ];
            endTTRecord[ namespace + "Parent_Object_Id__c" ] = tabRecord.ttRecord.tt[ namespace + "Parent_Object_Id__c" ];
			
			/*
			EITHER IT'S SOME ACTION OF CHILD RECORD OR REVIEW ACTION OF A PARENT RECORD ( TAB RECORD )
            SO VERIFY HERE.
			*/
            if( tabRecord.ttRecord.tt[ namespace + "Object_Id__c" ] ) {
                
                // SETS ACTION NAME AND OBJECT ID OF END TIME TRACKER ACCORDING TO ITS OPENING TIME TRACKER RECORD. 
                endTTRecord[ namespace + "Object_Id__c" ] = tabRecord.ttRecord.tt[ namespace + "Object_Id__c" ];
				var tabState = { mode : tabRecord.tabState.mode, objectState : {} };
				var listOfObjectWrappers = helper.getJsonComponentState( component, helper, 
                                                                         "v.jsonListOfObjectWrappers" 
                                                                       ); 
                tabState.objectState = helper.getRecordDetails
                							  ( component, 
                                                helper, 
                                                listOfObjectWrappers,
                                                "objectKeyPrefix", 
                                                tabRecord.ttRecord.tt[ namespace + "Object_Id__c" ].substring( 0, 3 ),
                                                false
                                              );
				endTTRecord[ namespace + "Action__c" ] = helper.getActionNameFromTabDetails( component, helper, 
                                                                                             tabState
                                                                                           );
            }
            else {
				if( tabRecord.ttRecord.tt[ namespace + "Object_Name__c" ] == tabRecord.tabState.objectState.objectName ) {
					endTTRecord[ namespace + "Object_Id__c" ] = tabRecord.tabState.recordId;
					endTTRecord[ namespace + "Action__c" ] = helper.getActionNameFromTabDetails( component, helper, 
                                                                                                 tabRecord.tabState 
                                                                                               );
				}
				else {
					// CANCEL ACTIVITY OF NEW RECORD WHICH WAS LAUNCHED FROM QUICK ACTION.
					var quickActionObjectTabState = JSON.parse( JSON.stringify( tabRecord.tabState ) );
					quickActionObjectTabState.objectState = helper.getRecordDetails
                                                            ( component, 
                                                             helper, 
                                                             listOfObjectWrappers,
                                                             "objectName", 
                                                             tabRecord.ttRecord.tt[ namespace + "Object_Name__c" ],
                                                             false
                                                            );
					endTTRecord[ namespace + "Action__c" ] = helper.getActionNameFromTabDetails
                    												( 
                        											 component, helper, quickActionObjectTabState 
                    												);
					endTTRecord[ namespace + "Parent_Object_Id__c" ] = tabRecord.tabState.recordId;
				}
            }
            
            endTTRecord[ namespace + "Source__c" ] = "Lightning Component";
            endTTRecord[ namespace + "Duration__c" ] = helper.getDuration
            										   ( 
                 										component, helper, 
                                                        tabRecord.ttRecord.activeTimeStamps, 
                                                        tabRecord.ttRecord.inactiveTimeStamps 
                                                       );
            if( endTTRecord[ namespace + "Duration__c" ] ) {
                endTTRecord[ namespace + "Activity_Time__c" ] = ( endTTRecord[ namespace + "Duration__c" ] * 1000 ) + 
                    											endTTRecord[ namespace + "Opening_Activity_Time__c" ];
        	}
        }
		return endTTRecord;
    },
    
    /*
    	@ PURPOSE : 1. FETCHES THE RECORD FROM AN ARRAY USING THE ATTRIBUTE OF THE RECORD AND ITS VALUE.
        			2. IF removeRecord IS TRUE, THEN REMOVES THE MATCHED ELEMENT FROM ARRAY.
    */
    getRecordDetails : function( component, helper, listOfRecords, attributeName, attributeValue, removeRecord ) {
        
        var matchedRecord;
        if( listOfRecords && listOfRecords.length > 0 ) {
            
            var matchedRecordIndex = listOfRecords.map( function( record ) {
                if( attributeName ) {
                    return record[ attributeName ];
                }
                else {
                    // COMPARES THE RECORD ITSELF WITH IF ARRAY IS NOT OF OBJECTS BUT STRINGS.
                    return record;
                }
            }).indexOf( attributeValue );
                    
            if( matchedRecordIndex != -1 ) {
                matchedRecord = listOfRecords[ matchedRecordIndex ];
                if( removeRecord ) {
                    listOfRecords.splice( matchedRecordIndex, 1 );
                }
            }
        }
        return matchedRecord;
    },
    
    /*
    	@ PURPOSE : FETCHES AN ACTION NAME FROM OBJECT DETAILS AND TAB'S MODE.
    */
    getActionNameFromTabDetails : function( component, helper, tabState ) {
        
        var actionName = "";
        if( tabState && tabState.objectState && tabState.mode ) {
			var tabMode = tabState.mode.toLowerCase();
            if( tabMode == "new" ) {
                actionName = "New " + tabState.objectState.objectLabel;
            }
            else if( tabMode == "edit" ) {
                actionName = "Edit " + tabState.objectState.objectLabel;
            }
            else if( tabMode == "cancel" ) {
                actionName = tabState.objectState.objectLabel + " Cancel";
            }
            else if( tabMode == "save" ) {
                actionName = tabState.objectState.objectLabel + " Save";
            }
            else if( tabMode == "view" ) {
                actionName = tabState.objectState.objectLabel;
                if( tabState.objectState.objectKeyPrefix ) {
                    actionName += " Review";
                }
            }
			else if( tabMode == "quickactionstate" || tabMode == "globalactionstate"  ) { 
				if( tabState.objectState.objectName ) {
					actionName = "New ";
				}
				actionName += tabState.objectState.objectLabel;
			}
        }
        return actionName;
    },
    
    /*
    	@ PURPOSE : FETCHES A RANDOM STRING ( 32 CHARACTERS ).
    */
    getDocumentId : function( component, helper ) {
        
        var d = ( new Date() ).getTime();
        var uuid = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, function(c) {
            var r = ( d + Math.random()*16 ) %16 | 0;
            d = Math.floor( d/16);
            return ( c == "x" ? r : ( r&0x3|0x8 ) ).toString( 16 );
        });
    	return uuid;
    },
    
    /*
    	@ PURPOSE : FETCHES THE PARSED VALUE OF THE COMPONENT USING NAME OF THE COMPONENT'S ATTRIBUTE.
    */
    getJsonComponentState : function( component, helper, attributeName ) {
        
        var componentState, jsonComponentState = component.get( attributeName );
        //console.log(':: componentState::'+ componentState);
        if( jsonComponentState ) {
            componentState = JSON.parse( jsonComponentState );
        }
        return componentState;
    },
    
    /*
    	@ PURPOSE : CALCULATES THE TIME DURATION FROM ACTIVETIMESTAMPS AND INACTIVETIMESTAMPS ARRAYS.
    */
    getDuration : function( component, helper, activeTimeStamps, inactiveTimeStamps ) {
        
        var duration = 0;
        if( activeTimeStamps && inactiveTimeStamps && 
            activeTimeStamps.length > 0 && activeTimeStamps.length == inactiveTimeStamps.length ) {
            
            activeTimeStamps.map( ( startTime, index ) => {
                var endTime = inactiveTimeStamps[ index ];
            	duration += ( endTime - startTime );
        	});
            duration *= 0.001;
        }
        return duration;
    },
    
	/*
		@ PURPOSE : SETS DEFAULT VALUES TO DEBUG STATEMENTS SUCH LOG, INFO, ERROR, ETC.
	*/
	getDebugTypeToStyle : function( component, helper ) {
		
		var debugTypeToStyle = new Object();
        var genericStyle = "color:#FFF;padding:5px;border-radius: 5px;line-height: 20px;";
		debugTypeToStyle[ "MISCELLANEOUS_JS_ConsoleLog" ] = "background: #4ab471;" + genericStyle;
		debugTypeToStyle[ "MISCELLANEOUS_JS_ConsoleInfo" ] = "background: #3F51B5;" + genericStyle;
		debugTypeToStyle[ "MISCELLANEOUS_JS_ConsoleError" ] = "background: #970e02;" + genericStyle;
		debugTypeToStyle[ "MISCELLANEOUS_JS_ConsoleSF" ] = "background: #fcad02;" + genericStyle;
		return debugTypeToStyle;
	},
	
	/*
    	@ PURPOSE : 1. COMPARES THE VALUE OF GIVEN FIELDAPINAME IN STRATEGY SETTINGS WITH GIVEN FIELD VALUE.
        			2. RETURNS THE SETTING RECORD IF VALUE IS MATCHED, OTHERWISE NULL.
    */
    getStrategySetting : function( component, helper, fieldApiName, fieldValue ) {
        
        var matchedStrategySetting = null;
        if( fieldApiName && fieldValue ) {
            
			var listOfStrategySettings = helper.getJsonComponentState( component, helper, 
																	   "v.jsonListOfStrategySettings" 
																     );
			if( listOfStrategySettings && listOfStrategySettings.length > 0 ) {
				
				var strategySettingIndex = listOfStrategySettings.map( function( strategySetting ) {
				   if( strategySetting[ fieldApiName ] ) {
					   return strategySetting[ fieldApiName ].toLowerCase().trim();
				   } 
				}).indexOf( fieldValue.toLowerCase().trim() );
				if( strategySettingIndex != -1 ) {
					matchedStrategySetting = listOfStrategySettings[ strategySettingIndex ];
				}
			}
        }
        return matchedStrategySetting;
    },
	
    /*
    	@ PURPOSE : SETS THE ATTRIBUTE OF THE COMPONENT WITH JSON OF ITS PROVIDED VALUE.
    */
    setJsonComponentState : function( component, helper, attributeName, attributeValue ) {
        
        if( attributeValue ) {
            component.set( attributeName, JSON.stringify( attributeValue ) );
        }
    },
    
    /*
    	@ PURPOSE : RESETS THE TRACKING OF ALL TABS AND RE-INITIALIZES CONSOLE STATE.
    */
	resetConsoleState : function( component, helper ) {
        
        var consoleState = { "activeTabId" : null, 
                             "lastActiveTabId" : null, 
							 "activeState" : "listOfTabs",
                             "listViewState" : { 
												 documentId : null,
												 tabState : { mode : null, recordId : null, objectState : {} }, 
												 ttRecord : { tt : null, activeTimeStamps : [], 
                                                              inactiveTimeStamps : [] 
                                                            }
											   }, 
							 "quickActionState" : { 
												   tabState : { mode : null, recordId : null, objectState : {} }, 
												   ttRecord : { tt : null, activeTimeStamps : [], 
                                                                inactiveTimeStamps : [] 
                                                              }
											      },
							 "globalActionState" : { 
												    tabState : { mode : null, recordId : null, objectState : {} }, 
												    ttRecord : { tt : null, activeTimeStamps : [], 
                                                                 inactiveTimeStamps : [] 
                                                               }
											       },
							 "listOfTabs" : [],
							 "extRecord" : { 
											 tabState : { mode : null, recordId : null, objectState : {} }, 
											 ttRecord : { tt : null, activeTimeStamps : [], 
														  inactiveTimeStamps : [] 
														}
										   },
							 "chatterRecord" : { 
											tabState : { mode : null, recordId : null, objectState : {} }, 
											ttRecord : { tt : null, activeTimeStamps : [], 
											inactiveTimeStamps : [] 
										   }
							 }
                           };
        helper.setJsonComponentState( component, helper, "v.jsonConsoleState", consoleState );
    },
	
	/*
		@ PURPOSE : RESETS THE VALUES OF ACTIVE STATE OF THE CONSOLE STATE IF 
					STRATEGY SETTING IS MISSING FOR THE ACTION FIRED BY LIST VIEW ACTION/QUICK ACTION/GLOBAL ACTION.
	*/
	resetActiveState : function( component, helper ) {
		
		var consoleState = helper.getJsonComponentState( component, helper, "v.jsonConsoleState" );
		if( consoleState ) {
			
			var activeState;
			var namespace = component.get( "v.namespace" );
			
			// OPENING QUICK ACTION WAS NOT FOUND IN STRATEGY SETTING.
			if( consoleState.activeState = "quickActionState" ) {
				activeState = consoleState[ "quickActionState" ];
				
				// RESUMES GLOBAL ACTION AND REVERT THE ACTIVE STATE IF GLOBAL ACTION WAS RUNNING EARLIER.
				if( consoleState.globalActionState && consoleState.globalActionState.ttRecord &&
					consoleState.globalActionState.ttRecord.tt && 
					consoleState.globalActionState.ttRecord.tt[ namespace + "Action__c" ] 
				) {
					consoleState.activeState = "globalActionState";
					helper.resumeTabTracking( component, helper, consoleState.globalActionState );
				}
			}
			else if( consoleState.activeState = "listViewState" ) {
				activeState = consoleState[ "listViewState" ];
			}
			
			// RESETS THE SET FOR WHICH SETTING WAS NOT FOUND OR TIME TRACKER WAS NOT PUSHED.
			helper.resetActionState( component, helper, activeState );
			helper.setJsonComponentState( component, helper, "v.jsonConsoleState", consoleState );
		}
	},
	
	/*
		@ PURPOSE : RESETS THE VALUES OF STATE OF THE CONSOLE STATE.
	*/
	resetActionState : function( component, helper, objState ) {
		
		if( objState && objState.tabState && objState.ttRecord ) {
			objState.tabState.mode = null;
			objState.tabState.recordId = null; 
			objState.tabState.objectState = null;
			
			objState.ttRecord.tt = null;
			objState.ttRecord.activeTimeStamps = [];
			objState.ttRecord.inactiveTimeStamps = [];
		}
	},
    
    /******************************* ACTIONS INVOKED BY/FOR CHROME EXTENSION *******************************/
    
	/*
		@ PURPOSE : FIRES AN EVENT TO CHROME EXTENSION REGARDING START AND STOP TRACKING OF LIST VIEW ACTION.
	*/
    handleListViewTracking : function( component, helper, consoleState, startTracking ) {        
        
        var eventMessage;
		if( consoleState ) {
			
			// STARTS TRACKING.
			if( startTracking ) {
				
				// CHECKS IF NOT STARTED BY NOW.
				if( !consoleState.listViewState.documentId ) {
					eventMessage = "ListViewTracking";
					consoleState.activeState = "listViewState";
					consoleState.listViewState.documentId = helper.getDocumentId( component, helper );
					helper.setJsonComponentState( component, helper, "v.jsonConsoleState", consoleState );
				}
			}
			else {
				// CHECKS IF STARTED BY NOW.
				if( consoleState.listViewState.documentId ) {
					eventMessage = "EndListViewTracking";
					consoleState.listViewState.documentId = null;
					helper.setJsonComponentState( component, helper, "v.jsonConsoleState", consoleState );
				}
			}
			
			if( eventMessage ) {
				helper.dispatchEventToExtension( component, helper, eventMessage, null );
			}
		}
    },
    
    /*
    	@ PURPOSE : DISPATCHES AN EVENT TO AN EXTENSION WHENEVER 'EDIT' BUTTON IS CLICKED 
					SO THAT A LISTENER ON 'CANCEL' BUTTON WILL BE SET BY CHROME EXTENSION.
    */
    dispatchEventToExtension : function( component, helper, eventType, action ) {
        
        if( eventType ) {
            setTimeout( function() {
                var sobjEvent = new CustomEvent( eventType, 
                                                 { 
                                                  detail : { mode : action }
                                                 }
                                               );
                document.dispatchEvent( sobjEvent );
            }, 2000 );
        }
    },
    
    /*
    	@ PURPOSE : RECEIVES MESSAGES/EVENTS FROM CHROME EXTENSION.
    */
    receiveMessagesFromExtension : function( component, helper ) {    
        	
        window.addEventListener( "message", function( windowEvent ) {
            if( windowEvent.data ) {
				
				var extensionResponse = JSON.parse( JSON.stringify( windowEvent.data ) );
                var namespace = component.get( "v.namespace" );
				
				if( extensionResponse.obj && extensionResponse.type ) {
					var consoleState = helper.getJsonComponentState( component, helper, "v.jsonConsoleState" );
					if( consoleState && consoleState[ extensionResponse.type ] && consoleState[ extensionResponse.type ].ttRecord ) {
						
						if( extensionResponse.actionClosed ) {
							var startTTRecord = consoleState[ extensionResponse.type ].ttRecord.tt;
							if( startTTRecord ) {
								
								extensionResponse.obj[ namespace + "DocumentId__c" ] = startTTRecord[ namespace + "DocumentId__c" ];
								extensionResponse.obj[ namespace + "Opening_Activity_Time__c" ] = startTTRecord[ namespace + "Activity_Time__c" ];
								
								if( extensionResponse.type == "chatterRecord" ) {
									helper.updateExcludeTime( component, helper, consoleState, extensionResponse.obj );
								}
								
								helper.pushTimeTracker( component, helper, extensionResponse.obj );
								helper.resetActionState( component, helper, consoleState[ extensionResponse.type ] );
							}
						}
						else {
							consoleState[ extensionResponse.type ].ttRecord.tt = extensionResponse.obj;
							helper.pushTimeTracker( component, helper, extensionResponse.obj );
						}
						helper.setJsonComponentState( component, helper, "v.jsonConsoleState", consoleState );
					}
				}
				else if( extensionResponse.closingAction ) {
					
					var consoleState = helper.getJsonComponentState( component, helper, "v.jsonConsoleState" );
					if( extensionResponse.closingAction.toLowerCase() == "escape" ) {
					
						// ESCAPE KEY CLICK DOESN'T CLOSE GLOBAL ACTION MODAL.
						if( consoleState && consoleState.activeState != "globalActionState" ) {
							helper.handleShowToast( component, helper, "success", "Cancel", null );
						}
					} 	
                    else {
                        if( consoleState && consoleState.activeState == "quickActionState" &&
							consoleState.quickActionState && consoleState.quickActionState.ttRecord &&
							consoleState.quickActionState.ttRecord.tt
						) {
							if( consoleState.quickActionState.ttRecord.tt[ namespace + "Action__c" ] &&
								consoleState.quickActionState.ttRecord.tt[ namespace + "Action__c" ].toLowerCase() == "upload files"
							) {
								extensionResponse.closingAction = "Save";
							}
						}
						setTimeout( function() {
							// CATCHES AN EVENT AS SOON AS CANCEL BUTTON CLICKED WHEN RECORD WAS EDITED.
							helper.handleShowToast( component, helper, "success", extensionResponse.closingAction, null );
						}, 1000 );
					}
				}	
                else if( extensionResponse.mode && extensionResponse.activeState ) {
					
					/*
					CHECKS IF THIS IS A CLONE ACTION THEN POPULATE CURRENT TAB'S OBJECTS LABEL 
					CONSIDERS IT AS NEW OBJECT RECORD CREATION.
					*/
					if( extensionResponse.actionName && extensionResponse.actionName.toLowerCase() == "clone" ) {
						var consoleState = helper.getJsonComponentState( component, helper, "v.jsonConsoleState" );
						if( consoleState ) {
							
							// FETCHES CURRENT TAB'S RECORD DETAILS.
							var currentTabRecord = helper.getRecordDetails( component, helper, 
																			consoleState.listOfTabs, "tabId", 
																			consoleState.activeTabId, false 
																		  );
							if( currentTabRecord && currentTabRecord.tabState && 
								currentTabRecord.tabState.objectState && 
								currentTabRecord.tabState.objectState.objectLabel
							) {
								extensionResponse.actionName = "";
								extensionResponse.mode = "New";
								extensionResponse.objectLabel = currentTabRecord.tabState.objectState.objectLabel;
							}
						}
					}
                    
					// HANDLES QUICK OR GLOBAL ACTION.
					helper.handleQuickOrGlobalAction( component, helper, extensionResponse );
                }
            }
        }, false);
    },
	
	/******************************* SERVER SIDE ACTIONS *******************************/
    
    /*
    	@ PURPOSE : FETCHES THE DETAILS OF THE SOBJECTS' LABEL, API NAME, PREFIX, PLURAL LABEL.
    */
    fetchAndSetObjectDetails : function( component, helper ) {
        
        var serverAction = component.get( "c.getObjectDetailsAndCustomSettings" );
        serverAction.setCallback( self, function( response ) {            
            
            var state = response.getState();
            if( state == "SUCCESS" ) {
                
                var jsonTimeTrackerWrapper = response.getReturnValue();
               // console.log('jsonTimeTrackerWrapper'+ jsonTimeTrackerWrapper);
                if( jsonTimeTrackerWrapper ) {
                    
                    var timeTrackerWrapper = JSON.parse( jsonTimeTrackerWrapper );
                    if( timeTrackerWrapper ) {
                        
                        if( timeTrackerWrapper.strNamespace ) {
                            component.set( "v.namespace", timeTrackerWrapper.strNamespace );
                        }
                        else {
                        	debug.info( "Namespace prefix is not available in this org." );    
                        }
                        
						var constants = timeTrackerWrapper.labelApiNameToValue;
						component.set( "v.constants", constants );
					
                        if( timeTrackerWrapper.listOfObjectWrappers && 
                            timeTrackerWrapper.listOfObjectWrappers.length > 0 &&
                        	timeTrackerWrapper.listOfStrategySettings && 
                            timeTrackerWrapper.listOfStrategySettings.length > 0
                        ) {
							// SETS THE LIST OF OBJECT WRAPPERS.
                            component.set( "v.jsonListOfObjectWrappers", 
                                           JSON.stringify( timeTrackerWrapper.listOfObjectWrappers ) 
                                         );
										 
							// SETS THE LIST OF STRATEGY SETTINGS.
                            component.set( "v.jsonListOfStrategySettings", 
                                            JSON.stringify( timeTrackerWrapper.listOfStrategySettings ) 
                                         );
										 
							// SETS THE LIST OF MISCELLANEOUS SETTINGS.
							component.set( "v.jsonListOfMiscellaneousSettings", 
										   JSON.stringify( timeTrackerWrapper.listOfMiscellaneousSettings ) 
										 );
										 
							// SETS THE LOGGED-IN-USER SETTINGS.
                            component.set( "v.jsonLoggedInUserSettings", 
                                            JSON.stringify( timeTrackerWrapper.loggedInUserSettings ) 
                                         );
							
							// SENDS USER SETTINGS AND NAMESPACE DETAILS TO EXTENSION.
							var configSettings = { Namespace : timeTrackerWrapper.strNamespace, UserSettings : timeTrackerWrapper.loggedInUserSettings };
							helper.dispatchEventToExtension( component, helper, "PostingSettings", JSON.stringify( configSettings ) );
							
							// PROCESSES CONSOLE TABS
                            helper.handleExistingTabs( component, helper, true );
							
							// BEAUTIFIES ( CSS ) DEBUG STATEMENTS.
                            helper.beautifyDebugStatements( component, helper );
                        }
                        else {
                            debug.error( constants.ERR_Object_Details_Or_Settings_Missing );
                        }
                    }
                    else {
                        debug.error( "Sorry, an unknown error occurred while parsing details." +
                                     "Please Contact System Administrator." );
                    }
                }
                else {
                    debug.error( "Sorry, No details were found. Please Contact System Administrator." );
                }
            }
            else {
               debug.error( "Sorry, an unexpected error occurred while fetching details. " +
                             "Please Contact System Administrator." );
            }
        });
        $A.enqueueAction( serverAction );
    },
	
    /*
    	@ PURPOSE : SENDS JSON OF A TIME TRACKER RECORD TO SALESFORCE SERVER TO CREATE ONE.
    */
    pushTimeTracker : function( component, helper, ttRecord ) {
        
		var constants = JSON.parse( JSON.stringify( component.get( "v.constants" ) ) );
		if( constants ) {
			
			if( ttRecord ) {
				
				var namespace = component.get( "v.namespace" );
				var actionName = ttRecord[ namespace + "Action__c" ];
				
				if( ttRecord[ namespace + "Opening_Action__c" ] ) {
					actionName = ttRecord[ namespace + "Opening_Action__c" ];
					
					// ENSURES MAXIMUM TRACKING TIME FOR AN ACTION IS NOT ELAPSED.
					var loggedInUserSettings = helper.getJsonComponentState( component, helper, 
																			 "v.jsonLoggedInUserSettings" 
																		   );
					if( loggedInUserSettings ) {
						var maximumTrackingTime =  loggedInUserSettings[ namespace + "Max_Duration_In_Minutes__c" ];
						if( Number.isInteger( maximumTrackingTime ) && maximumTrackingTime > 0 ) {
							maximumTrackingTime *= 60;
							if( ttRecord[ namespace + "Duration__c" ] > maximumTrackingTime ) {
								ttRecord[ namespace + "Duration__c" ] = maximumTrackingTime;
							}
						}
					}				
				}
				
				/*
				VALUE OF 'ACTION__C' FIELD OF OPENING TIME TRACKER & 'OPENING_ACTION__C' FIELD OF CLOSING TIME TRACKER
				MUST BE PRESENT IN TEXT1__C FIELD OF TIME TRACKER CONFIG SETTINGS OF TYPE 'STRATEGY'.
				*/
				var strategySetting = helper.getStrategySetting
											 ( 
											  component, helper, 
											  namespace + "Text1__c", actionName
											 );
				if( strategySetting ) {
					debug.log( "PUSHING - " + ttRecord[ namespace + "Action__c" ], ttRecord );
					var serverAction = component.get( "c.insertTimeTracker" );
					serverAction.setParams({
											"strJsonTimeTracker" : JSON.stringify( ttRecord )
										  });
					serverAction.setCallback( self, function( response ) {            
						
						var state = response.getState();
						if( state == "SUCCESS" ) {
							var status = response.getReturnValue();
						}
						else {
							debug.error( constants.ERR_Save_Time_Tracker_Record );
						}
					});
					$A.enqueueAction( serverAction );
				}
				else {
					debug.error( constants.ERR_Not_Pushing + " - " + ttRecord[ namespace + "Action__c" ] );
					helper.resetActiveState( component, helper );
				}
			}
		}
    }
})