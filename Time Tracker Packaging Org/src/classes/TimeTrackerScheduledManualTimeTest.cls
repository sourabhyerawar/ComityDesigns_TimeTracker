@isTest (SeeAllData = false)
private class TimeTrackerScheduledManualTimeTest
{
	/**
    * Test for logs older than 7 days, should be deleted
    */
	@isTest
	static void itShould()
	{
		Test.startTest();
		
		// Given
		List<ManualLineItem__c> mItems = new List<ManualLineItem__c> {
		new ManualLineItem__c(
			Engage_Time__c = Datetime.newInstance(2016, 01, 01, 01, 20, 00), 
			Disengage_Time__c = Datetime.newInstance(2016, 01, 01, 02, 30, 00)),
			new ManualLineItem__c(
				Engage_Time__c = Datetime.newInstance(2016, 01, 01, 02, 50, 00),
				Disengage_Time__c = Datetime.newInstance(2016, 01, 01, 03, 10, 00))
		};
		
		// insert records
		Database.SaveResult[] results = Database.insert(mItems, true);
        
        // ensure the ManualLineItem__c record has an Id
        for(Database.SaveResult sr : results) {
            system.assertNotEquals(null, sr.getId());
        }

		// When
		String cronExp = '0 0 0 3 9 ? 2022';
		
		String jobId = System.schedule('testScheduledCleanup', cronExp, new TimeTrackerScheduledManualTimeCleanup());
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        system.assertEquals(cronExp, ct.CronExpression);
        
        // Verify the job has not run
        system.assertEquals(0, ct.TimesTriggered);

        // Verify the next time the job will run
        system.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
        
        Test.stopTest();

		// Then
		Integer i = [SELECT COUNT() FROM ManualLineItem__c];
        //since not older than today it should not have been deleted
        system.assertEquals(i, 2);

	}
}