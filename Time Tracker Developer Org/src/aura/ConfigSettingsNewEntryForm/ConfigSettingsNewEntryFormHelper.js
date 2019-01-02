/*
	@ Purpose : Provides the service to the Controller --> ConfigSettingsNewEntryFormController
	@ Name    : ConfigSettingsNewEntryFormHelper
//*/

({
	showRespectiveFields : function(component, trackedEntity) {
		var csNameComponent = component.find("customSettingNameID");
		var consts = this.getConstants(component);

		switch(trackedEntity) {
		case consts.LBL_MANUAL_ACTIVITY:
			this.showElement(component, 'manualFieldDiv');
			component.set('v.isManualSelected', true);
			csNameComponent.set("v.maxlength",32);
			break;
		case consts.LBL_URL_VF_PAGE:
			this.showElement(component, 'urlFieldDiv');
			this.getVFPageList(component);
			csNameComponent.set("v.maxlength",26);
			break;
		case consts.LBL_CUSTOM_EVENTS:
			this.showElement(component, 'customEventDiv');
			csNameComponent.set("v.maxlength",19);
			break;
		default:
			//console.log('Invalid value in dropdown: '+ trackedEntity);
			break;
		}
		//console.log("Inside showRespFields");
    },

    getVFPageList : function(component){
        
		var action  =component.get("c.getVFPageList");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                console.log('response',response.getReturnValue());
                component.set("v.VFPageList", response.getReturnValue());
                if(response.getReturnValue() === null || response.getReturnValue()=== undefined){
                    component.set('v.errorMsg', $A.get('{!$Label.c.LEX_Controller_Exception}'));
                    this.showElement(component, 'errorMsgID');
                }
            } 
			else if (component.isValid() && state === "INCOMPLETE") {
                component.set('v.errorMsg', 'Error: Incomplete');
                this.showElement(component, 'errorMsgID');
                //console.log('Error: Incomplete');
            } 
			else if (component.isValid() && state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        //console.log("Error message: " + errors[0].message);
                        component.set('v.errorMsg',  errors[0].message);
                        this.showElement(component, 'errorMsgID');
                    }
                } 
				else {
                    //console.log("Unknown error");
                    component.set('v.errorMsg', 'Unknown error');
                    this.showElement(component, 'errorMsgID');
                }
            }
        });
        $A.enqueueAction(action);
    },

    hideErrorMessages: function(component, helper) {
        
		var errorDivIds =  [ 
            {uiEle:"errorDivCSName", errEle:"emcsnamerequired" }, 
            {uiEle:"errorDivCSName", errEle:"emcsnamelengthexceed"}, 
            {uiEle:"errorDivCSName", errEle:"emcsnameused"}, 
            {uiEle:"errorDiv", errEle:"error-message"}, 
            {uiEle:"errorDivJS",errEle:"error-message-JS"}, 
            {uiEle:"errorDivRegEx", errEle:"error-message-regEx"}, 
            {uiEle:"errorDivPage", errEle:"error-message-Page"}, 
            {uiEle:"errorDivVF", errEle:"error-message-vf-act-name"},
            {uiEle:"errordivmanact", errEle:"errormessagemanact"}, 
            {uiEle:"objErrDiv", errEle:"objErrMsgDiv"}, 
            {uiEle:"objErrDivCustom", errEle:"objErrMsgDivCustom"}, 
            {uiEle:"errorDivJSON", errEle:"error-message-JSON"},
            {uiEle:"errorDivActionCategoryId", errEle:"error-message-actionCategoryId"},
            {uiEle:"errorDivActionGroupId", errEle:"error-message-actionGroupId"}
        ];
		
        errorDivIds.forEach( function(el) {
            //console.log('this', this);
            helper.showRequiredHighlight(component, false, el.uiEle, el.errEle);
        });
    },

    populateCustomSettingName : function(component, customSettingName) {
        
        if( customSettingName ) {
            customSettingName = customSettingName.replace(/ /g,"_");
        }
        
        console.log( 'before overriding activityName by customSettingName', component.get( "v.activityName") );
        //this.populateTextWithValue( component, 'activityNameID', customSettingName );
        console.log( 'after overriding activityName by customSettingName', component.get( "v.activityName") );
        
        var customSettingNameComponent = component.find( 'errorDivCSName' );
        var customSettingType = component.get( "v.trackedEntity" );
		
        if( this.validateCustomSettingNameLength( component, customSettingName, customSettingType ) ) {
			$A.util.addClass( customSettingNameComponent, 'hide-element' );
			$A.util.removeClass( customSettingNameComponent, 'show-element' );
        }
        else {
			this.showRequiredHighlight( component, true, 'errorDivCSName', 'emcsnamelengthexceed' );
			$A.util.addClass( customSettingNameComponent, 'show-element' );
			$A.util.removeClass( customSettingNameComponent, 'hide-element' );
        }
    },
	
    //function that validates name with existing name-Check wheather it is already used or not
    validateCustomSettingName: function(component, customSettingNameList, type) {
        
		//console.log('ConfigSettingsNewEntryFormHelper.validateCustomSettingName:entered');
        //console.log('customSettingNameList', customSettingNameList, 'type', type);
        var isCsNamePresent, isActivityNamePresent, settings;
        settings = JSON.parse(component.get("v.settings"));
        isCsNamePresent = false;
        isActivityNamePresent = false;
        
		//console.log('settings',settings, 'ConfigSettings:', settings.ConfigSettings);
        if(!settings||!customSettingNameList) return;
        customSettingNameList.forEach(function(el) {
            for(var key in settings.ConfigSettings) {
                if(el.Name===key) { isCsNamePresent = false; return; }
                if(el.Name) {}
            }
        });
        
        if(customSettingName && ttconfigSettingsList.length > 0) {
            isValidName = !(ttconfigSettingsList.indexOf(customSettingName) > 0);
        }
        //console.log('ConfigSettingsNewEntryFormHelper.validateCustomSettingName:exit, isValidName: '+isValidName);
        return isValidName;
    },

    //function that validates length of custom setting name field
    validateCustomSettingNameLength: function(component, name, type){
        
		//console.log('ConfigSettingsNewEntryFormHelper.validateCustomSettingNameLength: entered, Name: '+name+', type: '+type);
        var isValidLength = true;
        var consts = this.getConstants(component);
        if(!name || !type) return false;
		
        /*
        switch(type) {
            case consts.LBL_MANUAL_ACTIVITY:
                isValidLength = (name.length < 32); //32-this length is calculated according to other constants such as MANUAL_(<Something>)
                break;
            case consts.LBL_URL_VF_PAGE:
                isValidLength = (name.length < 25);
                break;
            case consts.LBL_CUSTOM_EVENTS:
                isValidLength = (name.length < 19);
                break;
            default:
                console.log('Not able to match type: '+type);
                break;
        }
        //*/
        
        //*
		var nameLength = name.length;
        switch(type) {
            case consts.LBL_MANUAL_ACTIVITY:
                nameLength = nameLength > 31 ? 31 : nameLength; //32-this length is calculated according to other constants such as MANUAL_(<Something>)
                break;
            case consts.LBL_URL_VF_PAGE:
                nameLength = nameLength > 24 ? 24 : nameLength;
                break;
            case consts.LBL_CUSTOM_EVENTS:
                nameLength = nameLength > 18 ? 18 : nameLength;
                break;
            default:
                console.log('Not able to match type: '+type);
                break;
        }
		
		// If character limit is exceeded in name field, we will trim the contents to make it valid.
		component.set( "v.formattedName", name.substring( 0, nameLength ) );
        //*/
        
        //console.log('ConfigSettingsNewEntryFormHelper.validateCustomSettingNameLength: exit, isValidLength: '+isValidLength);        
		return isValidLength;
    },

    //function that auto-populate all the details on new custom object tracking form
    populateCustomObjectTrackingFields: function(component, objectApiName) {
        
        var IsArticleRelatedObject, objectDetails, activityName, objectPrefix, objLabel;
        var standardObjectLookup, customObjectLookup;
        
        IsArticleRelatedObject = (objectApiName.endsWith('__ka') || objectApiName.endsWith('__kav'));
        objectDetails = component.get("v.objectDetails");
        console.log( 'populateCustomObjectTrackingFields-objectDetails', objectDetails );
        
        if( objectDetails && objectDetails.ObjLable && objectDetails.ObjPrefix ) {
            objLabel = objectDetails['ObjLable'];
            activityName = objLabel.replace(/(?!\w|\s)./g, '');
            objectPrefix = objectDetails['ObjPrefix'];
        }
        
        console.log( 'objLabel-replace-activityName', activityName );
        if( !activityName || !objectPrefix) return;
        
        this.populateTextWithValue(component, 'customSettingNameID', activityName.toUpperCase().replace(/ /g, "_"));
        console.log( 'after-customSettingName-populated', component.get( "v.formattedName" ) );
        
        if( IsArticleRelatedObject ) {
            this.populateTextWithValue(component, 'regExID', "\\/knowledge\\/publishing\\/articleEdit\\.apexp(.*)");
        }
        else{
            this.populateTextWithValue(component, 'regExID', ("\\/"+objectPrefix+"(.*)\\/e(.*)"));
        }      
        
        console.log( 'before-populateFieldAccordingToActivityName', component.get( "v.activityName" ) );
        
        this.populateFieldAccordingToActivityName(component, activityName, IsArticleRelatedObject);
        component.set( "v.activityName", activityName );
        
        if( objectDetails.jsonListOfRelationshipTokens ) {
            var listOfRelationshipTokens = JSON.parse( objectDetails.jsonListOfRelationshipTokens );
            if( listOfRelationshipTokens && listOfRelationshipTokens.length > 0 ) {
                this.populateTextWithValue( component, 'stdObjLookupID', listOfRelationshipTokens[ 0 ] );
                if( listOfRelationshipTokens.length > 1 ) {
                	this.populateTextWithValue( component, 'custObjLookupID', listOfRelationshipTokens[ 1 ] );
                }
            }
        }
    },

    //function that clears all text-fields on form
    clearAllTextFiledsOnForm: function(component) {
        
		//console.log('ConfigSettingsNewEntryFormHelper.clearAllTextFiledsOnForm: entered');
        this.populateTextWithValue(component, 'activityNameID', '');
        this.populateTextWithValue(component, 'activityNameIDVF', '');
        //this.populateTextWithValue(component, 'regExID', '');
        //this.populateTextWithValue(component, 'JSFileNameID', '');
        this.populateTextWithValue(component, 'urlParamID', '');
		
        this.populateTextWithValue(component, 'excludeActID', '');
        this.populateTextWithValue(component, 'cancleActNameID', '');
        this.populateTextWithValue(component, 'cancleActCatID', '');
        this.populateTextWithValue(component, 'timesheetEntryNameID', '');
        this.populateTextWithValue(component, 'activityGroupTextID', '');
    },

    populateFieldAccordingToActivityName: function(component, activityName, IsArticleRelatedObject) {
		
        console.log( 'populateFieldAccordingToActivityName entered' );
        var objectDetails = component.get("v.objectDetails");
        var objLabel = '';
        if( objectDetails ) {
            objLabel = objectDetails[ 'ObjLable' ];
        }
        
		var objConstant = this.getConstants(component);
        this.populateCustomSettingName(component, activityName);
        
        this.populateTextWithValue( component, 'excludeActID', objConstant.VAL_NEW_LABEL + objConstant.VAL_LABEL_SEPARATOR + objLabel + ';' + 
		objConstant.VAL_LABEL_SEPARATOR + objConstant.VAL_EDIT_LABEL + objConstant.VAL_LABEL_SEPARATOR + objLabel );
        
        (IsArticleRelatedObject)?
            this.populateTextWithValue(component, 'cancleActNameID', 'Article' + objConstant.VAL_LABEL_SEPARATOR + objConstant.VAL_CANCEL_LABEL) :
                this.populateTextWithValue(component, 'cancleActNameID', activityName + objConstant.VAL_LABEL_SEPARATOR + objConstant.VAL_CANCEL_LABEL );
        
        (IsArticleRelatedObject)?
            this.populateTextWithValue(component, 'cancleActCatID', 'Article' + objConstant.VAL_LABEL_SEPARATOR + objConstant.VAL_CANCELLATION_LABEL ):
                this.populateTextWithValue(component, 'cancleActCatID', activityName + objConstant.VAL_LABEL_SEPARATOR + objConstant.VAL_CANCELLATION_LABEL );
        
        (IsArticleRelatedObject)?
            this.populateTextWithValue(component, 'timesheetEntryNameID', 'Article' + objConstant.VAL_LABEL_SEPARATOR + objConstant.VAL_REVIEW_LABEL ):
                this.populateTextWithValue(component, 'timesheetEntryNameID', activityName + objConstant.VAL_LABEL_SEPARATOR + objConstant.VAL_REVIEW_LABEL );
        
        (IsArticleRelatedObject)?
            this.populateTextWithValue(component, 'activityGroupTextID', 'Knowledge Base'):
                this.populateTextWithValue(component, 'activityGroupTextID', activityName + objConstant.VAL_LABEL_SEPARATOR + objConstant.VAL_WORK_LABEL);
    	
        var actionCategory = component.find("timesheetEntryNameID").get("v.value");
		if( !actionCategory ) {
			this.showRequiredHighlight(component, true, 'errorDivActionCategoryId', 'error-message-actionCategoryId');
		}
		else {
			this.showRequiredHighlight(component, false, 'errorDivActionCategoryId', 'error-message-actionCategoryId');
		}
		
		var activityGroup = component.find("activityGroupTextID").get("v.value");
		if( !activityGroup ) {
			this.showRequiredHighlight(component, true, 'errorDivActionGroupId', 'error-message-actionGroupId');
		}
		else {
			this.showRequiredHighlight(component, false, 'errorDivActionGroupId', 'error-message-actionGroupId');
		}
    },


    //function that populates text-box with value
    populateTextWithValue: function(component, id, value) {
        
		var comp = component.find(id);
        if(comp) comp.set("v.value", value);
        //console.log('can not able to find componet with id:'+id);
    },

    populateFieldsAccordingToName: function(component, activityName) {
        
		this.populateCustomSettingName(component, activityName);
        this.populateTextWithValue(component, 'timesheetEntryNameID', activityName);
        this.populateTextWithValue(component, 'activityGroupTextID', activityName);
    },

    loadOptionsForSObjectFields: function(component) {
        
        var objectDetails = component.get("v.objectDetails");
        if(!objectDetails) { return; }
        var objectFieldListStr = objectDetails["ObjFields"];
        var selectOptions = [];
        
        selectOptions.push ( { 'class': 'optionClass','label': '----SELECT----', 'value': '----SELECT----' });
        var objectFieldList = objectFieldListStr.split(';');
        for(var i=0; i<objectFieldList.length; i++) {
            selectOptions.push ( { 'class': 'optionClass','label': objectFieldList[i], 'value': objectFieldList[i] });
        }
        component.find('sobjectFieldId').set('v.options', selectOptions);
    },

    populateSObjectJsonDetails: function(component, sObjectField) {
        
        //console.log('ConfigSettingsNewEntryFormHelper.populateSObjectJsonDetails : entered');
        var jsonObjArr = {'fields': [] }
        if(sObjectField!=='----SELECT----') {
            jsonObjArr.fields.push({'field': sObjectField, 'search': true, 'show': true });
            component.find('jsonText').set('v.value', JSON.stringify(jsonObjArr).replace(',', ';'));
        } 
		else {
            component.find('jsonText').set('v.value', '');
        }
    },

    handleSave : function(component, evt, helper) {
       
        var isSaveAndNew, trackedEntity, consts;
        var isError= false;
        consts = this.getConstants(component);        
        trackedEntity = component.get( "v.trackedEntity" );
        console.log( 'trackedEntity', trackedEntity );
        
		var actionCategory = component.find("timesheetEntryNameID").get("v.value");
		if( !actionCategory ) {
			this.showRequiredHighlight(component, true, 'errorDivActionCategoryId', 'error-message-actionCategoryId');
			isError=true;
		}
		else {
			this.showRequiredHighlight(component, false, 'errorDivActionCategoryId', 'error-message-actionCategoryId');
		}
		
		var activityGroup = component.find("activityGroupTextID").get("v.value");
		if( !activityGroup ) {
			this.showRequiredHighlight(component, true, 'errorDivActionGroupId', 'error-message-actionGroupId');
			isError=true;
		}
		else {
			this.showRequiredHighlight(component, false, 'errorDivActionGroupId', 'error-message-actionGroupId');
		}
		
		//if( !isError ) {
			switch( trackedEntity ) {
					
				case consts.LBL_URL_VF_PAGE:
					var VFPage = component.find("VFPageID").get("v.value");
					var urlActivityName = component.find("activityNameIDVF").get("v.value");
					
					if( VFPage === consts.LBL_SELECT ) {
						this.showRequiredHighlight(component, true, 'errorDivPage', 'error-message-Page');
						isError=true;
					}
					else {
						this.showRequiredHighlight(component, false, 'errorDivPage', 'error-message-Page');
					}
					
					if(!urlActivityName) {
						isError=true;
						this.showRequiredHighlight(component, true, 'errorDivVF', 'error-message-vf-act-name');
					}
					else {
						this.showRequiredHighlight(component, false, 'errorDivVF', 'error-message-vf-act-name');
					}
					
					if(!isError) {
						this.showSpinner(component, true);
						this.sendConfigSettingsEntryToServer(component,trackedEntity, evt);
					}
					else {
						this.hideVerifyTabAndClearTypeAhead( component, event, helper, false );
					}
					break;
					
				case consts.LBL_MANUAL_ACTIVITY:
					
					var manualActivityName = component.find('activityNameIDMA').get('v.value');
					var jsonText = component.find('jsonText').get('v.value');
					var searchComponent = component.find('searchCompID');
					
					if(!searchComponent.get('v.valueIsSet')) {
						this.showRequiredHighlight(component, true, 'objErrDiv' , 'objErrMsgDiv');
						isError=true;
					}
					else {
						this.showRequiredHighlight(component, false, 'objErrDiv' , 'objErrMsgDiv');
					}
					
					if(!jsonText) {
						this.showRequiredHighlight(component, true, 'errorDivJSON', 'error-message-JSON');
						isError=true;
					}
					else {
						this.showRequiredHighlight(component, false, 'errorDivJSON', 'error-message-JSON');
					}
					
					if(!manualActivityName) {
						isError=true;
						this.showRequiredHighlight(component, true, 'errordivmanact', 'errormessagemanact');
					}
					else {
						this.showRequiredHighlight(component, false, 'errordivmanact', 'errormessagemanact');
					}
					
					if(!isError){
						this.showSpinner(component, true);
						this.sendConfigSettingsEntryToServer(component,trackedEntity, evt);
					}
					else {
						this.hideVerifyTabAndClearTypeAhead( component, event, helper, false );
					}
					break;
					
				case consts.LBL_CUSTOM_EVENTS:
					
					console.log( 'consts.LBL_CUSTOM_EVENTS', consts.LBL_CUSTOM_EVENTS );
                    var searchComponentCustom = component.find('searchCompCustom');
					var ceActivityName = component.find('activityNameID').get('v.value');
					var jsFileName= component.find('JSFileNameID').get('v.value');
					var regEx= component.find('regExID').get('v.value');
                    
                    if(!searchComponentCustom.get('v.valueIsSet')) {
						this.showRequiredHighlight(component, true, 'objErrDivCustom' , 'objErrMsgDivCustom');
						isError=true;
					}
					else {
						this.showRequiredHighlight(component, false, 'objErrDivCustom' , 'objErrMsgDivCustom');
					}
					
					if(!ceActivityName) {
						this.showRequiredHighlight(component, true, 'errorDiv', 'error-message');
						isError = true;
					}
					else {
						this.showRequiredHighlight(component, false, 'errorDiv', 'error-message');
					}
					
					if(!jsFileName){
						this.showRequiredHighlight(component, true, 'errorDivJS', 'error-message-JS');
						isError = true;
					} 
					else {
						this.showRequiredHighlight(component, false, 'errorDivJS', 'error-message-JS');
					}
					
					if(!regEx){
						this.showRequiredHighlight(component, true, 'errorDivRegEx', 'error-message-regEx');
						isError = true;
					} 
					else {
						this.showRequiredHighlight(component, false, 'errorDivRegEx', 'error-message-regEx');
					}
					
					if(!isError){
						this.showSpinner(component, true);
						this.sendConfigSettingsEntryToServer(component,trackedEntity, evt);
					}
					else {
						this.hideVerifyTabAndClearTypeAhead( component, event, helper, false );
					}
					break;
					
				default:
					break;
			}
		//}
    },

    setCustomSettingFields : function(name, code1, code2, flag1, flag2, flag3, flag4, text1, text2, text3, text4, text5, text6, text7, text8, type) {
        
		var customSettingObj = {};
        if(name.length>38){
            //console.log('Name: '+name+' field becoming larger than 38 characters');
            return null;
        }

        customSettingObj.Name = name;
        customSettingObj.Code1__c = code1;
        customSettingObj.Code2__c = code2;

        customSettingObj.Flag1__c = flag1;
        customSettingObj.Flag2__c = flag2;
        customSettingObj.Flag3__c = flag3;
        customSettingObj.Flag4__c = flag4;
		
        customSettingObj.Text1__c = text1; // ? text1.replace( new RegExp( '_', 'g'), ' ' ) : text1;
        customSettingObj.Text2__c = text2; // ? text2.replace( new RegExp( '_', 'g'), ' ' ) : text2;
        customSettingObj.Text3__c = text3; // ? text3.replace( new RegExp( '_', 'g'), ' ' ) : text3;
        customSettingObj.Text4__c = text4;
        customSettingObj.Text5__c = text5;
        customSettingObj.Text6__c = text6;
        customSettingObj.Text7__c = text7;
        customSettingObj.Text8__c = text8;
        customSettingObj.Type__c = type;
         customSettingObj.IsActive__c = true;

        return customSettingObj;
    },

    sendConfigSettingsEntryToServer : function(component,selectedValue,evt) {
        
        var customSettingsListTobeInserted = [];
		var objConstant = this.getConstants(component);
		
        var customSettingName = component.find("customSettingNameID").get("v.value");
        var timeSheetEntryName = component.find("timesheetEntryNameID").get("v.value");
        var activityGroup = component.find("activityGroupTextID").get("v.value");
        
        var isBillable = component.find("IsBillable").get("v.checked");
        var isNonReportable = component.find("IsReportable").get("v.checked");
        var IsUtilized = component.find("IsUtilized").get("v.checked");
        var isStagingCreation = component.find("IsStaging").get("v.checked");
		
        switch(selectedValue) {
            //for manual type custom settings only one CS will be created
            case objConstant.LBL_MANUAL_ACTIVITY:
                var activityNameMA = component.find("activityNameIDMA").get("v.value");
                var permissionSetsText = component.find("permissionSetsTextID").get("v.value");
                var sObjectText = component.get("v.objectName");
                var objectRequired = component.find("isRequired").get("v.value");
                var isCommentRequired = component.find("isCommentRequired").get("v.value");
                var commentReqdText='';
                var jsonString = component.find('jsonText').get('v.value');
                var type = objConstant.VAL_MANUAL_ACTIVITY_LABEL;

                if(objectRequired) sObjectText = sObjectText + '*';
                if(isCommentRequired) commentReqdText = 'Comment Required';

                var manualConfigSettingDetails = this.setCustomSettingFields(
                    customSettingName, sObjectText, jsonString, isBillable, IsUtilized,
                    isNonReportable, isStagingCreation, activityNameMA, activityGroup, timeSheetEntryName,
                    permissionSetsText, null, commentReqdText, null, null, type);
                if(manualConfigSettingDetails) {
                    customSettingsListTobeInserted.push(manualConfigSettingDetails);
                }
                break;
				
				// for URL pattern 2 custom settings will be created
				// one custom settings is of type URL pattern and other is of type strategy
            case objConstant.LBL_URL_VF_PAGE:
                var activityNameVF = component.find("activityNameIDVF").get("v.value");
                var urlPatternText = component.find("urlPatternTextID").get("v.value");
                var objParamText = component.find("objParamTextID").get("v.value");
                var parentObjParamText = component.find("parentObjParamTextID").get("v.value");
				var settingName = '';
				if( customSettingName ) {
					settingName = customSettingName.toUpperCase();
					var urlConfigSettingDetails = this.setCustomSettingFields(
						objConstant.VAL_URL_PATTERN_NAME + objConstant.VAL_NAME_SEPARATOR + settingName, urlPatternText, null,
						isBillable, IsUtilized, isNonReportable, isStagingCreation,
						activityNameVF, objParamText, parentObjParamText, null, null, null, null, null, objConstant.VAL_URL_PATTERN_LABEL );
					var strategyConfigSettingDetails = this.setCustomSettingFields(
						objConstant.VAL_STRATEGY_NAME + objConstant.VAL_NAME_SEPARATOR + settingName, objConstant.VAL_GENERIC_EXCLUDE_IMPL, null,
						isBillable, IsUtilized, isNonReportable, isStagingCreation,
						activityNameVF, activityGroup, timeSheetEntryName, null, null, null, null, null, objConstant.VAL_STRATEGY_LABEL );
					if(urlConfigSettingDetails && strategyConfigSettingDetails) {
						customSettingsListTobeInserted.push(urlConfigSettingDetails);
						customSettingsListTobeInserted.push(strategyConfigSettingDetails);
					}
                }
				else {
					this.createToastComponent( component, 'error', 'Error!', 'Please fill Activity Name', null );
				}
                break;
				
            case objConstant.LBL_CUSTOM_EVENTS:

                //CE type fields
                var activityName = component.find("activityNameID").get("v.value");
                var regEx = component.find('regExID').get('v.value');
                var staticResName = component.find('staticResNameID').get('v.value');
                var JSFileName = component.find('JSFileNameID').get('v.value');
				
                //Object type fields
                var objectApiName = component.get("v.objectName");
                var objectDetails = component.get('v.objectDetails');
                var objectLabel = '', objectPluralLabel = '', objectPrefix = '';
                
                if( objectDetails ) {
                    objectLabel = objectDetails['ObjLable'];
                    objectPluralLabel = objectDetails['ObjPluralLabel'];
					objectPrefix = objectDetails['ObjPrefix'];
                }
                
                var urlParam=component.find('urlParamID').get('v.value');
                var stdObjectLookup = component.find('stdObjLookupID').get('v.value');
                var custObjectLookup = component.find('custObjLookupID').get('v.value');

                //Strategy type fields
                var excludeAct=component.find('excludeActID').get("v.value");
                var cancleActName=component.find('cancleActNameID').get("v.value");
                var cancleActCat=component.find('cancleActCatID').get("v.value");
                var strategyBaseName=component.find('activityNameID').get("v.value").toUpperCase().replace(/ /g,"_");

                var isArticleRelatedObject;
                if( objectApiName ) {
                    isArticleRelatedObject = (objectApiName.endsWith('__ka') || objectApiName.endsWith('__kav'));
                }
				var newStrategySetting, editStrategySettings, objectSettings;
				if( isArticleRelatedObject ) {
                    newStrategySetting = this.setCustomSettingFields
										 (
										  objConstant.VAL_STRATEGY_NAME + objConstant.VAL_NAME_SEPARATOR + objConstant.VAL_NEW_NAME + objConstant.VAL_NAME_SEPARATOR + customSettingName, 
										  objConstant.VAL_GENERIC_TT_IMPL, 
										  null,
										  isBillable, 
										  IsUtilized, 
										  isNonReportable, 
										  isStagingCreation,
										  objConstant.VAL_NEW_LABEL + objConstant.VAL_LABEL_SEPARATOR + objectLabel, 
										  activityGroup, 
										  'Article' + objConstant.VAL_LABEL_SEPARATOR + objConstant.VAL_CREATION, 
										  null,
										  null, 
										  null, 
										  cancleActName, 
										  cancleActCat, 
										  objConstant.VAL_STRATEGY_LABEL
										 );
										 
					editStrategySettings = this.setCustomSettingFields
										   (
											objConstant.VAL_STRATEGY_NAME + objConstant.VAL_NAME_SEPARATOR + objConstant.VAL_EDIT_NAME + objConstant.VAL_NAME_SEPARATOR + customSettingName, 
											objConstant.VAL_GENERIC_TT_IMPL, 
											null,
											isBillable, 
											IsUtilized, 
											isNonReportable, 
											isStagingCreation,
											objConstant.VAL_EDIT_LABEL + objConstant.VAL_LABEL_SEPARATOR + objectLabel, 
											activityGroup, 
											'Article' + objConstant.VAL_LABEL_SEPARATOR + objConstant.VAL_MAINTAINANCE, 
											null,
											null, 
											null, 
											cancleActName, 
											cancleActCat, 
											objConstant.VAL_STRATEGY_LABEL
										   );
										   
					objectSettings = this.setCustomSettingFields
									 (
									  objConstant.VAL_OBJECT_SETTINGS_NAME + objConstant.VAL_NAME_SEPARATOR + customSettingName, 
									  objectPrefix, 
									  null,
									  isBillable, 
									  IsUtilized, 
									  isNonReportable, 
									  isStagingCreation,
									  'KnowledgeArticle', 
									  'Id', 
									  null, 
									  stdObjectLookup, 
									  custObjectLookup,
									  null, 
									  null, 
									  null, 
									  objConstant.VAL_OBJECT_SETTINGS_LABEL
									 );
				}
				else {
					newStrategySetting = this.setCustomSettingFields
										 (
										  objConstant.VAL_STRATEGY_NAME + objConstant.VAL_NAME_SEPARATOR + objConstant.VAL_NEW_NAME + objConstant.VAL_NAME_SEPARATOR + customSettingName,
										  objConstant.VAL_GENERIC_TT_IMPL,
										  null,
										  isBillable, 
										  IsUtilized, 
										  isNonReportable, 
										  isStagingCreation,
										  objConstant.VAL_NEW_LABEL + objConstant.VAL_LABEL_SEPARATOR + objectLabel, 
										  activityGroup, 
										  activityName + objConstant.VAL_LABEL_SEPARATOR +objConstant.VAL_CREATION,
										  null,
										  null, 
										  null, 
										  cancleActName, 
										  cancleActCat, 
										  objConstant.VAL_STRATEGY_LABEL
										 );
										
					editStrategySettings = this.setCustomSettingFields
										   (
											objConstant.VAL_STRATEGY_NAME + objConstant.VAL_NAME_SEPARATOR + objConstant.VAL_EDIT_NAME + objConstant.VAL_NAME_SEPARATOR + customSettingName, 
											objConstant.VAL_GENERIC_TT_IMPL, 
											null,
											isBillable, 
											IsUtilized, 
											isNonReportable, 
											isStagingCreation,
											objConstant.VAL_EDIT_LABEL + objConstant.VAL_LABEL_SEPARATOR + objectLabel,  
											activityGroup, 
											activityName + objConstant.VAL_LABEL_SEPARATOR + objConstant.VAL_MAINTAINANCE, 
											null,
											null, 
											null, 
											cancleActName, 
											cancleActCat, 
											objConstant.VAL_STRATEGY_LABEL
										  );
								  
					objectSettings = this.setCustomSettingFields
									 (
									  objConstant.VAL_OBJECT_SETTINGS_NAME + objConstant.VAL_NAME_SEPARATOR + customSettingName, 
									  objectPrefix, 
									  null,
									  isBillable, 
									  IsUtilized, 
									  isNonReportable, 
									  isStagingCreation,
									  objectApiName, 
									  'Id', 
									  null, 
									  stdObjectLookup, 
									  custObjectLookup,
									  null, 
									  null, 
									  null, 
									  objConstant.VAL_OBJECT_SETTINGS_LABEL
									 );
				}
				
                var reviewStrategySettings = this.setCustomSettingFields
											 (
											  objConstant.VAL_STRATEGY_NAME + objConstant.VAL_NAME_SEPARATOR + customSettingName + objConstant.VAL_NAME_SEPARATOR + objConstant.VAL_REVIEW_NAME, 
											  objConstant.VAL_GENERIC_EXCLUDE_IMPL, 
											  null,
											  isBillable, 
											  IsUtilized, 
											  isNonReportable, 
											  isStagingCreation,
											  objectLabel + objConstant.VAL_LABEL_SEPARATOR + objConstant.VAL_REVIEW_LABEL, 
											  activityGroup, 
											  timeSheetEntryName, 
											  null,
											  excludeAct, 
											  null, 
											  null, 
											  null, 
											  objConstant.VAL_STRATEGY_LABEL
											 );
											 
                var listViewStrategySettings = this.setCustomSettingFields
											   (
												objConstant.VAL_STRATEGY_NAME + objConstant.VAL_NAME_SEPARATOR + customSettingName + objConstant.VAL_NAME_SEPARATOR + objConstant.VAL_LIST_VIEW_NAME, 
												objConstant.VAL_GENERIC_TT_IMPL, 
												null,
												isBillable, 
												IsUtilized, 
												isNonReportable, 
												isStagingCreation,
												objectPluralLabel + objConstant.VAL_LABEL_SEPARATOR + objConstant.VAL_LIST_VIEW_LABEL, 
												objConstant.VAL_NON_CASE_WORK, 
												activityName + objConstant.VAL_LABEL_SEPARATOR + objConstant.VAL_MONITORING,
												null, 
												null, 
												null, 
												null, 
												null,
												objConstant.VAL_STRATEGY_LABEL
											   );
											   
                var customEventSettings = this.setCustomSettingFields
										  (
										   objConstant.VAL_CUSTOM_EVENT_NAME + objConstant.VAL_NAME_SEPARATOR + customSettingName, 
										   regEx, 
										   null,
										   isBillable, 
										   IsUtilized, 
										   isNonReportable, 
										   isStagingCreation,
										   staticResName, 
										   JSFileName, 
										   null, 
										   null, 
										   null, 
										   null, 
										   null, 
										   null,
										   objConstant.VAL_CUSTOM_EVENT_LABEL
										  );


				customSettingsListTobeInserted.push(newStrategySetting);
				customSettingsListTobeInserted.push(editStrategySettings);
				customSettingsListTobeInserted.push(reviewStrategySettings);
                
                if( objConstant.Extension_Objects.indexOf( objectApiName ) < 0  ) {
					customSettingsListTobeInserted.push(customEventSettings);
                }
                
                customSettingsListTobeInserted.push(objectSettings);
				if(!isArticleRelatedObject) {
					customSettingsListTobeInserted.push(listViewStrategySettings);
				}
                break;
				
            default:
                console.log('Invalid value in dropdown: ',selectedValue);
        }
        
        console.log( 'customSettingsListTobeInserted', customSettingsListTobeInserted );
        if( customSettingsListTobeInserted && customSettingsListTobeInserted.length > 0 ) {
			if(evt) {
				this.firePassNewlyCreatedSettingsToConfigSettingProgressEvent(component, evt, customSettingsListTobeInserted);
			} 
			else {
				this.createTimeTrackerConfigSettings(component, customSettingsListTobeInserted);
			}
		}
    },

    firePassNewlyCreatedSettingsToConfigSettingProgressEvent: function(component, evt, csList) {
        
        evt.setParams({ "newlyCreatedList": csList, "showVerifySettingsTab" : true });
        evt.fire();
    },

    addNamespaceToSettings: function(component, configSettingList) {
        
		var settings = JSON.parse(component.get('v.settings'));
        var namespace = settings.Namespace;
        var configSettingListWithNamespace = [];
        
		if(!configSettingList|| configSettingList.length<1) return;
        configSettingList.forEach(function(el) {
            var configSettingWithNameSpace = {};
            for(key in el) {
                var newKey;
                (namespace && key.endsWith('__c'))? newKey = namespace+ '__' + key : newKey = key;
                configSettingWithNameSpace[newKey] = el[key]
            }
            configSettingListWithNamespace.push(configSettingWithNameSpace);
        });
        return configSettingListWithNamespace;
    },


    createTimeTrackerConfigSettings: function(component, configSettingList ){
        
        var consts = this.getConstants( component );
        console.log('ConfigSettingsNewEntryFormHelper.createTimeTrackerConfigSettings: entered');
        console.log('Before',configSettingList);
        var configSettingList = this.addNamespaceToSettings(component, configSettingList);
        console.log('After',configSettingList)
        
        var action = component.get('c.insertTimeTrackerConfigSettings');
        action.setParams({ 
            ttconfigSettingsList: JSON.stringify(configSettingList),
            'areIdsPresent' : false
        });
        action.setCallback(this, function(response) {
            
			//console.log('response', response);
            var state = response.getState();
            //console.log('state: ' + state);
            
			var res=response.getReturnValue();  //gets exception if any returned from server
            console.log('response', res);
			
            if (component.isValid() && state === "SUCCESS") {
                
                if(!res.startsWith("ERROR")) {
                    var isSaveAndNew = component.get("v.isSaveAndNew");
                    
                    var message = consts.LBL_SUCCESS_RECORD_SAVE;
                    if( configSettingList && configSettingList.length > 1 ) {
                        message = consts.LBL_SUCCESS_RECORDS_SAVE;
                    }
                    this.createToastComponent(component,'success','Success!',message, res);
                    var changeTabEvt = $A.get( "e.c:ChangeTabEvent");
                    changeTabEvt.setParam( 'tabId', 'tab1' );
                    changeTabEvt.fire();
                } else {
                    this.showSpinner(component, false);
                    this.createToastComponent(component,'error','EXCEPTION!', res, null );
                }
            } 
            else if (component.isValid() && state === "INCOMPLETE") {
                this.createToastComponent(component,'error','INCOMPLETE!','Record creation incomplete!');
            } 
            else if (component.isValid() && state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    (errors[0] && errors[0].message.length<200) ? 
                        this.createToastComponent(component,'error','Error!',errors[0].message)
                            : this.createToastComponent(component,'error','Error!','Error in saving record');
                } else {
                    //console.log("Unknown error");
                    this.createToastComponent(component,'error','Error!','Unknown error');
                }
            }
        });

        $A.enqueueAction(action);
    },

    setSelectedValue : function(component, selectedValue, helper){
        
        console.log( 'setSelectedValue-selectedValue', selectedValue );
        var trackedEntity=component.get('v.trackedEntity');        
        var consts = this.getConstants(component);
        if(!selectedValue) {
            component.set('v.containsValue', false);
            helper.populateTextWithValue(component, 'JSFileNameID', '');
            helper.populateTextWithValue(component, 'regExID', '');
            helper.clearAllTextFiledsOnForm(component);
        } 
        else {
            this.showRequiredHighlight(component, false, 'objErrDiv' , 'objErrMsgDiv');
            component.find('isRequired').set('v.disabled', false);
            component.set('v.containsValue', true);
            component.set("v.objectName", selectedValue);
            this.getObjectPrefixIDAndLable(component, selectedValue);
            
			component.set('v.isManualObjectSelected', true);
            
            if(trackedEntity === consts.LBL_CUSTOM_EVENTS) {
                this.showSpinner(component, true);
                window.setTimeout($A.getCallback(function() {
                    if(component.isValid()){
                        
                        console.log( 'before populateCustomObjectTrackingFields' );
                        helper.populateCustomObjectTrackingFields(component, selectedValue);
                        var jsFileName = selectedValue.replace( new RegExp( 'timetracker__', 'g'), '' );
                        jsFileName = jsFileName.replace( new RegExp( '__c', 'g'), '' );
                        jsFileName = jsFileName.replace( new RegExp( '_', 'g'), '' );
                        
                        helper.populateTextWithValue( component, 'JSFileNameID', '/' + 
                                      jsFileName.replace( new RegExp( ' ', 'g'), '' ) + '.js'
                                  );
                    }
                }),2000);
            }
        }
    },

    getObjectPrefixIDAndLable : function(component, selectedValue){
        
		var action=component.get('c.getObjectPrefixIDAndLable');
        action.setParams({
            objName : selectedValue,
            'fetchRelationDetails' : true
        });
		
        action.setCallback(this, function (response){
            var state= response.getState();
            
			if(state === 'SUCCESS' && component.isValid()){
                var objectDetails = response.getReturnValue();
                console.log( 'getObjectPrefixIDAndLable-reponse', objectDetails );
                component.set("v.objectDetails", objectDetails);
            } 
			else if (component.isValid() && state === "INCOMPLETE") {
                component.set('v.errorMsg', 'Error: Incomplete');
                this.showElement(component, 'errorMsgID');
            } 
			else if (component.isValid() && state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set('v.errorMsg',  errors[0].message);
                        this.showElement(component, 'errorMsgID');
                    }
                } 
				else {
                    component.set('v.errorMsg', 'Unknown error');
                    this.showElement(component, 'errorMsgID');
                }
            }
        });
        $A.enqueueAction(action);
    },

    closeModal : function(component){
        
		var closeModalevent=$A.get("e.c:closeModalEvent");
        closeModalevent.fire();
    },

    createToastComponent : function(component,type, title, message, updatedSettings){
        
		//console.log('updatedSettings', updatedSettings);
        var settings = component.get('v.settings');
        var afterSaveRefresh=$A.get("e.c:afterSaveRefresh");
        
        if( updatedSettings ) {
            updatedSettings = JSON.parse( updatedSettings );
        }
        afterSaveRefresh.setParams({
            toastMSG: message,
            toastTitle: title,
            toastType: type,
            updatedSettings: updatedSettings
        });
        afterSaveRefresh.fire();
    },

    showElement : function(component, id){
        
		var divElement=component.find(id);
        if(divElement) {
            $A.util.removeClass(divElement, 'slds-hide');
            $A.util.addClass(divElement, 'slds-show');
        }
    },

    hideElement : function(component, id){
        
		var divElement=component.find(id);
        if(divElement) {
            $A.util.removeClass(divElement, 'slds-show');
            $A.util.addClass(divElement, 'slds-hide');
        }
    },

    showSpinner: function(component, isVisible) {
        
		//console.log('In show spinner');
        var spinner = component.find("spinnerDiv");
        if(isVisible){
            this.showElement(component, spinner);
        }
        else{
            this.hideElement(component, spinner);
        }
        //spinner.showSpinner(isVisible);
    },

    addDelay : function(component){
        
		//console.log('Inside addDelay');
        window.setTimeout(
            $A.getCallback(function() {
                if(component.isValid()) {
                    //var spinner = component.find("spinnerDiv");
                    //spinner.showSpinner(false);
                    var saveClickEvent = $A.get('e.c:saveClickEvent');
                    saveClickEvent.fire();
                } else {
                    //console.log('Component is Invalid');
                }
            }), 2000
        );
    },

    showRequiredHighlight : function(component, isTrue, divElement, divErrElement) {
        
		var errorDiv = component.find(divElement);
        if(isTrue) {
            $A.util.addClass(errorDiv, 'slds-has-error');
            this.showElement(component, divErrElement);
        } else {
            $A.util.removeClass(errorDiv, 'slds-has-error');
            this.hideElement(component, divErrElement);
        }
    },

    toggleElement : function(component, menuDiv) {
        
		var divElement=component.find(menuDiv);
        $A.util.toggleClass(divElement, 'slds-hide');
    },
    
    cancel : function( component, event, helper, clearTypeAheadText ) {
		
		this.hideVerifyTabAndClearTypeAhead( component, event, helper, clearTypeAheadText );
		var trackedEntity = component.get( 'v.trackedEntity' );
        var componentIdToValue = helper.getComponentIdToValue( component, trackedEntity, clearTypeAheadText );   
        
		if( componentIdToValue ) {
			
			componentIdToValue.map( function( objElement ) { 
				component.find( objElement.id ).set( objElement.valueProviderType, objElement.value );
			});
		}
	},
	
    hideVerifyTabAndClearTypeAhead : function( component, event, helper, clearTypeAheadText ) {
        
        var resetNewEntryFormEvent = $A.get( "e.c:ResetNewEntryFormEvent");
		resetNewEntryFormEvent.setParam( 'clearTypeAheadText', clearTypeAheadText );
        resetNewEntryFormEvent.fire();
        //console.log( 'Reset New Entry Form Event being fired', resetNewEntryFormEvent );
    },
    
	getComponentIdToValue : function( component, trackedEntity, clearTypeAheadText ) {
		
		var consts = this.getConstants(component)
		if( trackedEntity ) {
			
			var componentIdToValue = [];
            if( clearTypeAheadText || trackedEntity !== consts.LBL_MANUAL_ACTIVITY ) {
                componentIdToValue = [
                    					{ id: 'timesheetEntryNameID', valueProviderType : 'v.value', value: '' },
                                        { id: 'activityGroupTextID', valueProviderType : 'v.value', value: '' },
                                        { id: 'IsBillable', valueProviderType : 'v.checked', value: false },
                                        { id: 'IsUtilized', valueProviderType : 'v.checked', value: false },
                                        { id: 'IsReportable', valueProviderType : 'v.checked', value: false },
                                        { id: 'IsStaging', valueProviderType : 'v.checked', value: false }
                                     ];
      		}
                    
			switch( trackedEntity ) {
                
				case consts.LBL_URL_VF_PAGE:
					componentIdToValue.push( { id: 'VFPageID', valueProviderType : 'v.value', value: '' } );
					componentIdToValue.push( { id: 'activityNameIDVF', valueProviderType : 'v.value', value: '' } );
					componentIdToValue.push( { id: 'urlPatternTextID', valueProviderType : 'v.value', value: '' } );
					componentIdToValue.push( { id: 'objParamTextID', valueProviderType : 'v.value', value: '' } );
					componentIdToValue.push( { id: 'parentObjParamTextID', valueProviderType : 'v.value', value: '' } );
					break;
                
                case consts.LBL_MANUAL_ACTIVITY:
                    componentIdToValue.push( { id: 'sobjectFieldId', valueProviderType : 'v.options', value: [] } );
                    component.set('v.isManualObjectSelected', false);
                    //component.find('sobjectFieldId').set('v.options', '');
                    componentIdToValue.push( { id: 'jsonText', valueProviderType : 'v.value', value: '' } );
                    if(clearTypeAheadText) {
                        componentIdToValue.push( { id: 'customSettingNameID', valueProviderType : 'v.value', value: '' } );
                        componentIdToValue.push( { id: 'activityNameIDMA', valueProviderType : 'v.value', value: '' } );
                        componentIdToValue.push( { id: 'permissionSetsTextID', valueProviderType : 'v.value', value: '' } );
                        componentIdToValue.push( { id: 'timesheetEntryNameID', valueProviderType : 'v.value', value: '' } );
                        componentIdToValue.push( { id: 'activityGroupTextID', valueProviderType : 'v.value', value: '' } );
                        componentIdToValue.push( { id: 'isCommentRequired', valueProviderType : 'v.value', value: false } );
                        componentIdToValue.push( { id: 'isRequired', valueProviderType : 'v.value', value: false } );
                    }
                	break;
					
				case consts.LBL_CUSTOM_EVENTS:
					componentIdToValue.push( { id: 'customSettingNameID', valueProviderType : 'v.value', value: '' } );
					componentIdToValue.push( { id: 'JSFileNameID', valueProviderType : 'v.value', value: '' } );
					componentIdToValue.push( { id: 'activityNameID', valueProviderType : 'v.value', value: '' } );
					componentIdToValue.push( { id: 'regExID', valueProviderType : 'v.value', value: '' } );
					componentIdToValue.push( { id: 'stdObjLookupID', valueProviderType : 'v.value', value: '' } );
					componentIdToValue.push( { id: 'custObjLookupID', valueProviderType : 'v.value', value: '' } );
					componentIdToValue.push( { id: 'urlParamID', valueProviderType : 'v.value', value: '' } );
					componentIdToValue.push( { id: 'excludeActID', valueProviderType : 'v.value', value: '' } );
					componentIdToValue.push( { id: 'cancleActNameID', valueProviderType : 'v.value', value: '' } );
					componentIdToValue.push( { id: 'cancleActCatID', valueProviderType : 'v.value', value: '' } );
					break;
					
				default:
					break;
			}
			
			//console.log( 'getComponentIdToValue-componentIdToValue', componentIdToValue );
			return componentIdToValue;
		}
		return null;
	},
                
    getConstants: function( component ) {
		
		var consts = {
						// LABELS FOR ERROR MESSAGES
						'ERR_FIELD_REQUIRED' : 'This field is required',
						'ERR_FIELD_TOO_LONG' : 'This field is too long',
						'ERR_SETTING_NAME_ALREADY_USED' : 'This setting name is already used. Please try other',
						
						'LBL_ACTIVITY_NAME_IN_SETTINGS' :  'Activity Name as appear in Custom Setting',
						'LBL_ACTIVITY_NAME' :  'Activity Name',
						'LBL_OBJECT_NAME' : 'Object Name',
						'LBL_MAKE_COMMENT_MANDATORY' : 'Make Comment Mandatory',
						'LBL_SOBJECT_FIELD' : 'SObject Field',
						'LBL_MAKE_OBJECT_MANDATORY' : 'Make Object Mandatory',
						'LBL_SOBJECT_SETTINGS' : 'Settings for Object Field',
						'LBL_PERMISSION_SET':'Permission Set',
						
						// LABELS FOR VALUES OF CUSTOM SETTINGS WHEN AUTOPOPULATED
						'TT_PERMISSION_SET':'Time Tracker Permission Set',
						'TT_ADMIN_PERMISSION_SET':'Time Tracker Admin Permission Set',
						'OBJECTS':'Objects',
						'VAL_STRATEGY_NAME' : 'Strategy',
						'VAL_OBJECT_SETTINGS_NAME' : 'Object_Settings',
						'VAL_CUSTOM_EVENT_NAME' : 'CustomEvent',
						'VAL_URL_PATTERN_NAME' : 'URLPattern',
						
						'VAL_NEW_NAME' : 'NEW',
						'VAL_EDIT_NAME' : 'EDIT',
						'VAL_REVIEW_NAME' : 'REVIEW',
						'VAL_LIST_VIEW_NAME' : 'LIST_VIEW',
						'VAL_NAME_SEPARATOR' : '_',
						
						'VAL_NEW_LABEL' : 'New',
						'VAL_EDIT_LABEL' : 'Edit',
						'VAL_REVIEW_LABEL' : 'Review',
						'VAL_LIST_VIEW_LABEL' : 'List View',
						'VAL_WORK_LABEL' : 'Work',
						'VAL_CANCEL_LABEL' : 'Cancel',
						'VAL_CANCELLATION_LABEL' : 'Cancellation',
						'VAL_LABEL_SEPARATOR' : ' ',
						
						'VAL_GENERIC_TT_IMPL' : 'GenericTimeTrackerImpl',
						'VAL_GENERIC_EXCLUDE_IMPL' : 'GenericExcludeImpl',
						'VAL_MONITORING' : 'Monitoring',
						'VAL_CREATION' : 'Creation',
						'VAL_MAINTAINANCE' : 'Maintenance',
						'VAL_NON_CASE_WORK' : 'Non-Case Work',
                		
                		'Extension_Objects' : [ 'Case','Account','Campaign','Contact','Contract',
                						        'Event','Lead','Opportunity','Order','Task','Solution'
            								  ],
            			'LBL_SUCCESS_RECORD_SAVE': 'Record Saved Successfully!',
						'LBL_SUCCESS_RECORDS_SAVE': 'Records Saved Successfully!'
					 };
		
		if( component.get( 'v.namespace' ) ) {
		
			consts['LBL_SELECT'] = $A.get("$Label.timetracker.LBL_Select_DropDown");
			consts['LBL_URL_VF_PAGE'] = $A.get("$Label.timetracker.LBL_URL_VF_Page");
			consts['LBL_CUSTOM_EVENTS'] = $A.get("$Label.timetracker.LBL_Custom_Events");
			consts['LBL_MANUAL_ACTIVITY'] = $A.get("$Label.timetracker.LBL_Manual_Activity");
			consts['VAL_STRATEGY_LABEL' ] = $A.get( "$Label.timetracker.LBL_ConfigSetting_Strategy" );
			consts['VAL_OBJECT_SETTINGS_LABEL' ] = $A.get( "$Label.timetracker.LBL_ConfigSetting_Object" );
			consts['VAL_CUSTOM_EVENT_LABEL' ] = $A.get( "$Label.timetracker.LBL_ConfigSetting_Custom_Event" );
			consts['VAL_URL_PATTERN_LABEL' ] = $A.get( "$Label.timetracker.LBL_ConfigSetting_URLPattern" );
			consts['VAL_MANUAL_ACTIVITY_LABEL' ] = $A.get( "$Label.timetracker.LBL_ConfigSetting_Manual" );
		} 
		else {
			consts['LBL_SELECT'] = $A.get("$Label.c.LBL_Select_DropDown");
			consts['LBL_URL_VF_PAGE'] = $A.get("$Label.c.LBL_URL_VF_Page");
			consts['LBL_CUSTOM_EVENTS'] = $A.get("$Label.c.LBL_Custom_Events");
			consts['LBL_MANUAL_ACTIVITY'] = $A.get("$Label.c.LBL_Manual_Activity");
			consts['VAL_STRATEGY_LABEL' ] = $A.get( "$Label.c.LBL_ConfigSetting_Strategy" );
			consts['VAL_OBJECT_SETTINGS_LABEL' ] = $A.get( "$Label.c.LBL_ConfigSetting_Object" );
			consts['VAL_CUSTOM_EVENT_LABEL' ] = $A.get( "$Label.c.LBL_ConfigSetting_Custom_Event" );
			consts['VAL_URL_PATTERN_LABEL' ] = $A.get( "$Label.c.LBL_ConfigSetting_URLPattern" );
			consts['VAL_MANUAL_ACTIVITY_LABEL' ] = $A.get( "$Label.c.LBL_ConfigSetting_Manual" );
		}
        return consts;
	}
})