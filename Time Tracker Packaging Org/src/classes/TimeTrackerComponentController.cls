/**
    @ PURPOSE : CONTROLS THE LIGHTNING COMPONENT --> TimeTrackerComponent.cmp
*/
global without sharing class TimeTrackerComponentController {
    
    /*
        @ PURPOSE     : 1. FETCHES AN ARRAY OF OBJECTS WITH LABEL, PLURAL LABEL, API NAME, PREFIX.
                        2. FETCHES LIST OF ACTIVE TIME TRACKER CONFIG SETTINGS OF TYPES 'STRATEGY' AND 'MISCELLANEOUS'.
        @ RETURN TYPE : STRING [ JSON OF TIMETRACKERCOMPONENTWRAPPER CLASS INSTANCE ] HOLDS THE RESULT OF AN OPERATION.
    */
    @AuraEnabled
    global static String getObjectDetailsAndCustomSettings() {
        
        TimeTrackerComponentWrapper timeTrackerWrapper = new TimeTrackerComponentWrapper();
        timeTrackerWrapper.listOfStrategySettings = TimeTrackerComponentController.getListOfConfigSettings
                                                                                   ( 
                                                                                    TimeTrackerConstants.STRATEGY_TYPE, TRUE 
                                                                                   );
        if( timeTrackerWrapper.listOfStrategySettings.isEmpty() ) {
            timeTrackerWrapper.setStatus( FALSE, System.Label.ERR_Strategy_Settings_Missing );
        }
        else {
            timeTrackerWrapper.listOfMiscellaneousSettings = TimeTrackerComponentController.getListOfConfigSettings
                                                                                            ( 
                                                                                             TimeTrackerConstants.MISCELLANEOUS, TRUE 
                                                                                            );
            timeTrackerWrapper.listOfObjectWrappers = TimeTrackerComponentController.getListOfObjectWrappers();
            if( timeTrackerWrapper.listOfObjectWrappers.isEmpty() ) {
                timeTrackerWrapper.setStatus( FALSE, System.Label.ERR_Object_Details_Not_Found );
            }
            else {
                timeTrackerWrapper.setNamespace();
            }
        }
        
        // CREATES TIME TRACKER LOG RECORDS. 
        TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 'getObjectDetailsAndCustomSettings-timeTrackerWrapper:-\n' + 
                                          JSON.serialize( timeTrackerWrapper ), 
                                          Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                        );
        TimeTrackerUtility.upsertLogRecord();
        return JSON.serialize( timeTrackerWrapper );
    }
    
    /*
        @ PURPOSE     : PARSES THE JSON RECEIVED INTO A TIME_TRACKER__C RECORD AND INSERTS THE RECORD.
        @ PARAMETER   : STRING [ JSON OF TIME_TRACKER__C OBJECT RECORD ]
        @ RETURN TYPE : STRING [ JSON OF TIMETRACKERCOMPONENTWRAPPER CLASS INSTANCE ] HOLDS THE RESULT OF AN OPERATION.
    */
    @AuraEnabled
    global static String insertTimeTracker( String strJsonTimeTracker ) {
        
        TimeTrackerComponentWrapper timeTrackerWrapper = new TimeTrackerComponentWrapper();
        if( String.isNotBlank( strJsonTimeTracker ) ) {
            try {
                timeTrackerWrapper.ttRecord = ( Time_Tracker__c ) JSON.deserialize( strJsonTimeTracker, Time_Tracker__c.class );
                if( timeTrackerWrapper.ttRecord != NULL ) {
                    
                    if( timeTrackerWrapper.ttRecord.Activity_Time__c != NULL ) {
                        timeTrackerWrapper.ttRecord.Activity_Date__c = DateTime.newInstance
                                                                       ( ( Long ) timeTrackerWrapper.ttRecord.Activity_Time__c );
                    }
                    else {
                        timeTrackerWrapper.ttRecord.Activity_Date__c = System.now();
                        timeTrackerWrapper.ttRecord.Activity_Time__c = timeTrackerWrapper.ttRecord.Activity_Date__c.getTime();
                    }
                    
                    insert timeTrackerWrapper.ttRecord;
                    timeTrackerWrapper.setStatus( TRUE, System.Label.SUCCESS_Time_Tracker_Saved );
                }
            }
            catch( Exception e ) {
                timeTrackerWrapper.setStatus( FALSE, System.Label.ERR_Unexpected_Error_While_Saving_Record + ' Exception --> ' + e.getMessage() );
            }
        }
        else {
            timeTrackerWrapper.setStatus( FALSE, System.Label.ERR_Time_Tracker_Record_Missing );
        }
        
        // CREATES TIME TRACKER LOG RECORDS. 
        TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 'timeTrackerWrapper:-\n' + JSON.serialize( timeTrackerWrapper ), 
                                          Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                        );
        TimeTrackerUtility.upsertLogRecord();
        return JSON.serialize( timeTrackerWrapper );
    }
    
    /*
        @ PURPOSE     : RETRIEVES TIME TRACKER CONFIG SETTING RECORDS BASED ON THE TYPE AND ACTIVE STATUS RECEIVED.
        @ PARAMETER   : 1. STRING [ HOLDS THE TYPE OF TIME TRACKER CONFIG SETTINGS ].
                        2. BOOLEAN [ HOLDS THE ACTIVE STATUS OF TIME TRACKER CONFIG SETTING RECORD ].
        @ RETURN TYPE : LIST<TIMETRACKERCONFIGSETTINGS__C> [ HOLDS RETRIEVED RECORDS BASED ON THE PARAMETERS ].
    */
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
        return listOfConfigSettings;
    }
    
    /*
        @ PURPOSE     : FETCHES ALL CREATEABLE OBJECTS WHICH HAVE VALID OBJECT PREFIX CODES.
        @ RETURN TYPE : LIST<TIMETRACKERCOMPONENTWRAPPER.OBJECTWRAPPER> [ HOLDS THE LIST OF OBJECT DETAILS ].
    */
    private static List<TimeTrackerComponentWrapper.ObjectWrapper> getListOfObjectWrappers() {
        
        List<TimeTrackerComponentWrapper.ObjectWrapper> listOfObjectWrappers = new List<TimeTrackerComponentWrapper.ObjectWrapper>();
        for( Schema.SObjectType sObjType : Schema.getGlobalDescribe().values() ) {
            Schema.DescribeSObjectResult sObjResult = sObjType.getDescribe();
            
            if( sobjResult.getKeyPrefix() != NULL ) {
                listOfObjectWrappers.add
                                     ( 
                                      new TimeTrackerComponentWrapper.ObjectWrapper
                                      (
                                       sObjResult.getName(), 
                                       sObjResult.getLabel(),
                                       sObjResult.getLabelPlural(), 
                                       sObjResult.getKeyPrefix()
                                      )
                                     );
            }
        }
        
        // CREATES TIME TRACKER LOG RECORDS. 
        TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 'getListOfObjectWrappers-listOfObjectWrappers:-\n' + 
                                          JSON.serialize( listOfObjectWrappers ),
                                          Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                        );
        TimeTrackerUtility.upsertLogRecord();
        return listOfObjectWrappers;
    }
}