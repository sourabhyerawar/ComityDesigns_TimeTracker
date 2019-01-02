({
    populateDefaultValues : function(component) {
        
		var action=component.get('c.getHierarchySettings');
        action.setCallback(this, function(response) {
            
			var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var res = response.getReturnValue();
                console.log('before parse response >',res);
                
                res = JSON.parse( res );
                //console.log('after parse res',res);
                
                component.set('v.setting', res.orgWideSettings);
                component.set( 'v.namespace', res.Namespace );
                
                this.populateEachField(component.get('v.setting'), component);
                this.sendOrgSettingsToBrotherTab(component, res.orgWideSettings);		
                //To send the org settings to adj Tab if required while creating new user setting
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
				} else {
					//console.log("Unknown error");
					component.set('v.errorMsg', 'Unknown Error');
					this.showError(component);
				}
			}
        });
        $A.enqueueAction(action);
    },
    
    populateEachField : function(setting, component){
        
		//console.log('setting org def: ' , setting);
        //component.find('startDayID').set('v.value', setting.StartDayOfWeek__c);
        //component.find('extensionIDID').set('v.value', setting.ChromeExtensionID__c);
        component.find('clientDebugLevelID').set('v.value', setting.ClientDebugLevel__c);
        component.find('serverDebugLevelID').set('v.value', setting.Server_Debug_Level__c);
        component.find('maxDurationID').set('v.value', setting.Max_Duration_In_Minutes__c);
        component.find('weeklyHrsID').set('v.value', setting.Weekly_Hours__c);
        component.set("v.isServerDebug", setting.Server_Debug__c);
        component.set('v.isClientFailNot', setting.ClientFailureNotifications__c);
        component.set("v.isTimeSpentRO", setting.Is_Time_Tracker_Read_Only__c);
        component.set('v.isStopTrackingAfterCC', setting.StopTrackingAfterCloseCase__c);
    },
    
    sendOrgSettingsToBrotherTab : function(component, orgSetting){
        
		var evt=$A.get('e.c:sendOrgSettingEvent');
        evt.setParams({
            orgSetting: orgSetting
        });
        evt.fire();
    },
    
    addNamespace: function(component, userSetting) {
        
		var namespace = component.get("v.namespace");
        if(!userSetting || ! namespace) return userSetting;
        var newUserSetting = {};
		
        for(var key in userSetting) {
            var newKey;
            (key.endsWith('__c'))? newKey = namespace+'__'+key: newKey = key;
            newUserSetting[newKey] = userSetting[key];
        }
        return newUserSetting;
    },
    
    updateServer : function(component){
        
		var action=component.get('c.upsertSettings');
        var setting=component.get('v.setting');
		
        //setting['ChromeExtensionID__c']= component.find('extensionIDID').get("v.value");
        setting['ClientDebugLevel__c'] = component.find('clientDebugLevelID').get("v.value");
        setting['Server_Debug_Level__c'] = component.find('serverDebugLevelID').get("v.value");
        setting['ClientFailureNotifications__c'] = component.get('v.isClientFailNot');
        setting['Max_Duration_In_Minutes__c'] = component.find('maxDurationID').get("v.value");
        setting['Server_Debug__c'] = component.get('v.isServerDebug');
        setting['Is_Time_Tracker_Read_Only__c'] = component.get('v.isTimeSpentRO');
        setting['StopTrackingAfterCloseCase__c'] = component.get('v.isStopTrackingAfterCC');
        //setting['StartDayOfWeek__c'] = component.find('startDayID').get("v.value");
        setting['Weekly_Hours__c'] = component.find('weeklyHrsID').get("v.value");
        
        component.set('v.setting', setting);
        //console.log('b4 adding namespace ' , setting );
        
        setting = this.addNamespace(component, setting);
        //console.log('After Adding namespace', setting);
        //console.log('JSON.stringify(setting)',JSON.stringify(setting));
		
        action.setParams({
            strJsonRecordToUpdate : JSON.stringify(setting)
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                
				// Avoiding another server call.
                //this.populateDefaultValues(component);
				console.log( 'response> ', response.getReturnValue() );
                var result = JSON.parse( response.getReturnValue() );
                
                component.set('v.setting', result.orgWideSettings );
                
                if( result.isSucceeded ) {
                    this.sendOrgSettingsToBrotherTab(component, result.orgWideSettings);
					this.showSuccessToast(component, 'success', 'Success!', result.strMessage );
				}
				else {
					component.set( 'v.errorMsg', result.strMessage );
					this.showError(component);
				}
                this.showSpinner(component, false, 'spinnerDiv');
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
				} else {
					//console.log("Unknown error");
					component.set('v.errorMsg', 'Unknown Error');
					this.showError(component);
				}
			}
        });
        $A.enqueueAction(action);
    },
    
    toggleSaveButton : function(component){
        
        var numberFldIdLst = [ 'maxDurationID', 'weeklyHrsID'];
        var isSaveButtonDisabled = false;
        numberFldIdLst.forEach(function(el,i, arr) {
            var val = component.find(el);
            if(val){
                val= val.get('v.validity');
                console.log('val>',val);
                if(val.rangeOverflow || val.rangeUnderflow || val.badInput){
            		isSaveButtonDisabled = true;
        		}
            }
        });
        component.find('saveButtonID').set('v.disabled', isSaveButtonDisabled); 
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
    
    showSpinner: function(component, isVisible, spinnerDiv) {
        
		if(isVisible){
            this.showElement(component, spinnerDiv);
        }
        else{
            this.hideElement(component, spinnerDiv);
        }
    },
    
    hideError : function(component, element) {
        var el = component.find(element);
    	$A.util.removeClass(el, "slds-has-error"); // remove red border
    	$A.util.addClass(el, "hide-error-message");
    },
    
    showError : function(component){
        
		var error = component.find('errorID');
        error.showError(component.get('v.errorMsg'));
    },
    
    showSuccessToast : function(component, type, title, message){
		$A.createComponent(
            "c:ToastComponent",
            {
                "type" : type,
                "title" : title,
                "message": message
            },
            function(newToast, status, errorMessage){
                if (status === "SUCCESS") {
                    var body = component.get("v.body");
                    body.push(newToast);
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
    
    toggleDiv : function(component, isDown) {
        
		if(isDown){
            this.showElement(component, 'rightButtonID');
            this.hideElement(component, 'downButtonID');
        }
        else{
            this.showElement(component, 'downButtonID');
            this.hideElement(component, 'rightButtonID');
        }
        var divElement=component.find('boxDiv');
        $A.util.toggleClass(divElement, 'slds-hide');
    },
})