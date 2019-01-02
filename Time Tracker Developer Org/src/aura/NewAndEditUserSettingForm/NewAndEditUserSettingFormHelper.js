({  
    hidePopupHelper : function(component) {
        
		var modal = component.find('modaldialog'); 
        $A.util.addClass(modal, 'slds-fade-in-hide'); 
        $A.util.removeClass(modal, 'slds-fade-in-open'); 
        $A.util.removeClass(modal, 'slds-backdrop'); 
		
        var lockUI=component.find("lockUI");
        $A.util.addClass(lockUI, 'slds-backdrop--open'); 
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
        //console.log( 'after addNamespace-newUserSetting', newUserSetting );
        return newUserSetting;
    },
    
    saveRecord : function(component) {
        var consts = this.getConstants(component);
        var setting = {
					   //'ChromeExtensionID__c' : component.find('extensionIDID').get("v.value"),
					   'ClientDebugLevel__c'  : component.find('clientDebugLevelID').get("v.value"),
					   'Server_Debug_Level__c' : component.find('serverDebugLevelID').get("v.value"),
					   'ClientFailureNotifications__c' : component.find('clientFailID').get('v.checked'),
					   'Max_Duration_In_Minutes__c' : component.find('maxDurationID').get("v.value"),
					   'Server_Debug__c' : component.find('serverDebugID').get('v.checked'),
					   'Weekly_Hours__c' : component.find('weeklyHrsID').get("v.value"),
					   'Is_Time_Tracker_Read_Only__c' : component.find('tsro').get('v.checked'),
					   'SetupOwnerId' : this.getIDFromName(component, component.find('searchComponentID').get('v.searchInput'))
					  };
		//console.log( 'After Importing Values setting', setting );
		
		var editedRecord = component.get('v.record');
		//console.log( 'editedRecord', editedRecord );
		//console.log( 'hasOwnProperty-SetupOwner', editedRecord.hasOwnProperty( 'SetupOwner' ) );
		
		if( editedRecord && editedRecord.hasOwnProperty( 'SetupOwner' ) ) {
			
			setting.SetupOwner = editedRecord.SetupOwner;
            setting.Id = editedRecord.Id;
            
			if( !setting.SetupOwnerId ) {
                setting.SetupOwnerId = editedRecord.SetupOwnerId;
            }
			//console.log( 'setting.SetupOwner', setting );
			
			if( setting.SetupOwnerId ) {
				setting.SetupOwner.Id = setting.SetupOwnerId;
				var type = 'User';
				if( setting.SetupOwnerId.startsWith( '00e') ) {
					type = 'Profile';
				}
				setting.SetupOwner.attributes = {
					type : type,
					url : "/services/data/v40.0/sobjects/" + type + "/" + setting.SetupOwnerId                
				}
				//console.log( 'setting.SetupOwner.attributes', setting );
			}
		}
		
        if( component.get( 'v.isNew' ) ) {
            setting.Id = null;
        } 
		//console.log( 'Before NameSpace', setting );
        setting = this.addNamespace( component, setting );
        //console.log( 'After NameSpace', setting );
		
        var action = component.get('c.upsertSettings');
        action.setParams({ strJsonRecordToUpdate : JSON.stringify( setting ) });
        
		action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                
                console.log('response',response.getReturnValue());
                var result = JSON.parse( response.getReturnValue() );
                if( result.isSucceeded ) {
                    this.sendSuccessEvent(component);
                    this.hidePopupHelper(component);
                } 
				else {
                    component.set('v.errorMsg', consts.LEX_Insert_Failed + result.strMessage );
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
    
    getIDFromName : function(component, name) {
        
		var nameToIDMap= component.find('searchComponentID').get('v.trackedEntityMap');
        //console.log('nameToIDMap:',nameToIDMap,' nameToIDMap[name]:',nameToIDMap[name]);
        return nameToIDMap[name];
    },
    
    sendSuccessEvent : function(component) {
        
		var evt = component.getEvent('refreshUserSettingTabEvent');
        evt.setParams({isDelete : false });
        evt.fire();
    },
    
    showElement : function(component, id) {
        
		var divElement=component.find(id);
        if( divElement ) {
            $A.util.removeClass(divElement, 'slds-hide');
            $A.util.addClass(divElement, 'slds-show');
        }
    },
    
    hideElement : function(component, id) {
        
		var divElement=component.find(id);
        if( divElement ) {
            $A.util.removeClass(divElement, 'slds-show');
            $A.util.addClass(divElement, 'slds-hide');
        }
    },
    
    toggleSaveButton : function(component, element){
        
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
    
    showSpinner: function(component, isVisible, spinnerDiv) {
        
		(isVisible)? this.showElement(component, spinnerDiv): this.hideElement(component, spinnerDiv);
    },
    
    showError : function(component) {
       
	   var error = component.find('errorID');
        error.showError(component.get('v.errorMsg'));
    },
    
    showReqFieldMessage : function(component, isTrue) {
        
		var errorDiv = component.find('errorDiv');
        if( errorDiv ) {
            if(isTrue) {
                $A.util.addClass(errorDiv, 'slds-has-error');
                this.showElement(component, 'error-message');    
            } 
            else {
                $A.util.removeClass(errorDiv, 'slds-has-error');
                this.hideElement(component, 'error-message'); 
            }
        }
    },
	
	getConstants: function(component){
        
		var consts = {
						'LBL_NEW_USER_SETTING':'New User Setting',
						'LBL_EDIT_USER_SETTING':'Edit User Setting',
						'LBL_VALID_USERNAME':'Please enter a valid User or Profile name.',
						'USER':'User',
						'PROFILE':'Profile'
					};
            
        if( component.get('v.namespace') ) {
            consts['LEX_Insert_Failed'] = $A.get("$Label.timetracker.LEX_Insert_Failed");
            consts['LBL_SELECT'] = $A.get("$Label.timetracker.LBL_Select_DropDown");
        } 
        else{
            consts['LEX_Insert_Failed'] = $A.get("$Label.c.LEX_Insert_Failed");
            consts['LBL_SELECT'] = $A.get("$Label.c.LBL_Select_DropDown");
        }
        return consts;
    }    
})