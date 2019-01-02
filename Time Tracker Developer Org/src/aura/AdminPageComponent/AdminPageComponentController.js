({
    changeTabId : function( component, event, helper ) {
    	
        var tabId = event.getParam( 'tabId' );
        if( tabId ) {
            component.set( "v.selectedTabid", tabId );
        }
    },
    
    doInit : function(component, event, helper){
        
        // Fetching Constants that are set at client side.
        var consts = helper.getConstants(component);
        component.set('v.consts',consts);
        
        // Make sure these methods do not use constants set at server side.
        helper.getSettingsFromServer(component);
        
        //*
        // Object Approach
        helper.setCustomSettingMetaData(component, event, helper);
        //*/
        
        /*
        // Original Approach
        csMetadata = helper.getCustomSettingMetaData();
        component.set('v.customSettingMetadata', csMetadata);
        //*/
        
        // Get Name Space from server and Update server side constants variables based on the namespace received.
        helper.setNameSpace( component, helper );
    },
    
    //function to get custom settings according to its type
    getCustomSettingsByType : function(component, event, helper) {
        
        var customSettingsType, customSettingMetadata, consts, settings, relatedCustomSettings;
        customSettingsType = component.find("customsettingtype").get("v.value");
        console.log( 'getCustomSettingsByType-customSettingsType',customSettingsType);
        
        consts = helper.getConstants(component);
        customSettingMetadata = (JSON.parse(component.get("v.customSettingMetadata")))[customSettingsType];
        console.log( 'getCustomSettingsByType-customSettingMetadata',customSettingMetadata);
        
        settings = helper.getTTSettings(component);
		console.log( 'getCustomSettingsByType-settings',settings);
        
        if(customSettingsType !== consts.LBL_STRATEGY) {
            helper.hideElement(component, 'strategysettingtype');
            relatedCustomSettings = helper.getTTSettingsByType(component,customSettingsType, settings.ConfigSettings);
            helper.loadConfigSettingsDetailsComponent(component, customSettingsType, relatedCustomSettings, customSettingMetadata);
        } else {
            component.set("v.configSettingsTableComponent", []);
            component.set('v.filterFacet', []);
            helper.setDefaultSelectedValue(component, 'strategysettingtype', consts.LBL_SELECT);
            helper.showElement(component, 'strategysettingtype');
        }
    },

    //function to get strategy settings according to its type
    getStrategySettingsByType: function(component, event, helper) {
        
        //console.log('AdminPageComponentCtrler.getCustomSettingsByType: entered');
        var customSettingsType, strategySettingsType, customSettingMetadata, settings, relatedCustomSettings;
        customSettingsType = component.find("customsettingtype").get("v.value");
        console.log( 'getStrategySettingsByType-customSettingsType',customSettingsType);
        
        strategySettingsType = component.find("strategysettingtype").get("v.value");
        console.log( 'getStrategySettingsByType-strategySettingsType',strategySettingsType);
        
        customSettingMetadata = (JSON.parse(component.get("v.customSettingMetadata")))[customSettingsType];
        console.log('customSettingMetadata: ',customSettingMetadata);
        
        settings = helper.getTTSettings(component);
        console.log( 'settings',settings);
        
        relatedCustomSettings = helper.getTTSettingsByType(component,customSettingsType, settings.ConfigSettings);
        console.log( 'By Type-relatedCustomSettings',relatedCustomSettings);
        
        relatedCustomSettings = helper.filterStrategiesByActivityType(component,settings.Namespace, relatedCustomSettings,strategySettingsType);
        console.log( 'By Sub-Type-relatedCustomSettings',relatedCustomSettings);
        
        helper.loadConfigSettingsDetailsComponent(component, customSettingsType, relatedCustomSettings, customSettingMetadata);
    },

    handleChange: function(component, event, helper) {
        helper.hideElement(component, 'saveButtonID');
    },

    startTracking : function(component, event, helper) {
        
        var trackedEntity = component.find("tracknewactivity").get("v.value");
        console.log( 'startTracking-trackedEntity',trackedEntity);
        
        var settings = component.get("v.settings");
        var csMetadata = component.get( 'v.customSettingMetadata');
        helper.loadConfigSettingProgressComponent(component, trackedEntity, settings, csMetadata);
    },

    handleSave : function(component, event, helper){
        
        var customSettingsType = component.find("customsettingtype").get("v.value");
        console.log('In AdminPageComp customSettingsType>',customSettingsType);
        component.set('v.saveButtonLabel', 'Saving...');
        component.set("v.isSaveDisabled", true);

        window.setTimeout($A.getCallback(function() {
            if(component.isValid()){
                helper.hideElement(component, 'saveButtonID');
                component.set('v.saveButtonLabel', 'Save');
            }
        }),3000);
        
        //helper.fireSaveEventClient(component, event, helper);  
        ////Not required, To be deleted after rigorous testing
        helper.fireSaveEventServer(component, event, helper, customSettingsType);
       // component.set("v.counter", 0);
    },

    handleAfterSaveRefresh : function(component, event, helper){
        component.set("v.toastMSG", event.getParam("toastMSG"));
        component.set("v.toastTitle", event.getParam("toastTitle"));
        component.set("v.toastType", event.getParam("toastType"));
		
        var updatedSettings, deletedSetting;
        updatedSettings =  event.getParam("updatedSettings");
        if(updatedSettings) {
            helper.updateConfigSettings(component, updatedSettings);
        }	
        
        deletedSetting = event.getParam("deletedSetting");
        if(deletedSetting) {
            helper.deleteConfigSetting(component, deletedSetting);
        }
        
        if(event.getParam("toastMSG")){
        	helper.showToast(component, event, helper);
        }
        
    },

    handleToggleEvent : function(component, event, helper){
        
        var counter=component.get("v.counter");
        var isEdit=event.getParam("isEdit");
        var isNameFieldEmpty=event.getParam('isNameFieldEmpty');
		
        if( isNameFieldEmpty === true || isNameFieldEmpty === false ) {
            component.set('v.isNameFieldEmpty', isNameFieldEmpty);
        }
        
        if(component.get("v.rowColIndexSet").length <= 0 || component.get('v.isNameFieldEmpty')){
            helper.hideElement(component, 'saveButtonID');	//hide button
        }
        else{
            component.set("v.isSaveDisabled", false);
            helper.showElement(component, 'saveButtonID');//show button
        }
    },
    
    addRowColIndex : function(component, event, helper){
        
        var rowColIndexSetVar = component.get("v.rowColIndexSet");
        console.log( 'isAdd', event.getParam("isAdd") );
        //console.log('before>',component.get('v.rowColIndexSetVar'));
        console.log( 'before>', rowColIndexSetVar );
        
        if(event.getParam("isAdd") && rowColIndexSetVar.indexOf(event.getParam("rowIndex")+'-'+event.getParam("colIndex")) == -1)
        {
        	rowColIndexSetVar.push(event.getParam("rowIndex")+'-'+event.getParam("colIndex")); 
        } 
        
        if(!event.getParam("isAdd")) {
            var index = rowColIndexSetVar.indexOf(event.getParam("rowIndex")+'-'+event.getParam("colIndex"));
            rowColIndexSetVar.splice(index, 1)
        }
        
        component.set("v.rowColIndexSet",rowColIndexSetVar);   
        console.log('After>'+component.get('v.rowColIndexSet'));
    },

    handleSpinnerToggle : function(component, event, helper) {
    },

    createFilterComponent: function(component, event, helper){
        
        helper.createFilterComponent(component, event.getParam('customSettingList'),
                                     event.getParam('displayFieldsMetadata'),
                                     component.find('customsettingtype').get('v.value'));
    },

    setOrgSettinngRecord: function(component, event, helper){
        
        var orgSetting = event.getParam('orgSetting');
        component.set('v.orgSetting', orgSetting );
        
        var refreshUserSettingsTable = $A.get("e.c:RefreshUserSettingsTable");
        refreshUserSettingsTable.fire();
    },

    toggleHelpTtext: function(component, event, helper){
        helper.toggleElement(component, 'helpTextDiv');
    },

    hideHelpText : function(component, event, helper){
        helper.hideElement(component, 'helpTextDiv');
    },

    showSpinner: function(component) {
        component.set("v.spinner", true); 
    },

    hideSpinner: function(component) {
        component.set("v.spinner", false);
    },

    handleUserSettingTabActive: function(component, event, helper) {
        
        var settings = JSON.parse(component.get("v.settings"));
        helper.fireSetNamespaceEvent(component, settings.Namespace);
    },

    handleTrackNewTabActive: function(component, event, helper) {
        
        var consts = helper.getConstants(component);
        component.find('tracknewactivity').set('v.value', consts.LBL_SELECT);
        component.set("v.body", []);
    },

    handleActivityChange:function(component, event, helper) {
        
        var tablabel, consts;
        tablabel = event.currentTarget.value;
        consts = helper.getConstants(component);
        console.log( 'handleActivityChange-consts',consts);
        console.log( 'tablabel', tablabel );
        
        if(tablabel === consts.LBL_SELECT) {
            component.set("v.body", []);
            return;
        } 
        
		component.set("v.body", []);
		$A.createComponent(
			"c:ConfigSettingProgress",
			{
			  "tablabel": tablabel,
			  "settings": component.get("v.settings"),
			  "csMetadata": component.get( 'v.customSettingMetadata'), // helper.getCustomSettingMetaData(),
              "namespace" : component.get( "v.namespace" )
			}, 
			function(newButton, status, errorMessage) {
				if (status === "SUCCESS") {
					
					//Add the new button to the body array
					var body = component.get("v.body");
					body.push(newButton);
					component.set("v.body", body);
				} 
				else if (status === "INCOMPLETE") {
					console.log("Incomplete Loading ConfigSettingProgress.");
				} 
				else if (status === "ERROR") {
					console.log("Error: " + errorMessage);
				}
			}
		);
    },
})