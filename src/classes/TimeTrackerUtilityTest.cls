@isTest(SeeAllData=false)
private class TimeTrackerUtilityTest
{
    private static final String STANDARD_PROFILE_NAME = 'Standard User';
    @testSetup
    private static void setup() {
        TimeTrackerUserSettings__c ttUser = TimeTrackerUserSettings__c.getOrgDefaults();
        //ttUser.SetupOwnerId = stdUsr.Id;
        ttUser.Server_Debug__c = true;
        ttUser.Server_Debug_Level__c = 'DEBUG';
        upsert ttUser;
    }
    //@isTest static void getAllObjectSchema_test()
    //{
    //  Test.startTest();
    //      Map<String, Schema.SObjectType> schemaMap = TimeTrackerUtility.getAllObjectSchema();
    //  Test.stopTest();
    //  System.assert(schemaMap != null && !schemaMap.isEmpty());
    //}

    //@isTest static void getSalesforceBaseURL_test()
    //{
    //  Test.startTest();
    //      String baseURL = TimeTrackerUtility.getSalesforceBaseURL();
    //  Test.stopTest();
    //  System.assert(String.isNotBlank(baseURL));
    //}

    //@isTest static void addLogMessage_test()
    //{
    //  Test.startTest();
    //      TimeTrackerUserSettings__c ttUser = new TimeTrackerUserSettings__c();
    //      ttUser.Server_Debug_Level__c = 'ERROR';
    //      upsert ttUser;

    //      TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, 'Error Message', Datetime.now(),
    //          'Test Doc Id', 'Test Object Id', 'Console Toolkit', UserInfo.getUserId());
    //      TimeTrackerUtility.upsertLogRecord();
    //  Test.stopTest();
    //  List<Time_Tracker_Log__c> ttLogList = [Select Id, Name, Log__c From Time_Tracker_Log__c];
    //  System.assert(ttLogList != null && !ttLogList.isEmpty());
    //  System.assertEquals('[ERROR]:Error Message', ttLogList[0].Log__c, ttLogList[0].Log__c);
    //}

    @isTest static void addMultipleLogMessages_test()
    {
        TimeTrackerUserSettings__c ttUser = new TimeTrackerUserSettings__c();          
        ttUser.Server_Debug__c = true;          
        ttUser.Server_Debug_Level__c = 'DEBUG';         
        insert ttUser;
        
        String message = '1234567890123456789012345678901234567890123456789012345678901234567890'
                        + '1234567890123456789012345678901234567890123456789012345678901234567890'
                        + '1234567890123456789012345678901234567890123456789012345678901234';
        Test.startTest();
            for(Integer i = 0; i < 1800; i++) {
                TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, message, Datetime.now(),
                    'Test Doc Id', 'Test Object Id', 'Console Toolkit', UserInfo.getUserId());
            }
            TimeTrackerUtility.upsertLogRecord();
        Test.stopTest();
        Time_Tracker_Log__c logRec = [Select Id, Name, Log__c, Log2__c From Time_Tracker_Log__c Limit 1];
        System.assert(logRec.Log__c.length() == 131071 && logRec.Log2__c.length() == 131071);
    }

    @isTest static void addMultipleLogMessages2_test()
    {
        TimeTrackerUserSettings__c ttUser = new TimeTrackerUserSettings__c();           
        ttUser.Server_Debug__c = true;          
        ttUser.Server_Debug_Level__c = 'DEBUG';         
        insert ttUser;
        
        String message = '1234567890123456789012345678901234567890123456789012345678901234567890'
                        + '1234567890123456789012345678901234567890123456789012345678901234567890'
                        + '1234567890123456789012345678901234567890123456789012345678901234';
        Test.startTest();
            for(Integer i = 0; i < 200; i++) {
                TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, message, Datetime.now(),
                    'Test Doc Id', 'Test Object Id', 'Console Toolkit', UserInfo.getUserId());
            }
            TimeTrackerUtility.upsertLogRecord();
        Test.stopTest();
        Time_Tracker_Log__c logRec = [Select Id, Name, Log__c, Log2__c From Time_Tracker_Log__c Limit 1];
        System.assert(logRec.Log__c.length() == 42599 && logRec.Log2__c == null, logRec.Log__c.length());
    }
}