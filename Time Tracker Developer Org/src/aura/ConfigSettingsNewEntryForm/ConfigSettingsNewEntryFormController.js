/*
	@ Purpose : Controls the component --> ConfigSettingsNewEntryForm
	@ Name    : ConfigSettingsNewEntryFormController
//*/

({
    handleInit : function(component, event, helper){
        
		var trackedEntity = component.get("v.trackedEntity");
        var settings = component.get("v.settings");
        var csMetadata = component.get("v.csMetadata");
        //console.log('trackedEntity',trackedEntity,'settings',JSON.parse(settings),'csMetadata',csMetadata);
        helper.showRespectiveFields(component,trackedEntity);
        
        var constants = helper.getConstants(component);
        component.set( "v.consts", constants );
    },

    handleSave : function(component, event, helper) {
        
		// console.log('event.getParam("arguments"):',event.getParam('arguments'));
        // var evt = $A.get("e.c:PassNewlyCreatedSettingsToConfigSettingProgress");
        // helper.handleSave(component,event, helper);
        helper.handleSave( component, null , helper );
    },

    handleVerify: function(component, event, helper) {
        
        console.log( 'verify');
		var evt = $A.get("e.c:PassNewlyCreatedSettingsToConfigSettingProgress");
        helper.handleSave(component, evt, helper); 
    },

    handleCancel : function(component, event, helper){
        
        //helper.closeModal(component);
        helper.cancel( component, event, helper, true );
        //var errorDivIds = [ "emcsnamerequired", "emcsnamelengthexceed", "emcsnameused", "error-message", "error-message-JS"];
        helper.hideErrorMessages(component, helper);
    },

    handleCSNameFocus: function(component, event, helper) {
		
		helper.showRequiredHighlight(component, false, 'errorDivCSName', 'emcsnamerequired');
		helper.showRequiredHighlight(component, false, 'errorDivCSName', 'emcsnamelengthexceed');
    },

    makeCommentMandatory: function(component, event, helper) {

    },

    handleCustomSettingNameChange : function(component, event, helper) {
		
		console.log('ConfigSettingsNewEntryFormController.handleCustomSettingNameChange: entered');
		var customSettingName = component.find('customSettingNameID').get('v.value');
		var customSettingType = component.get("v.trackedEntity");
		var consts = helper.getConstants(component);
		
		console.log( 'customSettingName',customSettingName );
        console.log( 'customSettingType: ',customSettingType );
		helper.showRequiredHighlight(component, false, 'errorDivCSName', 'emcsnamerequired');
		helper.showRequiredHighlight(component, false, 'errorDivCSName', 'emcsnamelengthexceed');

		if(!customSettingName) {
			helper.showRequiredHighlight(component, false, 'errorDivCSName', 'emcsnamerequired');
		} 
		else if(customSettingType=== consts.LBL_MANUAL_ACTIVITY && customSettingName.length > 32) {
			helper.showRequiredHighlight(component, false, 'errorDivCSName', 'emcsnamelengthexceed');
		} 
		else if(customSettingType === consts.LBL_URL_VF_PAGE && customSettingName.length > 25) {
			helper.showRequiredHighlight(component, false, 'errorDivCSName', 'emcsnamelengthexceed');
		} 
		else if(customSettingType=== consts.LBL_CUSTOM_EVENTS && customSettingName.length > 19) {
			helper.showRequiredHighlight(component, false, 'errorDivCSName', 'emcsnamelengthexceed');
		}
    },

    handleNameChange : function(component, event, helper){
        
        var objectDetails = component.get("v.objectDetails");
        var activityName = component.find("activityNameID").get("v.value");
		console.log( 'handleNameChange-activityName', activityName );
        
		if(!activityName) {
            helper.clearAllTextFiledsOnForm(component);
            helper.showRequiredHighlight(component, true, 'errorDiv', 'error-message');
            component.find('customSettingNameID').set('v.value', '');
        } 
		else {
            helper.showRequiredHighlight(component, false, 'errorDiv', 'error-message');
            helper.populateFieldAccordingToActivityName(component, activityName);
        }
    },

    handleNameChangeVF: function(component, event, helper) {
        
		//console.log('ConfigSettingsNewEntryFormController.handleNameChangeVF: entered');
        var activityName = component.get('v.activityName');
        if(!activityName) {
            helper.showRequiredHighlight(component, true, 'errorDivVF', 'error-message-vf-act-name');
        } 
		else {
            helper.populateFieldsAccordingToName(component, activityName); 
        }
        
    },

    handleNameFocusVF:function(component, event, helper) {
        
		helper.showRequiredHighlight(component, false, 'errorDivVF', 'error-message-vf-act-name');
    },

    handleNameChangeMA: function(component, event, helper) {
        
		//console.log('ConfigSettingsNewEntryFormController.handleNameChangeMA: entered');
        var activityName = component.get('v.activityName');
        if(!activityName) {
            helper.showRequiredHighlight(component, true, 'errordivmanact', 'errormessagemanact');
        }
        else{
           helper.populateFieldsAccordingToName(component, activityName);
           helper.showRequiredHighlight(component, false, 'errordivmanact', 'errormessagemanact');
           helper.showRequiredHighlight(component, false, 'errorDivActionCategoryId', 'error-message-actionCategoryId');
           helper.showRequiredHighlight(component, false, 'errorDivActionGroupId', 'error-message-actionGroupId');
           helper.populateTextWithValue(component, 'customSettingNameID', 'Manual_'+activityName.toUpperCase()); 
        }
		
    },

    handlePageChange : function(component, event, helper) {
        
        var VFPage = component.find("VFPageID").get("v.value");
        //console.log( 'VFPage', VFPage );
        
        var urlPatternText = component.find('urlPatternTextID');
        var consts = helper.getConstants(component);
        
        //Throw error if name is empty
        //console.log( '!VFPage || VFPage === consts.LBL_SELECT', !VFPage || VFPage === consts.LBL_SELECT );
        if(!VFPage || VFPage === consts.LBL_SELECT) {
            helper.clearAllTextFiledsOnForm(component);
            helper.showRequiredHighlight(component, true, 'errorDivPage', 'error-message-Page');
            urlPatternText.set("v.value", '');
        } else {
            //console.log( 'handlePageChange-formattedName', component.get( "v.formattedName"));
            helper.populateTextWithValue( component, 'activityNameIDVF', VFPage ); //+ consts.VAL_NAME_SEPARATOR + 'Page' );
            //console.log( 'activityName', component.get( "v.activityName" ) );
            helper.populateFieldsAccordingToName( component, VFPage ); //+ consts.VAL_LABEL_SEPARATOR + 'Page' );
            helper.showRequiredHighlight( component, false,'errorDivPage', 'error-message-Page');
            urlPatternText.set('v.value', '/apex/'+VFPage);
        }
        helper.hideErrorMessages(component, helper);
    },

    populateJSONText: function(component, event, helper) {
        
		//console.log('populateJSONText.entered');
        var selectBoxValue = event.getSource().get("v.value");
        
		console.log('selectBoxValue: ',selectBoxValue);
        if(!selectBoxValue || selectBoxValue === '----SELECT----'){
            helper.showRequiredHighlight( component, true,'errorDivJSON', 'error-message-JSON');
        } else{
            helper.showRequiredHighlight( component, false,'errorDivJSON', 'error-message-JSON');
        }
        helper.populateSObjectJsonDetails(component, selectBoxValue);
    },

    setOptions: function(component, event, helper) {
        //console.log('setOptions: entered');
        helper.loadOptionsForSObjectFields(component);
    },

    setSelectedValue : function(component, event, helper){ 
        
		var val=event.getParam('value');
        helper.setSelectedValue(component,val, helper);
    },

    clearErrorMessages: function(component, event, helper) {
        
		//console.log('ConfigSettingsNewEntryFormController.clearErrorMessages: entered');
        var errorDivIds = [ "emcsnamerequired", "emcsnamelengthexceed", "emcsnameused", "error-message", "error-message-JS"];
        helper.hideErrorMessages(component, errorDivIds);
    },

    /*
	// DO NOT DELETE onblur is not function in ui:buttonn, hence this method can be later used when event.getSource is available in spring17
    showHelpText : function(component, event, helper){
        var div=event.getSource().getLocalId();
        div=div+'Div';
        helper.showElement(component, div);
    },

    hideHelpText : function(component, event, helper){
        var div=event.getSource().getLocalId();
        div=div+'Div';
        helper.hideElement(component, div);
    },
    //*/

    showHelpTextA : function(component,event, helper){
        
		helper.showElement(component,  'helpTextDiv');
    },

    showHelpTextB : function(component,event, helper){
        
		helper.showElement(component, 'helpTextDivObjDiv');
    },

    showHelpTextC : function(component,event, helper){
        
		helper.showElement(component, 'helpTextDivPObjDiv');
    },

    hideHelpTextA : function(component,event, helper){
        
		helper.hideElement(component, 'helpTextDiv');
    },

    hideHelpTextB : function(component,event, helper){
        
		helper.hideElement(component, 'helpTextDivObjDiv');
    },

    hideHelpTextC : function(component,event, helper){
        
		helper.hideElement(component, 'helpTextDivPObjDiv');
    },

    /*
	showJSONGenerator : function(component, event, helper){
        helper.showJSONGenerator(component);
    },
	//*/

    setJSON : function(component, event, helper){
        
		var jsonText=event.getParam('jsonString');
        if(jsonText === '' || jsonText === undefined || jsonText === null){
            //helper.showRequiredHighlight(component, true, 'errorDivJSON', 'error-message-JSON');
        } else {
            helper.showRequiredHighlight(component, false, 'errorDivJSON', 'error-message-JSON');
            component.find('jsonText').set('v.value', event.getParam('jsonString'));
        }
    },
    
    handlerClearTextTypeAheadEvent : function( component, event, helper ) {
    	
        //console.log( 'Clear Type Ahead Text Event being caught', event );
        helper.hideErrorMessages(component, helper);
        helper.cancel( component, event, helper, false );
    },
    
    /*
    handleValueChange : function(component, event, helper){
        var source=event.getSource();
        var val=source.find('JSFileNameID').get('v.value');
        if(val === '' || val === undefined || val= null){
            helper.showRequiredHighlight(component, true, 'errorDivJS', 'error-message-JS');
        }
        else{
            helper.showRequiredHighlight(component, false, 'errorDivJS', 'error-message-JS');
        }
    },
    */
})