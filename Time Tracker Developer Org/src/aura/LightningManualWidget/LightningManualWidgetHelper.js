({      
    start : function( component, event, helper ) {  
        component.set("v.isStopDisabled", false);
        component.set("v.isTimerDisabled", true);
        component.set("v.isSubmitDisabled", true);
        var button = event.getSource();
        if(button.get("v.iconName") == "utility:right") {
            var activeTime = [];
            helper.timer( component, event, helper );
            var timerId = setInterval( function() {
                helper.timer( component, event, helper );
            }, 1000 );      
            component.set( 'v.timerId', timerId );
            activeTime = component.get( 'v.activeTimeStamps');
            activeTime.push(new Date().getTime());
            component.set( 'v.activeTimeStamps', activeTime);
            var currentDate = new Date();
            component.set("v.activityDate", currentDate.toISOString());
        } else {
            var inactiveTime = [];
            clearInterval( component.get( 'v.timerId' ) );
            inactiveTime = component.get( 'v.inactiveTimeStamps');
            inactiveTime.push(new Date().getTime());
            component.set( 'v.inactiveTimeStamps', inactiveTime);
            this.calculateDuration(component);
        }
        component.set("v.icon",
                      component.get("v.icon")=="utility:right"?
                      "utility:pause":"utility:right");
	},
   
    stop : function( component, event, helper ) { 
        var inactiveTime = [];
    	var labelClass = component.find( 'timer' );       
        component.set("v.icon", "utility:right");
        labelClass.set( 'v.labelClass', 0);
        component.set("v.isStopDisabled", true);
        component.set("v.isTimerDisabled", false);
        component.set("v.isBtnDisabled", false);
        component.set("v.isSubmitDisabled", false);
        clearInterval( component.get( 'v.timerId' ) );   
        inactiveTime = component.get( 'v.inactiveTimeStamps');
        inactiveTime.push(new Date().getTime());
        component.set( 'v.inactiveTimeStamps', inactiveTime);
        this.calculateDuration(component);
    },
   
	timer : function( component, event, helper ) {      
    	var labelClassValue = component.find( 'timer' ).get( 'v.labelClass' );        
        var count = parseInt( labelClassValue );      
        var timeValue = helper.toHHMMSS( component, event, helper , count );
        component.set( 'v.trackedTime', timeValue );
        count += 1;
        component.find( 'timer' ).set( 'v.labelClass', count );
	},
   
    toHHMMSS : function( component, event, helper, count ) {     
    	var sec_num = parseInt( count, 10 );        
        var hours = Math.floor( sec_num / 3600 );
        var minutes = Math.floor( ( sec_num - ( hours * 3600 ) ) / 60 );
        var seconds = sec_num - ( hours * 3600 ) - ( minutes * 60 );
        if (hours < 10) {
            hours = "0" + hours;
        }
        if (minutes < 10) {
            minutes = "0" + minutes;
        }
        if (seconds < 10) {
            seconds = "0" + seconds;
        }
        return hours + ':' + minutes + ':' + seconds;
	},
    
    calculateDuration: function(component) {
        var duration = 0;
        var manualEngageTime = component.get("v.activeTimeStamps");
        var manualDisengageTime = component.get("v.inactiveTimeStamps");
        console.log('manualEngageTime>> ',manualEngageTime);
        console.log('manualDisengageTime>> ',manualDisengageTime);
        if (manualEngageTime.length != manualDisengageTime.length){
        	component.set("v.trackedDuration",  duration); 
        } 
        // If the manualEngageTime and manualDisEngageTime arrays have length
        // Loop thru the activeTimestamps and inActiveTumestamps to calculate the duration.
        manualEngageTime.map(function(startTime, i) {
            var endTime = manualDisengageTime[i];
            duration += (endTime - startTime);
            component.set("v.trackedDuration",  duration); 
        });
        component.set("v.trackedDuration",  Math.floor(duration * 0.001)); 
    },
    
	getActivityList : function(component) {       
		var action = component.get("c.getActivityList");
        var dummyStr= '';
        action.setParams({
            dummy : dummyStr   
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS'){
                var retResponse = response.getReturnValue();
                retResponse = JSON.parse(retResponse);
                if(!retResponse.system_error_type) {
                    var activityLst = [];
                    activityLst.push( { label: '--Select--', value:'select', selected : true } );
                    var responseArray = retResponse.split(',');
                    for(var i=0; i<responseArray.length; i++){
                        activityLst.push({ label: responseArray[i], value:responseArray[i] });
                    }
                    var activityListElement = component.find( 'activityLst' );
                    activityListElement.set( 'v.options', activityLst );
                  
                }else {
                	this.showMessage(component, true, retResponse.system_error_message);
                }
            }
            else {
                this.showMessage(component, true, $A.get(label) + ": " + state);
            }          
        });
        $A.enqueueAction(action); 
	},
	
    getSObjectDetailsFromCS : function(component) {    
        component.set("v.searchInput", null);
        component.set("v.comment", null);
		var action = component.get("c.getSObjectDetailsFromMCS");
        action.setParams({
            selectedActivity : component.get("v.selectedValue")  
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS'){
                var retResponse = response.getReturnValue();
                retResponse = JSON.parse(retResponse); 
                component.set("v.showFields", retResponse.showFields);
                component.set("v.sObjectApiName", retResponse.sObjectApiName);
                component.set("v.sObjectLabel", retResponse.sObjectLabel);
                component.set("v.commentLabel", 'Comment');   
                component.set("v.isSobjectRequired", retResponse.isSobjectRequired);    
                component.set("v.isCommentRequired", retResponse.isCommentRequired);                 
                component.set("v.searchField", retResponse.sObjectSearchField);
                component.set("v.isSobjectDisabled", false);   
            	component.find("activityLst").set("v.errors", null);
            }        
        });
        $A.enqueueAction(action); 
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
    
	getSobjectRecords:function(component) { 
        var showFlds = component.get("v.showFields");
        var searchField = component.get("v.searchField");
        
		var action = component.get("c.getSObjectRecords");       
		action.setParams({
            searchKeyword : component.get("v.searchInput"),
            sObjectApiName : component.get( "v.sObjectApiName" ),
            sObjectSearchField : searchField,
            showFlds : showFlds                           
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS'){
                var retResponse = response.getReturnValue();
                retResponse = JSON.parse(retResponse);  
                if(retResponse != null){
                	var recordList = [];    
                    component.set("v.showSobjectRecordList", true);
                    component.set("v.searchedRecordList", retResponse);
                    retResponse.forEach(function(record) {
                        var showFldsString = '';
                        showFlds.forEach(function(field){
                            showFldsString += record[field] +' ';              			
                        });
                        recordList.push(showFldsString.trim()); 
                    });	
                    component.set("v.sObjectRecordList", recordList); 							           
                }  
                else{
                	component.set("v.showSobjectRecordList", false); 
                }                    
            }
            else {
                this.showMessage(component, true, $A.get(label) + ": " + state);
            }          
        });
        $A.enqueueAction(action); 
	},
	    
    clearSearchtext :function(component, event, helper) {
        component.set("v.searchInput", '');
        helper.hideElement(component, 'iterationID');
        var lookupMenu = component.find("lookupMenu");
        $A.util.addClass(lookupMenu, "slds-hide");
        $A.util.removeClass(lookupMenu, "slds-lookup__menu");
    },
    
    getFocusedTabName : function(component, event, helper) {      
        var currentTabJSON = component.get( "v.currentTabJSON" );
        if( currentTabJSON ) {
            var currentTabRecord = JSON.parse( currentTabJSON );
            if( currentTabRecord ) {
                if( currentTabRecord.iconAlt == component.get( "v.sObjectApiName" ) ) {
                    return currentTabRecord.recordId;
                }
            }
        }
        return null;
    } ,
    
    getFocusedTabRecord :function(component, event, helper, recordId) { 
		var action = component.get("c.getSobjectSearchFldValue");
		action.setParams({
            sObjectApiName : component.get("v.sObjectApiName") ,
            searchField : component.get("v.searchField"),
            sObjectRecordId : recordId
        });
        action.setCallback(this,function(response){            
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS'){
                var retResponse = response.getReturnValue();
                retResponse = JSON.parse(retResponse);  
                if(retResponse != null){	  
                	component.set("v.searchInput", retResponse);         
                }                     
            }                     
        });
        $A.enqueueAction(action); 
	},    
        
    validateAllFields : function(component, event, helper) {
        component.set("v.isValid", true);
        var actDateFld = component.find("actDate");
        var actDateValue = actDateFld.get("v.value");
        if(!actDateValue && actDateValue.length == 0) {
            component.set("v.isValid", false);
            actDateFld.set("v.errors", [{message:"Please enter activity date"}]);
        }else{
            const activityTimestamp = Date.parse(actDateValue);
    		if (isNaN(activityTimestamp)) {
                component.set("v.isValid", false);
            	actDateFld.set("v.errors", [{message:"Please enter valid activity date"}]);
            }
            if(actDateValue){
                actDateFld.set("v.errors", null);
            }          
        }
   		
        var timeRegex = new RegExp("([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]");
        var timerFld = component.find("timer");
        var timer = timerFld.get("v.value");
        console.log('activityLstValue> ', timer);
        if (!timer || timer.indexOf('00:00:00') > -1 || timer.length != 8 || !timeRegex.test(timer)) {
            component.set("v.isValid", false);
            timerFld.set("v.errors", [{message:"Invalid duration"}]);
        }else{
            timerFld.set("v.errors", null);
        }
        
        var activityLst = component.find("activityLst");
        var activityLstValue = activityLst.get("v.value");
        console.log('activityLstValue> ', activityLstValue);
        if(!activityLstValue || activityLstValue == 'select') {
            component.set("v.isValid", false);
            activityLst.set("v.errors", [{message:"Please select activity"}]);
        }
        else{
            activityLst.set("v.errors", null);
        }
        
        var sobjectFld = component.find("searchInput");
        var sobjectFldValue = sobjectFld.get("v.value");
        console.log('value> '+sobjectFldValue);
        if(!sobjectFldValue && component.get("v.isSobjectRequired")) {
            component.set("v.isValid", false);
            sobjectFld.set("v.errors", [{message:"Please enter sObject value"}]);
        }
        else{
            sobjectFld.set("v.errors", null);
        }
        
        var commentField = component.find("commentFld");
	    var commentvalue = commentField.get("v.value");	    
        if(commentvalue && commentvalue.length > 255) {
            component.set("v.isValid", false);
            commentField.set("v.errors", [{message:"Comment is too long"}]);
	    }
        else if(!commentvalue && component.get("v.isCommentRequired")){
            component.set("v.isValid", false);
        	commentField.set("v.errors", [{message:"Please enter comment"}]);  
        }
        else{
        	commentField.set("v.errors", null);  
        }        
    },
    
    buildManualLineItems : function(component, event, helper){       
		var manualLineItems = [];
        var manualEngageTime = component.get("v.activeTimeStamps");
        var manualDisengageTime = component.get("v.inactiveTimeStamps");
        if (manualEngageTime.length == 0 || manualDisengageTime.length == 0 || manualEngageTime.length != manualDisengageTime.length){
        	return manualLineItems;
        }           
        for (let i = 0; i < manualEngageTime.length; i++) {
            manualLineItems.push({ "Engage_Time__c": manualEngageTime[i], "Disengage_Time__c": manualDisengageTime[i] });
        }
        return manualLineItems;
    },
    
    pushManualLineItems : function(component, event, helper){       
		var manualLineItems = [];		
        manualLineItems = this.buildManualLineItems(component, event, helper);
		if(manualLineItems.length == 0) {
            console.log('Pushed Manual Line Items');
            return;
        }
        var action = component.get("c.saveManualLineItems");
        action.setParams({
        	data : JSON.stringify(manualLineItems)
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS'){
                var retResponse = response.getReturnValue();
                if(retResponse != null){
                    console.log('Pushed Manual Line Items', manualLineItems);
                    component.set( 'v.activeTimeStamps', []);
                    component.set( 'v.inactiveTimeStamps', []);
                }
                else{
                    console.log('Manual Line Items are not pushed');
                }
            }
		 });
        $A.enqueueAction(action); 
    },
 
    pushTimesheetEntry :function(component, event, helper) {
        var currentDate = new Date();
        currentDate.setHours(0,0,0,0);
        var date = new Date(component.get("v.activityDate"));
        var hours = date.getHours() > 12 ? date.getHours() - 12 : date.getHours();
        var am_pm = date.getHours() >= 12 ? "PM" : "AM";
        hours = hours < 10 ? "0" + hours : hours;
        var minutes = date.getMinutes() < 10 ? "0" + date.getMinutes() : date.getMinutes();
        var timeStr = hours + ":" + minutes + " " + am_pm;
        var d = date.getDate() < 10 ? "0" + date.getDate() : date.getDate();
        var m = date.getMonth() + 1;
        m = m < 10 ? "0" + m : m;
        var dateStr = m +'/'+ d +'/'+ date.getFullYear();
    	var dateTimeStr = dateStr+' '+timeStr;
    
        var records = component.get("v.searchedRecordList");
        var searchFLd = component.get("v.searchField"); 
        var selectedRecordValue = component.get("v.searchInput");
        var sobjectid;
        records.forEach(function(record) {
            console.log(record['Id'],'pushTimesheetEntry',record[searchFLd],'>>',component.get("v.searchInput"));
            if( selectedRecordValue == record[searchFLd] || selectedRecordValue.includes(record[searchFLd]) ){
            	sobjectid = record['Id'];   
            }
        });	
    	var action = component.get("c.createTimesheetEntry");
        action.setParams({
            timer :           component.get("v.trackedTime"),
            hiddenTimer :     component.get("v.trackedDuration"),
            activityDateStr : dateTimeStr,
            activity :        component.get("v.selectedValue"),
            sObjetId :        sobjectid,
            sObjectValue :    component.get("v.searchInput"),
            comment :         component.get("v.comment")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS'){
                var retResponse = response.getReturnValue();
                console.log('retResponse>>', retResponse);
                if(!retResponse.system_error_type) {
                    if(retResponse != null){
                        if(retResponse == 'true'){
                            component.set("v.trackedTime", '00:00:00');
                            component.set("v.trackedDuration", '0');
                            component.set("v.activityDate", currentDate.toISOString());
							component.find("activityLst").set('v.value', 'select');
                            component.set("v.searchInput", '');
                            component.set("v.comment", '');
                            component.set("v.isSobjectDisabled", true);
                            $A.util.addClass(component.find("clearbtn"), "slds-hide");
                            console.log('Pushed Timesheet Entry');  
                        	this.pushManualLineItems(component, event, helper);
                            this.showToast(component, event, helper);
                        }
                        else if (retResponse == 'Locked') {
                        	console.log('Timesheet is Locked');  
							var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error!",
                                "type": "error",
                                "message": "Timesheet is Locked."
                            });
                            toastEvent.fire();
                        } else if (retResponse == 'Value Not Found') {
                            console.log('Timesheet Entry Value Not Found'); 
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error!",
                                "type": "error",
                                "message": "Timesheet Entry Value Not Found."
                            });
                            toastEvent.fire();
                        }                       
                    }
                    else if(retResponse == null || retResponse == 'false'){
                    	console.log('SESSION EXPIRED: Pushing to Queue');
                    }        
                }
                else {
                	this.showMessage(component, true, retResponse.system_error_message);
                }
            }
            else {
                this.showMessage(component, true, $A.get(label) + ": " + state);
            }          
        });
        $A.enqueueAction(action); 
    },
    
    showToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "type": "success",
            "message": "Time Tracker record saved."
        });
        toastEvent.fire();
	}
})