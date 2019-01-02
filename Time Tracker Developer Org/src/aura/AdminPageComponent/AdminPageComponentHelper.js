({
    //Function to get settings from Apex
    getSettingsFromServer : function(component) {
        
        var consts = this.getConstants(component);
        
		var action = component.get("c.getSettings");
        action.setParams({ dummy : '' });
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === consts.SUCCESS) {
                console.log("getSettingsFromServer", JSON.parse( response.getReturnValue() ) );
                component.set( 'v.settings', response.getReturnValue() );
            } 
            else if (state === "INCOMPLETE") {
                console.log( "State is incomplete" );
            } 
			else if (state === consts.ERROR) {
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log("Error message: " + errors[0].message);
					}
				} else {
					console.log("Unknown error");
				}
			}
        });
        $A.enqueueAction(action);
    },
	
    setNameSpace : function( component,helper ) {
        
        var action = component.get( "c.getNameSpace");
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if ( state === 'SUCCESS' ) {
                
                var result = response.getReturnValue();
                component.set( "v.namespace", result );
                
                var consts = helper.getConstants(component);
                console.log( 'setNameSpace-consts', consts );
                component.set('v.consts',consts);
            }
        });
        $A.enqueueAction(action);
    },
    
    //function to get settings data from global attribute
    getTTSettings: function(cmp) {
      
		//console.log('AdminPageComponentHelper.getTTSettings: entered');
		var settings = cmp.get("v.settings");
		var settingsObj = JSON.parse(settings);
		console.log('getTTSettings-settingsObj:',settingsObj);
		return settingsObj;
    },

    //function to change config settings after update on server
    updateConfigSettings : function(component, newUpdatedSettings) {
        
		console.log('updateConfigSettings-newUpdatedSettings',newUpdatedSettings);
		var settings = JSON.parse(component.get("v.settings"));
		var consts = this.getConstants(component);
		if(!newUpdatedSettings || !settings) return;
        
		newUpdatedSettings.forEach(function(el) {
			
			var isIdMatched = false;
			for( var settingNameAsKey in settings.ConfigSettings ) {
				if( settings.ConfigSettings[ settingNameAsKey ] &&
                    settings.ConfigSettings[ settingNameAsKey ].Id === el.Id ) {
					
					isIdMatched = true;
					for(var key in el) { 
						settings.ConfigSettings[settingNameAsKey][key] = el[key]; 
					}
				}
			}
			
			if( !isIdMatched ) {
				settings.ConfigSettings[ el.Name ] = el;
			}
        });
        
		console.log( 'after update settings', settings );
        component.set("v.settings", JSON.stringify(settings));
        
        if( component.get('v.selectedTabid')!=='tab1') {
            component.find("customsettingtype").set('v.value', consts.LBL_SELECT);
            component.set("v.configSettingsTableComponent", []);
        	component.set('v.filterFacet', []);
        }   
        else {
            var customSettingsType, customSettingMetadata, relatedCustomSettings;
            customSettingsType = component.find("customsettingtype").get("v.value");
            customSettingMetadata = (JSON.parse(component.get("v.customSettingMetadata")))[customSettingsType];
            relatedCustomSettings = this.getTTSettingsByType(component,customSettingsType, settings.ConfigSettings);
            console.log( 'Before filter by subtype', relatedCustomSettings );
            
            if( customSettingsType === consts.LBL_STRATEGY ) {
                var strategySettingsType = component.find("strategysettingtype").get("v.value");
                relatedCustomSettings = this.filterStrategiesByActivityType( component, settings.Namespace, relatedCustomSettings, strategySettingsType );
        		console.log( 'After filter by subtype', relatedCustomSettings );
            }
            
			//console.log( 'relatedCustomSettings',relatedCustomSettings);
            this.loadConfigSettingsDetailsComponent(component, customSettingsType, 
                                                    relatedCustomSettings, customSettingMetadata
                                                   );
        }
    },

    deleteConfigSetting: function(component, deleteSetting) {
        
		if(!deleteSetting) return;
		var settings = JSON.parse(component.get('v.settings'));
		delete settings['ConfigSettings'][deleteSetting.Name];
		component.set('v.settings',JSON.stringify(settings));
    },

    //function to get name of field of custom settings from namespace
    getCustomSettingsFieldName: function(namespace, name) {
      
		return (namespace) ? namespace+'__'+name : name;
    },

    //function to get custom settings according to particular type i.e Manual, Object, URL, Strategy etc
    getTTSettingsByType: function(component,type, settings) {
      
		var requiredSettings=[];
		var consts = this.getConstants(component);
		var customSettingsType = consts.TYPE_FIELD;

		for(var key in settings) {
			if (settings.hasOwnProperty(key) && settings[key][customSettingsType] === type) {
				requiredSettings.push(settings[key]);
			}
		}
        return requiredSettings;
    },

    filterStrategiesByActivityType: function(component,namespace, strategySettings, activityType) {
        
		if(!strategySettings || !activityType) { return; }
        var consts, text1, requiredStrategySettings;
        consts = this.getConstants(component);
        
		text1 = consts.TEXT1_FIELD;
        requiredStrategySettings=[];
        
		for(var i=0; i<strategySettings.length; i++) {
            switch(activityType){
                case consts.LBL_LIST_VIEW_STRATEGIES :
                    if(strategySettings[i][text1] && strategySettings[i][text1].toLowerCase().includes('list view')){
                        
						//console.log(strategySettings[i][text1]);
                        requiredStrategySettings.push(strategySettings[i]);
                    }
					break;
                case consts.LBL_OBJECT_REVIEW_STRATEGIES:
                    if(strategySettings[i][text1] && strategySettings[i][text1].toLowerCase().includes(' review')){
                        //console.log(strategySettings[i][text1]);
                        requiredStrategySettings.push(strategySettings[i]);
                    }
					break;
                case consts.LBL_NEW_OBJECT_STRATEGIES:
                    if(strategySettings[i][text1] && strategySettings[i][text1].toLowerCase().includes('new ')){
                        //console.log(strategySettings[i][text1]);
                        requiredStrategySettings.push(strategySettings[i]);
                    }
					break;
                case consts.LBL_EDIT_OBJECT_STRATEGIES:
                    if(strategySettings[i][text1] && strategySettings[i][text1].toLowerCase().includes('edit ')){
                        //console.log(strategySettings[i][text1]);
                        requiredStrategySettings.push(strategySettings[i]);
                    }
					break;
                case consts.LBL_OTHER_STRATEGIES:
                    if((strategySettings[i][text1] && strategySettings[i][text1].toLowerCase().includes('list view')) ||
                        (strategySettings[i][text1] && strategySettings[i][text1].toLowerCase().includes(' review')) ||
                        (strategySettings[i][text1] && strategySettings[i][text1].toLowerCase().includes('new ')) ||
                        (strategySettings[i][text1] && strategySettings[i][text1].toLowerCase().includes('edit '))) {
                        }
						else{
                             requiredStrategySettings.push(strategySettings[i]);
                        }
					break;
                default :
					console.log('Invalid Activity From Stratey type custom settings');
					break;
            }
        }
        
		//console.log('requiredStrategySettings:',requiredStrategySettings);
        return requiredStrategySettings;
    },

    //function to load ConfigSettingDetailsComponent
    loadConfigSettingsDetailsComponent: function(component, customSettingType, relatedCustomSettings, customSettingMetadata) {
      
		var configSettingsTableComponent, namespace, consts;
		configSettingsTableComponent = component.get("v.configSettingsTableComponent");
		namespace = JSON.parse(component.get('v.settings')).Namespace;
		consts =  this.getConstants(component);
      
		if(customSettingType !== consts.LBL_SELECT) {
			
			//var localBody = component.get("v.body");
			component.set("v.configSettingsTableComponent", []);
			configSettingsTableComponent = [];
			component.set("v.filterFacet", []);
          	
			$A.createComponent(
				"c:ConfigSettingDetailsComponent",
				{
				"customSettingByTypeSettingType": relatedCustomSettings,
				"customSettingMetadata": JSON.stringify(customSettingMetadata),
				"namespace": namespace
				}, 
				function(newComponent, status, errorMessage) {
					
                    //Add the new button to the body array
					if (status === consts.SUCCESS) {
					  
					  configSettingsTableComponent.push(newComponent);
					  configSettingsTableComponent.push(component.get("v.toastComponent"));
					  component.set("v.configSettingsTableComponent", configSettingsTableComponent);
					} 
					else if (status === consts.INCOMPLETE) {
						console.log("No response from server or client is offline.");  // Show offline error
					} 
					else if (status === consts.ERROR) {
					}
				}
			);
        } 
		else {
			component.set("v.configSettingsTableComponent", []);
			component.set("v.filterFacet", []);
        }
    },

    createFilterComponent: function(component, customSettingList, displayFieldsMetadata,settingType){
        
		var consts = this.getConstants(component);
        $A.createComponent(
            "c:FilterMenu",
            {
                settingType: settingType,
                customSettingList:customSettingList,
                displayFieldsMetadata:displayFieldsMetadata,
                namespace : component.get( "v.namespace" )
            },
            function(newComponent, status, errorMessage){
                //Add the new button to the body array
                if (status === consts.SUCCESS) {
                    var filterFacet = component.get("v.filterFacet");
                    filterFacet.push(newComponent);			//TODO see if can be done usinng splice() instead of using reverse method
                    component.set("v.filterFacet", filterFacet);
                } else if (status === consts.INCOMPLETE) {
                    //console.log("No response from server or client is offline.");
                    // Show offline error
                } else if (status === consts.ERROR) {
                        //console.log("Error: " + errorMessage);
                        // Show error message
                }
            }
        );
    },

    loadConfigSettingProgressComponent :function(component, trackedEntity, settings, csMetadata){
        
		//console.log('Inside createDynamicComponent method');
        /*
		this.showElement(component, 'cancleButton');
        this.showElement(component, 'saveAndNewButton');
        this.showElement(component, 'saveButton');
		//*/
        component.set("v.body", []);    //clear current modal elements TODO:NOT WORKING
        $A.createComponent(
            "c:ConfigSettingProgress",
            {
                "trackedEntity" : trackedEntity,
                "settings": settings,
                "csMetadata": csMetadata,
                "namespace" : component.get( "v.namespace" )
            },
            function(newComponent, status, errorMessage){
                
				//Add the new button to the body array
                if (status === "SUCCESS") {
                    var body = component.get("v.body");
                    body.push(newComponent);
                    component.set("v.body", body);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                    // Show offline error
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }
            }
        );
    },

    fireSetNamespaceEvent: function(component, namespace) {
		
		//console.log('AdminPageComponentHelper.fireSetNamespaceEvent')
		window.setTimeout($A.getCallback(function() {
			
			var setNamespaceEvent = $A.get("e.c:setNamespaceEvent");
			//console.log('setNamespaceEvent',setNamespaceEvent,'namespace:', namespace);
			setNamespaceEvent.setParams({'namespace': namespace});
			setNamespaceEvent.fire();
			}), 
			1000
		);
    },

    fireSaveEventClient : function(component, event, helper) {
        
		//console.log('AdminPageComponentHelper.fireSaveEventClient: entered');
        var saveClickEvent = $A.get("e.c:saveClickEvent");
        saveClickEvent.fire();
    },

    fireSaveEventServer : function(component, event, helper, csType) {
        
		//console.log('AdminPageComponentHelper.fireSaveEventServer: entered');
        var callServerEvent = $A.get("e.c:callServerEvent");
        callServerEvent.setParams({'cstype': csType});
        callServerEvent.fire();
    },

    showToast : function(component,event, helper) {
		console.log('In AdminPage Component');
		//console.log('AdminPageComponentHelper.showToast: entered');
        $A.createComponent(
            "c:ToastComponent",
            {
                "type" : component.get("v.toastType"),
                "title" : component.get("v.toastTitle"),
                "message": component.get("v.toastMSG")
            },
            function(newToast, status, errorMessage){
                if (status === "SUCCESS") {
					component.set("v.saveMessageComponent", []);
					var saveMessageComponent = component.get("v.saveMessageComponent");
					saveMessageComponent.push(newToast);
					component.set("v.saveMessageComponent", saveMessageComponent);
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

    showElement: function(component, id){
        
		var divElement = component.find(id);
		//console.log('Div element is: ' , divElement );
        $A.util.removeClass(divElement, 'slds-hide');
        //$A.util.addClass(divElement, 'slds-show');
    },

    hideElement: function(component, id){
        
		var divElement = component.find(id);
        $A.util.removeClass(divElement, 'slds-show');
        $A.util.addClass(divElement, 'slds-hide');
    },

    setDefaultSelectedValue: function(component, id, defaultValue) {
        
		var selectList = component.find(id).set("v.value", defaultValue);
    },

    toggleElement: function(component, menuDiv) {
        
		var divElement = component.find(menuDiv);
        $A.util.toggleClass(divElement, 'slds-hide');
    },

    setCustomSettingMetaData : function( component, event, helper ) {
        
        component.set( 'v.customSettingMetadata', helper.getCustomSettingMetaData() );
        /*
        // This is the Object Approach.
        var action = component.get( "c.getJsonOfConfigSettingsTable" );
        if( action ) {
            action.setCallback( this, function( response ) {
                var state = response.getState();
                if( state === "SUCCESS") {
                    component.set( 'v.customSettingMetadata', response.getReturnValue() );
                } 
                else if( state === 'INCOMPLETE' ) {
                    console.log( 'Incomplete State error' );
                } 
                else if ( state === "ERROR" ) {
                	var errors = response.getError();
                    if ( errors ) {
                        if ( errors[0] && errors[0].message ) {
                            console.log( 'error message:- ', errors[0].message );
                        }
                    } else {
                        console.log( 'An unknown error while fetching custom settings metadata.' );
                    }
                }
            });
            $A.enqueueAction(action);
        } 
        else {
            console.log( 'Sorry, Service side action was not found while fetching custom settings metadata.' );
        }
        //*/
	  },
    
    getCustomSettingMetaData: function() {
        
		return JSON.stringify({
          "Custom Event":[
            {
              "apiName":"Name",
              "labelName":"Name",
              "isBoolean":false,
              "description":"Custom Setting Name",
              "width":"75rem",
              "used":true,
              "display":true,
              "displayOrder":0,
              "isRequired" : true,
			  "placeHolder" : 'CustomEvent_CASE'
            },
            {
              "apiName":"Code1__c",
              "labelName":"RegEx-Matching URL",
              "isBoolean":false,
              "description":"Regular expression for matching URL",
              "width":"75rem",
              "used":true,
              "display":true,
              "displayOrder":1,
              "isRequired" : true,
			  "placeHolder" : '\/500(.*)\/e(.*)'
            },
            {
              "apiName":"Code2__c",
              "labelName":"RegEx-Exclude URL",
              "description":"Regular expression for exclude URL",
              "isBoolean":false,
              "width":"75rem",
              "used":true,
              "display":false,
              "displayOrder":2,
              "isRequired" : false,
			  "placeHolder" : '\/500(.*)\/id=(.*)'
            },
            {
              "apiName":"Flag1__c",
              "labelName":"Billable",
              "isBoolean":true,
              "description":"Billable activity",
              "width":"25rem",
              "used":true,
              "display":false,
              "displayOrder":3,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Flag2__c",
              "labelName":"Utilized",
              "description":"Utilized activity",
              "isBoolean":true,
              "width":"25rem",
              "used":true,
              "display":false,
              "displayOrder":4,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Flag3__c",
              "labelName":"Non Reportable",
              "isBoolean":true,
              "description":"Non Reportable activity",
              "width":"25rem",
              "used":true,
              "display":false,
              "displayOrder":5,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Flag4__c",
              "labelName":"Create Staging Record",
              "description":"Create Staging record to reconsile with other activities",
              "isBoolean":true,
              "width":"25rem",
              "used":true,
              "display":false,
              "displayOrder":6,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Text1__c",
              "labelName":"Static Resource Name",
              "description":"Static resource name having custom event js files",
              "isBoolean":false,
              "width":"75rem",
              "used":true,
              "display":true,
              "displayOrder":7,
              "isRequired" : true,
			  "placeHolder" : 'TimeTrackerCustomEvents'
            },
            {
              "apiName":"Text2__c",
              "labelName":"JS File Name",
              "description":"JavaScript file name present in static resource",
              "isBoolean":false,
              "width":"75rem",
              "used":true,
              "display":true,
              "displayOrder":8,
              "isRequired" : true,
			  "placeHolder" : '/Case.js'
            },
            {
              "apiName":"Text3__c",
              "labelName":"Not Used",
              "description":"Not Used",
              "isBoolean":false,
              "width":"75rem",
              "used":false,
              "display":false,
              "displayOrder":9,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Text4__c",
              "labelName":"Not Used",
              "description":"Not Used",
              "isBoolean":false,
              "width":"75rem",
              "isInComplete":false,
              "used":false,
              "display":false,
              "displayOrder":10,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Text5__c",
              "labelName":"Not Used",
              "description":"Not Used",
              "isBoolean":false,
              "width":"75rem",
              "used":false,
              "display":false,
              "displayOrder":11,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Text6__c",
              "labelName":"Not Used",
              "description":"Not Used",
              "isBoolean":false,
              "width":"75rem",
              "used":false,
              "display":false,
              "displayOrder":12,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Text7__c",
              "labelName":"Not Used",
              "description":"Not Used",
              "isBoolean":false,
              "width":"25rem",
              "used":false,
              "display":false,
              "displayOrder":13,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Text8__c",
              "labelName":"Not Used",
              "description":"Not Used",
              "isBoolean":false,
              "width":"25rem",
              "used":false,
              "display":false,
              "displayOrder":14,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"IsActive__c",
              "labelName":"Active",
              "isBoolean":true,
              "description":"Active/InActive Custom Settings",
              "width":"75rem",
              "used":true,
              "display":true,
              "displayOrder":-1,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Type__c",
              "labelName":"Type",
              "isBoolean":true,
              "description":"Custom Setting Type",
              "width":"75rem",
              "used":true,
              "display":false,
              "displayOrder":15,
              "isRequired" : true,
			  "placeHolder" : 'Custom Event'
            }
          ],
          "Manual":[
            {
              "apiName":"Name",
              "labelName":"Name",
              "description":"Setting Name",
              "width":"75rem",
              "isBoolean":false,
              "used":true,
              "display":true,
              "displayOrder":0,
              "isRequired" : true,
			  "placeHolder" : 'Manual_LUNCH_BREAK'
            },
            {
              "apiName":"Code1__c",
              "labelName":"Object",
              "description":"Object displayed on Manual Widget",
              "width":"75rem",
              "isBoolean":false,
              "used":true,
              "display":true,
              "displayOrder":1,
              "isRequired" : true,
			  "placeHolder" : 'Case'
            },
            {
              "apiName":"Code2__c",
              "labelName":"Object-Field Settings",
              "description":"Settings for search/show fields displayed on manual widget",
              "width":"75rem",
              "isBoolean":false,
              "used":true,
              "display":false,
              "displayOrder":2,
              "isRequired" : true,
			  "placeHolder" : '{"fields":[{"field":"CaseNumber";"search":true,"show":true}]}'
            },
            {
              "apiName":"Flag1__c",
              "labelName":"Billable",
              "description":"Billable activity",
              "isBoolean":true,
              "width":"25rem",
              "used":true,
              "display":false,
              "displayOrder":3,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Flag2__c",
              "labelName":"Utilized",
              "isBoolean":true,
              "description":"Utilized activity",
              "width":"25rem",
              "used":true,
              "display":false,
              "displayOrder":4,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Flag3__c",
              "labelName":"Non Reportable",
              "description":"Non Reportable activity",
              "isBoolean":true,
              "width":"25rem",
              "used":true,
              "display":false,
              "displayOrder":5,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Flag4__c",
              "labelName":"Create Staging Record",
              "description":"Create Staging record to reconsile with other activities",
              "isBoolean":true,
              "width":"25rem",
              "used":true,
              "display":false,
              "displayOrder":6,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Text1__c",
              "labelName":"Action Name",
              "description":"Activity Name will populate in Activity field of TT Record",
              "isBoolean":false,
              "width":"75rem",
              "used":true,
              "display":true,
              "displayOrder":7,
              "isRequired" : true,
			  "placeHolder" : 'Lunch Break'
            },
            {
              "apiName":"Text2__c",
              "labelName":"Activity Type",
              "description":"Activity Type will populate in Activity Type field of TT Record",
              "isBoolean":false,
              "width":"75rem",
              "used":true,
              "display":true,
              "displayOrder":8,
              "isRequired" : true,
			  "placeHolder" : 'Case Work'
            },
            {
              "apiName":"Text3__c",
              "labelName":"Action Category",
              "description":"Action Category will populate in Action Category field of TT Record",
              "isBoolean":false,
              "width":"75rem",
              "used":true,
              "display":true,
              "displayOrder":9,
              "isRequired" : true,
			  "placeHolder" : 'Lunch Break'
            },
            {
              "apiName":"Text4__c",
              "labelName":"TimeTracker Permission Set",
              "description":"This activity is visible to this Permission Set by default it is set to blank(Visible to all)",
              "isBoolean":false,
              "width":"75rem",
              "isInComplete":false,
              "used":true,
              "display":false,
              "displayOrder":10,
              "isRequired" : false,
			  "placeHolder" : 'Time Tracker Admin Permission Set'
            },
            {
              "apiName":"Text5__c",
              "labelName":"TimeTracker Permission Set",
              "description":"This activity is visible to this Permission Set by default it is set to blank(Visible to all)",
              "isBoolean":false,
              "width":"75rem",
              "used":false,
              "display":false,
              "displayOrder":11,
              "isRequired" : false,
			  "placeHolder" : 'TimeTracker Permission Set'
            },
            {
              "apiName":"Text6__c",
              "labelName":"Comment Required",
              "description":"Comment is mandatory for this type of manual activity",
              "isBoolean":false,
              "width":"75rem",
              "used":true,
              "display":false,
              "displayOrder":12,
              "isRequired" : false,
			  "placeHolder" : 'comment required'
            },
            {
              "apiName":"Text7__c",
              "labelName":"Not Used",
              "description":"Not Used",
              "isBoolean":false,
              "width":"25rem",
              "used":false,
              "display":false,
              "displayOrder":13,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Text8__c",
              "labelName":"Not Used",
              "description":"Not Used",
              "isBoolean":false,
              "width":"25rem",
              "used":false,
              "display":false,
              "displayOrder":14,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"IsActive__c",
              "labelName":"Active",
              "isBoolean":true,
              "description":"Active/InActive Custom Settings",
              "width":"75rem",
              "used":true,
              "display":true,
              "displayOrder":-1,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Type__c",
              "labelName":"Type",
              "isBoolean":true,
              "description":"Custom Setting Type",
              "width":"75rem",
              "used":true,
              "display":false,
              "displayOrder":15,
              "isRequired" : true,
			  "placeHolder" : 'Manual'
            }
          ],
          "Object Settings":[
            {
              "apiName":"Name",
              "labelName":"Name",
              "description":"Setting Name",
              "isBoolean":false,
              "width":"75rem",
              "used":true,
              "display":true,
              "displayOrder":0,
              "isRequired" : true,
			  "placeHolder" : 'ObjectSettings_CASE'
            },
            {
              "apiName":"Text1__c",
              "labelName":"Object API Name",
              "description":"API Name of Object",
              "isBoolean":false,
              "width":"75rem",
              "used":true,
              "display":true,
              "displayOrder":1,
              "isRequired" : true,
			  "placeHolder" : 'Case'
            },
            {
              "apiName":"Code2__c",
              "labelName":"Not Used",
              "description":"Not Used",
              "isBoolean":false,
              "width":"75rem",
              "used":false,
              "display":false,
              "displayOrder":2,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Flag1__c",
              "labelName":"Billable",
              "description":"Billable activity",
              "isBoolean":true,
              "width":"25rem",
              "used":true,
              "display":false,
              "displayOrder":3,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Flag2__c",
              "labelName":"Utilized",
              "description":"Utilized activity",
              "isBoolean":true,
              "width":"25rem",
              "used":true,
              "display":false,
              "displayOrder":4,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Flag3__c",
              "labelName":"Non Reportable",
              "description":"Non Reportable activity",
              "isBoolean":true,
              "width":"25rem",
              "used":true,
              "display":false,
              "displayOrder":5,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Flag4__c",
              "labelName":"Create Staging Record",
              "description":"Create Staging record to reconsile with other activities",
              "isBoolean":true,
              "width":"25rem",
              "used":true,
              "display":false,
              "displayOrder":6,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Code1__c",
              "labelName":"Object Prefix",
              "description":"Key Prefix of Object",
              "isBoolean":false,
              "width":"75rem",
              "used":true,
              "display":true,
              "displayOrder":7,
              "isRequired" : true,
			  "placeHolder" : '500'
            },
            {
              "apiName":"Text2__c",
              "labelName":"URL Parameter",
              "description":"URL parameter field used to get the parent Id",
              "isBoolean":false,
              "width":"75rem",
              "used":true,
              "display":true,
              "displayOrder":8,
              "isRequired" : false,
			  "placeHolder" : 'accountId'
            },
            {
              "apiName":"Text3__c",
              "labelName":"Not Used",
              "description":"Not Used",
              "isBoolean":false,
              "width":"75rem",
              "used":false,
              "display":false,
              "displayOrder":9,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Text4__c",
              "labelName":"Lookup Fields Map 1",
              "description":"Lookup Field details in Key:Value pair seperated by semicolon <(Object.FieldName): (TimeTracker Field)>",
              "isBoolean":false,
              "width":"75rem",
              "isInComplete":false,
              "used":true,
              "display":false,
              "displayOrder":10,
              "isRequired" : false,
			  "placeHolder" : 'Id:Case__c;Contact.AccountId:Account__c;'
            },
            {
              "apiName":"Text5__c",
              "labelName":"Lookup Fields Map 2",
              "description":"Lookup Field details in Key:Value pair seperated by semicolon <(Object.FieldName): (TimeTracker Field)>",
              "isBoolean":false,
              "width":"75rem",
              "used":true,
              "display":false,
              "displayOrder":11,
              "isRequired" : false,
			  "placeHolder" : 'ContactId:Contact__c;'
            },
            {
              "apiName":"Text6__c",
              "labelName":"Not Used",
              "description":"Not Used",
              "isBoolean":false,
              "width":"75rem",
              "used":false,
              "display":false,
              "displayOrder":12,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Text7__c",
              "labelName":"Not Used",
              "description":"Not Used",
              "isBoolean":false,
              "width":"25rem",
              "used":false,
              "display":false,
              "displayOrder":13,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Text8__c",
              "labelName":"Not Used",
              "description":"Not Used",
              "isBoolean":false,
              "width":"25rem",
              "used":false,
              "display":false,
              "displayOrder":14,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"IsActive__c",
              "labelName":"Active",
              "isBoolean":true,
              "description":"Active/InActive Custom Settings",
              "width":"75rem",
              "used":true,
              "display":true,
              "displayOrder":-1,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Type__c",
              "labelName":"Type",
              "isBoolean":true,
              "description":"Custom Setting Type",
              "width":"75rem",
              "used":true,
              "display":false,
              "displayOrder":15,
              "isRequired" : true,
			  "placeHolder" : 'Object Settings'
            }
          ],
          "Strategy":[
            {
              "apiName":"Name",
              "labelName":"Name",
              "description":"Setting Name",
              "isBoolean":false,
              "width":"75rem",
              "used":true,
              "display":true,
              "displayOrder":0,
              "isRequired" : true,
			  "placeHolder" : 'Strategy_NEW_CASE'
            },
            {
              "apiName":"Code1__c",
              "labelName":"Impemetation Class",
              "description":"Implementation Class Name (Eg: Review-GenericExcludeImpl)",
              "isBoolean":false,
              "width":"50rem",
              "used":true,
              "display":true,
              "displayOrder":1,
              "isRequired" : true,
			  "placeHolder" : 'GenericTimeTrackerImpl'
            },
            {
              "apiName":"Code2__c",
              "labelName":"Not Used",
              "description":"Not Used",
              "isBoolean":false,
              "width":"75rem",
              "used":false,
              "display":false,
              "displayOrder":2,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Flag1__c",
              "labelName":"Billable",
              "description":"Billable activity",
              "isBoolean":true,
              "width":"25rem",
              "used":true,
              "display":false,
              "displayOrder":3,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Flag2__c",
              "labelName":"Utilized",
              "description":"Utilized activity",
              "isBoolean":true,
              "width":"25rem",
              "used":true,
              "display":false,
              "displayOrder":4,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Flag3__c",
              "labelName":"Non Reportable",
              "description":"Non Reportable activity",
              "isBoolean":true,
              "width":"25rem",
              "used":true,
              "display":false,
              "displayOrder":5,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Flag4__c",
              "labelName":"Create Staging Record",
              "description":"Create Staging record to reconsile with other activities",
              "isBoolean":true,
              "width":"25rem",
              "used":true,
              "display":false,
              "displayOrder":6,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Text1__c",
              "labelName":"Action Name",
              "description":"Activity Name will populate in Activity field of TT Record",
              "isBoolean":false,
              "width":"75rem",
              "used":true,
              "display":true,
              "displayOrder":7,
              "isRequired" : true,
			  "placeHolder" : 'New Case'
            },
            {
              "apiName":"Text2__c",
              "labelName":"Activity Type",
              "description":"Activity Type will populate in Activity Type field of TT Record",
              "isBoolean":false,
              "width":"75rem",
              "used":true,
              "display":true,
              "displayOrder":8,
              "isRequired" : true,
			  "placeHolder" : 'Case Work'
            },
            {
              "apiName":"Text3__c",
              "labelName":"Action Category",
              "description":"Action Category will populate in Action Category field of TT Record",
              "isBoolean":false,
              "width":"75rem",
              "used":true,
              "display":true,
              "displayOrder":9,
              "isRequired" : true,
			  "placeHolder" : 'Case Creation'
            },
            {
              "apiName":"Text4__c",
              "labelName":"Not Used",
              "description":"Not Used",
              "isBoolean":false,
              "width":"75rem",
              "used":false,
              "display":false,
              "displayOrder":10,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Text5__c",
              "labelName":"Exclude Actions",
              "description":"All the activities(time) mentioned in this field will be excuded from the main activity",
              "isBoolean":false,
              "isInComplete":false,
              "width":"75rem",
              "used":true,
              "display":false,
              "displayOrder":11,
              "isRequired" : false,
			  "placeHolder" : 'Post Case Comment'
            },
            {
              "apiName":"Text6__c",
              "labelName":"Exclude Actions",
              "description":"All the activities(time) mentioned in this field will be excuded from the main activity",
              "isBoolean":false,
              "width":"75rem",
              "used":false,
              "display":false,
              "displayOrder":12,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Text7__c",
              "labelName":"Cancel Action",
              "description":"Cancel Action",
              "isBoolean":false,
              "width":"25rem",
              "used":true,
              "display":false,
              "displayOrder":13,
              "isRequired" : false,
			  "placeHolder" : 'Case Cancel'
            },
            {
              "apiName":"Text8__c",
              "labelName":"Cancel Action Category",
              "description":"Cancel Action Category",
              "isBoolean":false,
              "width":"25rem",
              "display":false,
              "used":true,
              "displayOrder":14,
              "isRequired" : false,
			  "placeHolder" : 'Case Cancellation'
            },
            {
              "apiName":"IsActive__c",
              "labelName":"Active",
              "isBoolean":true,
              "description":"Active/InActive Custom Settings",
              "width":"75rem",
              "used":true,
              "display":false,
              "displayOrder":-1,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Type__c",
              "labelName":"Type",
              "isBoolean":true,
              "description":"Custom Setting Type",
              "width":"75rem",
              "used":true,
              "display":false,
              "displayOrder":15,
              "isRequired" : true,
			  "placeHolder" : 'Strategy'
            }
          ],
          "URLPattern":[
            {
              "apiName":"Name",
              "labelName":"Name",
              "description":"Setting Name",
              "isBoolean":false,
              "width":"75rem",
              "used":true,
              "display":true,
              "displayOrder":0,
              "isRequired" : true,
			  "placeHolder" : 'URLPattern_VIEW_ALL_NOTES'
            },
            {
              "apiName":"Code1__c",
              "labelName":"URL Pattern value",
              "description":"URL Pattern value, commonly URL suffix for VF page",
              "isBoolean":false,
              "width":"50rem",
              "used":true,
              "display":true,
              "displayOrder":1,
              "isRequired" : true,
			  "placeHolder" : ''
            },
            {
              "apiName":"Code2__c",
              "labelName":"Not Used",
              "description":"Not Used",
              "isBoolean":false,
              "width":"75rem",
              "used":false,
              "display":false,
              "displayOrder":2,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Flag1__c",
              "labelName":"Billable",
              "description":"Billable activity",
              "isBoolean":true,
              "width":"25rem",
              "used":true,
              "display":false,
              "displayOrder":3,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Flag2__c",
              "labelName":"Utilized",
              "description":"Utilized activity",
              "isBoolean":true,
              "width":"25rem",
              "used":true,
              "display":false,
              "displayOrder":4,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Flag3__c",
              "labelName":"Non Reportable",
              "description":"Non Reportable activity",
              "isBoolean":true,
              "width":"25rem",
              "used":true,
              "display":false,
              "displayOrder":5,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Flag4__c",
              "labelName":"Create Staging Record",
              "description":"Create Staging record to reconsile with other activities",
              "isBoolean":true,
              "width":"25rem",
              "used":true,
              "display":false,
              "displayOrder":6,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Text1__c",
              "labelName":"Action Name",
              "description":"Activity Name will populate in Activity field of TT Record",
              "isBoolean":false,
              "width":"75rem",
              "used":true,
              "display":true,
              "displayOrder":7,
              "isRequired" : true,
			  "placeHolder" : 'Notes Review'
            },
            {
              "apiName":"Text2__c",
              "labelName":"Parent Id",
              "description":"Parent Id parameter from URL (If any)",
              "isBoolean":false,
              "width":"75rem",
              "used":true,
              "display":true,
              "displayOrder":8,
              "isRequired" : false,
			  "placeHolder" : 'pid'
            },
            {
              "apiName":"Text3__c",
              "labelName":"Parent Name",
              "description":"Parent Name parameter from URL (If any)",
              "isBoolean":false,
              "width":"75rem",
              "used":true,
              "display":true,
              "displayOrder":9,
              "isRequired" : false,
			  "placeHolder" : 'parentname'
            },
            {
              "apiName":"Text4__c",
              "labelName":"Not Used",
              "description":"Not Used",
              "isBoolean":false,
              "width":"75rem",
              "used":false,
              "display":false,
              "displayOrder":10,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Text5__c",
              "labelName":"Not Used",
              "description":"Not Used",
              "isBoolean":false,
              "isInComplete":true,
              "width":"75rem",
              "used":false,
              "display":false,
              "displayOrder":11,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Text6__c",
              "labelName":"Not Used",
              "description":"Not Used",
              "isBoolean":false,
              "width":"75rem",
              "used":false,
              "display":false,
              "displayOrder":12,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Text7__c",
              "labelName":"Not Used",
              "description":"Not Used",
              "isBoolean":false,
              "width":"25rem",
              "used":false,
              "display":false,
              "displayOrder":13,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Text8__c",
              "labelName":"Not Used",
              "description":"Not Used",
              "isBoolean":false,
              "width":"25rem",
              "display":false,
              "used":false,
              "displayOrder":14,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"IsActive__c",
              "labelName":"Active",
              "isBoolean":true,
              "description":"Active/InActive Custom Settings",
              "width":"75rem",
              "used":true,
              "display":true,
              "displayOrder":-1,
              "isRequired" : false,
			  "placeHolder" : ''
            },
            {
              "apiName":"Type__c",
              "labelName":"Type",
              "isBoolean":true,
              "description":"Custom Setting Type",
              "width":"75rem",
              "used":true,
              "display":false,
              "displayOrder":15,
              "isRequired" : true,
			  "placeHolder" : 'URLPattern'
            }
          ]
        });
    },
	
	getConstants: function(component) {
        
		var consts = {
						'LBL_LIST_VIEW_STRATEGIES': 'List View Strategies',
						'LBL_OBJECT_REVIEW_STRATEGIES': 'Object Review Strategies',
						'LBL_NEW_OBJECT_STRATEGIES': 'New Object Strategies',
						'LBL_EDIT_OBJECT_STRATEGIES': 'Edit Object Strategies',
						'LBL_OTHER_STRATEGIES': 'Other Strategies',
						'LBL_VIEW_CUSTOM_SETTING_TYPE':'View Custom Setting Type',
						'LBL_START_TRACKING_NEW_ENTITY': 'START TRACKING A NEW ENTITY',
						'LBL_CONFIGURATION_SETTINGS': 'Configuration Settings',
						'LBL_USER_SETTINGS': 'User Settings',
						'LBL_TRACK_NEW_ACTIVITIES':'Track New Activities',
						'LBL_ORG_LEVEL_VAL':'Organisation Level Value',
						'LBL_USER_LEVEL_SETTINGS':'Profile/User Settings',
						'LBL_STRART_TRACKING_HELP':'Click to track Custom Events, Manual Activity , URL or Visualforce Pages.',
						'SUCCESS': 'SUCCESS',
						'INCOMPLETE': 'INCOMPLETE',
						'ERROR': 'ERROR',
						'TYPE_FIELD': 'Type__c',
						'TEXT1_FIELD':'Text1__c'
					 };
        
		if( component.get( 'v.namespace' ) ) {
			consts['LBL_SELECT'] = $A.get("$Label.timetracker.LBL_Select_DropDown");
			consts['LBL_STRATEGY']=  $A.get("$Label.timetracker.LBL_ConfigSetting_Strategy");
			consts['LBL_MANUAL']=  $A.get("$Label.timetracker.LBL_ConfigSetting_Manual");
			consts['LBL_URLPATTERN']= $A.get("$Label.timetracker.LBL_ConfigSetting_URLPattern");
			consts['LBL_MISCELLANEOUS']= $A.get("$Label.timetracker.LBL_ConfigSetting_Miscellaneous");
			consts['LBL_OBJECT']= $A.get("$Label.timetracker.LBL_ConfigSetting_Object");
			consts['LBL_CUSTOM_EVENT']= $A.get("$Label.timetracker.LBL_ConfigSetting_Custom_Event");
			consts['LBL_URL_VF_PAGE']= $A.get("$Label.timetracker.LBL_URL_VF_Page");
			consts['LBL_CUSTOM_EVENTS']= $A.get("$Label.timetracker.LBL_Custom_Events");
			consts['LBL_MANUAL_ACTIVITY']= $A.get("$Label.timetracker.LBL_Manual_Activity");
		}
		else {
			consts['LBL_SELECT'] = $A.get("$Label.c.LBL_Select_DropDown");
			consts['LBL_STRATEGY']=  $A.get("$Label.c.LBL_ConfigSetting_Strategy");
			consts['LBL_MANUAL']=  $A.get("$Label.c.LBL_ConfigSetting_Manual");
			consts['LBL_URLPATTERN']= $A.get("$Label.c.LBL_ConfigSetting_URLPattern");
			consts['LBL_MISCELLANEOUS']= $A.get("$Label.c.LBL_ConfigSetting_Miscellaneous");
			consts['LBL_OBJECT']= $A.get("$Label.c.LBL_ConfigSetting_Object");
			consts['LBL_CUSTOM_EVENT']= $A.get("$Label.c.LBL_ConfigSetting_Custom_Event");
			consts['LBL_URL_VF_PAGE']= $A.get("$Label.c.LBL_URL_VF_Page");
			consts['LBL_CUSTOM_EVENTS']= $A.get("$Label.c.LBL_Custom_Events");
			consts['LBL_MANUAL_ACTIVITY']= $A.get("$Label.c.LBL_Manual_Activity");
		}
		return consts;
    }
})