({
	showSpinner: function(component,event) {
        
        var params = event.getParam('arguments');
        var documentProcessSpinner = component.find('spinnerDiv');
        if(params.show) {
            $A.util.removeClass(documentProcessSpinner, 'slds-hide');
            $A.util.addClass(documentProcessSpinner, 'slds-show');
        } else {
            $A.util.removeClass(documentProcessSpinner, 'slds-show');
            $A.util.addClass(documentProcessSpinner, 'slds-hide');
        }
    }
})