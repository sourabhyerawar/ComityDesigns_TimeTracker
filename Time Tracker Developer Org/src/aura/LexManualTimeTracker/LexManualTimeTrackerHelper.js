/*
  	@ PURPOSE : PROVIDES SERVICE TO THE LIGHTNING COMPONENT CONTROLLER --> LexManualTimeTrackerController
	@ NAME 	  : LexManualTimeTrackerHelper.js
*/
({	
    /******************************* ACTIONS INVOKED BY CONTROLLER *******************************/
    
    /*
    	@ PURPOSE : 1. INITIALIZES ALL UNDEFINED ATTRIBUTES OF A COMPONENT WITH DEFAULT VALUES.
					2. INVOKES METHODS TO FETCH OBJECT DETAILS AND CUSTOM SETTINGS FROM SERVER.
    */
    initializeFooterComponent : function( component, event, helper ) {
		
		helper.resetConsoleState( component, helper );
		helper.fetchManualTimeTrackerCmpWrapper( component, event, helper );
	},
    
    /*
		@ PURPOSE : POPULATES OBJECT LABEL AND MAKES OBJECT AND COMMENT SECTIONS MANDATORY BASED ON ACTIVITY SELECTED. 
	*/
	refreshSObjectDetails : function( component, event, helper ) {
        
		var consoleState = JSON.parse( JSON.stringify( component.get( "v.consoleState" ) ) );
		if( consoleState && consoleState.toggleStatus && consoleState.typeAheadStatus ) {
            helper.validateActivityType( component, helper, consoleState, true );
            
			if( consoleState.timeTracker && consoleState.timeTracker.activityName &&
				consoleState.listOfManualActivityWrappers && consoleState.listOfManualActivityWrappers.length > 0
			) {
				var matchedActivityWrapper = helper.getRecordFromList
													( component, helper, consoleState.listOfManualActivityWrappers,
													  "manualActivityType", consoleState.timeTracker.activityName, false
													);
				if( matchedActivityWrapper ) {
					
					consoleState.typeAheadStatus.sObjectApiName = matchedActivityWrapper.sObjectApiName;
					consoleState.typeAheadStatus.sObjectLabel = matchedActivityWrapper.sObjectLabel;
					consoleState.typeAheadStatus.sObjectKeyPrefix = matchedActivityWrapper.sObjectKeyPrefix;
					consoleState.typeAheadStatus.sObjectSearchField = matchedActivityWrapper.sObjectSearchField;
					consoleState.typeAheadStatus.listOfShowFields = matchedActivityWrapper.listOfShowFields;
					
					consoleState.toggleStatus.isSobjectRequired = matchedActivityWrapper.isSobjectRequired;
					consoleState.toggleStatus.isCommentRequired = matchedActivityWrapper.isCommentRequired;
					consoleState.toggleStatus.isSobjectDisabled = false;
				}
			}
			else {
				consoleState.typeAheadStatus.sObjectApiName = "";
				consoleState.typeAheadStatus.sObjectLabel = "Case";
				consoleState.typeAheadStatus.sObjectKeyPrefix = ""
				consoleState.typeAheadStatus.sObjectSearchField = "";
				consoleState.typeAheadStatus.listOfShowFields = [];
				consoleState.toggleStatus.isSobjectDisabled = true;
				consoleState.toggleStatus.isSobjectRequired = false;
				consoleState.toggleStatus.isCommentRequired = false;
			}
			
			consoleState.typeAheadStatus.searchInput = "";
			consoleState.timeTracker.objectId = null;
			consoleState.listOfSobjectRecords = [];
			
			consoleState.toggleStatus.isSubmitDisabled = !helper.validateForm( component, helper, consoleState, false );
			component.set( "v.consoleState", consoleState );
		}
	},
    
    /*
		@ PURPOSE : 1. STARTS/PAUSES THE TIMER BASED ON ICON NAME OF THE BUTTON. 
					2. INCREMENTS THE TIME BY ONE SECOND WHEN TIMER IS RUNNING.
					3. IF STARTED THEN PUSHES CURRENT TIME STAMP TO ACTIVETIMESTAMPS ARRAY AND OTHERWISE, INACTIVETIMESTAMPS ARRAY.
	*/
	start : function( component, event, helper ) {  
        
		var consoleState = JSON.parse( JSON.stringify( component.get( "v.consoleState" ) ) );
		if( consoleState && consoleState.toggleStatus &&
			consoleState.labelStatus && consoleState.timeTracker
		) {
			var constants = JSON.parse( JSON.stringify( component.get( "v.constants" ) ) );
			if( constants ) {
				consoleState.toggleStatus.isStopDisabled = false;
				consoleState.toggleStatus.isTimerDisabled = true;
				consoleState.toggleStatus.isSubmitDisabled = true;
				
				if( consoleState.labelStatus.startIcon == "utility:right" ) {
					
					consoleState.labelStatus.startIcon = "utility:pause";
					consoleState.labelStatus.playPauseBtnText = constants.LBL_TT_Widget_Pause;
					consoleState.timeTracker.activeTimeStamps.push( new Date().getTime() );
					component.set( "v.consoleState", consoleState );
					
					// Keeps the timer updating on UI
					helper.timer( component, helper );
					consoleState = JSON.parse( JSON.stringify( component.get( "v.consoleState" ) ) );
					component.find( "timerId" ).set( "v.errors", [] );
					consoleState.timeTracker.timerId = setInterval( function() {
						helper.timer( component, helper );
					}, 1000 );
					
					consoleState.timeTracker.activityDate = new Date().toISOString();
					component.set( "v.consoleState", consoleState );
				}
				else {
					clearInterval( consoleState.timeTracker.timerId );
					consoleState.timeTracker.inactiveTimeStamps.push( new Date().getTime() );
					consoleState.labelStatus.startIcon = "utility:right";
					consoleState.labelStatus.playPauseBtnText = constants.LBL_TT_Widget_Start;
					component.set( "v.consoleState", consoleState );
				}
			}
		}
	},
    
    /*
		@ PURPOSE : STOPS THE TIMER AND PUSHES CURRENT TIME STAMP TO INACTIVETIMESTAMPS ARRAY.
	*/
	stop : function( component, event, helper ) { 
        
		var consoleState = JSON.parse( JSON.stringify( component.get( "v.consoleState" ) ) );
		if( consoleState && consoleState.timeTracker && 
			consoleState.labelStatus && consoleState.toggleStatus 
		) {
			var constants = JSON.parse( JSON.stringify( component.get( "v.constants" ) ) );
			if( constants ) {
				consoleState.labelStatus.startIcon = "utility:right";
				consoleState.labelStatus.playPauseBtnText = constants.LBL_TT_Widget_Start;
				consoleState.timeTracker.counter = 0;
				
				consoleState.toggleStatus.isStopDisabled = true;
				consoleState.toggleStatus.isTimerDisabled = false;
				consoleState.toggleStatus.isBtnDisabled = false;
				
				clearInterval( consoleState.timeTracker.timerId );
				if( consoleState.timeTracker.activeTimeStamps.length - 1 == consoleState.timeTracker.inactiveTimeStamps.length ) { 
					consoleState.timeTracker.inactiveTimeStamps.push( new Date().getTime() );
				}
				
				consoleState.toggleStatus.isSubmitDisabled = !helper.validateForm( component, helper, consoleState, false );
				component.set( "v.consoleState", consoleState );
			}
		}
    },
    
    /*
		@ PURPOSE : 1. VALIDATES THE FORM DETAILS AND DISPLAYS ERROR MESSAGE BELOW FIELDS WITH INVALID DATA. 
					2. CREATES TIME TRACKER RECORD AND MANUAL LINE ITEM RECORDS IF PROPER DATA IS PROVIDED.
	*/
	handleSubmit : function( component, event, helper ) { 
	
    	var consoleState = JSON.parse( JSON.stringify( component.get( "v.consoleState" ) ) );
		if( consoleState ) {
			
			var isFormValid = helper.validateForm( component, helper, consoleState, true );
			component.set( "v.consoleState", consoleState );
			if( isFormValid ) {
				helper.pushTimeTracker( component, helper, consoleState );
			}
		}
    },
    
    /******************************* ACTIONS INVOKED BY HELPER *******************************/
	
	/*
    	@ PURPOSE : 1. FETCHES THE RECORD FROM AN ARRAY USING THE ATTRIBUTE OF THE RECORD AND ITS VALUE.
        			2. IF REMOVERECORD IS TRUE, THEN REMOVES THE MATCHED ELEMENT FROM ARRAY.
    */
    getRecordFromList : function( component, helper, listOfRecords, attributeName, attributeValue, removeRecord ) {
        
        var matchedRecord;
        if( listOfRecords && listOfRecords.length > 0 ) {
            
            var matchedRecordIndex = listOfRecords.map( function( record ) {
                if( attributeName ) {
                    return record[ attributeName ];
                }
                else {
                    // Compares the record itself with if array is not of objects but strings.
                    return record;
                }
            }).indexOf( attributeValue );
                    
            if( matchedRecordIndex != -1 ) {
                matchedRecord = listOfRecords[ matchedRecordIndex ];
                if( removeRecord ) {
                    listOfRecords.splice( matchedRecordIndex, 1 );
                }
            }
        }
        return matchedRecord;
    },
    
    /*
		@ PURPOSE : CLEARS THE OBJECT ID AND SEARCH INPUT FIELD. 
	*/
	clearSearchtext : function( component, event, helper ) {
		
        var consoleState = JSON.parse( JSON.stringify( component.get( "v.consoleState" ) ) );
		if( consoleState && consoleState.timeTracker && consoleState.typeAheadStatus ) {
			
			consoleState.listOfSobjectRecords = [];
			consoleState.timeTracker.objectId = null;
			consoleState.typeAheadStatus.searchInput = "";
			component.set( "v.consoleState", consoleState );
		}
    },
	
    /*
		@ PURPOSE : KEEPS THE TIMER VALUE INCREMENTING FOR EVERY SECOND. 
	*/
	timer : function( component, helper ) {
		
		var consoleState = JSON.parse( JSON.stringify( component.get( "v.consoleState" ) ) );
		if( consoleState && consoleState.timeTracker ) {
			consoleState.timeTracker.trackedTime = helper.toHHMMSS( component, helper , consoleState.timeTracker.counter );
			consoleState.timeTracker.counter += 1;
		}
		component.set( "v.consoleState", consoleState );
	},
	
	/*
		@ PURPOSE : FETCHES THE TIME IN HH:MM:SS FORMAT FROM SECONDS FORMAT. 
	*/
    toHHMMSS : function( component, helper, count ) {   
		
		var toHHMMSS = "00:00:00";
		if( count ) {
			
			var sec_num = parseInt( count, 10 );        
			var hours = Math.floor( sec_num / 3600 );
			var minutes = Math.floor( ( sec_num - ( hours * 3600 ) ) / 60 );
			var seconds = sec_num - ( hours * 3600 ) - ( minutes * 60 );
			
			toHHMMSS = "";
			if( hours < 10 ) {
				toHHMMSS = "0"
			}
			toHHMMSS += hours + ":";
			
			if( minutes < 10 ) {
				toHHMMSS += "0";
			}
			toHHMMSS += minutes + ":";
			
			if( seconds < 10 ) {
				toHHMMSS += "0";
			}
			toHHMMSS += seconds;
		}
        return toHHMMSS;
	},
    
	/*
		@ PURPOSE : VALIDATES ACTIVITY DATE AND DISPLAYS AN ERROR MESSAGE ON INVALID VALUE AND DISABLES SUBMIT BUTTON. 
	*/
    validateActivityDate : function( component, helper, consoleState, showError ) {
		
		var isDateValid = true;
        if( consoleState && consoleState.timeTracker && consoleState.timeTracker.activityDate && 
            consoleState.timeTracker.activityDate.length > 0 
        ) {
            
			var activityTimestamp = Date.parse( consoleState.timeTracker.activityDate );
			if( isNaN( activityTimestamp ) ) {
				isDateValid = false;
			}
			else {
				var dateValue = new Date( activityTimestamp );
				if( !dateValue || dateValue.getFullYear() < 2000 ) {
					isDateValid = false;
				}
			}
		}
		else {
			isDateValid = false;
		}
		return isDateValid;
    },
    
	/*
		@ PURPOSE : VALIDATES TIMER FIELD AND DISPLAYS AN ERROR MESSAGE ON INVALID VALUE AND DISABLES SUBMIT BUTTON. 
	*/
    validateTimer : function( component, helper, consoleState, showError ) {
		
		var isTimerValid = true;
        if( consoleState && consoleState.timeTracker ) {
			var timerElement = component.find( "timerId" );
			var timeRegex = new RegExp( "([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]" );
			
			if( consoleState.timeTracker.trackedTime && consoleState.timeTracker.trackedTime.indexOf( "00:00:00" ) == -1 &&
				consoleState.timeTracker.trackedTime.length == 8 && timeRegex.test( consoleState.timeTracker.trackedTime )
			) {
				timerElement.set( "v.errors", [] );
			}
			else {
				isTimerValid = false;
				if( showError ) {
					var constants = JSON.parse( JSON.stringify( component.get( "v.constants" ) ) );
					if( constants ) {
						timerElement.set( "v.errors", [{ message : constants.ERR_Invalid_duration }] );
					}
				}
			}
		}
		else {
			isTimerValid = false;
		}
		return isTimerValid;
    },
    
	/*
		@ PURPOSE : VALIDATES ACTIVITY PICKLIST AND DISPLAYS AN ERROR MESSAGE ON INVALID VALUE AND DISABLES SUBMIT BUTTON. 
	*/
    validateActivityType : function( component, helper, consoleState, showError ) {
		
		var isActivityTypeValid = true;
        if( consoleState && consoleState.timeTracker ) {
			var activityListElement = component.find( "activityListId" );
			if( consoleState.timeTracker.activityName ) {
				activityListElement.set( "v.errors", [] );
			}
			else {
				isActivityTypeValid = false;
				if( showError ) {
					var constants = JSON.parse( JSON.stringify( component.get( "v.constants" ) ) );
					if( constants ) {
						activityListElement.set( "v.errors", [{ message : constants.ERR_Activity_Required }] );
					}
				}
			}
		}
		else {
			isActivityTypeValid = false;
		}
		return isActivityTypeValid;
    },
	
	/*
		@ PURPOSE : VALIDATES SELECTED/TYPED RECORD VALUE AND DISPLAYS AN ERROR MESSAGE ON INVALID VALUE AND DISABLES SUBMIT BUTTON. 
	*/
    validateSObjectRecord : function( component, helper, consoleState, showError ) {
		
		var isSObjectRecordValid = true;
        if( consoleState && consoleState.timeTracker && consoleState.toggleStatus ) {
			
			var constants = JSON.parse( JSON.stringify( component.get( "v.constants" ) ) );
			if( constants ) {
						
				var recordSearchElement = component.find( "searchInput" );
				if( !consoleState.timeTracker.objectId ) {
					
					if( consoleState.typeAheadStatus.searchInput ) {
						isSObjectRecordValid = false;
						if( showError ) {
							recordSearchElement.set( "v.errors", [{ message : constants.ERR_Invalid_SObject }] );
						}
					}
					else if( consoleState.toggleStatus.isSobjectRequired ) {
						isSObjectRecordValid = false;
						if( showError ) {
							recordSearchElement.set( "v.errors", [{ message : constants.ERR_Invalid_SObject }] );
						}
					}
					else {
						recordSearchElement.set( "v.errors", [] );
					}
				}
				else {
					recordSearchElement.set( "v.errors", [] );
				}
			}
		}
		else {
			isSObjectRecordValid = false;
		}
		return isSObjectRecordValid;
    },
    
	/*
		@ PURPOSE : VALIDATES COMMENT FIELD CONTENTS AND DISPLAYS AN ERROR MESSAGE IF LEFT EMPTY WHEN IT IS RRQUIRED AND DISABLES SUBMIT BUTTON.
	*/
    validateComment : function( component, helper, consoleState, showError ) {
		
		var isCommentValid = true;
        if( consoleState && consoleState.timeTracker && consoleState.toggleStatus ) {
			if( consoleState.timeTracker.comment && consoleState.timeTracker.comment.length > 255 ) {
				isCommentValid = false;
			}
			else if( !consoleState.timeTracker.comment && consoleState.toggleStatus.isCommentRequired ) {
				isCommentValid = false;  
			}   
		}
		else {
			isCommentValid = false;
		}
		return isCommentValid;
    },
    
    /*
		@ PURPOSE : VALIDATES THE FORM AND ON FAILURE, DISPLAYS ERROR MESSAGES, DISABLES SUBMIT BUTTON AND ON SUCCESS, REMOVES THE ERROR MESSAGES. 
	*/
    validateForm : function( component, helper, consoleState, showErrors ) {
		
		var isFormValid = true;
        if( consoleState ) {
			var constants = JSON.parse( JSON.stringify( component.get( "v.constants" ) ) );
			if( constants ) {
				
				if( consoleState.timeTracker && consoleState.toggleStatus && consoleState.typeAheadStatus ) {
				
					// ACTIVITY DATE VALIDATION
					if( !helper.validateActivityDate( component, helper, consoleState, showErrors ) ) {
						isFormValid = false;
					}
					
					// TIMER VALIDATION
					if( !helper.validateTimer( component, helper, consoleState, showErrors ) ) {
						isFormValid = false;
					}
					
					// ACTIVITY TYPE VALIDATION
					if( !helper.validateActivityType( component, helper, consoleState, showErrors ) ) {
						isFormValid = false;
					}
					
					// OBJECT RECORD VALIDATION
					if( !helper.validateSObjectRecord( component, helper, consoleState, showErrors ) ) {
						isFormValid = false;
					}
					
					// COMMENT VALIDATION
					if( !helper.validateComment( component, helper, consoleState, showErrors ) ) {
						isFormValid = false;
					}
					
					if( !consoleState.toggleStatus.isStopDisabled ) {
						isFormValid = false;
					}
				} 
				else {
					isFormValid = false;
					helper.showToastMessage( "error", "Error!", constants.ERR_Lex_Component_Unhandled_Message );
				}
			}
        }
		else {
			isFormValid = false;
		}
		return isFormValid;
	},
    
    /*
		@ PURPOSE : DISPLAYS TOAST MESSAGE BASED ON THE TYPE, TITLE, AND MESSAGE PROVIDED. 
	*/
	showToastMessage : function( type, title, message ) {
			
		if( type && message ) {
			var toastMessageEvent = $A.get( "e.force:showToast" );
			toastMessageEvent.setParams({
										 "type" : type,
										 "title" : title,
										 "message" : message
									   });
			toastMessageEvent.fire();
		}
	},
    
    /*
		@ PURPOSE : FETCHES MISCELLANEOUS SETTINGS FROM SALESFORCE AND SETS VALUES/STYLES TO DEBUG STATEMENTS.
	*/
    beautifyDebugStatements : function( component, helper, consoleState ) {
    	
		if( consoleState && consoleState.loggedInUserSettings && 
			consoleState.loggedInUserSettings[ consoleState.namespace + "ClientDebugLevel__c" ] &&
            ( consoleState.loggedInUserSettings[ consoleState.namespace + "ClientDebugLevel__c" ].toUpperCase() == "INFO" ||
			  consoleState.loggedInUserSettings[ consoleState.namespace + "ClientDebugLevel__c" ].toUpperCase() == "DEBUG"
			)
        ) {
			// Fetches object with default styling applied.
			var debugTypeToStyle = helper.getDebugTypeToStyle( component, helper );
			
			// Fetches Miscellaneous settings to override the default style of debug statements.
			if( consoleState.listOfMiscellaneousSettings && consoleState.listOfMiscellaneousSettings.length > 0 ) {
				
				for( var debugTypeAsSettingName in debugTypeToStyle ) {
					var miscellaneousSetting = helper.getRecordFromList( component, helper, 
                                                                         consoleState.listOfMiscellaneousSettings, 
																		 "Name", debugTypeAsSettingName, false 
																	   );
					if( miscellaneousSetting && miscellaneousSetting[ consoleState.namespace + "Code1__c" ] ) {
						debugTypeToStyle[ debugTypeAsSettingName ] = miscellaneousSetting[ consoleState.namespace + "Code1__c" ];
					}
				}				
			}
			
            window.debug.info = function() {
                
                var args = Array.prototype.slice.call( arguments );
                var el = "%cLightning%c" + args.shift();
                args.unshift( el, debugTypeToStyle[ "MISCELLANEOUS_JS_ConsoleSF" ], 
                              debugTypeToStyle[ "MISCELLANEOUS_JS_ConsoleInfo" ] 
                            );
                console.info.apply( window.console, args );
            }
            
            window.debug.log = function() {
                
                var args = Array.prototype.slice.call( arguments );
                var el = "%cLightning%c" + args.shift();
                args.unshift( el, debugTypeToStyle[ "MISCELLANEOUS_JS_ConsoleSF" ], 
                              debugTypeToStyle[ "MISCELLANEOUS_JS_ConsoleLog" ] 
                            );
                console.log.apply( console, args );
            }
            
            window.debug.error = function() {
                
                var args = Array.prototype.slice.call( arguments );
                var el = "%cLightning%c" + args.shift();
                args.unshift( el, debugTypeToStyle[ "MISCELLANEOUS_JS_ConsoleSF" ], 
                              debugTypeToStyle[ "MISCELLANEOUS_JS_ConsoleError" ] 
                            );
                console.log.apply( console, args );
            }
    	}
    },
    
    /*
		@ PURPOSE : CONVERTS THE JAVASCRIPT DATE TIME FIELD TO STRING FORMAT.
					I. INPUT - 2018-06-18T09:05:18.865Z
					II. OUTPUT - 06/18/2018 02:35 PM
	*/
	getDateTimeValueInStringFormat : function( component, helper, selectedDateTime ) {
		
		var strDateTimeValue = "";
		if( selectedDateTime ) {
			var date = new Date( selectedDateTime );
			if( date ) {
				
				var hours = date.getHours() > 12 ? date.getHours() - 12 : date.getHours();
				var am_pm = date.getHours() >= 12 ? "PM" : "AM";
				
				hours = hours < 10 ? "0" + hours : hours;
				if( hours == "00" ) {
					hours = "12";
				}
				
				var minutes = date.getMinutes() < 10 ? "0" + date.getMinutes() : date.getMinutes();
				
				var d = date.getDate() < 10 ? "0" + date.getDate() : date.getDate();
				var m = date.getMonth() + 1;
				m = m < 10 ? "0" + m : m;
				
				strDateTimeValue = m + "/" + d + "/" + date.getFullYear() + " " + hours + ":" + minutes + " " + am_pm;
			}
		}
		return strDateTimeValue;
	},
    
    /*
		@ PURPOSE : 1. CALCULATES THE DURATION FROM ACTIVE AND INACTIVE TIME STAMP ARRAYS.
					2. BUILDS RECORDS OF MANUAL LINE ITEMS FROM THE SAME ARRAYS.
	*/
	getListOfManualLineItems : function( component, helper, consoleState ) {
		
		var listOfManualLineItems = [];
		if( consoleState && consoleState.timeTracker && consoleState.timeTracker.trackedTime ) {
			consoleState.timeTracker.duration = 0;
			
			// CALCULATES DURATION IF LENGTH OF ACTIVE AND INACTIVE TIMESTAMP ARRAYS ARE MATCHED.
			if( consoleState.timeTracker.activeTimeStamps.length == consoleState.timeTracker.inactiveTimeStamps.length &&
				consoleState.timeTracker.activeTimeStamps.length != 0
			) {
				var endTime;
				consoleState.timeTracker.activeTimeStamps.map( function( startTime, i ) {
					endTime = consoleState.timeTracker.inactiveTimeStamps[ i ];
                    listOfManualLineItems.push({ 
												[ consoleState.namespace + "Engage_Time__c" ] : startTime, 
												[ consoleState.namespace + "Disengage_Time__c" ] : endTime 
											  });
					consoleState.timeTracker.duration += ( endTime - startTime );
				});
				
				// CONVERTS FROM MILLISECONDS TO SECONDS.
				consoleState.timeTracker.duration = Math.floor( consoleState.timeTracker.duration * 0.001 );
			}
		}
		return listOfManualLineItems;
	},
    
    /*
		@ PURPOSE : 1. RECEIVES RECORD, LIST OF FIELDS, AND NAMESPACE.
					2. BUILDS LABEL WITH VALUES OF EACH FIELD SEPARATED BY " - ".
					2. TRIM THE CONTENTS TO AVOID THE X-SCROLLING.
	*/
	getLabelFromRecordAndFields : function( record, listOfFields, namespace ) {
			
		var label = "";
		if( record && listOfFields && listOfFields.length > 0 ) {
			
			if( !namespace ) {
				namespace = "";
			}
			
			var separator = "";
			listOfFields.forEach( function( fieldApiName ) {
										
				if( label ) {
					separator = " - ";
				}
				
				if( fieldApiName.endsWith( "__c" ) && record[ namespace + fieldApiName ] ) {
					label += separator + record[ namespace + fieldApiName ];    
				}
				else if( record[ fieldApiName ] ) {
					label += separator + record[ fieldApiName ];
				}
			});
			
			if( label.length > 50 ) {
				label = label.substring( 0, 50 ) + "...";
			}
		}
		return label;
	},
    
    /*
		@ PURPOSE : SETS DEFAULT VALUES TO DEBUG STATEMENTS SUCH LOG, INFO, ERROR, ETC.
	*/
	getDebugTypeToStyle : function( component, helper ) {
		
		var debugTypeToStyle = new Object();
        var genericStyle = "color:#FFF;padding:5px;border-radius: 5px;line-height: 20px;";
		debugTypeToStyle[ "MISCELLANEOUS_JS_ConsoleLog" ] = "background: #4ab471;" + genericStyle;
		debugTypeToStyle[ "MISCELLANEOUS_JS_ConsoleInfo" ] = "background: #3F51B5;" + genericStyle;
		debugTypeToStyle[ "MISCELLANEOUS_JS_ConsoleError" ] = "background: #970e02;" + genericStyle;
		debugTypeToStyle[ "MISCELLANEOUS_JS_ConsoleSF" ] = "background: #fcad02;" + genericStyle;
		return debugTypeToStyle;
	},
    
    /*
		@ PURPOSE : SETS THE CONSOLESTATE ATTRIBUTE/OBJECT WITH DEFAULT VALID VALUES.
	*/
	resetConsoleState : function( component, helper ) {
		
        var currentDate = new Date();
        currentDate.setHours( 0, 0, 0, 0 );
		
        var consoleState = {
							"namespace" : "",
							"isFormValid" : false,
							"loggedInUserSettings" : {},
							"listOfMiscellaneousSettings" : [],
							"listOfManualActivityWrappers" : [],
							"listOfSobjectRecords" : [],
							"timeTracker"  :
											{ 
                                             "activityDate" : currentDate.toISOString(), 
                                             "activityName" : "", 
                                             "objectId" : "",
                                             "trackedTime" : "00:00:00", "comment" : "", "timerId" : "",
											 "counter" : 0, "duration" : 0,
											 "activeTimeStamps" : [], "inactiveTimeStamps" : []
                                            },
							"typeAheadStatus" :
											   {
											   	"searchInput" : "", "sObjectApiName" : "", "sObjectSearchField" : "",
												"sObjectKeyPrefix" : "", "sObjectLabel" : "Case", 
                                                "listOfShowFields" : [] 
											   },
							"toggleStatus" :
											{
										     "isTimerDisabled" : false, "isBtnDisabled" : false,
										     "isStopDisabled" : true, "isSobjectRequired" : false,
											 "isCommentRequired" : false, "isSubmitDisabled" : true, 
                                             "isSobjectDisabled" : true
											},
							"labelStatus" :
											{
											 "message" : "", "startIcon" : "utility:right", 
                                             "stopIcon" : "utility:stop", "playPauseBtnText" : "Start",
                                             "minActivityDate" : new Date( "2000-01-01 00:00:00" ).toISOString()
											}
						   };
		component.set( "v.consoleState", consoleState );
		
		// SETS THE DEBUG ATTRIBUTE OF WINDOW.
        if( !window[ "debug" ] ) {
			window[ "debug" ] = {};
        }
        window.debug[ "info" ] = window.debug[ "log" ] = window.debug[ "error" ]  = function() {};
	},
    
    /*
		@ PURPOSE : SETS THE LIST OF ACTIVITIES FOR SELECTION.
	*/
	setListOfActivities : function ( component, helper, listOfManualActivityWrappers ) {
		
		if( listOfManualActivityWrappers && listOfManualActivityWrappers.length > 0 ) {
			var constants = JSON.parse( JSON.stringify( component.get( "v.constants" ) ) );
			if( constants ) {
				
				var activityListElement = component.find( "activityListId" );
				var listOfManualActivities = [];
				listOfManualActivities.push( { label: constants.LBL_Select_DropDown, value: "", selected : true } );
				listOfManualActivityWrappers.forEach( function( manualActivityWrapper ) {
					if( manualActivityWrapper.manualActivityType ) {
						listOfManualActivities.push( { label : manualActivityWrapper.manualActivityType, 
													   value : manualActivityWrapper.manualActivityType 
												   } );
					}
				});
				activityListElement.set( "v.options", listOfManualActivities );
			}
		}
	},
    
	/*
		@ PURPOSE : UPDATES THE START AND PAUSE BUTTON HOVER-LABELS FROM CUSTOM LABELS.
	*/
    updateConsoleState : function( component, helper, consoleState, constants ) {
		
		if( consoleState && consoleState.labelStatus && constants ) {
			consoleState.labelStatus.playPauseBtnText = constants.LBL_TT_Widget_Start;
		}
	},
    
    /******************************* SERVER SIDE ACTIONS *******************************/
	
	/*
		@ PURPOSE : FETCHES MANUAL, MISCELLANEOUS, AND USER SETTINGS ALONG WITH NAMESPACE.
	*/
	fetchManualTimeTrackerCmpWrapper : function( component, event, helper ) {
		
		var serverAction = component.get( "c.getManualTimeTrackerCmpWrapper" );
		serverAction.setCallback( self, function( response ) {
			
			var state = response.getState();
			if( component.isValid() && state == "SUCCESS" ) {
				
				var result = JSON.parse( response.getReturnValue() );
				if( result.isSucceeded ) {
					var constants = result.labelApiNameToValue;
					component.set( "v.constants", constants );
					
					var consoleState = JSON.parse( JSON.stringify( component.get( "v.consoleState" ) ) );
					if( consoleState ) {
						
						helper.updateConsoleState( component, helper, consoleState, constants );
						consoleState.namespace = result.strNamespace;
						consoleState.loggedInUserSettings = result.loggedInUserSettings;
						consoleState.listOfMiscellaneousSettings = result.listOfMiscellaneousSettings;
						consoleState.listOfManualActivityWrappers = result.listOfManualActivityWrappers;
						
						// Beautifies ( CSS ) debug statements
						helper.beautifyDebugStatements( component, helper, consoleState );
						
						helper.setListOfActivities( component, helper, consoleState.listOfManualActivityWrappers );
						component.set( "v.consoleState", consoleState );
						debug.log( "Manual Time Tracker Settings Loaded", consoleState );
					}
				}
				else {
					helper.showToastMessage( "error", "Error!", result.strMessage );
				}
			}
		});
		$A.enqueueAction( serverAction );
	},
	
	/*
		@ PURPOSE : 1. SEARCHES RECORDS BASED ON KEYWORD PROVIDED AND BUILDS DROP DOWN LIST ACCORDINGLY.
					2. IF THIS WAS INVOKED FROM "GET FROM ACTIVE TAB" THEN POPULATES ONLY RECORD DETAILS IN THE SEARCH FIELD
					   AND MAKE THE DROP DOWN LIST EMPTY IMMEDIATELY.
	*/
	searchRecords : function( component, helper, consoleState, getFromFocusedTab ) {
		
		if( consoleState && consoleState.typeAheadStatus && consoleState.typeAheadStatus.searchInput &&
			consoleState.typeAheadStatus.searchInput.length > 2
		) {
			var constants = JSON.parse( JSON.stringify( component.get( "v.constants" ) ) );
			if( constants ) {
						
				var serverAction = component.get( "c.getSObjectRecords" );       
				serverAction.setParams({
										"searchInput" : consoleState.typeAheadStatus.searchInput,
										"sObjectApiName" : consoleState.typeAheadStatus.sObjectApiName,
										"sObjectSearchField" : consoleState.typeAheadStatus.sObjectSearchField,
										"listOfShowFields" : consoleState.typeAheadStatus.listOfShowFields                           
									  });
									  
				serverAction.setCallback( self, function( response ) {
					
					var state = response.getState();
					if( component.isValid() && state == "SUCCESS" ) {
						
						var consoleState = JSON.parse( JSON.stringify( component.get( "v.consoleState" ) ) );
						if( consoleState ) {
							
							var listOfMatchingRecords = JSON.parse( response.getReturnValue() );
							if( listOfMatchingRecords && listOfMatchingRecords.length > 0 ) {
								
								// HIDES ERROR MESSAGE OF TYPE AHEAD SEARCH FIELD.
								component.find( "searchInput" ).set( "v.errors", [] );
								
								if( consoleState && consoleState.typeAheadStatus && 
									consoleState.typeAheadStatus.listOfShowFields 
								) {
									if( getFromFocusedTab ) {
										consoleState.typeAheadStatus.searchInput = helper.getLabelFromRecordAndFields
																						  (
																						   listOfMatchingRecords[0], 
																						   consoleState.typeAheadStatus.listOfShowFields,
																						   consoleState.namespace
																						  );
										consoleState.timeTracker.objectId = listOfMatchingRecords[0].Id;
									}
									else {
										consoleState.listOfSobjectRecords = [];
										var label;
										listOfMatchingRecords.forEach( function( matchingRecord ) {
											label = helper.getLabelFromRecordAndFields
														   (
															matchingRecord, 
															consoleState.typeAheadStatus.listOfShowFields,
															consoleState.namespace
														   );
											consoleState.listOfSobjectRecords.push( { "label" : label, "value" : matchingRecord.Id } ); 
										});
									}
								}
							}
							else {
								consoleState.listOfSobjectRecords = [];
								if( consoleState.timeTracker && consoleState.typeAheadStatus ) {
									consoleState.timeTracker.objectId = null;
									
									if( consoleState.typeAheadStatus.searchInput && consoleState.typeAheadStatus.searchInput.length > 2 ) {
										helper.validateSObjectRecord( component, helper, consoleState, true );
									}
								}
							}
							consoleState.toggleStatus.isSubmitDisabled = !helper.validateForm( component, helper, consoleState, false );
							component.set( "v.consoleState", consoleState );
						}
					}
					else {
						helper.showToastMessage( "error", "Error!", constants.ERR_Lex_Component_Unhandled_Message );
					}
				});
				$A.enqueueAction( serverAction );
			}
		}
	},
	
	/*
		@ PURPOSE : 1. INSERTS THE TIMETRACKER OBJECT RECORD AND MANUAL LINE ITEM OBJECT RECORDS TOO.
					2. ON SUCCESS, SETS THE CONSOLESTATE ATTRIBUTE/OBJECT WITH DEFAULT VALID VALUES.
	*/
	pushTimeTracker : function( component, helper, consoleState ) {
		
		if( consoleState && consoleState.timeTracker && consoleState.typeAheadStatus ) {
			var constants = JSON.parse( JSON.stringify( component.get( "v.constants" ) ) );
			if( constants ) {
				
				var strDateTimeValue = helper.getDateTimeValueInStringFormat( component, helper, consoleState.timeTracker.activityDate );
				if( strDateTimeValue ) {
					
					var listOfManualLineItems = helper.getListOfManualLineItems( component, helper, consoleState );
					var timeTrackerWrapper = {
											  "strTrackedTime" : consoleState.timeTracker.trackedTime,
											  "strTrackedDuration" : consoleState.timeTracker.duration,
											  "strActivityDateTime" : strDateTimeValue,
											  "strActivitySubType" : consoleState.timeTracker.activityName,
											  "strObjectId" : consoleState.timeTracker.objectId,
											  "strComments" : consoleState.timeTracker.comment,
											  "listOfManualLineItems" : listOfManualLineItems
											 };
					debug.log( "Pushing Manual Time Tracker", timeTrackerWrapper );
					
					var serverAction = component.get( "c.insertTimeTrackerWithManualLineItems" );
					serverAction.setParams({ "strTimeTrackerWrapper" : JSON.stringify( timeTrackerWrapper ) });
						
					serverAction.setCallback( self, function( response ) {
						
						var state = response.getState();
						if( component.isValid() && state == "SUCCESS" ) {
							
							var result = JSON.parse( response.getReturnValue() );
							if( result.isSucceeded ) {
								helper.showToastMessage( "success", "Success!", result.strMessage );
								helper.initializeFooterComponent( component, event, helper );
							}
							else {
								helper.showToastMessage( "error", "Error!", result.strMessage );
							}
						}
						else {
							helper.showToastMessage( "error", "Error!", constants.ERR_Lex_Component_Unhandled_Message );
						}
					});
					$A.enqueueAction( serverAction );
				}
				else {
					helper.showToastMessage( "error", "Error!", constants.ERR_Invalid_Activity_Date );
				}
			}
		}
 	}
})