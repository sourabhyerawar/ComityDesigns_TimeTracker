/*
	@ Purpose : Controls the component --> ConfigSettingProgress
	@ Name    : ConfigSettingProgressController
//*/

({
	initializeComponent : function(component, event, helper) {
		
		var tablabel, settings, csMetadata, consts;
		tablabel = component.get("v.tablabel");
		settings = component.get("v.settings");
		csMetadata = component.get("v.csMetadata");
        consts = helper.getConstants(component);
        component.set("v.consts", consts);
	},


	setOptions: function(component, event, helper) {
        
		helper.loadOptionsForSObjectFields(component);
    },

    getnewActivityCsList: function(component, event, helper) {
    	
		var newActivityCsList, consts;
        newActivityCsList = event.getParam("newlyCreatedList");
        console.log( 'Before relating newActivityCsList', JSON.stringify( newActivityCsList ) );
        
        //newActivityCsList = helper.relateWithExistingRecords( component, newActivityCsList );
        //console.log( 'After relating newActivityCsList', JSON.stringify( newActivityCsList ) );
        
        consts = helper.getConstants(component);
    	component.set("v.newActivityCsList", newActivityCsList);
        
        if( event.getParam("showVerifySettingsTab") ) {
            component.set("v.verifyTabLable", consts.LBL_VERIFY_CS_DETAILS);
            setTimeout( function() { 
                component.set("v.selectedTabId", 'verifydetails');
            	helper.loadConfigSettingRecordComponent(component, 0); 
            }, 5);
            
        }
    	//component.find("verifydetails").set('v.label', 'Verify Custom Setting Details');
    },

    loadComponent: function(component, event, helper) {
    	
		var currentTargetElement = event.currentTarget;
    	var index = currentTargetElement.getAttribute('data-index');
		helper.loadConfigSettingRecordComponent(component, index);
    },

    updateNewActivitiyCsList: function(component, event, helper) {
        
        var newActivityCsList = component.get('v.newActivityCsList');
        var csToUpdate = event.getParam("configSettingRecord");
        var updatedRecordIndex = event.getParam( "updatedRecordIndex" );
        
        var listOfUpdatedActivities = new Array();
        var noOfActivities = newActivityCsList.length;
        for( var activityListindex = 0; activityListindex < noOfActivities; activityListindex ++ ) {
            if( activityListindex == updatedRecordIndex ) {
                listOfUpdatedActivities.push( csToUpdate );
            }
            else {
                listOfUpdatedActivities.push( newActivityCsList[ activityListindex ] );
            }
        }
        component.set( "v.newActivityCsList", listOfUpdatedActivities );
    },
    
    handleSaveCS: function(component, event, helper) {
		
		var configSettingRecordList = component.get("v.newActivityCsList");
        console.log('in handleSave configSettingRecordList >>',configSettingRecordList);
		helper.createTimeTrackerConfigSettings(component, configSettingRecordList);
	},
	
    resetNewEntryForm : function( component, event, helper ) {
        
		component.set( "v.verifyTabLable", '' );
    }
})