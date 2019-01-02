@isTest(SeeAllData=false)
private class TimeTrackerStagingLineItemTest {

private static Datetime now = System.now();

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

	@isTest static void Test_TimeTrackerStagingLineItemTime_Batch(){
		insertChat1_S1();
		insertChat2_S1();

		//Assert Staging-records are present before Batch
		Integer existingStagingRecordsCount = [SELECT COUNT() FROM TimeTracker_StagingLineItem__c];
		System.assertEquals(2,existingStagingRecordsCount);

		//Assert No Time-tracker records are present before Batch
		Integer ttAlreadyPresent = [SELECT COUNT() FROM Time_Tracker__c];
		System.assertEquals(0, ttAlreadyPresent);

		Test.startTest();
			TimeTrackerStagingLineItem processStagingRecords = new TimeTrackerStagingLineItem();
			Database.executeBatch(processStagingRecords);
		Test.stopTest();

		//Assert Time-tracker records are created after Batch
		Integer ttInserted = [SELECT COUNT() FROM Time_Tracker__c];
		System.assertEquals(2, ttInserted);

		//Assert Staging-records are deleted after Batch
		Integer stagingRecordsCountAfterBatch = [SELECT COUNT() FROM TimeTracker_StagingLineItem__c];
		System.assertEquals(0,stagingRecordsCountAfterBatch);		
	}
}