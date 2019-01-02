/*
    @ Purpose : 1. Controls the lightning component --> LexManualTimeTrackerController
                2. Fetches Time Tracker Config Settings of Type Manual
                3. Creates Time Tracker and Manual Line Item records.
*/
public class LexManualTimeTrackerController {
    
    @AuraEnabled
    public static String getLexManualTimeTrackerWrapper() {
        
        LexManualTimeTrackerWrapper wrapper = new LexManualTimeTrackerWrapper();
        List<TimeTrackerConfigSettings__c> listOfManualConfigSettings = getListOfConfigSettings( TimeTrackerConstants.MANUAL_TYPE, TRUE );
        if( !listOfManualConfigSettings.isEmpty() ) {
            
            wrapper.listOfMiscellaneousSettings = getListOfConfigSettings( TimeTrackerConstants.MISCELLANEOUS, TRUE  );
            if( !wrapper.listOfMiscellaneousSettings.isEmpty() ) {                                                                          
            
                LexManualTimeTrackerWrapper.ManualActivityWrapper activityWrapper;
                Schema.SobjectType sobjType;
                Map<String, Object> fieldsToListOfConfigurations, fieldNameToValue;
                List<Object> listOfFieldConfigurations;
                
                for( TimeTrackerConfigSettings__c manualSetting : listOfManualConfigSettings ) {
                    try {
                        if( String.isNotBlank( manualSetting.Text1__c ) && String.isNotBlank( manualSetting.Code1__c ) &&
                            String.isNotBlank( manualSetting.Code2__c )
                        ) {
                            activityWrapper = new LexManualTimeTrackerWrapper.ManualActivityWrapper();
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
                                            }
                                        }
                                        wrapper.listOfManualActivityWrappers.add( activityWrapper );
                                    }
                                }
                            }
                        }
                    }
                    catch( Exception e ) {
                        String strExceptionMessage = 'Invalid Setting Record:-\n' + JSON.serialize( manualSetting ) +
                                                     '\nLexManualTimeTrackerController-getLexManualTimeTrackerWrapper:-\n' + e.getMessage();
                        TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, strExceptionMessage,
                                                          Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                                        );
                    }
                }
            
                if( !wrapper.listOfManualActivityWrappers.isEmpty() ) {
                    wrapper.setNamespace();
                }
                else {
                    wrapper.setStatus( FALSE, 'Sorry, Invalid Manual settings were found. Please contact System Administrator.' );
                }
            }
            else {
                wrapper.setStatus( FALSE, 'Sorry, Miscellaneous settings were not found. Please contact System Administrator.' ); 
            }
        }
        else {
            wrapper.setStatus( FALSE, 'Sorry, Manual settings were not found. Please contact System Administrator.' ); 
        }
        
        TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 'getLexManualTimeTrackerWrapper-wrapper:-\n' + 
                                          JSON.serialize( wrapper ),
                                          Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                        );
        TimeTrackerUtility.upsertLogRecord();
        
        return JSON.serialize( wrapper );
    }
    
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
    
    @AuraEnabled
    public static String insertTimeTrackerWithManualLineItems( string strTimeTrackerWrapper ) { 
        
        TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 'insertTimeTracker-strTimeTrackerWrapper:-\n' + strTimeTrackerWrapper,
                                          Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                        );
                                        
        LexManualTimeTrackerWrapper wrapper = new LexManualTimeTrackerWrapper();
        if( String.isNotBlank( strTimeTrackerWrapper ) ) {
            try {
                LexManualTimeTrackerWrapper.TimeTrackerWrapper ttWrapper;
                ttWrapper = ( LexManualTimeTrackerWrapper.TimeTrackerWrapper ) JSON.deserialize( strTimeTrackerWrapper,
                                                                                                 LexManualTimeTrackerWrapper.TimeTrackerWrapper.class
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
										wrapper.setStatus( TRUE, 'Time Tracker record was saved successfully.'  );
									}
									else {
										wrapper.setStatus( FALSE, 'Sorry, Manual Line Items were not found. Please contact System Administrator.' );
									}
                                }
                                else {
                                    wrapper.setStatus( FALSE, 'Error occured while creating Timesheet record. Please contact System Administrator.' );
                                }
                            } 
                            else if( String.valueOf( sr.getErrors() ).contains( TimeTrackerConstants.ERROR_TIMESHEET_LOCKED ) ) {
                                wrapper.setStatus( FALSE, TimeTrackerConstants.LOCKED_TEXT );
                            }
                            else {
                                wrapper.setStatus( FALSE, 'Sorry, an unexpected error occurred while saving the record. Please try again.' );
                            }
                        }
                        else {
                            wrapper.setStatus( FALSE, 'Sorry, Activity date found was invalid. Please provide valid date.'  );
                        }
                    }
                    else {
                        wrapper.setStatus( FALSE, 'Sorry, Activity date was missing.'  );
                    }
                }
                else {
                    wrapper.setStatus( FALSE, 'Sorry, Custom setting for this activity was not found. Please contact System Administrator.' ); 
                }
            }
            catch( JSONException e ) {
                wrapper.setStatus( FALSE, 'Sorry, an unexpected error occurred while parsing details. Please try again.' ); 
                String strExceptionMessage = 'strTimeTrackerWrapper:-\n' + strTimeTrackerWrapper +
                                             '\nLexManualTimeTrackerController-insertTimeTracker:-\n' + e.getMessage();
                TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, strExceptionMessage,
                                                  Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                                );
            }
			catch( DMLException e ) {
                wrapper.setStatus( FALSE, 'Sorry, an unknown error occurred while saving Manual Line Items. Please try again.' ); 
                String strExceptionMessage = 'wrapper:-\n' + JSON.serialize( wrapper ) +
                                             '\nLexManualTimeTrackerController-insertTimeTracker:-\n' + e.getMessage();
                TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, strExceptionMessage,
                                                  Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                                );
            }
            catch( Exception e ) {
                wrapper.setStatus( FALSE, 'Sorry, an unknown error occurred while saving the record. Please try again.' ); 
                String strExceptionMessage = 'wrapper:-\n' + JSON.serialize( wrapper ) +
                                             '\nLexManualTimeTrackerController-insertTimeTracker:-\n' + e.getMessage();
                TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, strExceptionMessage,
                                                  Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                                );
            }
        }
        else {
            wrapper.setStatus( FALSE, 'Sorry, record details were not found. Please contact System Administrator.' ); 
        }
        
        TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 'insertTimeTracker-wrapper:-\n' + 
                                          JSON.serialize( wrapper ),
                                          Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                        );
        TimeTrackerUtility.upsertLogRecord();
        
        return JSON.serialize( wrapper );
    }
    
    /*
        @ Purpose     : Retrieves Time Tracker Config Setting records based on the type and active status received.
        @ Parameter   : 1. String [ Holds the type of Time Tracker Config Settings ].
                        2. Boolean [ Holds the active status of Time Tracker Config Setting record ].
        @ Return Type : List<TimeTrackerConfigSettings__c> [ holds retrieved records based on the parameters ].
    */
    private static List<TimeTrackerConfigSettings__c> getListOfConfigSettings( String strType, Boolean isActive ) {
        
        List<TimeTrackerConfigSettings__c> listOfConfigSettings = new List<TimeTrackerConfigSettings__c>();
        for( TimeTrackerConfigSettings__c configSetting : TimeTrackerConfigSettings__c.getAll().values() ) {
        
            if( configSetting.Type__c == strType && configSetting.IsActive__c == isActive ) {
                listOfConfigSettings.add( configSetting );
            }
        }
        
        // Creates Time Tracker Log records. 
        TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 'getListOfConfigSettings-listOfConfigSettings:-\n' + 
                                          JSON.serialize( listOfConfigSettings ),
                                          Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                        );
        TimeTrackerUtility.upsertLogRecord();
        System.debug( 'getListOfConfigSettings:-\n' + JSON.serialize( listOfConfigSettings ) );
        return listOfConfigSettings;
    }
    
    private static ID getTimesheetId( ID timeTrackerRecordId ) {
        
        Time_Tracker__c timeTrackerRecord = new Time_Tracker__c();
        if( timeTrackerRecordId != NULL ) {
            try {
                timeTrackerRecord = [ SELECT ID, Timesheet__c FROM Time_Tracker__c WHERE ID =: timeTrackerRecordId LIMIT 1 ];
            }
            catch( Exception e ) {
                String strExceptionMessage = 'timeTrackerRecordId:-\n' + timeTrackerRecordId +
                                             '\nLexManualTimeTrackerController-getTimesheetId:-\n' + e.getMessage();
                TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, strExceptionMessage,
                                                  Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                                );
            }
        }
        return timeTrackerRecord.Timesheet__c;
    }
}