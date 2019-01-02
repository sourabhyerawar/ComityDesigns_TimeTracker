/*
	@ Purpose : Provides the service to the Controller --> SearchComponentController
	@ Name    : SearchComponentHelper
//*/

({
    searchTrackedEntity : function(component) {
        
        var trackedEntity = component.get("v.trackedEntity");
        var settingType = component.get('v.settingType');
        var consts = this.getConstants(component);
        console.log('consts',consts);
        
        var searchInput = component.get("v.searchInput");
        console.log('trackedEntity',trackedEntity,'settingType',settingType,'searchInput',searchInput);
       
	   var a;
		if( trackedEntity === consts.LBL_OBJECTS ) {
			var fetchOnlyUnique=false;
			if(settingType === consts.LBL_CUSTOM_EVENTS) {
				fetchOnlyUnique =true;
			}
			a = component.get("c.getMatchingEntities");
			a.setParams({
				searchedEntity: trackedEntity,
				searchString: searchInput,
				fetchOnlyUnique : fetchOnlyUnique,
				includeMandatory : false
			});
		}
		else{
			a = component.get("c.getUserAndProfileDetails");
			a.setParams({
				searchedEntity: trackedEntity,
				searchString: searchInput
			});
		}
		
        // Create a callback that is executed after
        // the server-side action returns
        a.setCallback(this, function(action) {
            
			//console.log('action.getState()',action.getState());
			//console.log('action.getReturnValue()',action.getReturnValue());
            if (action.getState() === "SUCCESS") {
                if(trackedEntity === consts.LBL_OBJECTS ){
                    var trackedEntityArray=action.getReturnValue();
                    component.set("v.trackedEntityArray", trackedEntityArray);
                    if(trackedEntityArray.length === 0 || trackedEntityArray === undefined) {
                        component.set('v.notFoundText', ' not found or is already being tracked');
                    }
                    else{
                        component.set('v.notFoundText', '');
                    }
                }
                else{
                    this.setTrackedEntityArray(component, action.getReturnValue());
                }
                if(action.getReturnValue() === null){
                    component.set('v.errorMsg', consts.LEX_Controller_Exception);
                    this.showElement(component, 'errorMsgID');
                }
            } 
			else {
                component.set('v.errorMsg', action.getError());
                this.showElement(component, 'errorMsgID');
                //console.log('Error: '+ action.getError());
            }
        });
        if(searchInput) $A.enqueueAction(a);
    },
    
    setTrackedEntityArray : function(component, nameToIDMap){
        
        if( nameToIDMap ) {
            var trackedEntityArray = Object.keys( nameToIDMap );
            component.set('v.trackedEntityArray', trackedEntityArray);
            component.set('v.trackedEntityMap', nameToIDMap);
            if(trackedEntityArray.length === 0 || trackedEntityArray === undefined){
                component.set('v.notFoundText', ' not found');
            }
            else{
                component.set('v.notFoundText', '');
            }
        }
        else {
            component.set('v.notFoundText', ' not found');
        }
    },
    
    showElement : function(component, id){
        
		var divElement=component.find(id);
        $A.util.removeClass(divElement, 'slds-hide');
        $A.util.addClass(divElement, 'slds-show');
    },
    
    hideElement : function(component, id){
        
		var divElement=component.find(id);
        $A.util.removeClass(divElement, 'slds-show');
        $A.util.addClass(divElement, 'slds-hide');
    },
    
    toggleElement : function(component, id) {
        
		var toggleText = component.find(id);
        $A.util.toggleClass(toggleText, "toggle");
    },
    
    clearSearchtext :function(component, event, helper) {
        
        //console.log('valueisSet befoer: ' + component.get('v.valueIsSet'));
        component.set("v.searchInput", '');
        component.set('v.valueIsSet', false);
		
        //console.log('valueisSet after: ' + component.get('v.valueIsSet'));
        helper.hideElement(component, 'iterationID');
        var lookupMenu=component.find("lookupMenu");
        $A.util.addClass(lookupMenu, "slds-hide");
        $A.util.removeClass(lookupMenu, "slds-lookup__menu");
    },
	
	getConstants: function(component) {
        
		var consts = {
						'LBL_OBJECTS' : 'Objects'
					 };
					 
		if(component.get('v.namespace')){
			consts['LBL_CUSTOM_EVENTS'] = $A.get("$Label.timetracker.LBL_Custom_Events");
			consts['LEX_Controller_Exception'] = $A.get("$Label.timetracker.LEX_Controller_Exception");
		}
		else {
			consts['LBL_CUSTOM_EVENTS'] = $A.get("$Label.c.LBL_Custom_Events");
			consts['LEX_Controller_Exception'] = $A.get("$Label.c.LEX_Controller_Exception");
		} 
		return consts;
    }
})