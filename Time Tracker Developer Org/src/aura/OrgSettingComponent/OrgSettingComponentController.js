({
    handleInit : function(component, event, helper){
        
		helper.showSpinner(component, false, 'spinnerDiv');
        helper.populateDefaultValues(component);
    },   
    
    handleEdit : function(component, event, helper) {
        
		component.set('v.isDisabled', false);
        component.set('v.saveDisabled', false);
        component.set('v.cancelDisabled', false);
        component.set('v.editDisabled', true);
    },
    
    handleCancel : function(component, event, helper){
        
		helper.populateEachField(component.get('v.setting'),component);
        helper.hideError(component, "maxDurationID");
        helper.hideError(component, "weeklyHrsID");
        component.set('v.saveDisabled', true);
        component.set('v.isDisabled', true);
        component.set('v.cancelDisabled', true);
        component.set('v.editDisabled', false);
    },
    
    handleSave : function(component, event, helper){
        
        /*console.log( 'handleSave' );
		helper.showSpinner(component, true, 'spinnerDiv');
        var numberFldIdLst = [ 'maxDurationID', 'weeklyHrsID'];
        
        var isError = false;
        numberFldIdLst.forEach(function(el,i, arr) {
            var element = component.find(el);
            if(element){
                var val= element.get('v.value');
                console.log( 'val',val );
                if( !val || val === 0) {
                    element.set('v.value',0);
                }
                if( !(val >= 0) ) {
                    console.log( 'isError-inner',isError );
                    isError = true;
                }
            }
        });
        
        console.log( 'isError-outer',isError );
        if( !isError) {
            helper.updateServer(component);
        }
        else {
           component.set('v.errorMsg', 'Please provide valid data.');
           this.showError(component); 
        }
        */
        helper.showSpinner(component, true, 'spinnerDiv');
        helper.updateServer(component);
        component.set('v.saveDisabled', true);
        component.set('v.isDisabled', true);
        component.set('v.cancelDisabled', true);
        component.set('v.editDisabled', false);
    },
    
    toggleDivA : function(component, event, helper){
        
		helper.toggleDiv(component, true);
    },
    
    toggleDivB : function(component, event, helper){
        
		helper.toggleDiv(component, false);
    },

    loadNamespace: function(component, event, helper) {
        
		//console.log('OrgSettingComponentController.loadNamespace: entered ');
        var namespace = event.getParam("namespace");
        //console.log("namespace", namespace);
        component.set("v.namespace", namespace);
    },
    
    /*
    //To be implemented after spring 17 release to disallow save button enabling till all fields are valid
    validateField : function(component,  event,  helper){
        
        var source=event.getSource();  
        var val=source.get('v.validity');
        console.log('validity: ', val);
       
    }, 
    //*/
    
    validateFieldA : function(component,  event,  helper){
        
		//var maxD = component.find('maxDurationID');
        helper.toggleSaveButton(component);
    },
    
    validateFieldB : function(component,  event,  helper){
        
		//var weeklyHrs = component.find('weeklyHrsID');
        helper.toggleSaveButton(component);
    },
})