@isTest
public class TimeTrackerUserSettings_Test {

    	@isTest static void getMaxAllowedMinutesDifference_test_HavingValue()
	{	
        TimeTrackerUserSettings__c ttSettings = TimeTrackerUserSettings__c.getOrgDefaults();
        ttSettings.Max_Duration_In_Minutes__c = 15;
        upsert ttSettings;
        
        Test.startTest();
			Integer mins = TimeTrackerUserSettings.getMaxAllowedMinutesDifference();
		Test.stopTest();

		System.assertEquals(15, mins, 'mins : ' + mins);
	}	
	@isTest static void getMaxAllowedMinutesDifference_test_WithoutHavingValue()
	{	
		Test.startTest();
			Integer mins = TimeTrackerUserSettings.getMaxAllowedMinutesDifference();
		Test.stopTest();

		System.assertEquals(30, mins, 'mins : ' + mins);
	}
}