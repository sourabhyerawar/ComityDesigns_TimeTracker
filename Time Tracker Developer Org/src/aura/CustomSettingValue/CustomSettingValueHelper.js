({  
    handleInit : function(component) {
        
        var setting = component.get("v.setting");
        var field = component.get("v.field");
        //console.log('setting:',setting,'field',field);
        
		var outputText = component.find("outputTextId");
        var outputCheckbox = component.find("inputCheckboxId");
        component.set("v.oldFieldValue", setting[field.apiName]);
        //TODO: add namespace prefixed fields as well in comparison
        
		if(field.isBoolean) { /*for boolean field render checkbox*/
            this.showElement(component, 'inputCheckBoxDiv');
            component.set("v.isCheckboxRendered", true);
            (setting[field.apiName]) ? component.set("v.isChecked", true) : component.set("v.isChecked", false);
        } 
		else { /*for text field render textbox*/
            this.showElement(component,'outputTextDiv');
            component.set("v.isOutputTextRendered", true);
            outputText.set("v.value",setting[field.apiName]);
        }
        //console.log('component.set("v.oldFieldValue")',component.get("v.oldFieldValue"));
    }, 
    
    handleBlurEvent : function(component,event, isCode2){
        
		console.log('CustomSettingValueHelper.handleBlurEvent:entered');
		field = component.get('v.field');
        var inValue;
        if(isCode2){
            inValue=event.getParam('jsonString');
            //console.log('inValue : ' , inValue);
        } 
		else{
            var comp=event.getSource();
            inValue=comp.get("v.value"); 
        }
        component.set("v.newFieldValue", inValue);
        console.log('handleBlurEvent ',inValue);
        console.log('oldValue ',component.get("v.oldFieldValue"));
        
        if(field.isBoolean){
            if(inValue != component.get("v.oldFieldValue")){
                this.hideElement(component,'inputTextDiv');
                this.showElement(component,'outputTextDiv');
                component.set("v.isChecked", inValue);
                
                var passRowColIndextoAdd = component.getEvent("passRowColIndexEvt");
        		passRowColIndextoAdd.setParams({
            			"rowIndex" : component.get('v.rowIndex'),
                    	"colIndex" : component.get('v.colIndex'),
                    	"isAdd"	   : true
                });
        		passRowColIndextoAdd.fire();
                
                this.fireToggleEvent(component,event,true);
            }
            this.showBGColor(component);
            this.showElement(component, 'undoButton');
            component.set('v.valueIsChanged', true);
        }
        
        //Case of required NAME field
        //if( (inValue === '' || (!inValue)) && component.get("v.fieldName") === 'Name'){
        if( component.get("v.field").apiName === 'Name' && (inValue === '' || inValue === null || (!inValue.replace(/\s/g, '').length))){
            component.set('v.isNameFieldEmpty', true);
            this.showElement(component, 'reqDiv');
            this.showBGColor(component);
            comp.set("v.required", 'true');
            this.showElement(component,'undoButton');
            component.set('v.valueIsChanged', false);
            this.fireToggleEvent(component,event,null);		//send isEdit null whenever we dont want to change counter
        } 
		else if(inValue === component.get("v.oldFieldValue")) { //case where new and old values are same
            this.hideBGColor(component);
            this.hideElement(component,'undoButton');
            this.showElement(component,'editButton');
            if(component.get("v.isCheckboxRendered")) {
                comp.set("v.disabled", true);
            }
            else if(component.get("v.isOutputTextRendered")) {
                this.hideElement(component,'inputTextDiv');
                this.showElement(component,'outputTextDiv');
            }
            
            component.set("v.changedTextAfterInput", component.get("v.oldFieldValue"));
            component.set('v.valueIsChanged', false);
            
            var passRowColIndextoRemove = component.getEvent("passRowColIndexEvt");
        		passRowColIndextoRemove.setParams({
            			"rowIndex" : component.get('v.rowIndex'),
                    	"colIndex" : component.get('v.colIndex'),
                    	"isAdd"	   : false
                });
        	passRowColIndextoRemove.fire();
            
            this.fireToggleEvent(component,event,false);
        } 
		else if(inValue != component.get("v.changedTextAfterInput")) { //case when old and new are not same
            console.log('updated Value >',inValue);
            if(component.get("v.isOutputTextRendered")) {
                if(component.get("v.field").apiName === 'Name') {
                    component.set('v.isNameFieldEmpty', false);
                    //this.fireToggleEvent(component,event,true);
                }
                this.hideElement(component,'inputTextDiv');
                this.showElement(component,'outputTextDiv');
                component.set("v.changedTextAfterInput", inValue);
                
                var passRowColIndextoAdd = component.getEvent("passRowColIndexEvt");
        		passRowColIndextoAdd.setParams({
            			"rowIndex" : component.get('v.rowIndex'),
                    	"colIndex" : component.get('v.colIndex'),
                    	"isAdd"	   : true
                });
        		passRowColIndextoAdd.fire();
                
                this.fireToggleEvent(component,event,true);
            }
            this.showBGColor(component);
            this.showElement(component, 'undoButton');
            component.set('v.valueIsChanged', true);
            
        }
        this.fireUpdateEvent(component, event);
    },
    
    onEditHelper : function(component, setting, fieldMetadata) {
        
		if(component.get("v.isOutputTextRendered")) {
            this.showElement(component, 'inputTextDiv');
            this.hideElement(component, 'outputTextDiv');
            component.set("v.defaultInputText", component.find("outputTextId").get("v.value"));
            component.find('inputTextId').getElement().focus();
        } 
		else if(fieldMetadata.isBoolean) {
            component.set("v.isCheckBoxDisabled", false);
        }
    },
    
    unDoComponentAttributeChanges: function(component) {
        
		var setting, field, newValue, oldValue;
        setting = component.get('v.setting');
        field = component.get('v.field');
        newValue = component.find("inputTextId").get("v.value");
        oldValue = component.get("v.oldFieldValue");
		
        //console.log('newValue',newValue,'oldValue',oldValue)
        setting[(field.apiName)] = oldValue;
        field.isEdit = true ;
        component.set('v.setting', setting);
        component.set('v.field', field);
    },

    onUndoHelper : function(component) {
        
        this.hideElement(component, 'undoButton');
        this.showElement(component, 'editButton');
        this.hideElement(component, 'inputTextDiv');
        this.showElement(component, 'outputTextDiv');
		
        component.set("v.isCheckBoxDisabled", true);
        component.set("v.valueIsChanged", false);
        //tempSetting[FieldName]=component.get("v.oldFieldValue");
		
        var newVal = component.get("v.newFieldValue");
        var oldVal = component.get("v.oldFieldValue");
        //Hide dropdown and show outputtext
        if(component.get("v.isInputSelectRendered")){
            this.showElement(component, 'outputTextDiv');
            this.hideElement(component, 'inputSelectDiv');
            this.hideBGColor(component);
            component.set('v.isOutputTextRendered', true);
        }
        
        console.log('onUndoHelper oldVal>',oldVal);
        console.log('onUndoHelper newVal>',newVal);
        /*IF BLOCK:  If undo is clicked w/o making any changes or w/o blur event
        * ELSE BLOCK: If undo is clicked after some change is made or after hover event is done 
        */
        if(oldVal === newVal || newVal === 'null'){            
            if(component.get("v.isOutputTextRendered")){
                this.showElement(component, 'outputTextDiv');
                this.hideElement(component, 'inputTextDiv');
                component.set('v.isOutputTextRendered', true);
            }
        }
        else{
            if(component.get("v.isCheckboxRendered")){
                var checkBox=component.find('inputCheckboxId');
                checkBox.set("v.value", component.get("v.oldFieldValue"));   
            }
            else if(component.get("v.isOutputTextRendered")){
                var outText=component.find('outputTextId');
                outText.set("v.value", component.get("v.oldFieldValue"));

                component.set('v.isOutputTextRendered', true);
            }
            this.hideBGColor(component);
        }
    },
    
    showElement : function(component, id){
        
		var divElement=component.find(id);
        $A.util.removeClass(divElement, 'slds-hide');
        $A.util.addClass(divElement, 'slds-show');
    },
    
    hideElement : function(component, id){
        
		var divElement=component.find(id);
        $A.util.removeClass(divElement, 'slds-show');
        $A.util.addClass(divElement, 'slds-hide');
    },
    
    hideBGColor : function(component){
        
        var outerDiv=component.find('outerDivID');
        $A.util.removeClass(outerDiv, 'textClass');
        /*
        var evt=component.getEvent('c.changeColorEvt');
        evt.setParams({
            show : false
        });
        evt.fire();
        */
    },
    
    showBGColor : function(component){
        
        var outerDiv=component.find('outerDivID');
        $A.util.addClass(outerDiv, 'textClass');
        /*
        var evt=$A.get('e.c:changeColorEvt');
        evt.setParams({
            show : true
        });
        evt.fire();
        */
    },
    
    getObjectNameList : function(component){  
        
		var action=component.get("c.getObjectNameList");
        action.setParams({
            removeAlreadyTrackedObj : false,
            includeMandatory : true
        });
		
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (component.isValid() && state === "SUCCESS") {
                
                component.set("v.objNameList", response.getReturnValue());
            } 
			else if (component.isValid() && state === "INCOMPLETE") {
                //console.log('State incomplete: '+ state);
            } 
			else if (component.isValid() && state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        //console.log("Error message: " + errors[0].message);
                    }
                } else {
                    //console.log("Unknown error");
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    
    //Method to fire event for toggling save button enable
    fireToggleEvent: function(component, event, isEdit){
        
		var toggleEvent = $A.get("e.c:onEditToggleEvent");
        /*
		if(component.get("v.field").Name === 'Name'){
            toggleEvent.setParams({
                "isEdit" : isEdit,
                "isNameFieldEmpty" : component.get('v.isNameFieldEmpty')
            });    
        }
		//*/
        toggleEvent.setParams({
            "isEdit" : isEdit,
        });
        toggleEvent.fire();
    }, 
    
    fireUpdateEvent : function(component, event) {
        
		//console.log('CustomSettingValueHelper.fireUpdateEvent: entered');
        var updateEvent = $A.get("e.c:updateEvent");
        var setting = component.get("v.setting");
        var field = component.get("v.field");
		
        console.log('fireUpdateEvent > settings',setting, 'field',field);
        var updateSettings = {};
        updateSettings[(field.apiName)] = setting[(field.apiName)];
        updateSettings.Name = setting.Name;
        updateSettings.Id = setting.Id;
        updateSettings.Type__c = setting.Type__c;
		
        //console.log('updateSettings: ',updateSettings);
        updateEvent.setParams({
            "setting" : updateSettings,
            "field" : field
            //"fieldAPIName": component.get("v.fieldName"),
            //"fieldValue": component.get("v.newFieldValue")
        });
        updateEvent.fire();
    },
    
    handlePushBack : function(component, event){
        
		//console.log('inside handlePushBack');
        var sourceComponent=event.getSource();
        var val=sourceComponent.get('v.value');
        if(val === null || val === ''){
            //do nothing, blur event will handle null checks
        }
        else{
            component.set('v.isNameFieldEmpty', false);
            this.hideElement(component, 'inputTextDiv');
            this.showElement(component, 'outputTextDiv');   
        }
        this.handleBlurEvent(component,event, false);
		
        /*
        if(component.get('v.isNameFieldEmpty')){
            component.set('v.isNameFieldEmpty', false);
        }
        this.fireToggleEvent(component,event, false);
        this.onUndoHelper(component);
        //*/
    },
    
	getConstants: function(component) {
		
		var consts;
		
		if(component.get('v.namespace')){
			consts['LBL_SELECT'] = $A.get("$Label.timetracker.LBL_Select_DropDown");
		} 
		else{
			consts['LBL_SELECT'] = $A.get("$Label.c.LBL_Select_DropDown");
		} 
		return consts;  
    }
})