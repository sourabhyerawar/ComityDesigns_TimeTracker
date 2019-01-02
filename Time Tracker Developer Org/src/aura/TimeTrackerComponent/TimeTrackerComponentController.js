/*
  	@ PURPOSE : CONTROLS THE LIGHTNING COMPONENt --> TimeTrackerComponent.cmp
	@ NAME 	  : TimeTrackerComponentController.js
*/
({
    /*
		@ PURPOSE : INITIALIZES COMPONENT ATTRIBUTES WHEN COMPONENT IS LOADED.
    */
	initializeFooterComponent : function( component, event, helper ) {
        
		helper.initializeFooterComponent( component, helper );
    },
    
	/*
		@ PURPOSE : HANDLES THE NEW TAB FOR TRACKING WHEN IT IS OPENED.
    */
    handleTabCreated : function( component, event, helper ) {
        
		// PROVIDES SOME DELAY SINCE WORKSPACE API RETURNS PARTIAL RESULTS OF THE TAB WHEN API IS INVOKED AT ONCE.
		setTimeout( 
			function() {
				helper.handleTabCreated( component, helper );
			},1000
		);
    },
    
	/*
		@ PURPOSE : HANDLES THE EXISTING/NEW TAB FOR TRACKING WHEN IT IS FOCUSED/SWITCHED/OPENED.
    */
    handleTabFocused : function( component, event, helper ) {
		
		// PROVIDES SOME DELAY SINCE WORKSPACE API RETURNS PARTIAL RESULTS OF THE TAB WHEN API IS INVOKED AT ONCE.
        setTimeout( 
			function() {
                
                var consoleState = helper.getJsonComponentState( component, helper, "v.jsonConsoleState" );
				var currentTabId = event.getParam( "currentTabId" );
				helper.handleTabFocused( component, helper, currentTabId );
				var namespace = component.get( "v.namespace" );
				
				// CHECKS IF GLOBAL ACTION IS NOT RUNNING
				if( consoleState.globalActionState && consoleState.globalActionState.ttRecord && 
					( !consoleState.globalActionState.ttRecord.tt || 
					  !consoleState.globalActionState.ttRecord.tt[ namespace + "Action__c" ]
					)
				) {
					/* 
					RESUMES/PAUSES LIST VIEW TRACKING BASED ON CURRENT TAB ID.
					IT DOES NOT PAUSE OR RESUME LIST VIEW IF GLOBAL ACTION IS RUNNING.
					GLOBAL ACTION HAS A PRIORITY OVER LIST VIEW ACTION.
					*/					
					helper.handleListViewTracking( component, helper, consoleState, !currentTabId );

					// PAUSE TRACKING OF CURRENT TAB IF USER SWITCHES TO LIST VIEW.
					if( !currentTabId ) {
						helper.handleTabSwitch( component, helper, consoleState, null );
					}
				}
			},
			1000
		);
    },
    
	/*
		@ PURPOSE : HANDLES THE PREVIOUS TAB FOR TRACKING WHEN IT WAS JUST CLOSED.
    */
    handleTabClosed : function( component, event, helper ) {
        
		// PROVIDES SOME DELAY SINCE WORKSPACE API RETURNS PARTIAL RESULTS OF THE TAB WHEN API IS INVOKED AT ONCE.
        var closedTabId = event.getParam( "tabId" );
		setTimeout( function() {
            helper.handleTabClosed( component, helper, closedTabId );
        },1000);
    },
    
	/*
		@ PURPOSE : HANDLES THE CURRENT TAB FOR TRACKING WHEN THE RECORD IS EDITED.
    */
    handleEditRecord : function( component, event, helper ) {
        
		// PROVIDES SOME DELAY SINCE IT TAKES TIME FOR DOM ( POP-UP/MODAL ) TO LOAD.
        setTimeout( function() {
        	helper.handleEditRecord( component, event, helper, "Edit", "OpenRecordModalEvent", null );
        },1000);
    },
    
	/*
		@ PURPOSE : HANDLES THE CURRENT TAB FOR TRACKING WHEN THE RECORD IS SUCCESSFULLY SAVED; 
        			i.e. TOAST MESSAGE IS DISPLAYED.
    */
    handleShowToast : function( component, event, helper ) {
        
		var toastMessageType = event.getParam( "type" );
		
        /*
		USES THIS VALUE TO AVOID CONFLICT WITH MESSAGES/EVENTS FIRED FROM LIGHTNING MANUAL WIDGET.
        SALESFORCE KEEPS THIS TITLE VALUE EMPTY FOR STANDARD TOAST MESSAGES.
		*/
        var toastMessageTitle = event.getParam( "title" );
        if( toastMessageType && !toastMessageTitle ) {
			toastMessageType = toastMessageType.toLowerCase();
			
			if( toastMessageType == "success" ) {
				var savedRecordId = null;
				var toastMessageTemplateData = event.getParam( "messageTemplateData" );
				
				// FETCHES NEWLY CREATED RECORD'S ID IF AVAILABLE.
				if( toastMessageTemplateData && toastMessageTemplateData.length > 1 &&
					toastMessageTemplateData[1].executionComponent && 
					toastMessageTemplateData[1].executionComponent.attributes
				) {
					savedRecordId = toastMessageTemplateData[1].executionComponent.attributes.recordId;
				}
				helper.handleShowToast( component, helper, toastMessageType, "Save", savedRecordId );
			}
			else if( toastMessageType == "error" ) {
				var consoleState = helper.getJsonComponentState( component, helper, "v.jsonConsoleState" );
				if( consoleState ) {
					var namespace = component.get( "v.namespace" );
				
					if( consoleState.activeState == "quickActionState" ) {
						var quickActionState = consoleState.quickActionState;
						
						if( quickActionState && quickActionState.ttRecord && quickActionState.ttRecord.tt &&
							quickActionState.ttRecord.tt && quickActionState.ttRecord.tt[ namespace + "Action__c" ]
						) {
							/*
							CHECKS IF OPENING ACTION CONTAINS 'FILES' THEN 
							CONSIDERS AN ERROR TOAST MESSSAGE AS A CLOSING ACTION.
							*/
							var actionName = quickActionState.ttRecord.tt[ namespace + "Action__c" ].toLowerCase();
							if( actionName.endsWith( "files" ) ) {
								helper.handleShowToast( component, helper, toastMessageType, "Cancel", savedRecordId );
							}
						}
					}
				}
			}
        }
    }
})