({
    handleInit : function(component, event, helper) {
        
		//console.log( 'UserSettingComponentController-handleInit-orgSetting', component.get( 'v.orgSetting') );
        helper.getConfigSettingsDetails(component, true);
        var consts = helper.getConstants();
        component.set("v.consts", consts);
    },
    
    handleNew : function(component, event, helper){
        console.log('Before creating compnent');
		helper.renderNewOrEditForm(component, true, component.get('v.orgSetting'));
        console.log('After creating compnent');
    },
    
    editRow : function(component, event, helper){
        
		var id = event.currentTarget.getAttribute("data-recId");
        helper.fetchCustomSettingRecordByID(component, id, true);
    },

    loadNamespace: function(component, event, helper) {
        
		//console.log('UserSettingComponentController.loadNamespace: entered');
        var namespace = event.getParam('namespace');
        if( namespace && !component.get('v.namespace' ) ) {
        	component.set('v.namespace', namespace);
        }
    },
    
    deleteRow : function(component, event, helper){
        
		var id = event.currentTarget.getAttribute("data-recId");
        //console.log( 'deleteRow-id', id );
        helper.fetchCustomSettingRecordByID(component, id, false);
    },
    
    refreshTab: function(component, event, helper){
        
		var isDelete = event.getParam('isDelete');
        //console.log( 'isDelete', isDelete );
        
        if(isDelete) {		//Do not change the order of spinner and toast in this method
            helper.deleteSelectedRow(component);
        } 
		else {
            helper.showToast(component, 'success', 'Success!', 'Record Saved Successfully!');
         	helper.getConfigSettingsDetails(component, false, false);
        }
    },
})