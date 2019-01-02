({
    doInit : function(component,event, helper) {
        console.log('Initialized');
		var consts = helper.getConstants(component);
        component.set('v.consts', consts);
        if(component.get('v.isNew')) {
            component.set('v.modalHeader', consts.LBL_NEW_USER_SETTING);  
        } 
		else {
            component.set('v.modalHeader', consts.LBL_EDIT_USER_SETTING);
            var searchComponentID = component.find('searchComponentID');
            if( searchComponentID ) {
                searchComponentID.set('v.valueIsSet', true);
            }
			//Setting it true as name field is mandatory and when edit is clicked on any record, it is autopopulated
        }
    },
    valueChangeValidationMaxDuration: function(component, event, helper){
        
        //var maxD = component.find('maxDurationID');
        helper.toggleSaveButton(component);
    },
    
    valueChangeValidationWeeklyHrs: function(component, event, helper){
        //var weekD = component.find('weeklyHrsID');
        helper.toggleSaveButton(component);
    },
    
    hideErrorMsg : function(component, event, helper) {
        helper.showReqFieldMessage(component, false);
    },
    
    handleSave : function(component,event,helper) {
        var searchComponentID = component.find('searchComponentID');
        if( searchComponentID && searchComponentID.get('v.valueIsSet') ) {
        	helper.showSpinner(component, true, 'spinnerDiv');
            helper.showReqFieldMessage(component, false);
            helper.saveRecord(component);
        } 
        else {
            	helper.showReqFieldMessage(component, true);
        }
    },
    
    cancel : function(component,event, helper) {
        
		helper.hidePopupHelper(component);
    },
})