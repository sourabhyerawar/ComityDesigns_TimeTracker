@isTest (SeeAllData = false)
/**
* @description unit test class for TimeTrackerScheduledCleanup.cls
*/
public class TimeTrackerScheduledCleanupTest {
    static Datetime dtNow = Datetime.now();
    
   /**
    * Test for orphans older than today, should be deleted
    */
   @isTest static void testSchedule()
   {
        TimeTrackerTestHelper.insertRecordsFromStaticResource(TimeTrackerUtility.getNamespace()
            + 'TimeTrackerConfigSettings__c', 'TimeTrackerConfigSettings_Records');
        Case caseObj = new Case(Type = 'Other', Status = 'New', Origin = 'Phone');
        insert caseObj;

        Time_Tracker__c reviewtt = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CASE_REVIEW_STR,
                                        String.valueOf(dtNow.addMinutes(10).getTime()), String.valueOf(dtNow.addMinutes(10).getTime()),
                                        TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(dtNow.getTime()), String.valueOf(dtNow.getTime()),
                                        caseObj.Id, '',  
                                        null, UserInfo.getUserId());
        reviewtt.Object_Id__c = caseObj.Id;
        reviewtt.Duration__c = 600;
        reviewtt.Parent_Object_Id__c = caseObj.Id;
        // This will execute GenericExcludeImpl
        insert reviewtt;
        System.assert(reviewtt.Id != null);

        String cronExp = '0 0 0 3 9 ? 2022';
        Test.startTest();
            String jobId = System.schedule('testScheduledCleanup', cronExp, new TimeTrackerScheduledCleanup());
            // Get the information from the CronTrigger API object
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime
                              FROM CronTrigger WHERE id = :jobId];
            // Verify the expressions are the same
            System.assertEquals(cronExp,ct.CronExpression);
            // Verify the job has not run
            System.assertEquals(0, ct.TimesTriggered);
            // Verify the next time the job will run
            System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
        Test.stopTest();

        Integer i = [SELECT COUNT() FROM Time_Tracker__c];
        System.debug(LoggingLevel.ERROR, '--++--i : ' + i);
        System.assertEquals(i, 1);
   }
}