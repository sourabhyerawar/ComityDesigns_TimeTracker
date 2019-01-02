({
	getConfigSettingList: function(settings) {
		
		var csList = [];
		for(var key in settings.ConfigSettings) {
			csList.push(settings.ConfigSettings[key]);
		}
		return csList;
	},
	
	loadOptionsForSObjectFields: function(component) {
        
		var objectDetails, objectFieldListStr, selectOptions, consts;
        objectDetails = component.get("v.objectDetails");
        consts = this.getConstants(component);
		
        if(!objectDetails) { return; }
		
        objectFieldListStr = objectDetails["ObjFields"];
        
		selectOptions = [];

        selectOptions.push ( { 'class': 'optionClass','label': consts.LBL_SELECT, 'value': consts.LBL_SELECT });
        var objectFieldList = objectFieldListStr.split(';');
        for(var i=0; i<objectFieldList.length; i++) {
            selectOptions.push ( { 'class': 'optionClass','label': objectFieldList[i], 'value': objectFieldList[i] });
        }
        component.find('sobjectFieldId').set('v.options', selectOptions);
    },

	createCustomSettings: function(component) {
		
		var settingList =[]
		var csType = component.get('v.tablabel');
		switch(csType) {
			case 'MANUALACTIVITY': 
				settingList = this.createManualSettings(component);
				break;
			case 'CUSTOMOBJECT': 
				settingList = this.createCustomEventSettings(component);
				break;
			case 'VFPAGE': 
				settingList = this.createVFPageSettings(component)
				break;
			default:
		}
		return settingList;
	},

    loadConfigSettingRecordComponent: function(component, index) {
		
        var configSettingMetadata, settings, newActivityCsList, configsettingsList, namespace;
        var configsettingRecordToVerify;
        
        configSettingMetadata = JSON.parse(component.get("v.csMetadata"));
        settings = JSON.parse(component.get("v.settings"));
		newActivityCsList = component.get("v.newActivityCsList");
        configsettingsList = this.getConfigSettingList(settings);
        namespace = settings.Namespace;
		configsettingRecordToVerify = newActivityCsList[index];
        console.log( 'configsettingRecordToVerify', configsettingRecordToVerify );
        
        $A.createComponent(
            "c:ConfigSettingRecord",
            { 
			  "configsettingmetadata": configSettingMetadata,
			  "configsetting": configsettingRecordToVerify,
			  "originalCsList": configsettingsList,
			  "verifiySettingsListIndex": index,
              "namespace": namespace
			}, 
			function(newButton, status, errorMessage) {
				//Add the new button to the body array
				if (status === "SUCCESS") {
					component.set("v.body", []);
					var body = component.get("v.body");
					body.push(newButton);
					component.set("v.body", body);
				} 
				else if (status === "INCOMPLETE") {
				} 
				else if (status === "ERROR") {
				}
			}
        );
	},
    
    createToastComponent : function(component,type, title, message, jsonUpdatedSettings){
		
		var updatedSettings = [];
        if( jsonUpdatedSettings ) {
            updatedSettings = JSON.parse( jsonUpdatedSettings );
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

    addNamespaceToSettings: function(component, configSettingList) {
        
		var settings = JSON.parse(component.get('v.settings'));
        var namespace = settings.Namespace;
        var configSettingListWithNamespace = [];
        if(!configSettingList|| configSettingList.length<1) return;
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

    createTimeTrackerConfigSettings: function(component, configSettingList ){
        
        configSettingList = this.addNamespaceToSettings(component, configSettingList);
        var consts = this.getConstants(component);
        
		var action = component.get('c.insertTimeTrackerConfigSettings');
        action.setParams({ 
            'ttconfigSettingsList' : JSON.stringify(configSettingList),
            'areIdsPresent' : true
        });
        action.setCallback(this, function(response) {
            
			var state = response.getState();
            var res = response.getReturnValue(); 
            
            if ( component.isValid() && state === "SUCCESS" ) {
                if( !res.startsWith("ERROR")) {
                    
                    var message = consts.LBL_SUCCESS_RECORD_SAVE;
                    if( configSettingList && configSettingList.length > 1 ) {
                        message = consts.LBL_SUCCESS_RECORDS_SAVE;
                    }
                    component.set("v.newActivityCsList",JSON.parse(res));
                    this.createToastComponent(component,'success','Success!', message, res);
                    this.loadConfigSettingRecordComponent( component, 0 );
                } 
				else {
                    this.createToastComponent( component,'error','EXCEPTION!', res, null );
                }
            } 
			else if (component.isValid() && state === "INCOMPLETE") {
                this.createToastComponent(component, 'error', 'INCOMPLETE!', 'An unexpected error occurred while saving the record(s).', null );
            } 
			else if (component.isValid() && state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    (errors[0] && errors[0].message.length<200) ? 
                        this.createToastComponent(component,'error','Error!',errors[0].message, null)
                            : this.createToastComponent(component,'error','Error!','Error in saving record',null);
                } 
				else {
                    this.createToastComponent(component,'error','Error!','Unknown error',null);
                }
            }
        });
        $A.enqueueAction(action);
    },
	
    relateWithExistingRecords : function( component, listOfNewCustomSettings ) {
		
        console.log( 'listOfNewCustomSettings', JSON.stringify( listOfNewCustomSettings ) );
		if( listOfNewCustomSettings && listOfNewCustomSettings.length > 0 ) {
			var settings = component.get( "v.settings" );
			if( settings ) {
				
				settings = JSON.parse( settings );
				var listOfOldCustomSettings = this.getConfigSettingList( settings );
                console.log( 'listOfOldCustomSettings', JSON.stringify( listOfOldCustomSettings ) );
				if( listOfOldCustomSettings && listOfOldCustomSettings.length > 0 ) {
					
					var consts = this.getConstants( component );
					var typeField = consts.TYPE_FIELD;
					var comparingFieldApiName = '';
		
					listOfNewCustomSettings.forEach( function( newCustomSettingRecord ) {
						
						comparingFieldApiName = '';
						var filterResult = listOfOldCustomSettings.filter( function( oldCustomSettingRecord ) {
							if( oldCustomSettingRecord.Name && newCustomSettingRecord.Name ) {
							   return oldCustomSettingRecord.Name.toLowerCase() === newCustomSettingRecord.Name.toLowerCase()
							}
						});
						console.log( 'name matched filterResult', filterResult );
						if( filterResult.length > 0 ) {
							newCustomSettingRecord.Id = filterResult[0].Id;
						}
						else {
							if( newCustomSettingRecord[ typeField ] === consts.VAL_CUSTOM_EVENT_LABEL ) {
								comparingFieldApiName = consts.CODE1_FIELD;
							}
							else {
								comparingFieldApiName = consts.TEXT1_FIELD;
							}
							console.log( 'comparingFieldApiName', comparingFieldApiName );
							filterResult = listOfOldCustomSettings.filter( function( oldCustomSettingRecord ) {
								if( oldCustomSettingRecord[ typeField ] && newCustomSettingRecord[ typeField ] && 
									oldCustomSettingRecord[ comparingFieldApiName] && newCustomSettingRecord[ comparingFieldApiName ]
								) {
								   return oldCustomSettingRecord[ typeField ].toLowerCase() === newCustomSettingRecord[ typeField ].toLowerCase() && oldCustomSettingRecord[ comparingFieldApiName ].toLowerCase() === newCustomSettingRecord[ comparingFieldApiName ].toLowerCase()
								}
							});
							console.log( 'type matched filterResult', filterResult );
							if( filterResult.length > 0 ) {
								newCustomSettingRecord.Id = filterResult[0].Id;
							}
						}
					});
				}
			}
		}
        return listOfNewCustomSettings;
	},
    
	getConstants: function(component) {
		
        var consts = {
						'LBL_SAVE_ALL': 'Save All',
						'LBL_VERIFY_CS_DETAILS':'Verify Custom Setting Details',
            			'LBL_SUCCESS_RECORD_SAVE': 'Record Saved Successfully!',
						'LBL_SUCCESS_RECORDS_SAVE': 'Records Saved Successfully!',
            			'TYPE_FIELD': 'Type__c',
						'TEXT1_FIELD': 'Text1__c',
						'CODE1_FIELD': 'Code1__c',
					 };
		if( component.get( 'v.namespace' ) ) {
			consts[ 'LBL_SELECT' ] = $A.get("$Label.timetracker.LBL_Select_DropDown");
            consts['VAL_CUSTOM_EVENT_LABEL'] = $A.get( "$Label.timetracker.LBL_ConfigSetting_Custom_Event" );
		}
		else {
			consts[ 'LBL_SELECT' ] = $A.get("$Label.c.LBL_Select_DropDown");
            consts['VAL_CUSTOM_EVENT_LABEL'] = $A.get( "$Label.c.LBL_ConfigSetting_Custom_Event" );
		}
		return consts;
    }
})