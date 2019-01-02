({
    doInit : function(component, event, helper) {
        
        var customSetting = component.get('v.customSettingByTypeSettingType');
        var InitialCustomSetting = JSON.stringify(customSetting);
        component.set('v.InitialCustomSetting',InitialCustomSetting);
        
		helper.loadConfigSettingsDetails(component);
        var consts = helper.getConstants(component);
        component.set('v.consts', consts);
    },

    // Stores the changed setting records in a list
    handleUpdateEvent : function(component, event, helper) {
        
		//console.log('ConfigSettingsDetailsController.handleUpdateEvent: entered');
        var setting = event.getParam("setting");
        console.log('handleUpdateEvent-setting',setting);
        
        var field = event.getParam("field");
        console.log('handleUpdateEvent-field',field);
        
        var updatedCustomSettingList = component.get("v.updatedCustomSettingList");
        console.log('Before-updatedCustomSettingList',updatedCustomSettingList);
        
		updatedCustomSettingList = helper.updateSettingIfAlreadyInUpdatedCSList(field, setting, updatedCustomSettingList);
        component.set("v.updatedCustomSettingList", updatedCustomSettingList);
		console.log('After-updatedCustomSettingList',updatedCustomSettingList);
    },

    //Calls method to call server and pass updated list
    handleCallServerEvent : function(component, event, helper) {
        
		var csToUpdate = event.getParam("csToUpdate");
        console.log('handleCallServerEvent-csToUpdate',csToUpdate);
        
        var csToDelete = event.getParam("csToDelete");
        console.log('handleCallServerEvent-csToDelete',csToDelete);
        
        var updatedCsList = component.get("v.updatedCustomSettingList");
        console.log('handleCallServerEvent-updatedCsList',updatedCsList);
        
		if(csToDelete) {
            helper.callServerForDelete(component, csToDelete);
        } 
		else {
            helper.callServerForUpdate(component, updatedCsList, csToUpdate);
        }
    },

    handleMouseOver: function(component, event, helper) {
    },

    editRow: function(component, event, helper) {
        
		var customSettingList = component.get("v.customSetting");
        var currentTargetElement = event.currentTarget;
        
        var index = Number(currentTargetElement.getAttribute('data-index'));
        console.log('editRow-index', index);
        
        var setting = customSettingList[index];
		console.log('editRow-setting', setting);
        
        helper.createConfigSettingRecordModal(component, setting);
    },

    deleteRow: function(component, event, helper) {
        
		var customSettingList = component.get("v.customSetting");
        console.log('deleteRow-customSettingList', customSettingList );
        
        var currentTargetElement = event.currentTarget;
        
        var index = Number(currentTargetElement.getAttribute('data-index'));
        console.log('deleteRow-index', index);
        
        var setting = customSettingList[index];
        console.log('deleteRow-setting', setting);
        
		helper.showToast(component, setting);
    },

    countComponents : function(component, event, helper) {
        
		helper.countComponents(component);
    },

    handleFilterTableEvent : function(component, event, helper) {
        
		helper.handleFilterTableEvent(component, event);
    },

    handleMore : function(component, event, helper) {
        
		helper.showNextBatch(component);
    },

    showSpinner : function(component, event, helper) {
    },

    changeColor : function(component, event, helper) {
        
		var show = event.getParam('show');
        var cell = component.find('cellID');
        
		if(show) {
            $A.Util.addClass(cell, 'slds-is-edited cellContainer');
        } 
		else {
            $A.Util.removeClass(cell, 'slds-is-edited cellContainer');
        }
    },
})