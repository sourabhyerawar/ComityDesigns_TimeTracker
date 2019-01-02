({
    addDelay : function(component, event, helper){
        
		window.setTimeout(
            $A.getCallback( function() {
                if(component.isValid()) {
                    var toastDiv= component.find('toastDiv');
                    $A.util.removeClass(toastDiv, "slds-show");
                    $A.util.addClass(toastDiv, "slds-hide");
                } 
				else {
                    //console.log('Component is Invalid');
                }
            }), 3000
        );
    },
    
    fireRefreshUserSettingsTabEvent:  function(component) {
        
		var evt = component.getEvent('refreshUserSettingTabEvent');
        evt.setParams({ isDelete : true  });
        evt.fire();
    },

    fireCallServerEvent: function(component, csToDelete) {
        
		//console.log('ToastComponentHelper.fireCallServerEvent: entered');
        //console.log('csToDelete',csToDelete);
        var callServerEvent = $A.get("e.c:callServerEvent");
        callServerEvent.setParams({'csToDelete': csToDelete});
        callServerEvent.fire();
    },

    fireAfterSaveRefreshEvent: function(component, csToDelete) {
        
		//console.log('ToastComponentHelper.fireAfterSaveRefreshEvent: entered');
        //console.log('csToDelete',csToDelete);
        var afterSaveRefreshEvent = $A.get("e.c:afterSaveRefresh");
        afterSaveRefreshEvent.setParams({'deletedSetting': csToDelete});
        afterSaveRefreshEvent.fire();
    },
    
    closeToast : function(component) {
        
		this.hideElement(component, 'toastDiv');
        this.hideElement(component,  'promptDivId'); 
    },
    
    showElement : function(component, id){
        
		var divElement=component.find(id);
        $A.util.removeClass(divElement, 'slds-hide');
        $A.util.addClass(divElement, 'slds-show');
    },
    
    hideElement : function(component, id) {
       
	    var divElement=component.find(id);
        $A.util.removeClass(divElement, 'slds-show');
        $A.util.addClass(divElement, 'slds-hide');
    },
})