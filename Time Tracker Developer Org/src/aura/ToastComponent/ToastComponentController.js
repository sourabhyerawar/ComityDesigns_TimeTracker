({
    handleInit : function(component, event, helper) {
        
        if(component.get('v.type') === 'prompt'){
            helper.showElement(component, 'promptDivId');
        } 
        else {
            //console.log('Inside success toast');
            helper.showElement(component, 'toastDiv');
            if(component.get('v.type')){
             	if(component.get('v.type') === 'success') {
                	$A.util.addClass(component.find('typeDiv'), 'slds-theme--success');
            	} 
				else {
                	$A.util.addClass(component.find('typeDiv'), 'slds-theme--error');
            	}   
            }
            helper.addDelay(component, event, helper);   
        }
    },
    
    closeToast : function(component, event, helper) {
        
		helper.closeToast(component);
    },
    
    handleOK : function(component, event, helper) {
		
		var csType = component.get('v.cstype'); 
        console.log( 'handleOK-csType', csType );
        
		var csObj = component.get('v.csObj');
		console.log( 'handleOK-csObj', csObj );
		
        if(csType === 'TimeTrackerUserSettings__c') {
			helper.fireRefreshUserSettingsTabEvent(component);
		} 
		else if(csType === 'TimeTrackerConfigSettings__c') {
			helper.fireCallServerEvent(component, csObj);
			helper.fireAfterSaveRefreshEvent(component, csObj);
		} else {
			console.log('Invalid Custom Setting type')
		}
		helper.closeToast(component);
    },
})