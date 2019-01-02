/*
  	@ PURPOSE : CONTROLS THE LIGHTNING COMPONENT --> LexManualTimeTracker.cmp
	@ NAME 	  : LexManualTimeTrackerController.js
*/
({
    /*
		@ PURPOSE : INITIALIZES COMPONENT'S ATTRIBUTES WHEN COMPONENT IS LOADED.
    */
	initializeFooterComponent : function( component, event, helper ) {
		
        console.log( "ManualTimeTrackerCmpController-initializeFooterComponent" );
		helper.initializeFooterComponent( component, event, helper );
	},
	
	/*
		@ PURPOSE : 1. FETCHES ACTIVE TAB DETAILS WHENEVER TAB IS OPENED/SWITCHED/CLOSED.
					2. PROVIDES SOME DELAY TO MAKE SURE TAB IS LOADED COMPLETELY WITH ALL NECESSARY DETAILS.
	*/
	handleTabFocused : function( component, event, helper ) {      
        
        setTimeout( function() {          
            var workspaceAPI = component.find( "workspace" );        
            if( workspaceAPI ) {
				
                workspaceAPI.getFocusedTabInfo().then( function( openedConsoleTab ) {
                    var currentTabRecord = JSON.parse( JSON.stringify( openedConsoleTab ) );
					component.set( "v.currentTabRecord", currentTabRecord );
                });
            }
        }, 2000 );
    },
	
	/*
		@ PURPOSE : STARTS THE TIMER.
	*/
	start : function( component, event, helper ) {
		
		helper.start( component, event, helper );
    },
	
	/*
		@ PURPOSE : STOPS THE TIMER.
	*/
	stop : function( component, event, helper ) { 
	
    	helper.stop( component, event, helper );
    },
	
	/*
		@ PURPOSE : 1. INVOKES THIS METHOD WHENEVER ACTIVITY SECTION IS CHANGED.
					2. POPULATES OBJECT LABEL AND MAKES OBJECT AND COMMENT SECTIONS MANDATORY BASED ON ACTIVITY SELECTED. 
	*/
	refreshSObjectDetails : function( component, event, helper ) {
        
		helper.refreshSObjectDetails( component, event, helper );
	},
	
	/*
		@ PURPOSE : 1. INVOKES THIS METHOD WHENEVER USER STARTS TYPING IN SEARCH RECORD FIELD.
					2. FETCHES RECORD BASED ON KEYWORD PROVIDED AND DISPLAYS RESULTS ACCORDING TO 
                       CUSTOM SETTING DATA OF THE SELECTED ACTIVITY. 
	*/
	fetchListOfSobjectRecords : function( component, event, helper ) {
		
		var consoleState = JSON.parse( JSON.stringify( component.get( "v.consoleState" ) ) );
		if( consoleState && consoleState.typeAheadStatus && consoleState.timeTracker ) {
			if( consoleState.timeTracker.activityName ) {
				
				if( consoleState.typeAheadStatus.searchInput && consoleState.typeAheadStatus.searchInput.length > 2 ) {
					helper.searchRecords( component, helper, consoleState, false );
				}
				else {
					consoleState.listOfSobjectRecords = [];
					consoleState.timeTracker.objectId = null;
					consoleState.toggleStatus.isSubmitDisabled = !helper.validateForm( component, helper, consoleState, false );
                    component.set( "v.consoleState", consoleState );
				}
			}
			else {
				consoleState.listOfSobjectRecords = [];
				consoleState.timeTracker.objectId = null;
				consoleState.toggleStatus.isSubmitDisabled = !helper.validateForm( component, helper, consoleState, false );
                component.set( "v.consoleState", consoleState );
			}
		}
	},
	
	/*
		@ PURPOSE : 1. INVOKES THIS METHOD WHEN USER SELECTS ANY ENTRY FROM DROP DOWN LIST.
					2. SAVES THE VALUES BASED ON SELECTION. 
	*/
	getSelectedValue : function( component, event, helper ) {        
		
		var selectedRecord = event.getParam( "selectedRecord" );
		if( selectedRecord ) {
			
			var consoleState = JSON.parse( JSON.stringify( component.get( "v.consoleState" ) ) );
			if( consoleState && consoleState.typeAheadStatus && consoleState.timeTracker ) {
				
				consoleState.typeAheadStatus.searchInput = selectedRecord.label;
				consoleState.listOfSobjectRecords = [];
				consoleState.timeTracker.objectId = selectedRecord.value;
				
				consoleState.toggleStatus.isSubmitDisabled = !helper.validateForm( component, helper, consoleState, false );
				component.set( "v.consoleState", consoleState ); 
			}
		}
    },
	
	/*
		@ PURPOSE : 1. INVOKES THIS METHOD WHEN USER CLICKS ON LINK --> GET FROM ACTIVE TAB.
					2. FETCHES CURRENT TAB RECORD DETAILS AND POPULATES THE VALUES IN SEARCH FIELD. 
	*/
	getRecordFromFocusedTab : function( component, event, helper ) { 
		
		var consoleState = JSON.parse( JSON.stringify( component.get( "v.consoleState" ) ) );
		if( consoleState && consoleState.typeAheadStatus && consoleState.typeAheadStatus.sObjectKeyPrefix ) {
			
			var currentTabRecord = JSON.parse( JSON.stringify( component.get( "v.currentTabRecord" ) ) );
			if( currentTabRecord && currentTabRecord.recordId &&
				currentTabRecord.recordId.startsWith( consoleState.typeAheadStatus.sObjectKeyPrefix ) 
			) {
				consoleState.typeAheadStatus.searchInput = currentTabRecord.recordId;
				consoleState.typeAheadStatus.sObjectSearchField = "Id";
				helper.searchRecords( component, helper, consoleState, true ); 
			}
            else {
                var constants = JSON.parse( JSON.stringify( component.get( "v.constants" ) ) );
				if( constants ) {
                    helper.showToastMessage( "warning", "Info!", constants.ERR_Get_From_Active_Tab );
                }
            }
		}
    },
	
	/*
		@ PURPOSE : VALIDATES ACTIVITY DATE AND DISPLAYS AN ERROR MESSAGE ON INVALID VALUE. 
	*/
	validateActivityDate : function( component, event, helper ) {
		
		var consoleState = JSON.parse( JSON.stringify( component.get( "v.consoleState" ) ) );
		helper.validateActivityDate( component, helper, consoleState, true );
		consoleState.toggleStatus.isSubmitDisabled = !helper.validateForm( component, helper, consoleState, false );
		component.set( "v.consoleState", consoleState );
    },
	
	/*
		@ PURPOSE : VALIDATES TIMER FIELD AND DISPLAYS AN ERROR MESSAGE ON INVALID VALUE. 
	*/
	validateTimer : function( component, event, helper ) {
		
		var consoleState = JSON.parse( JSON.stringify( component.get( "v.consoleState" ) ) );
		helper.validateTimer( component, helper, consoleState, true );
		consoleState.toggleStatus.isSubmitDisabled = !helper.validateForm( component, helper, consoleState, false );
		component.set( "v.consoleState", consoleState );
    },
	
	/*
		@ PURPOSE : VALIDATES ACTIVITY PICKLIST AND DISPLAYS AN ERROR MESSAGE ON INVALID VALUE. 
	*/
	validateActivityType : function( component, event, helper ) {
		
		var consoleState = JSON.parse( JSON.stringify( component.get( "v.consoleState" ) ) );
		helper.validateActivityType( component, helper, consoleState, true );
		consoleState.toggleStatus.isSubmitDisabled = !helper.validateForm( component, helper, consoleState, false );
		component.set( "v.consoleState", consoleState );
    },
	
    /*
		@ PURPOSE : 1. INVOKES THIS METHOD WHEN USER CLICKS ON X BUTTON IN SEARCH RECORD FIELD.
					2. CLEARS THE EARLIER SELECTION MADE OR VALUES PROVIDED AND SET IN THE BACKGROUND. 
	*/
	clearSearchtext : function( component, event, helper ) {
		
        helper.clearSearchtext( component, event, helper );
        var consoleState = JSON.parse( JSON.stringify( component.get( "v.consoleState" ) ) );
		helper.validateSObjectRecord( component, helper, consoleState, true );
		consoleState.toggleStatus.isSubmitDisabled = !helper.validateForm( component, helper, consoleState, false );
		component.set( "v.consoleState", consoleState );
    },
    
	/*
		@ PURPOSE : VALIDATES SELECTED/TYPED RECORD VALUE AND DISPLAYS AN ERROR MESSAGE ON INVALID VALUE. 
	*/
	validateSObjectRecord : function( component, event, helper ) {
		
		var consoleState = JSON.parse( JSON.stringify( component.get( "v.consoleState" ) ) );
		helper.validateSObjectRecord( component, helper, consoleState, true );
		consoleState.toggleStatus.isSubmitDisabled = !helper.validateForm( component, helper, consoleState, false );
		component.set( "v.consoleState", consoleState );
    },
	
	/*
		@ PURPOSE : VALIDATES COMMENT FIELD CONTENTS AND DISPLAYS AN ERROR MESSAGE IF LEFT EMPTY WHEN IT IS RRQUIRED. 
	*/
	validateComment : function( component, event, helper ) {
		
		var consoleState = JSON.parse( JSON.stringify( component.get( "v.consoleState" ) ) );
		helper.validateComment( component, helper, consoleState, true );
		consoleState.toggleStatus.isSubmitDisabled = !helper.validateForm( component, helper, consoleState, false );
		component.set( "v.consoleState", consoleState );
    },
	
	/*
		@ PURPOSE : 1. INVOKES THIS METHOD WHEN USER CLICKS ON SUBMIT BUTTON.
					2. INVOKES SUBMIT METHOD OF HELPER CLASS.
	*/
	handleSubmit : function( component, event, helper ) { 
	
    	helper.handleSubmit( component, event, helper );
    },
    
	/*
		@ PURPOSE : DISPLAYES SPINNER BY SETTING TRUE VALUE TO SPINNER ATTRIBUTE.
	*/
    showSpinner: function( component, event, helper ) {
		
        component.set( "v.Spinner", true ); 
    },
	
	/*
		@ PURPOSE : HIDES SPINNER BY SETTING FALSE VALUE TO SPINNER ATTRIBUTE.
	*/
    hideSpinner : function( component,event,helper ) {
		
        component.set( "v.Spinner", false );
    }
})