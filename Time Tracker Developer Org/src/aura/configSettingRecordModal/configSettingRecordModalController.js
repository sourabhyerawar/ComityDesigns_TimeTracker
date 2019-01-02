({
	doInit : function(component, event, helper) {
		
		//console.log('configSettingRecordModalController.doInit: entered');
		var csMetadata, setting, namespace, isEdit, consts;
		csMetadata = component.get("v.csMetadata");
		setting = component.get("v.setting");
		
		namespace = component.get("v.namespace");
		isEdit = component.get("v.isEdit");
		consts = helper.getConstants(component);
		component.set("v.consts", consts);
		//console.log('csMetadata',csMetadata,'setting',setting,'namespace',namespace,'isEdit',isEdit);

		window.setTimeout(
            $A.getCallback( function() {
                $A.createComponent(
		            "c:ConfigSettingRecord",
		            {
		                'configsettingmetadata':csMetadata,
		                'configsetting': setting,
		                'isModal': true,
		                'editMode': isEdit,
		                'namespace': namespace 
		            }, 
                    function(newComponent, status, errorMessage) {
		                if (status === "SUCCESS") {
		                    var body = component.get("v.body");
		                    body.push(newComponent);
		                    component.set("v.body", body);  
		                } 
                        else if (status === "INCOMPLETE") {
		                } 
                        else if (status === "ERROR") {
		                }
		            }
		        ); 
            }),500
        );
	},

	closeModal: function(component, event, helper) {
		
		//console.log('configSettingRecordModalController.closeModal: entered');
		helper.hidePopupHelper(component);
	},

	closeCSRecordModal: function(component, event, helper) {
		
		//console.log('configSettingRecordModalController.closeCSRecordModal: entered');
		helper.hidePopupHelper(component);
	},
})