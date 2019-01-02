({
	getFieldName : function(namespace, fieldName) {
		
		(namespace) ? fieldName = namespace + '__' + fieldName : fieldName;
		return fieldName;
	},
	
	isCurrentCsPresentInCsList: function(component, helper, namespace, cs, csList) {
		
        if( !cs || !csList ) {
            return false;
        }
		
        var typeField, comparingFieldApiName, csObj, consts, message;
        consts = this.getConstants(component);
		typeField = helper.getFieldName(null, consts.TYPE_FIELD);
		
		csObj = csList.filter( function(el) {
            if( el.Name && cs.Name ) {
               return el.Name.toLowerCase() === cs.Name.toLowerCase()
            }
        });
        
        if( csObj.length > 0 ) {
            return { 'state': consts.STATE_ERROR, 'message': consts.LBL_CS_NAME_EXIST };
        }
		
		if( cs[ typeField ] === consts.VAL_CUSTOM_EVENT_LABEL || 
           	cs[ typeField ] === consts.VAL_OBJECT_SETTINGS_LABEL || 
           	cs[ typeField ] === consts.VAL_URL_PATTERN_LABEL
		) {
			comparingFieldApiName = helper.getFieldName( null, consts.CODE1_FIELD );
            message = consts.LBL_CS_REG_EX_URL_EXIST;
		}
		else {
			comparingFieldApiName = helper.getFieldName( null, consts.TEXT1_FIELD );
            message = consts.LBL_CS_ACT_TYPE_EXIST;
		}
        
		csObj = csList.filter( function (el) {
            if( el[ typeField ] && cs[ typeField ] && el[ comparingFieldApiName ] && cs[ comparingFieldApiName ] ) {
                
                if( cs[ typeField ] !== consts.VAL_CUSTOM_EVENT_LABEL && cs[ typeField ] !== consts.VAL_OBJECT_SETTINGS_LABEL ) {
            		return el[ typeField ].toLowerCase() === cs[ typeField ].toLowerCase() && el[ comparingFieldApiName ].toLowerCase() === cs[ comparingFieldApiName ].toLowerCase()
                }
                else {
                    return el[ typeField ].toLowerCase() === cs[ typeField ].toLowerCase() && el[ comparingFieldApiName ] === cs[ comparingFieldApiName ]
                }
            }
        });
        
        if( csObj.length > 0 ) {
            return { 'state': consts.STATE_ERROR, 'message': message };
        }
        else {
            return false;
        }
	},

	createToastComponent : function(component,type, title, message, updatedSettings) {
		
        if( updatedSettings ) {
            updatedSettings = JSON.parse(updatedSettings);
        }
        var afterSaveRefresh=$A.get("e.c:afterSaveRefresh");
        afterSaveRefresh.setParams({
            toastMSG: message,
            toastTitle: title,
            toastType: type,
            updatedSettings: updatedSettings
        });
        afterSaveRefresh.fire();
    },

    fireCallServerEvent: function(component, csToUpdate) {
    	
		var evt = $A.get('e.c:callServerEvent');
        evt.setParams({ "csToUpdate": csToUpdate });
        evt.fire();
    },

    fireCloseConfigSettingRecordModalEvent: function(component, compEvent) {
        
		compEvent.fire();
    },

    fireUpdateSettingsInProgressComponent: function(component, event) {
        
        var updateSettingsInProgressComponentEvt = component.getEvent( "updateSettingsInProgressComponent" );
        var configSettingRecord = component.get("v.configsetting");
        var updatedRecordIndex = component.get( "v.verifiySettingsListIndex" );
        
        updateSettingsInProgressComponentEvt.setParams({ "configSettingRecord": configSettingRecord, 
                                                         "updatedRecordIndex" : updatedRecordIndex
                                                      });
        updateSettingsInProgressComponentEvt.fire();
    },

    addNamespaceToSettings: function(component, configSettingList) {
        
        var namespace = component.get('v.namespace');
        if(!configSettingList || configSettingList.length<1 || !namespace) return configSettingList;
        
        var configSettingListWithNamespace = [];
        configSettingList.forEach(function(el) {
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

    createTimeTrackerConfigSettings: function(component, configSettingList ) {
            
        configSettingList = this.addNamespaceToSettings(component, configSettingList);
		var action = component.get('c.insertTimeTrackerConfigSettings');
        var consts = this.getConstants(component);
        action.setParams({ 
            ttconfigSettingsList: JSON.stringify(configSettingList),
            'areIdsPresent' : true
        });
        
		action.setCallback(this, function(response) {
            
            var state = response.getState();
			var res=response.getReturnValue();
            
			if (component.isValid() && state === consts.STATE_SUCCESS) {
                if(!res.startsWith(consts.STATE_ERROR)) {
                    
                    var configsetting = component.get("v.configsetting");                    
                    var listOfUpdatedRecords = JSON.parse(res);
					                    
                    if( listOfUpdatedRecords && listOfUpdatedRecords.length > 0 ) {
                        component.set( "v.configsetting", listOfUpdatedRecords[0] );
                        component.set( "v.lastSavedConfigSettingJson", JSON.stringify( listOfUpdatedRecords[0] ) );
                        
                        var isModalOpened = component.get( "v.isModal" );
                        if( !isModalOpened ) {
                            this.fireUpdateSettingsInProgressComponent(component, event);
                        }
                    }
                    
                    var message = consts.LBL_SUCCESS_RECORD_SAVE;
                    if( configSettingList && configSettingList.length > 1 ) {
                        message = consts.LBL_SUCCESS_RECORDS_SAVE;
                    }
                    this.createToastComponent(component,'success','Success!', message, res);
                    component.set( 'v.editMode', false );
                } else {
                    this.showSpinner(component, false);
                    this.createToastComponent(component,'error','EXCEPTION!',res);
                }
            } 
			else if (component.isValid() && state === consts.STATE_INCOMPLETE) {
                this.createToastComponent(component,'error','INCOMPLETE!', consts.LBL_ERROR_INCOMPLETE);
            } 
			else if (component.isValid() && state === consts.STATE_ERROR) {
                var errors = response.getError();
                if (errors) {
                    (errors[0] && errors[0].message.length<200) ? 
                        this.createToastComponent(component,'error','Error!',errors[0].message)
                    : this.createToastComponent(component,'error','Error!',consts.LBL_ERROR_RECORD_SAVE);
                } 
				else {
                    this.createToastComponent(component,'error','Error!',LBL_ERROR_UNKNOWN);
                }
            }
        });
        $A.enqueueAction(action);
    },

    applyCSS: function(cmp, event, divid, className) {
        
		var cmpTarget = cmp.find(divid);
        $A.util.addClass(cmpTarget, className);
    },
    
    removeCSS: function(cmp, event, divid, className) {
        
		var cmpTarget = cmp.find(divid);
        $A.util.removeClass(cmpTarget, className);
    },
    
    validateForm : function( component ) {
			
		var formStatus = { 'type' : 'success', 'title' : 'Success!', 'message' : '' };
		var configSettingToUpdate = component.get("v.configsetting");
        
		if( configSettingToUpdate ) {
            var consts = this.getConstants(component);
			if( consts ) {
				
				var fieldNameToFieldDetails = component.get( "v.csfield" );
				if( fieldNameToFieldDetails ) {
					
					Object.keys( fieldNameToFieldDetails ).forEach( function( fieldApiNameAsKey, index ) {
						
						var fieldDetails = fieldNameToFieldDetails[ fieldApiNameAsKey ];
						if( fieldDetails.isRequired && !configSettingToUpdate[ fieldApiNameAsKey ] ) {
							formStatus.type = 'error';
							formStatus.title = 'Error!';
							
							if( fieldDetails.labelName ) {
								formStatus.message =  'Sorry, ' + fieldDetails.labelName + ' may not be empty.';
							}
							else {
								formStatus.message =  'Sorry, Required fields were missing. Please fill the form again.';
							}
							return formStatus;
						}
					});
					
				}
				else {
					formStatus.type = 'error';
					formStatus.title = 'Error!';
					formStatus.message = 'Sorry, field details were missing, please refresh the page.';
				}
			}
			else {
				formStatus.type = 'error';
				formStatus.title = 'Error!';
				formStatus.message = 'Sorry, predefined configuration details were missing, please refresh the page.';
			}
		}
		else {
			formStatus.type = 'error';
			formStatus.title = 'Error!';
			formStatus.message = 'Sorry, record details were missing, please refresh the page.';
		}
		return formStatus;
	},
	
    showSpinner: function(component, isVisible) {
        
		var spinner = component.find("spinnerDiv");
        if(isVisible){
            this.showElement(component, spinner);
        }
        else{
            this.hideElement(component, spinner);
        }
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
    
    stylePageMessage : function( component, messageType ) {
    	
        if( messageType ) {
            var pageHeaderDiv = component.find( "pageheader");
            if( pageHeaderDiv ) {
                
                var pageHeaderMessageDiv = component.find( "pageHeaderMessage");
                if( pageHeaderMessageDiv ) {
                	if( messageType.toLowerCase() === 'warning') {
                		$A.util.removeClass( pageHeaderDiv, 'infoSection');
                        $A.util.removeClass( pageHeaderMessageDiv, 'infoMessage');
                    }
                    else {
                        $A.util.addClass( pageHeaderDiv, 'infoSection');
                        $A.util.addClass( pageHeaderMessageDiv, 'infoMessage');
                    }    
                }
            }
        }
    },
    
    hideFieldsForStrategy : function( component, configsetting ) {
        
		console.log( 'hideFieldsForStrategy-configsetting', configsetting );
		if( configsetting ) {
			var consts = this.getConstants( component );
			if( consts ) {
				
				console.log( 'consts.VAL_STRATEGY_LABEL', consts.VAL_STRATEGY_LABEL );
				var configSettingType = configsetting[ consts.TYPE_FIELD ];
				console.log( 'configSettingType', configSettingType );
				if( configSettingType === consts.VAL_STRATEGY_LABEL || configSettingType === 'Strategy' ) {
					
					var strategySubType = '';
					var text1FieldValue = configsetting[ consts.TEXT1_FIELD ];
					console.log( 'text1FieldValue', text1FieldValue );
					if( text1FieldValue ) {
						
						text1FieldValue = text1FieldValue.toLowerCase();
						if( text1FieldValue.includes('new ') ) {
							strategySubType = 'NEW';
						}
						else if( text1FieldValue.includes('edit ') ) {
							strategySubType = 'EDIT';
						}
						else if( text1FieldValue.includes(' review') ) {
							strategySubType = 'REVIEW';
						}
						else if( text1FieldValue.includes('list view') ) {
							strategySubType = 'LIST';
						}
					}
					
					console.log( 'strategySubType', strategySubType );
					var listOfFieldValueProviders = this.getListOfFieldValueProviders( component, strategySubType );
                    console.log( 'listOfFieldValueProviders', listOfFieldValueProviders.length );
                    
                    if( listOfFieldValueProviders && listOfFieldValueProviders.length > 0 ) {
                        
                        listOfFieldValueProviders.forEach( function( fieldValueProvider ) {
							component.set( fieldValueProvider, false );
						});
					}
				}
			}
		}
    },
    
	getListOfFieldValueProviders: function( component, strategySubType ) {
		
		var listOfFieldValueProviders = [];
		if( strategySubType ) {
			switch( strategySubType ) {
				
				case 'NEW':
						listOfFieldValueProviders = [ 'v.showText5Field', 'v.showText6Field' ];
						break;
						
				case 'EDIT':
						listOfFieldValueProviders = [ 'v.showText5Field', 'v.showText6Field' ];
						break;
													  
				case 'REVIEW':
						listOfFieldValueProviders = [ 'v.showText7Field', 'v.showText8Field' ];
						break;
													  
				case 'LIST':
						listOfFieldValueProviders = ['v.showText5Field','v.showText6Field','v.showText7Field','v.showText8Field'];
						break;
						
				case 'OTHER':
						listOfFieldValueProviders = [];
						break;
						
				default:
						break;
			}
			console.log( 'listOfFieldValueProviders', listOfFieldValueProviders );
		}
        return listOfFieldValueProviders;
	},
	
	getConstants: function(component) {
		
		var consts = {
						'STATE_SUCCESS':'SUCCESS',
						'STATE_ERROR':'ERROR',
						'STATE_INCOMPLETE':'ERROR',
		
						'TYPE_FIELD': 'Type__c',
						'TEXT1_FIELD': 'Text1__c',
						'CODE1_FIELD': 'Code1__c',
		
						'LBL_SUCCESS_RECORD_SAVE': 'Record Saved Successfully!',
						'LBL_SUCCESS_RECORDS_SAVE': 'Records Saved Successfully!',
            
						'LBL_ERROR_RECORD_SAVE': 'Error while saving the record',
						'LBL_ERROR_INCOMPLETE': 'Record creation incomplete',
						'LBL_ERROR_UNKNOWN': 'Unknown error',
		
						'LBL_CS_NAME_EXIST': 'Custom setting with same name already exists.',
						'LBL_CS_ACT_TYPE_EXIST': 'Custom setting with same name and same type already exists.',
						'LBL_CS_REG_EX_URL_EXIST': 'Custom setting with same type and RegEx-Matching URL already exists.', 
		
						'LBL_EDIT_BTN': 'Edit',
						'LBL_SAVE_BTN': 'Save',
						'LBL_CANCEL_BTN': 'Cancel',
						
						'LBL_LIST_VIEW_STRATEGIES': 'List View Strategies',
						'LBL_OBJECT_REVIEW_STRATEGIES': 'Object Review Strategies',
						'LBL_NEW_OBJECT_STRATEGIES': 'New Object Strategies',
						'LBL_EDIT_OBJECT_STRATEGIES': 'Edit Object Strategies',
						'LBL_OTHER_STRATEGIES': 'Other Strategies'
					};
					
		if(component.get('v.namespace')){
			 consts['VAL_STRATEGY_LABEL'] = $A.get( "$Label.timetracker.LBL_ConfigSetting_Strategy" );
			 consts['VAL_OBJECT_SETTINGS_LABEL'] = $A.get( "$Label.timetracker.LBL_ConfigSetting_Object" );
			 consts['VAL_CUSTOM_EVENT_LABEL'] = $A.get( "$Label.timetracker.LBL_ConfigSetting_Custom_Event" );
			 consts['VAL_URL_PATTERN_LABEL'] = $A.get( "$Label.timetracker.LBL_ConfigSetting_URLPattern" );
			 consts['VAL_MANUAL_ACTIVITY_LABEL'] = $A.get( "$Label.timetracker.LBL_ConfigSetting_Manual" );
		} 
		else {
			 consts['VAL_STRATEGY_LABEL'] = $A.get( "$Label.c.LBL_ConfigSetting_Strategy" );
			 consts['VAL_OBJECT_SETTINGS_LABEL'] = $A.get( "$Label.c.LBL_ConfigSetting_Object" );
			 consts['VAL_CUSTOM_EVENT_LABEL'] = $A.get( "$Label.c.LBL_ConfigSetting_Custom_Event" );
			 consts['VAL_URL_PATTERN_LABEL'] = $A.get( "$Label.c.LBL_ConfigSetting_URLPattern" );
			 consts['VAL_MANUAL_ACTIVITY_LABEL'] = $A.get( "$Label.c.LBL_ConfigSetting_Manual" );
		}
		return consts;
	}
})