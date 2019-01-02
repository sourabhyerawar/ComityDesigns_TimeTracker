/*
	@ Purpose : Controls the component --> SearchComponent
	@ Name    : SearchComponentController
//*/

({  
    showLookupMenu : function(component, event, helper) {
        
        var clearTypeAheadTextEvent = component.getEvent( "clearTypeAheadText" );
        clearTypeAheadTextEvent.fire();
        
		var lookupMenu=component.find("lookupMenu");
        $A.util.removeClass(lookupMenu, "slds-hide");
        $A.util.addClass(lookupMenu, "slds-lookup__menu");
    },
    
    searchTrackedEntity : function(component, event, helper) {
        
		helper.hideElement(component, 'leftDropdown');
        component.set("v.trackedEntity",'Objects');
        helper.searchTrackedEntity(component);
    }, 
    
    expandMenu :function(component, event, helper) {
		helper.showElement(component, 'leftDropdown');
    }, 
    
    searchInputChange : function(component, event, helper) {
        
		helper.showElement(component, 'iterationID');
        var searchInput = component.get("v.searchInput");
        //console.log( 'searchInput', searchInput );
        if(searchInput && searchInput.length >= 2) helper.searchTrackedEntity(component);
    },
    
    clearSearchtext :function(component, event, helper) {

        helper.clearSearchtext( component, event, helper );
        var clearTypeAheadTextEvent = component.getEvent( "clearTypeAheadText" );
        clearTypeAheadTextEvent.fire();
        //console.log( 'Clear Type Ahead Text Event being fired', clearTypeAheadTextEvent );
    },
    
    resetNewEntryForm : function( component, event, helper ) {
        
        //console.log( 'Reset New Entry Form Event being caught', event );
		var clearTypeAheadText = event.getParam( 'clearTypeAheadText' );
        //console.log( 'SearchComponentController-resetNewEntryForm-clearTypeAheadText', clearTypeAheadText );
		if( clearTypeAheadText ) {
			helper.clearSearchtext( component, event, helper );
		}
    },
    
    setSelectedValue : function(component, event, helper){
        
		var value=event.getParam("value");
        component.set("v.searchInput", value);
        component.set('v.valueIsSet', true);
        //console.log('valueisSet on selet: ' + component.get('v.valueIsSet'));
        
		var lookupMenu=component.find("lookupMenu");
        $A.util.addClass(lookupMenu, "slds-hide");
        $A.util.removeClass(lookupMenu, "slds-lookup__menu");
    }
})