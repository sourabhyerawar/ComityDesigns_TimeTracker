({

	hidePopupHelper : function(component) {
		
		//console.log('configSettingRecordModalHelper.hidePopupHelper: entered');
        var modal = component.find('modaldialog'); 
        $A.util.addClass(modal, 'slds-fade-in-hide'); 
        $A.util.removeClass(modal, 'slds-fade-in-open'); 
        $A.util.removeClass(modal, 'slds-backdrop'); 
        
		var dialogbackdrop = component.find("dialogbackdrop");
        $A.util.addClass(dialogbackdrop, 'slds-backdrop_open'); 
        $A.util.removeClass(dialogbackdrop, 'slds-backdrop');
        $A.util.removeClass(dialogbackdrop, 'slds-backdrop_open');//slds-backdrop_open
        //console.log('configSettingRecordModalHelper.hidePopupHelper: exit');
    },

    getConstants: function(component) {
        
		return {
            'LBL_CLOSE': 'Close',
            'LBL_EDIT_CS': 'Edit Configuration Setting'
        }
    }
})