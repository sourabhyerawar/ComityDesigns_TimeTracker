/**
    @ PURPOSE : 1. CONTROLS THE LIGHTNING COMPONENT --> ManualTimeTrackerCmp.cmp
                2. FETCHES TIME TRACKER CONFIG SETTINGS OF TYPE MANUAL, MISCELLANEOUS AND USER SETTINGS TOO.
                3. CREATES TIME TRACKER AND MANUAL LINE ITEM RECORDS.
*/
public class ManualTimeTrackerCmpController {
    
    /*
        @ PURPOSE : FETCHES MANUAL, MISCELLANEOUS TIME TRACKER CONFIG SETTINGS, USER SETTINGS, AND NAMESPACE DETAILS. 
    */
    @AuraEnabled
    public static String getManualTimeTrackerCmpWrapper() {
        
        ManualTimeTrackerCmpWrapper wrapper = new ManualTimeTrackerCmpWrapper();
        List<TimeTrackerConfigSettings__c> listOfManualConfigSettings = getListOfConfigSettings( TimeTrackerConstants.MANUAL_TYPE, TRUE );
        if( !listOfManualConfigSettings.isEmpty() ) {
            
            wrapper.listOfMiscellaneousSettings = getListOfConfigSettings( TimeTrackerConstants.MISCELLANEOUS, TRUE  );
            if( !wrapper.listOfMiscellaneousSettings.isEmpty() ) {                                                                          
            
                ManualTimeTrackerCmpWrapper.ManualActivityWrapper activityWrapper;
                Schema.SobjectType sobjType;
                Map<String, Object> fieldsToListOfConfigurations, fieldNameToValue;
                List<Object> listOfFieldConfigurations;
                Set<String> setOfPermissionSets = getSetOfPermissionSets( UserInfo.getUserId() );
                
                // DISPLAYS MANUAL SETTINGS IN ASCENDING ORDER BASED ON THE NAME FIELD.
        		listOfManualConfigSettings.sort();
                for( TimeTrackerConfigSettings__c manualSetting : listOfManualConfigSettings ) {
                    if( String.isNotBlank( manualSetting.Text1__c ) && String.isNotBlank( manualSetting.Code1__c ) &&
                        String.isNotBlank( manualSetting.Code2__c )
                    ) {
                        
                        // FETCHES THOSE MANUAL SETTINGS WHOSE TEXT4 IS EITHER BLANK OR 'ALL' OR
                        // THE NAME OF THE PERMISSION SET GIVEN IN TEXT 4 SHOULD BE ASSIGNED TO THE LOGGED-IN USER.
                        if( String.isBlank( manualSetting.Text4__c ) || manualSetting.Text4__c == 'ALL' ||
                            setOfPermissionSets.contains( manualSetting.Text4__c.toLowerCase() )
                        ) {
                            activityWrapper = new ManualTimeTrackerCmpWrapper.ManualActivityWrapper();
                            activityWrapper.sObjectApiName = manualSetting.Code1__c;
                            activityWrapper.isSobjectRequired = activityWrapper.sObjectApiName.endsWith( '*' );
                            if( activityWrapper.isSobjectRequired ) {
                                activityWrapper.sObjectApiName = activityWrapper.sObjectApiName.removeEnd( '*' );
                            }
                            
                            sobjType = Schema.getGlobalDescribe().get( activityWrapper.sObjectApiName );
                            if( sobjType != NULL ) {
                                activityWrapper.sObjectLabel = sobjType.getDescribe().getLabel();
                                activityWrapper.sObjectKeyPrefix = sobjType.getDescribe().getKeyPrefix();
                                
                                activityWrapper.manualActivityType = manualSetting.Text1__c;
                                activityWrapper.isCommentRequired = ( manualSetting.Text6__c == 'Comment Required' );
                                
                                try {
                                    fieldsToListOfConfigurations = ( Map<String, Object> ) JSON.deserializeUntyped( manualSetting.Code2__c.replace( ';', ',' ) );
                                    if( !fieldsToListOfConfigurations.isEmpty() ) {
                                        listOfFieldConfigurations = ( List<Object> ) fieldsToListOfConfigurations.get( 'fields' );
                                        if( !listOfFieldConfigurations.isEmpty() ) {
                                            
                                            for( Object fieldConfiguration : listOfFieldConfigurations ) {
                                                fieldNameToValue = ( Map<String,Object> ) fieldConfiguration;
                                                if( ( Boolean ) fieldNameToValue.get( 'show' ) ) {
                                                    activityWrapper.listOfShowFields.add( ( String ) fieldNameToValue.get( 'field' ) );   
                                                }
                                                if( ( Boolean ) fieldNameToValue.get( 'search' ) ) {
                                                    activityWrapper.sObjectSearchField = ( String ) fieldNameToValue.get( 'field' );
													activityWrapper.sObjectSearchFieldLabel = ( String ) fieldNameToValue.get( 'label' );
                                                }
                                            }
                                            wrapper.listOfManualActivityWrappers.add( activityWrapper );
                                        }
                                    }
                                }
                                catch( Exception e ) {
                                    String strExceptionMessage = 'Invalid Setting Record:-\n' + JSON.serialize( manualSetting ) +
                                                                 '\nManualTimeTrackerCmpController-getManualTimeTrackerCmpWrapper:-\n' + e.getMessage();
                                    TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, strExceptionMessage,
                                                                      Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                                                    );
                                }
                            }
                        }
                    }
                }
            
                if( !wrapper.listOfManualActivityWrappers.isEmpty() ) {
                    wrapper.setNamespace();
                }
                else {
                    wrapper.setStatus( FALSE, System.Label.ERR_Invalid_Manual_Custom_Settings );
                }
            }
            else {
                wrapper.setStatus( FALSE, System.Label.ERR_Miscellaneous_Settings_Missing ); 
            }
        }
        else {
            wrapper.setStatus( FALSE, System.Label.ERR_Manual_Custom_Settings_Missing ); 
        }
        
        TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 'getManualTimeTrackerCmpWrapper-wrapper:-\n' + 
                                          JSON.serialize( wrapper ),
                                          Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                        );
        TimeTrackerUtility.upsertLogRecord();
        
        return JSON.serialize( wrapper );
    }
    
    /*
        @ PURPOSE : FETCHES RECORDS BASED ON THE SEARCH KEYWORD, OBJECT NAME, FIELD TO BE SEARCHED, FIELDS TO BE DISPLAYED. 
    */
    @AuraEnabled
    public static String getSObjectRecords( String searchInput, String sObjectApiName, 
                                            String sObjectSearchField, List<String> listOfShowFields 
    ) {
        List<sObject> listOfSObjectRecords;
        if( String.isNotBlank( searchInput ) ) {
            listOfSObjectRecords = TimeTrackerTypeAheadCompCtrl.searchRecords( searchInput, sObjectApiName, 
                                                                               sObjectSearchField, listOfShowFields, NULL, NULL
                                                                             );
        }
        
        if( listOfSObjectRecords == NULL ) {
            listOfSObjectRecords = new List<sObject>();
        }
        return JSON.serialize( listOfSObjectRecords );
    } 
    
    /*
        @ PURPOSE : 1. PARSES THE RECEIVED JSON INTO MANUALTIMETRACKERCMPWRAPPER.TIMETRACKERWRAPPER INSTANCE. 
                    2. INSERTS THE TIME TRACKER RECORD FROM THE CLASS INSTANCE AND INSERTS MANUAL LINE ITEMS.
    */
    @AuraEnabled
    public static String insertTimeTrackerWithManualLineItems( string strTimeTrackerWrapper ) { 
        
        TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 'insertTimeTracker-strTimeTrackerWrapper:-\n' + strTimeTrackerWrapper,
                                          Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                        );
                                        
        ManualTimeTrackerCmpWrapper wrapper = new ManualTimeTrackerCmpWrapper();
        if( String.isNotBlank( strTimeTrackerWrapper ) ) {
            try {
                ManualTimeTrackerCmpWrapper.TimeTrackerWrapper ttWrapper;
                ttWrapper = ( ManualTimeTrackerCmpWrapper.TimeTrackerWrapper ) JSON.deserialize( strTimeTrackerWrapper,
                                                                                                 ManualTimeTrackerCmpWrapper.TimeTrackerWrapper.class
                                                                                               );
                                                                                               
                TimeTrackerConfigSettings__c configRecord = TimeTrackerConfigSettings.getactivityvsActivityDetails().get( ttWrapper.strActivitySubType );
                if( configRecord != NULL ) {
                    
                    if( string.isNotBlank( ttWrapper.strActivityDateTime ) ) {
                        wrapper.ttRecord = new Time_Tracker__c
                                           (
                                            Action__c = ttWrapper.strActivitySubType,
                                            Object_Id__c = ttWrapper.strObjectId,
                                            Opening_Action__c = ttWrapper.strActivitySubType,
                                            Action_Category__c = configRecord.Text3__c,
                                            Source__c = TimeTrackerConstants.MANUAL_STR,
                                            Action_Closed__c = TRUE,
                                            User__c = UserInfo.getUserId(),
                                            Duration__c = 0,
                                            Time_Spent__c = ttWrapper.strTrackedTime,
                                            Comment__c = ttWrapper.strComments,
                                            IsBillable__c = configRecord.Flag1__c,
                                            IsUtilized__c = configRecord.Flag2__c,
                                            Non_Reportable__c = configRecord.Flag3__c
                                           );
                        
                        if( String.isNotBlank( ttWrapper.strTrackedDuration ) ) {
                            wrapper.ttRecord.Duration__c = Integer.valueOf( ttWrapper.strTrackedDuration );
                        }
                        
                        wrapper.ttRecord.Activity_Date__c = TimeTrackerLocaleToDateFormat.convertStringToDate( ttWrapper.strActivityDateTime );
                        if( wrapper.ttRecord.Activity_Date__c != NULL ) {
                            wrapper.ttRecord.Activity_Time__c = wrapper.ttRecord.Activity_Date__c.getTime();
                            
                            Database.SaveResult sr = Database.insert( wrapper.ttRecord, FALSE );
                            if( sr.isSuccess() ) {
                                
                                ID timesheetRecordId = getTimesheetId( sr.getId() );
                                if( timesheetRecordId != NULL ) {
                                    
                                    if( !ttWrapper.listOfManualLineItems.isEmpty() ) {
                                        INSERT ttWrapper.listOfManualLineItems;
                                    }
                                    wrapper.setStatus( TRUE, System.Label.SUCCESS_Time_Tracker_Saved );
                                }
                                else {
                                    wrapper.setStatus( FALSE, System.Label.ERR_Timesheet_Insertion_Error );
                                }
                            } 
                            else if( String.valueOf( sr.getErrors() ).contains( TimeTrackerConstants.ERROR_TIMESHEET_LOCKED ) ) {
                                wrapper.setStatus( FALSE, TimeTrackerConstants.LOCKED_TEXT );
                            }
                            else {
                                wrapper.setStatus( FALSE, System.Label.LEX_Insert_Failed + ' ' + sr.getErrors() );
                            }
                        }
                        else {
                            wrapper.setStatus( FALSE, System.Label.ERR_Invalid_Activity_Date );
                        }
                    }
                    else {
                        wrapper.setStatus( FALSE, System.Label.ERR_Invalid_Activity_Date );
                    }
                }
                else {
                    wrapper.setStatus( FALSE, System.Label.ERR_Custom_Setting_For_Activity_Missing ); 
                }
            }
            catch( JSONException e ) {
                wrapper.setStatus( FALSE, System.Label.ERR_Unexpected_Error_While_Parsing ); 
                String strExceptionMessage = 'strTimeTrackerWrapper:-\n' + strTimeTrackerWrapper +
                                             '\nManualTimeTrackerCmpController-insertTimeTracker:-\n' + e.getMessage();
                TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, strExceptionMessage,
                                                  Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                                );
            }
            catch( DMLException e ) {
                wrapper.setStatus( FALSE, System.Label.ERR_Unknown_Error_While_Saving_Record ); 
                String strExceptionMessage = 'wrapper:-\n' + JSON.serialize( wrapper ) +
                                             '\nManualTimeTrackerCmpController-insertTimeTracker:-\n' + e.getMessage();
                TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, strExceptionMessage,
                                                  Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                                );
            }
            catch( Exception e ) {
                wrapper.setStatus( FALSE, System.Label.ERR_Unexpected_Error_While_Saving_Record );
                String strExceptionMessage = 'wrapper:-\n' + JSON.serialize( wrapper ) +
                                             '\nManualTimeTrackerCmpController-insertTimeTracker:-\n' + e.getMessage();
                TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, strExceptionMessage,
                                                  Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                                );
            }
        }
        else {
            wrapper.setStatus( FALSE, System.Label.ERR_Time_Tracker_Record_Missing ); 
        }
        
        TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 'insertTimeTracker-wrapper:-\n' + 
                                          JSON.serialize( wrapper ),
                                          Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                        );
        TimeTrackerUtility.upsertLogRecord();
        
        return JSON.serialize( wrapper );
    }
    
    /*
        @ PURPOSE : FETCHES NAMES OF PERMISSION SETS ASSIGNED TO THE GIVEN USER.
    */
    private static Set<String> getSetOfPermissionSets( ID userId ) {
        
        Set<String> setOfPermissionSets = new Set<String>();
        if( userId != NULL ) {
            for( PermissionSetAssignment perm_set : [ SELECT PermissionSet.Label FROM PermissionSetAssignment WHERE AssigneeId =: userId ] ) {
                setOfPermissionSets.add( perm_set.PermissionSet.Label.toLowerCase() );
            }
        }
        return setOfPermissionSets;
    }
    
    
    /*
        @ PURPOSE     : RETRIEVES TIME TRACKER CONFIG SETTING RECORDS BASED ON THE TYPE AND ACTIVE STATUS RECEIVED.
        @ PARAMETER   : 1. STRING [ HOLDS THE TYPE OF TIME TRACKER CONFIG SETTINGS ].
                        2. BOOLEAN [ HOLDS THE ACTIVE STATUS OF TIME TRACKER CONFIG SETTING RECORD ].
        @ RETURN TYPE : LIST<TIMETRACKERCONFIGSETTINGS__C> [ HOLDS RETRIEVED RECORDS BASED ON THE PARAMETERS ].
    */
    @TestVisible
    private static List<TimeTrackerConfigSettings__c> getListOfConfigSettings( String strType, Boolean isActive ) {
        
        List<TimeTrackerConfigSettings__c> listOfConfigSettings = new List<TimeTrackerConfigSettings__c>();
        for( TimeTrackerConfigSettings__c configSetting : TimeTrackerConfigSettings__c.getAll().values() ) {
        
            if( configSetting.Type__c == strType && configSetting.IsActive__c == isActive ) {
                listOfConfigSettings.add( configSetting );
            }
        }
        
        // CREATES TIME TRACKER LOG RECORDS. 
        TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 'getListOfConfigSettings-listOfConfigSettings:-\n' + 
                                          JSON.serialize( listOfConfigSettings ),
                                          Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                        );
        TimeTrackerUtility.upsertLogRecord();
        System.debug( 'getListOfConfigSettings:-\n' + JSON.serialize( listOfConfigSettings ) );
        return listOfConfigSettings;
    }
    
    /*
        @ PURPOSE : FETCHES TIMESHEET RECORD ID FROM TIME TRACKER RECORD DETAILS.
    */
    private static ID getTimesheetId( ID timeTrackerRecordId ) {
        
        Time_Tracker__c timeTrackerRecord = new Time_Tracker__c();
        if( timeTrackerRecordId != NULL ) {
            try {
                timeTrackerRecord = [ SELECT ID, Timesheet__c FROM Time_Tracker__c WHERE ID =: timeTrackerRecordId LIMIT 1 ];
            }
            catch( Exception e ) {
                String strExceptionMessage = 'timeTrackerRecordId:-\n' + timeTrackerRecordId +
                                             '\nManualTimeTrackerCmpController-getTimesheetId:-\n' + e.getMessage();
                TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, strExceptionMessage,
                                                  Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                                );
            }
        }
        return timeTrackerRecord.Timesheet__c;
    }
}