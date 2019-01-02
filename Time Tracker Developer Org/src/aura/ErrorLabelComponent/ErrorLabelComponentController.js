({    
    showError : function(component, event, helper){
        var params = event.getParam('arguments');
        component.set('v.errorMsg', params.errorMsg);
        $A.util.addClass(component.find('containerID'), 'slds-show');
        $A.util.removeClass(component.find('containerID'), 'slds-hide');
    },
    
	closeLabel : function(component, event, helper) {
		$A.util.addClass(component.find('containerID'), 'slds-hide');
        $A.util.removeClass(component.find('containerID'), 'slds-show');
	}
})