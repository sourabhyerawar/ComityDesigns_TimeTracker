({
    doInit : function(component, event,helper) {
		var counterEvent = $A.get("e.c:counterEvent");
        counterEvent.fire();
        helper.handleInit(component); 
    }, 
    
    onEdit : function( component, event, helper ) {
        
        var setting = component.get('v.setting');
        var fieldMetadata = component.get('v.field');
		if(component.get("v.isOutputTextRendered")) {
            helper.onEditHelper(component, setting, fieldMetadata);
        } 
		else if(component.get("v.isCheckboxRendered")){
            helper.onEditHelper(component, setting, fieldMetadata);
        }
    },

    handleFocus: function(component, event, helper) {
        
		//helper.fireToggleEvent(component, event, true);
    },
    
    /*Logic for showing changed value along with BGColor and icon toggle*/
    showChangedValue : function(component, event,helper) {
        
		console.log('CustomSettingValueController.showChangedValue Controller: entered');
        var setting, fieldMetadata, newValue, oldValue;
        setting = component.get('v.setting');
        fieldMetadata = component.get('v.field');
        oldValue = component.get("v.oldFieldValue");
        
        (fieldMetadata.isBoolean)? 
            newValue = component.find('inputCheckboxId').get('v.value'):
                newValue = component.get('v.defaultInputText');
        
        console.log('setting',setting,'fieldMetadata',fieldMetadata,'newValue',newValue, 'oldValue',oldValue);
        
        fieldMetadata.isEdit = (newValue!==oldValue) ;
        if(fieldMetadata.isEdit) {
            setting[(fieldMetadata.apiName)] = newValue;
        } 
       // console.log('on blur new val>>'+component.get('v.defaultInputText'));
        component.set('v.setting', setting);
		//console.log('After modification on blur settings>>'+setting[(fieldMetadata.apiName)]);
        //component.set("v.valueChanged", true);
        //helper.showUndoButton(component);	
        //console.log('inside showChangedValue');
		//console.log('isInputSelectRendered'+component.get('v.isInputSelectRendered'));
        helper.handleBlurEvent(component,event, false);
        if(component.get('v.isInputSelectRendered')){
            //helper.handleBlurEvent(component, event);
        } 
		else {
            //helper.handlePushBack(component, event);   
            setting[(fieldMetadata.apiName)] = component.find("inputTextId").get("v.value");
            //console.log('After modification in else>>'+setting[(fieldMetadata.apiName)]);
        }
    },
    
    pushThisBack : function(component, event, helper){
        
		helper.hideElement(component, 'inputTextDiv');
        helper.showElement(component, 'outputTextDiv');
    },
    
    /*Logic for showing changed value along with BGColor and icon toggle FOR CODE2 FIELD*/
    showChangedJSONValue : function(component, event,helper){
        
		helper.handleBlurEvent(component,event, true); 
    },
    
    onUndo : function(component, event,helper){
        
		//When name field is empty, reqd warning is thrown and save is disabled, and then undo is pressed:
        //Notify save button that empty value is removed and bring save back to its eariler position(can be disable/enable)
        if(component.get('v.isNameFieldEmpty')) {
            component.set('v.isNameFieldEmpty', false);
        }
        
        var passRowColIndextoRemove = component.getEvent("passRowColIndexEvt");
        		passRowColIndextoRemove.setParams({
            			"rowIndex" : component.get('v.rowIndex'),
                    	"colIndex" : component.get('v.colIndex'),
                    	"isAdd"	   : false
                });
        passRowColIndextoRemove.fire();
        
        helper.fireToggleEvent(component,event, false);
        helper.onUndoHelper(component);
        helper.unDoComponentAttributeChanges(component);
        helper.fireUpdateEvent(component, event);
    },
    
    handleSave : function(component, event,helper) {
        
		var consts = helper.getConstants(component);
        if(component.get("v.valueIsChanged")) {
            if(component.get("v.isInputSelectRendered")) {
                if(component.get("v.newFieldValue") === consts.LBL_SELECT || component.get("v.newFieldValue") === '') {
                } 
				else {
                    //Logic to fire event to enable save button
                    helper.fireUpdateEvent(component, event);
                }
            } 
			else {
                helper.fireUpdateEvent(component, event);
            }
        }
    },
})