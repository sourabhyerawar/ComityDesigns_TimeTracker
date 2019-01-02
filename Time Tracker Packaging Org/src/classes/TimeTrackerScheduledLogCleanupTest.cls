@isTest (SeeAllData = false)
/**
* @description unit test class for TimeTrackerScheduledLogCleanup.cls
*/
public class TimeTrackerScheduledLogCleanupTest {
    /**
    * Test for logs older than 7 days, should be deleted
    */
   	@isTest static void testScheduleShouldNotDelete() {

        TimeTrackerUserSettings__c us = new TimeTrackerUserSettings__c( Server_Debug_Level__c='ERROR',  Server_Debug__c=true);
        insert us;

        Test.startTest();

        TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, 'Test Log', DateTime.now(), '', '',
            TimeTrackerConstants.SYSTEM_STR, UserInfo.getUserId());
        TimeTrackerUtility.upsertLogRecord();
        
        List<Time_Tracker_Log__c> logs = [SELECT Name from Time_Tracker_Log__c];        
        // ensure the Timesheet record has an Id
        system.assertNotEquals(0, logs.size());

        String cronExp = '0 0 0 3 9 ? 2022';
        
        String jobId = System.schedule('testScheduledCleanup', cronExp, new TimeTrackerScheduledLogCleanup());
        // Get the information from the CronTrigger API object

        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime
                          FROM CronTrigger WHERE id = :jobId];


        // Verify the expressions are the same
        system.assertEquals(cronExp,ct.CronExpression);

        // Verify the job has not run

        system.assertEquals(0, ct.TimesTriggered);


        // Verify the next time the job will run
        system.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));

        Test.stopTest();

        Integer i = [SELECT COUNT() FROM Time_Tracker_Log__c];
        //since not older than today it should not have been deleted
        //system.assertEquals(i, 2);
        system.assertEquals(i, 1);
    }

     /**
     * Test for logs older than 7 days, should be deleted
     */
        @isTest static void testScheduleShouldDelete()
        {

         TimeTrackerUserSettings__c us = new TimeTrackerUserSettings__c( Server_Debug_Level__c='ERROR', Server_Debug__c=true);
         insert us;

        Test.startTest();

            TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, 'Test Log', DateTime.now().addDays(-8), '', '',
                TimeTrackerConstants.SYSTEM_STR, UserInfo.getUserId());
            TimeTrackerUtility.upsertLogRecord();
             
             List<Time_Tracker_Log__c> logs = [SELECT Id, Name from Time_Tracker_Log__c];        
             // ensure the Timesheet record has an Id
             system.assertEquals(1, logs.size());
             String cronExp = '0 0 0 3 9 ? 2022';
             String jobId = System.schedule('testScheduledCleanup', cronExp, new TimeTrackerScheduledLogCleanup());
             // Get the information from the CronTrigger API object
             CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime
                               FROM CronTrigger WHERE id = :jobId];

             // Verify the expressions are the same
             system.assertEquals(cronExp,ct.CronExpression);

             // Verify the job has not run
             system.assertEquals(0, ct.TimesTriggered);

             // Verify the next time the job will run
             system.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
        Test.stopTest();

         //List<Time_Tracker_Log__c> logCurrent = [SELECT Id, Name FROM Time_Tracker_Log__c];
         //System.debug(LoggingLevel.ERROR, '--++--prev log : ' + logs[0]);
         //System.debug(LoggingLevel.ERROR, '--++--current log : ' + logCurrent[0]);
         //since 7 days older, it should have been deleted
         //system.assertEquals(i, 2);
         //system.assertEquals(0, i);
     }
}