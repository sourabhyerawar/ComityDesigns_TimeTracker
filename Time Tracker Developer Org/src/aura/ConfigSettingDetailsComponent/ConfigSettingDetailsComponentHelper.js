({
    sortKeyFunctionOnArray: function() {
		Array.prototype.sortOnKey = function(key) {
			this.sort(function(a, b) {
				if(a[key] > b[key]) return 1;
				if(a[key] < b[key]) return -1;
				return 0;
			});
		}
    },

    getFieldName : function(namespace, fieldName) {
        
		(namespace)? fieldName = namespace + '__' + fieldName : fieldName;
        return fieldName;
    },

    //loads configSettings into component
    loadConfigSettingsDetails: function(component, doNotCreateFilter) {
      
		var customSettingData,customSettingMetadata, consts, noOfRecords;
		customSettingData = component.get('v.customSettingByTypeSettingType');
		console.log( 'loadConfigSettingsDetails-customSettingData', customSettingData );
        
		consts = this.getConstants(component);
		customSettingMetadata = JSON.parse(component.get('v.customSettingMetadata'));
        console.log( 'customSettingMetadata', customSettingMetadata );
        
		this.sortKeyFunctionOnArray();
		customSettingData.sortOnKey(consts.TEXT1_FIELD);
		noOfRecords = customSettingData.length;
		
		component.set('v.customSetting', customSettingData);
		this.displayFieldList(component);
		if(!doNotCreateFilter) this.fireCreateComponentEvent(component, doNotCreateFilter);
    },

    displayFieldList: function(component) {
      
		var customSettingMetadata = JSON.parse(component.get("v.customSettingMetadata"));
		var displayFields = customSettingMetadata.filter(function(field) { return field.display; });
		component.set("v.displayFields", displayFields);
	},

    getConfigSettingsDetails: function(component) {
		
		var noOfRecords=component.get('v.noOfRecords');
        var type=component.get("v.settingType");
        
        var action = component.get("c.getConfigSettingDetails");
        action.setParams({ type: type });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                
                var res=response.getReturnValue();
                component.set('v.tempCustomSetting', res);
                component.set('v.originalCustomSetting', res); 
				
				//STORED IN AN ATTRIBUTE AS BACKUP AND IN CASE ALL FILTERS ARE CLEARED
                var topTwelve = res.slice( noOfRecords, noOfRecords + 10 );
                this.getFieldNamesList(component, topTwelve.length);
                this.fireCreateComponentEvent(component);
                
                component.set('v.noOfRecords', noOfRecords+10);
                component.set('v.customSetting', topTwelve);
                this.showElement(component, 'moreDiv');
                
                if(res === null || res.length===0 ){
                    component.set('v.errorMsg', consts.LEX_Controller_Exception);
                    this.showElement(component, 'errorMsgID');
                }
            } 
			else if (component.isValid() && state === "INCOMPLETE") {
                component.set('v.errorMsg', 'STATE : INCOMPLETE');
                this.showElement(component, 'errorMsgID');
            } 
			else if (component.isValid() && state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            component.set('v.errorMsg', errors[0].message);
                            this.showElement(component, 'errorMsgID');
                        }
                    } else {
                        component.set('v.errorMsg', 'Unknown Error');
                        this.showElement(component, 'errorMsgID');
                    }
                }
        });
        $A.enqueueAction(action);
    },

    showNextBatch : function(component){
        
		this.hideElement(component, 'moreDiv');
        this.showElement(component, 'scrollTextDiv');
        
        var noOfRecords=component.get('v.noOfRecords');
        var tempCustomSetting=component.get('v.tempCustomSetting');
        
        var newArr=tempCustomSetting.slice(noOfRecords, noOfRecords+10);
        component.set('v.noOfRecords', noOfRecords+10);
        
        var concatenatedArr=component.get('v.customSetting');
        concatenatedArr=concatenatedArr.concat(newArr);
        component.set('v.customSetting', concatenatedArr);
        
        if(concatenatedArr.length>=tempCustomSetting.length){
            this.hideElement(component, 'scrollTextDiv');
        }
    },

    fireCreateComponentEvent : function(component) {
      
		var filterEvt = component.getEvent('createFilter');
		filterEvt.setParams({
			customSettingList: component.get('v.customSettingByTypeSettingType'),
			displayFieldsMetadata: component.get("v.displayFields")
		});
		filterEvt.fire();
    },
    
    updateSettingIfAlreadyInUpdatedCSList: function(field, setting, updatedCustomSettingList) {
        
        //var newDuplicateCustomSettingList;
		var isCurrentSettingExistInList = false;
        updatedCustomSettingList.forEach( function(el,i, arr) {
            /*if(el.Id === setting.Id){
                newDuplicateCustomSettingList = el;
            }*/
            if (el.Id === setting.Id) {
                	el[(field.apiName)] = setting[(field.apiName)];
                	isCurrentSettingExistInList= true;
            }
        });
        /*if(newDuplicateCustomSettingList){
            console.log('newDuplicateCustomSettingList >',newDuplicateCustomSettingList);
            updatedCustomSettingList.splice(updatedCustomSettingList.indexOf(newDuplicateCustomSettingList),1);
        }*/
        if(isCurrentSettingExistInList ) return updatedCustomSettingList;
        if(field.isEdit) updatedCustomSettingList.push(setting);
        console.log('updatedCustomSettingList> ',updatedCustomSettingList);
		
        return updatedCustomSettingList;
    },

    updateClientSideConfigSettings: function(listToUpdate, customSettingList) {
        
		listToUpdate.forEach( function(elToUpdate) {
            customSettingList.forEach( function(el) {
                if(el.Name === elToUpdate.Name) {
                    for(var key in elToUpdate) {
                        el[key] = elToUpdate[key];
                    }
                }
            });
        });
        component.set('v.customSetting',customSettingList);
    },

    createConfigSettingRecordModal: function(component, setting) {
        
		var csTypeField, csTypeValue, csMetadataObj, body, consts;
        consts = this.getConstants(component);
        csTypeField = consts.TYPE_FIELD;
        csTypeValue = setting[csTypeField];
        csMetadataObj = {};
        csMetadataObj[csTypeValue] = JSON.parse(component.get('v.customSettingMetadata'));
		
        body = component.get("v.body");
        $A.createComponent(
            "c:configSettingRecordModal",
            {
                'csMetadata':csMetadataObj,
                'setting': setting,
                'isEdit': true,
                'namespace': component.get('v.namespace') 
            }, 
			function(newComponent, status, errorMessage) {
                
                if (status === "SUCCESS") {
                    body = component.get("v.body");
                    body.push(newComponent);
                    component.set("v.body", body);  
                } 
				else if (status === "INCOMPLETE") {
                    
                } 
				else if (status === "ERROR") {
                   
                }
            }
        ); 
    },

    callServerForDelete: function(component, csToDelete) {
        console.log('called callServerForDelete');
		var csListToDelete, customSettingList, consts;
        csListToDelete = [];
        customSettingList = JSON.stringify(component.get('v.customSetting'));
        consts = this.getConstants(component);
        csListToDelete.push(csToDelete);

		csListToDelete = this.addNamespaceToSettings(component, csListToDelete);

		var action = component.get("c.deleteConfigSettingRecordList");
		action.setParams({ 
			strListToDelete:  JSON.stringify(csListToDelete),  
			strListToReturn: customSettingList
		});
		
        action.setCallback(this, function(response) {
            
			var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                
                var res = response.getReturnValue();
                //console.log('callServerForDelete-res',res);
                console.log('In callback');
                if(res.startsWith("ERROR")) {
                    this.createToastAndRefresh(component, 'error', 'Error!', res);
                } 
				else {
                    var csList = JSON.parse(res);
                    this.sortKeyFunctionOnArray();
                    csList.sortOnKey(consts.TEXT1_FIELD);
                    component.set('v.customSetting', csList);
                    component.set('v.customSettingByTypeSettingType', csList);
                    component.set('v.InitialCustomSetting',JSON.stringify(csList));
                    this.createToastAndRefresh(component, 'success', 'Success!', 'Record deleted successfully!');
                }
                
            } 
			else if (component.isValid() && state === "INCOMPLETE") {
                this.createToastAndRefresh(component, 'error', 'Error!', 'state: INCOMPLETE');
            } 
			else if (component.isValid() && state === "ERROR") {
                var errors = response.getError();
                if (errors) {
					if (errors[0] && errors[0].message) {
						this.createToastAndRefresh(component, 'error', 'Error!', "Error message: " + errors[0].message);
					}
                } 
				else {
                    this.createToastAndRefresh(component, 'error', 'Error!', "Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    addNamespaceToSettings: function(component, configSettingList) {
        
		var namespace = component.get('v.namespace');
        var configSettingListWithNamespace = [];
        if(!configSettingList|| configSettingList.length<1 || !namespace) return configSettingList;
        configSettingList.forEach( function(el) {
            var configSettingWithNameSpace = {};
            for(key in el) {
                var newKey;
                (namespace && key.endsWith('__c'))? newKey = namespace+ '__' + key : newKey = key;
                configSettingWithNameSpace[newKey] = el[key]
            }
            configSettingListWithNamespace.push(configSettingWithNameSpace);
        });
        return configSettingListWithNamespace;
    },

    //Method to call server for saving updated values on page
    callServerForUpdate : function(component, cslistToUpdate, csToUpdate) {
        
        var missingRequiredField = [];
        var customSettingList, cslistToUpdateOnServer, consts;
        cslistToUpdateOnServer = [];
        customSettingList = component.get('v.customSetting');
        console.log('callServerForUpdate-customSettingList',customSettingList);
        
        consts = this.getConstants(component);
		if(csToUpdate) {
            cslistToUpdateOnServer.push(csToUpdate);
        } 
		else {
            cslistToUpdateOnServer = cslistToUpdate; 
            //Existing bug in salesforce that we need to stringify and send structured data
        }
        console.log('cslistToUpdateOnServer >',cslistToUpdateOnServer);
        console.log('customSettingList >',customSettingList);
        
        var isRequiredFieldMissing = this.isRequiredFieldMissing(component, event, customSettingList, missingRequiredField);

        if(!isRequiredFieldMissing){
            cslistToUpdateOnServer = this.addNamespaceToSettings(component, cslistToUpdateOnServer);
        	customSettingList = this.addNamespaceToSettings(component, customSettingList);
            var action = component.get("c.updateEditedValues");
        action.setParams({ 
            strListToUpdate:  JSON.stringify(cslistToUpdateOnServer),  
            strListToReturn: JSON.stringify(customSettingList)
        });
		
        action.setCallback(this, function(response) {
            
            //this.showSpinner( component, false, 'spinnerDiv' );
            
			var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var res = response.getReturnValue();
                console.log('callServerForUpdate-res',res);
                
                if(res.startsWith("ERROR")) {
                    this.createToastAndRefresh(component, 'error', 'Error!', res);
                } 
				else {
                    var csList = JSON.parse(res);
                    this.sortKeyFunctionOnArray();
                    
                    csList.sortOnKey(consts.TEXT1_FIELD);
                    component.set('v.customSetting', csList);
                    component.set('v.customSettingByTypeSettingType', csList);
                    component.set('v.InitialCustomSetting',JSON.stringify(csList));
                    var message = consts.LBL_SUCCESS_RECORD_SAVE;
                    if( cslistToUpdateOnServer && cslistToUpdateOnServer.length > 1 ) {
                        message = consts.LBL_SUCCESS_RECORDS_SAVE;
                    }
                    this.createToastAndRefresh(component, 'success', 'Success!', message );
                    
                    if(!csToUpdate) component.set('v.updatedCustomSettingList', []);
                }
                
            } 
			else if (component.isValid() && state === "INCOMPLETE") {
                this.createToastAndRefresh(component, 'error', 'Error!', 'state: INCOMPLETE');
            } 
			else if (component.isValid() && state === "ERROR") {
                var errors = response.getError();
                if (errors) {
					if (errors[0] && errors[0].message) {
						this.createToastAndRefresh(component, 'error', 'Error!', "Error message: " + errors[0].message);
					}
                } 
				else {
                    this.createToastAndRefresh(component, 'error', 'Error!', "Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
        } else {
            this.createToastAndRefresh(component, 'error', 'Error!', "Sorry, Unable to save changes. Required fields were missing [ "+ missingRequiredField +"]");
        }
		
    },
    
    isRequiredFieldMissing : function(component, event, customSettingList, missingRequiredField){
        var isRequiredFieldEmpty = false;
        var missingRequiredFieldLabel = [];
        var requiredFields = [];
        
        var obj = JSON.parse(component.get('v.customSettingMetadata'));
        
        console.log('obj>',obj);
        for(var i =0 ; i< obj.length ; i++){
            if(obj[i].isRequired){
                console.log(obj[i].apiName);
                requiredFields.push(obj[i].apiName);
                missingRequiredFieldLabel.push(obj[i].labelName);
            }
        }
        console.log('requiredFields lst>',requiredFields);
        
        for(var i=0; i< customSettingList.length ;i++ ){
            for(var j=0; j<requiredFields.length; j++ ){
                if(!customSettingList[i][requiredFields[j]]) {
                    if(missingRequiredField.indexOf(missingRequiredFieldLabel[j]) == -1){
                     	missingRequiredField.push(missingRequiredFieldLabel[j]); 
                        isRequiredFieldEmpty = true;
                    }
                } 
            }
        }
        return isRequiredFieldEmpty;
    },
    

    //Method to show filtered out records limiting the 10 at a time
    handleFilterTableEvent : function(component, event){
        
		var filteredCustomSettingList = event.getParam('filteredCustomSettingList');
        var noOfFields = filteredCustomSettingList.length;
        if(filteredCustomSettingList === null || filteredCustomSettingList.length=== 0) {
            
			//Setting full table size
            component.set('v.tableSize', component.get('v.tempCustomSetting').length*noOfFields);
            component.set('v.isNotFiltered', true);
            this.showElement(component, 'noRecordsDiv');
            component.set('v.customSetting', filteredCustomSettingList);
        } 
		else {
			component.set('v.customSetting', filteredCustomSettingList);
            this.hideElement(component, 'noRecordsDiv');
        }
		
        component.set('v.numberOfChildComponents', 0);
        this.hideElement(component, 'scrollTextDiv');
    },

    createToastAndRefresh : function(component, type, title, message){
        
        var updatedCustomSettingList = component.get('v.updatedCustomSettingList');
        if( type === 'error') {
            var InitialCustomSetting = component.get('v.InitialCustomSetting');
            if( InitialCustomSetting ) {
                updatedCustomSettingList = JSON.parse( InitialCustomSetting );
                console.log( 'updatedCustomSettingList reverted on error' );
            }
        }
        
		var afterSaveRefresh=$A.get("e.c:afterSaveRefresh");
		afterSaveRefresh.setParams({
			"toastMSG" : message,
			"toastTitle" : title,
			"toastType" : type,
			"isNewEntry": false,
			"updatedSettings":updatedCustomSettingList 
		});
		afterSaveRefresh.fire();
    },

    showElement : function(component, id){
		
		var divElement = component.find(id);
        if( divElement ) {
            $A.util.removeClass(divElement, 'slds-hide');
            $A.util.addClass(divElement, 'slds-show');
        }
    },

    hideElement : function(component, id){
        
		var divElement = component.find(id);
        if( divElement ) {
            $A.util.removeClass(divElement, 'slds-show');
        	$A.util.addClass(divElement, 'slds-hide');
        }
    },

    //method to increase count of number of components rendered
    countComponents : function(component) {
        
		var counter = component.get("v.numberOfChildComponents");
        if(counter < component.get("v.tableSize")-1){
            counter++;
            component.set("v.numberOfChildComponents",  counter);
        } 
		else {
        }
    },

    showSpinner: function(component, isVisible, spinnerDiv) {
        
        if ( isVisible ) { 
            this.showElement(component, spinnerDiv);
        }
        else {
            this.hideElement(component, spinnerDiv);
        }
    },

    showToast : function(component, csObj) {
        
		var consts = this.getConstants(component);
        $A.createComponent( "c:ToastComponent", 
			{
                "type" : 'prompt',
                "title" :  consts.LBL_RECORD_DELETE_CONFIRMATION_HEADER,
                "message": consts.LBL_RECORD_DELETE_CONFIRMATION,
                "cstype": 'TimeTrackerConfigSettings__c',
                "csObj":  csObj,
            }, 
			function(newToast, status, errorMessage) {
                if (status === "SUCCESS") {
                    var body = component.get("v.body");
                    body.push(newToast);
                    component.set("v.body", body);  
                } 
				else if (status === "INCOMPLETE") {
                } 
				else if (status === "ERROR") {
                }
            }
        );
    },
	
	getConstants: function(component) {
        
        var consts = {
        				'TEXT1_FIELD': 'Text1__c',
        				'TYPE_FIELD':'Type__c',
        				'LBL_NO_RECORDS':'No records were fetched with these filters.',
        				'LBL_MORE_RECORDS':'Click or scroll down for more records',
        				'LBL_RECORD_DELETE_CONFIRMATION_HEADER':'Record Deletion',
        				'LBL_RECORD_DELETE_CONFIRMATION':'The record will be deleted. Are you sure?',
        				'LBL_EDIT':'Edit',
        				'LBL_DEL':'Del',
        				'LBL_ACTION':'Action',
            			'LBL_SUCCESS_RECORD_SAVE': 'Record Saved Successfully!',
						'LBL_SUCCESS_RECORDS_SAVE': 'Records Saved Successfully!'
        			};
        if(component.get('v.namespace')){
        	consts['LEX_Controller_Exception'] = $A.get("$Label.timetracker.LEX_Controller_Exception");
        }
        else {
        	consts['LEX_Controller_Exception'] = $A.get("$Label.c.LEX_Controller_Exception");
        }
        return consts;    
    }
})