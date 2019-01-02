({
	doInit : function(component, event, helper) {
        helper.getActivityList(component); 
        var currentDate = new Date();
        currentDate.setHours(0,0,0,0);
        component.set("v.activityDate", currentDate.toISOString());
	},
    
    handleTabFocused : function( component, event, helper ) {      
        setTimeout( function() {          
            var workspaceAPI = component.find( 'workspace' );        
            if( workspaceAPI ) {
                workspaceAPI.getFocusedTabInfo().then( function( openedConsoleTab ) {
                    var currentTabJSON = '';
                    if( openedConsoleTab.tabId ) {
                        currentTabJSON = JSON.stringify( openedConsoleTab );
                    }
                    component.set( "v.currentTabJSON", currentTabJSON );
                });
            }
        }, 1000 );
    },
    
	start : function( component, event, helper ) {
    	helper.start( component, event, helper );
    },      

    stop : function( component, event, helper ) { 
    	helper.stop( component, event, helper );
    },
    
	getSObjectDetails: function(component, event, helper) {
        var selectedActivity = component.get("v.selectedValue");
        if(selectedActivity && selectedActivity != 'select'){           
        	helper.getSObjectDetailsFromCS(component);    
        }else{
            component.set("v.isSobjectDisabled", true);
            component.set("v.isSobjectRequired", false);    
            component.set("v.isCommentRequired", false);  
            component.set("v.searchInput", null);
        }
	},

    getFocusedTab : function(component,event, helper) {
        var selectedActivity = component.get("v.selectedValue");
        if(selectedActivity && selectedActivity != 'select'){
        	var recordId =  helper.getFocusedTabName(component, event, helper );
            if(recordId){
                helper.getFocusedTabRecord( component, event, helper, recordId);
            }                       
        }else{
            component.find("activityLst").set("v.errors", [{message:"Please select activity"}]); 
        } 
    },
	 
    getRelatedData : function(component,event, helper) {
    	var selectedActivity = component.get("v.selectedValue");
        var lookupMenu = component.find("lookupMenu");
        var clearbtn = component.find("clearbtn");
    	console.log( 'selectedActivity', selectedActivity );
    	if(selectedActivity && selectedActivity != 'select'){
    		var clearTypeAheadTextEvent = component.getEvent( "clearTypeAheadText" );
	        clearTypeAheadTextEvent.fire();     	
	    	$A.util.removeClass(lookupMenu, "slds-hide");
	        $A.util.addClass(lookupMenu, "slds-lookup__menu");
            $A.util.removeClass(clearbtn, "slds-hide");
    	}
    	else{
            component.find("activityLst").set("v.errors", [{message:"Please select activity"}]); 
        } 
    },
    
    searchInputChange : function(component, event, helper) {
    	var selectedActivity = component.get("v.selectedValue");
        if(selectedActivity && selectedActivity != 'select'){
			helper.showElement(component, 'iterationID');
	        var searchInput = component.get("v.searchInput");	        
	        if(searchInput && searchInput.length >= 2 && selectedActivity) helper.getSobjectRecords(component);
        }
    },
    
    resetNewEntryForm : function( component, event, helper ) {
		var clearTypeAheadText = event.getParam( 'clearTypeAheadText' );
		if( clearTypeAheadText ) {
			helper.clearSearchtext( component, event, helper );
		}
    },
    
    setSelectedValue : function(component, event, helper){        
		var value=event.getParam("value");
        component.set("v.searchInput", value);        
		var lookupMenu=component.find("lookupMenu");
        $A.util.addClass(lookupMenu, "slds-hide");
        $A.util.removeClass(lookupMenu, "slds-lookup__menu");
    },
     	
	clearSearchtext :function(component, event, helper) {
        helper.clearSearchtext( component, event, helper );
        var clearTypeAheadTextEvent = component.getEvent( "clearTypeAheadText" );
        clearTypeAheadTextEvent.fire();
    },
    
    handleSubmit : function(component, event, helper) {
        helper.validateAllFields(component, event, helper);
        var isValid = component.get("v.isValid");
        if(isValid){
            helper.pushTimesheetEntry(component, event, helper);
        }
    },

    afterScriptsLoaded : function(component, event, helper) {

	}
})