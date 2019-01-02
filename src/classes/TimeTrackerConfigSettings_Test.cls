@isTest
private class TimeTrackerConfigSettings_Test
{
	@isTest static void getManualSettings_test_ForPermissionSet()
	{	

        // create test user
        User usr = TimeTrackerTestHelper.createUser();
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Label =: TimeTrackerConstants.TIME_TRACKER_ADMIN_PERMISSION_SET_NAME];

        //Assign-Permission set
		PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = usr.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;

		system.runAs(usr) {
			// insert TimeTrackerConfigSetting Records
			TimeTrackerTestHelper.insertRecordsFromStaticResource(TimeTrackerUtility.getNamespace() + 'TimeTrackerConfigSettings__c',
				'TimeTrackerConfigSettings_Records');

			Test.startTest();
				Map<String, TimeTrackerConfigSettings__c> stratgyManualMap = TimeTrackerConfigSettings.getactivityvsActivityDetails();
				//system.debug('####'+stratgyManualMap);
			Test.stopTest();
			

			System.assertNotEquals(0, stratgyManualMap.size());
			System.assertEquals(TRUE, stratgyManualMap.containsKey(TimeTrackerConstants.BREAKs));
		}
	}
	@isTest static void getManualSettings_test_WithoutPermissionSet()
	{	

        // create test user
        User usr = TimeTrackerTestHelper.createUser();
        
		system.runAs(usr) {
			// insert TimeTrackerConfigSetting Records
			TimeTrackerTestHelper.insertRecordsFromStaticResource(TimeTrackerUtility.getNamespace() + 'TimeTrackerConfigSettings__c',
				'TimeTrackerConfigSettings_Records');
           		List<TimeTrackerConfigSettings__c> manual_Break = [SELECT Name, Text1__c, Text4__c FROM TimeTrackerConfigSettings__c WHERE Name=: TimeTrackerConstants.MANUAL_BREAK];
				manual_Break.get(0).Text4__c = TimeTrackerConstants.TIME_TRACKER_ADMIN_PERMISSION_SET_NAME;
            	update manual_Break;
            
			Test.startTest();
				Map<String, TimeTrackerConfigSettings__c> stratgyManualMap = TimeTrackerConfigSettings.getactivityvsActivityDetails();
			Test.stopTest();
			

			System.assertNotEquals(0, stratgyManualMap.size());
			System.assertEquals(FALSE, stratgyManualMap.containsKey(TimeTrackerConstants.BREAKs));
		}
	}	
	@isTest static void getMaxAllowedMinutesDifference_test_HavingValue()
	{	

		// insert TimeTrackerConfigSetting Records
		TimeTrackerTestHelper.insertRecordsFromStaticResource(TimeTrackerUtility.getNamespace() + 'TimeTrackerConfigSettings__c',
			'TimeTrackerConfigSettings_Records');

		Test.startTest();
			Integer mins = TimeTrackerConfigSettings.getMaxAllowedMinutesDifference();
		Test.stopTest();

		System.assertEquals(30, mins, 'mins : ' + mins);
	}	
	@isTest static void getMaxAllowedMinutesDifference_test_WithoutHavingValue()
	{	

		// insert TimeTrackerConfigSetting Records
		TimeTrackerTestHelper.insertRecordsFromStaticResource(TimeTrackerUtility.getNamespace() + 'TimeTrackerConfigSettings__c',
			'TimeTrackerConfigSettings_Records');
		List<TimeTrackerConfigSettings__c> maxTime = [SELECT Name, Text1__c FROM TimeTrackerConfigSettings__c WHERE Name=: TimeTrackerConstants.MISCELLANEOUS_MAX_TIME_CONSIDERIN_MIN];
		//system.debug('@@'+maxTime);
		delete maxTime;

		Test.startTest();
			Integer mins = TimeTrackerConfigSettings.getMaxAllowedMinutesDifference();
		Test.stopTest();

		System.assertEquals(30, mins, 'mins : ' + mins);
	}
	@isTest static void getRunTimeTrackerTriggers_test_HavingValue()
	{	

		// insert TimeTrackerConfigSetting Records
		TimeTrackerTestHelper.insertRecordsFromStaticResource(TimeTrackerUtility.getNamespace() + 'TimeTrackerConfigSettings__c',
			'TimeTrackerConfigSettings_Records');

		Test.startTest();
			Boolean isRunTriggers = TimeTrackerConfigSettings.getRunTimeTrackerTriggers();
		Test.stopTest();
		System.assert(isRunTriggers);
	}
	@isTest static void getRunTimeTrackerTriggers_test_WithoutHavingValue()
	{	

		// insert TimeTrackerConfigSetting Records
		TimeTrackerTestHelper.insertRecordsFromStaticResource(TimeTrackerUtility.getNamespace() + 'TimeTrackerConfigSettings__c',
			'TimeTrackerConfigSettings_Records');
		List<TimeTrackerConfigSettings__c> runTrigger = [SELECT Name, Text1__c FROM TimeTrackerConfigSettings__c WHERE Name=: TimeTrackerConstants.MISCELLANEOUS_EXECUTE_TRIGGERS];
		//system.debug('@@'+runTrigger);
		delete runTrigger;

		Test.startTest();
			Boolean isRunTriggers = TimeTrackerConfigSettings.getRunTimeTrackerTriggers();
		Test.stopTest();
		System.assert(isRunTriggers);
	}
	@isTest static void geturlPatternvsActivityMap_test()
	{	

		// insert TimeTrackerConfigSetting Records
		TimeTrackerTestHelper.insertRecordsFromStaticResource(TimeTrackerUtility.getNamespace() + 'TimeTrackerConfigSettings__c',
			'TimeTrackerConfigSettings_Records');

		Test.startTest();

			Map<String,String> urlMap = TimeTrackerConfigSettings.geturlPatternvsActivityMap();
			Integer mins = TimeTrackerConfigSettings.getMaxAllowedMinutesDifference();
		Test.stopTest();

		System.assertNotEquals(0, urlMap.size());
	}		
}