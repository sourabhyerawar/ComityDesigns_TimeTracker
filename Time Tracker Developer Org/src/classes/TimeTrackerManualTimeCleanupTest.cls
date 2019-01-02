@isTest (SeeAllData = false)
private class TimeTrackerManualTimeCleanupTest
{
	@isTest
	static void itShould()
	{
		// Given
		Datetime today = System.now().addDays(-8);
		List<ManualLineItem__c> mItems = new List<ManualLineItem__c> {
			new ManualLineItem__c(
				Engage_Time__c = Datetime.newInstance(today.year(), today.month(), today.day(), 01, 20, 00), 
				Disengage_Time__c = Datetime.newInstance(today.year(), today.month(), today.day(), 02, 30, 00)),
				new ManualLineItem__c(
					Engage_Time__c = Datetime.newInstance(today.year(), today.month(), today.day(), 02, 50, 00),
					Disengage_Time__c = Datetime.newInstance(today.year(), today.month(), today.day(), 03, 10, 00))
		};
		
		// insert records
		Database.SaveResult[] results = Database.insert(mItems, true);
        
        // ensure the ManualLineItem__c record has an Id
        for(Database.SaveResult sr : results) {
            System.assertNotEquals(null, sr.getId());
        }

		// When
		Test.startTest();
		
		TimeTrackerCleanupManualTime cleanMts = new TimeTrackerCleanupManualTime();
       	Database.executeBatch(cleanMts);
       	
       	Test.stopTest();

		// Then
		// Verify merchandise items got deleted 
       	Integer i = [SELECT COUNT() FROM ManualLineItem__c];
       	System.assertEquals(i, 0);
	}
}