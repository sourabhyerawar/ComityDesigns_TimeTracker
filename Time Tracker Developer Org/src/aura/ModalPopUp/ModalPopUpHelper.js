({
    hidePopupHelper : function(component){
        
		component.set("v.comments", "");
        var modal = component.find('modaldialog'); 
        $A.util.addClass(modal, 'slds-fade-in-hide'); 
        $A.util.removeClass(modal, 'slds-fade-in-open'); 
        $A.util.removeClass(modal, 'slds-backdrop'); 
        var lockUI=component.find("lockUI");
        $A.util.addClass(lockUI, 'slds-backdrop--open'); 
    },
    
    makeHttpCalloutForWFAction : function(component){
       
	   var documentProcessSeq=component.get("v.documentProcessResp").documentProcessSeq;
        var actionName=component.get("v.modalHeader");
        var buttonID=component.get("v.buttonID");
        var body=component.find("comments").get("v.value");
        var action=component.get("c.postWFAction");	//Calling server action to post the request
        
        action.setParams({
            "documentProcessSeq" : documentProcessSeq,
            "actionName" : buttonID,
            "body" : body
        });
        
        action.setCallback(this, function(response){
            
			var state=response.getState();
            
			if(component.isValid() && state === 'SUCCESS'){
                var returnValue = response.getReturnValue();
                console.log('response > ' + returnValue);
                
				if(returnValue!=null){
                    returnValue = JSON.parse(returnValue);
                    
					if(!returnValue.system_error_type){ 
                        this.createToastComponent(component, 'success', 'Success!', actionName+'workflow action successfully completed');
                    }
                    else{
                        this.createToastComponent(component, 'error', returnValue.system_error_type+' error', returnValue.system_error_message);
                    }
                }
                else {
                    this.createToastComponent(component, 'error', 'Error in response!', 'Sorry, data was not found. Please try again.' );
                } 
            }
            else {
            	this.createToastComponent(component, 'error', 'Error in response!', 'Sorry, unable to load component. Please try again.' );
            }
        });
        $A.enqueueAction(action);
    },
    
    createToastComponent : function(component, type, title, message){
        
        $A.createComponent(
            "c:CLDS_Toast",
            {
                "type" : type,
                "title" : title,
                "message": message
            },
            function(newToast, status, errorMessage){
                if(errorMessage!==null){
                	console.log('Toast errorMessage: '+ errorMessage);
                }
                else{
                    //Do Nothing
                }
            }
        );
    }
})