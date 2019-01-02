({        
    getConfigSettingsDetails: function(component, isFirstTime,isDelete){
        
		var action = component.get("c.getUserHierarchySettings");
        action.setCallback(this, function(response) {
            
			var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                
				var res = response.getReturnValue();
                console.log(' before parse v.customSetting',res);
                res = JSON.parse( res );
                component.set('v.customSetting', res.listOfUserSettings );  
                component.set( 'v.namespace', res.Namespace );
                
                if(isFirstTime){
                    this.setTabelHeaders(component); 
                }
            } 
			else if (component.isValid() && state === "INCOMPLETE") {
                component.set('v.errorMsg', 'STATE : INCOMPLETE');
                this.showError(component);
            } 
			else if (component.isValid() && state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        //console.log("Error message: " + errors[0].message);
                        component.set('v.errorMsg', errors[0].message);
                        this.showError(component);
                    }
                } 
				else {
                    //console.log("Unknown error");
                    component.set('v.errorMsg', 'Unknown Error');
                    this.showError(component);
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    
    setTabelHeaders: function(component){
        
		var fieldNamesList = component.get('v.fieldNamesList');
        var consts = this.getConstants();
		
        fieldNamesList.push(consts.LBL_ACTION);
        fieldNamesList.push(consts.LBL_SETUP_OWNER);
        //fieldNamesList.push(consts.LBL_CHROME_EXT_ID);
        fieldNamesList.push(consts.LBL_CLI_DEBUG_LEVEL);
        fieldNamesList.push(consts.LBL_SER_DEBUG_LEVEL);
		
        //fieldNamesList.push(consts.LBL_CLI_FAILURE_NOTIFY);
        //fieldNamesList.push(consts.LBL_SER_DEBUG);
		
        fieldNamesList.push(consts.LBL_MAX_DURATION);
        fieldNamesList.push(consts.LBL_WEEKLY_HOURS);
		
        //fieldNamesList.push(consts.LBL_IS_TT_READ_ONLY);
        /*
		fieldNamesList.push('StopTrackingAfterCloseCase__c');
		//*/
        component.set('v.fieldNamesList', fieldNamesList);
    },
    
    renderNewOrEditForm : function(component, isNew, record){
        
        var nameSpace = component.get( "v.namespace" );        
		$A.createComponent("c:NewAndEditUserSettingForm",
                           {
                               "isNew" : isNew,
                               "record" : record,
                               "namespace" : nameSpace
                           }, 
                           function(newComponent, status, errorMessage){
                               if (status === "SUCCESS") {
                                   var body = component.get("v.body");
                                   body.push(newComponent);
                                   component.set("v.body", body);  
                               } 
                               else if (status === "INCOMPLETE") {
                                   //console.log("toast incomplete");
                                   // Show offline error
                               } 
                                   else if (status === "ERROR") {
                                       //console.log("Error: " + errorMessage);
                                       // Show error message
                                   }
                           }
		);
    },
    
    fetchCustomSettingRecordByID : function(component, id, isEdit) {
        
        var setting=component.get('v.customSetting');
        var recordToEdit=setting[id];
        console.log( 'fetchCustomSettingRecordByID-recordToEdit', recordToEdit );
        
        component.set('v.recordToEdit', recordToEdit);
        if(isEdit) {
            this.showEditor(component, recordToEdit);            
        } 
		else {
            this.askConfirmation(component);
        }
    },
    
    showEditor : function(component, recordToEdit) {
        
		this.renderNewOrEditForm(component, false, recordToEdit);
    },
    
    askConfirmation : function(component) {
        
		var consts = this.getConstants();
        this.showToast(component, 'prompt', consts.LBL_RECORD_DELETE_CONFIRMATION_HEADER, consts.LBL_RECORD_DELETE_CONFIRMATION);
    },
    
    deleteSelectedRow : function(component) {
        
        //console.log( 'deleteSelectedRow-recordToEdit', component.get('v.recordToEdit') );
        var action = component.get("c.deleteUserSetting");
        action.setParams({
            strJsonRecordToDelete : JSON.stringify( component.get('v.recordToEdit') ) 
        });
		
        action.setCallback(this, function(response) {
            
			var state = response.getState();
            var res=response.getReturnValue();
			
            if (component.isValid() && state === "SUCCESS") {
                if(res !== 'SUCCESS') {
                    console.log('response >',res);
                    component.set('v.errorMsg', 'EXCEPTION! Delete Failed: ' + res);
                    this.showError(component);
                }
                this.showToast(component, 'success', 'Success!', 'Record Deleted Successfully!');
                this.getConfigSettingsDetails(component, false);
            } 
			else if (component.isValid() && state === "INCOMPLETE") {
                component.set('v.errorMsg', 'STATE : INCOMPLETE');
                this.showError(component);
            } 
			else if (component.isValid() && state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        //console.log("Error message: " + errors[0].message);
                        component.set('v.errorMsg', errors[0].message);
                        this.showError(component);
                    }
                } 
				else {
                    //console.log("Unknown error");
                    component.set('v.errorMsg', 'Unknown Error');
                    this.showError(component);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    showError : function(component){
        
		var error = component.find('errorID');
        error.showError(component.get('v.errorMsg'));
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
    
    showToast : function(component, type, title, message) {
        
		$A.createComponent( "c:ToastComponent", {
                "type" : type,
                "title" : title,
                "message": message,
                "cstype": 'TimeTrackerUserSettings__c'
            }, 
			function(newToast, status, errorMessage) {
                if (status === "SUCCESS") {
                    var body = component.get("v.body");
                    body.push(newToast);
                    component.set("v.body", body);  
                } 
				else if (status === "INCOMPLETE") {
                    console.log("toast incomplete");
                    // Show offline error
                } 
				else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }
            }
        );
    },
	
	getConstants: function(){
        
		return {
            'LBL_NEW': 'New',
            'LBL_EDIT': 'Edit',
            'LBL_DEL': 'Del',
            'LBL_ACTION':'Action',
            'LBL_SETUP_OWNER':'PROFILE / USER',
            'LBL_CHROME_EXT_ID':'Chrome Extension ID',
            'LBL_CLI_DEBUG_LEVEL':'Client Debug Level',
            'LBL_SER_DEBUG_LEVEL':'Server Debug Level',
            'LBL_CLI_FAILURE_NOTIFY':'Client Failure Notifications',
            'LBL_SER_DEBUG':'Server Debug',
            'LBL_MAX_DURATION':'Max Duration Allowed In Minutes',
            'LBL_WEEKLY_HOURS':'Weekly Hours',
            'LBL_IS_TT_READ_ONLY':'Is Time Tracker Read Only',
            'LBL_RECORD_DELETE_CONFIRMATION_HEADER':'Record Deletion',
            'LBL_RECORD_DELETE_CONFIRMATION':'The record will be deleted. Are you sure?'
        }
    }
})