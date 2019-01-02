/*
	@ Purpose : Controls the component --> ConfigSettingRecord
	@ Name    : ConfigSettingRecordController
//*/

({
	loadConfigSettingAndMetadata : function(component, event, helper) {
		
		var configsettingmetadata, configsetting, namespace, csFieldObj, originalCsList, isModal, consts;
		configsettingmetadata = component.get("v.configsettingmetadata");
		namespace = component.get("v.namespace");
		originalCsList = component.get("v.originalCsList");
        
        configsetting = component.get("v.configsetting");
        console.log( 'ConfigSettingRecordController-loadConfigSettingAndMetadata-configsetting', configsetting );
        
        var lastSavedConfigSettingJson = JSON.stringify(configsetting);
        console.log( 'loadConfigSettingAndMetadata-lastSavedConfigSettingJson', lastSavedConfigSettingJson );
        component.set( "v.lastSavedConfigSettingJson", lastSavedConfigSettingJson );
        
		isModal = component.get("v.isModal");
		consts = helper.getConstants(component);
		component.set("v.consts", consts);
		
		if(!configsettingmetadata || !configsetting) return;
		
        helper.hideFieldsForStrategy( component, configsetting );
        
		csType = configsetting[consts.TYPE_FIELD];
        console.log( 'csType', csType );
        
		csFieldObj={};
		
		var csMetadataByType = configsettingmetadata[csType];
		if(csMetadataByType && csMetadataByType.length>0) {
			csMetadataByType.forEach(function(el) {
				var fieldName = el.apiName;
				if(fieldName.startsWith('timetracker__')) fieldName.replace('timetracker__','');
				csFieldObj[el.apiName] = el;
			});
		}
		component.set("v.csfield", csFieldObj);
        
        var isModal = component.get("v.isModal");
        console.log( 'isModal', isModal );
        
		var isCurrentCsPresent = helper.isCurrentCsPresentInCsList(component, helper, namespace, configsetting, originalCsList);
		if( isCurrentCsPresent && isCurrentCsPresent.state === consts.STATE_ERROR ) {
			component.set("v.formheader", isCurrentCsPresent.message);
			helper.applyCSS(component, event, 'pageheader', 'alert');
			helper.applyCSS(component, event, 'pageheader', 'alert-error');
			helper.removeCSS(component, event, 'pageheader', 'slds-page-header');
            
            if( !isModal ) {
                helper.stylePageMessage( component, 'warning' );
            }
		} else {
			helper.applyCSS(component, event, 'pageheader', 'alert');
			helper.removeCSS(component, event, 'pageheader', '');
            if( !isModal ) {
                helper.stylePageMessage( component, 'info' );
            }
		}
	},
    
    handleEditCS: function(component, event, helper) {
		
        component.set( 'v.editMode', true );
	},
    
	handleCancelCS: function(component, event, helper) {
		
		var isModal, compEvent;
		isModal = component.get('v.isModal');
        
        var configsetting = component.get( "v.configsetting" );
        console.log( 'before-cancel-configsetting', configsetting );
        
        var lastSavedConfigSettingJson = component.get( "v.lastSavedConfigSettingJson" );
        console.log( 'lastSavedConfigSettingJson', lastSavedConfigSettingJson );
        
        component.set( "v.configsetting", JSON.parse( lastSavedConfigSettingJson ) );
        console.log( 'after-cancel-configsetting', component.get( "v.configsetting" ) );
        
		if(!isModal) {
			component.set( 'v.editMode', false );
		} else {
			compEvent = component.getEvent("closeConfigSettingRecordModal");
			helper.fireCloseConfigSettingRecordModalEvent(component, compEvent);
		}
	},

	handleSaveCS: function(component, event, helper) {
		
        var namespace, configsetting, configSettingRecordList, csType, compEvent, consts;
		namespace = component.get("v.namespace");
		configsetting = component.get("v.configsetting");
		compEvent = component.getEvent("closeConfigSettingRecordModal");
		
		configSettingRecordList=[];
		consts = helper.getConstants(component);
		csType = configsetting[(helper.getFieldName(namespace, consts.TYPE_FIELD))];
		configSettingRecordList.push(component.get("v.configsetting"));
        
        // Adding Client Side Validations on 23rd October,2017.
		var formStatus = helper.validateForm( component );
		if( formStatus.type === 'success' ) {
            helper.createTimeTrackerConfigSettings(component, configSettingRecordList);
        }
        else {
			helper.showSpinner( component, false );
            helper.fireCloseConfigSettingRecordModalEvent(component, compEvent);
			helper.createToastComponent( component, formStatus.type, formStatus.title, formStatus.message );
		}
	},
})