@isTest (SeeAllData = false)
/**
* @description unit test class for TimeTrackerScheduledCleanup.cls
*/
public class TimeTrackerScheduledStagingLineItemTest {
    static Datetime now = Datetime.now();

	private static void insertChat1_S1(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat1';
		stgRec.Start_Date__c = now.addMinutes(2);
		stgRec.End_Date__c= now.addMinutes(17);
		insert stgRec;
	}
	private static void insertChat2_S1(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat2';
		stgRec.Start_Date__c = now.addMinutes(3);
		stgRec.End_Date__c= now.addMinutes(5);
		insert stgRec;
	}

   /**
    * Test for orphans older than today, should be deleted
    */
   @isTest static void testSchedule()
   {
   		insertChat1_S1();
		insertChat2_S1();

        String cronExp = '0 0 0 3 9 ? 2022';
        Test.startTest();
            String jobId = System.schedule('testTimeTrackerScheduledStagingLineItem', cronExp, new TimeTrackerScheduledStagingLineItem());
            
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
        System.assertEquals(0, i);
   }
}