@isTest
private class TimeTrackerStagingAfterTSLcokTest
{
	private static final String STANDARD_PROFILE_NAME = 'Standard User';
  	static List<Timesheet__c> listTimesheets;
	private static Datetime now = System.now();

	private static void init() {
		// method to install only new TimeTrackerConfigSettings records
		TimeTrackerTestHelper.insertRecordsFromStaticResource(TimeTrackerUtility.getNamespace()
		+ 'TimeTrackerConfigSettings__c',
		'TimeTrackerConfigSettings_Records');

		TimeTrackerConfigSettings__c setting = new TimeTrackerConfigSettings__c();
		setting.Name = 'Strategy_SnapEngage Chat';
		setting.Type__c = 'Strategy';
		setting.Text1__c = 'SnapEngage Chat';
		setting.Code1__c = 'GenericImpl';
		setting.Text3__c = 'Customer Chat';
		setting.IsActive__c = true;
		insert setting;
		System.assertNotEquals(0, TimeTrackerConfigSettings__c.getAll().values().size());

		Database.SaveResult sr = null;
		User stdUsr = TimeTrackerTestHelper.createUser(STANDARD_PROFILE_NAME);
        
		system.runAs(stdUsr) {
			//Test.startTest();
			Account acct = new Account(Name='Test Account');
			//insert the Account record
			sr = Database.Insert(acct, true);
			// ensure the Case record has an Id
			system.assertNotEquals(null, sr.getId());
			String acctid = sr.getId();

			//create a Case record
			Case newCase = new Case(OwnerId = stdUsr.Id);
			newCase.AccountId = acctid;

			//insert the Case record
			sr = Database.Insert(newCase, true);
			// ensure the Case record has an Id
			system.assertNotEquals(null, sr.getId());
			String sObjectId = sr.getId();

			// all information supplied
			String isSuccessful1 = TimeTrackerController.doCreateTimesheetEntry('00:01:00', '60',
			DateTime.now().format(),	TimeTrackerConstants.GENERAL_OTHER,
			null, null, 'TrackerComment');
			system.assertEquals('true', isSuccessful1);

			/*String isSuccessful2 = TimeTrackerController.doCreateTimesheetEntry('00:02:00', '2',
			DateTime.now().addDays(16).format(),	TimeTrackerConstants.CASE_REVIEW_STR,
			sObjectId, '2', 'TrackerComment');
			system.assertEquals('true', isSuccessful2);

			String isSuccessful3 = TimeTrackerController.doCreateTimesheetEntry('00:03:00', '3',
			DateTime.now().addDays(24).format(),	TimeTrackerConstants.CASE_REVIEW_STR,
			sObjectId, '3', 'TrackerComment');
			system.assertEquals('true', isSuccessful3);

			String isSuccessful4 = TimeTrackerController.doCreateTimesheetEntry('00:04:00', '4',
			DateTime.now().addDays(32).format(),	TimeTrackerConstants.CASE_REVIEW_STR,
			sObjectId, '4', 'TrackerComment');
			system.assertEquals('true', isSuccessful4);

			String isSuccessful5 = TimeTrackerController.doCreateTimesheetEntry('00:05:00', '5',
			DateTime.now().addDays(40).format(),	TimeTrackerConstants.CASE_REVIEW_STR,
			sObjectId, '5', 'TrackerComment');
			system.assertEquals('true', isSuccessful5);*/

			//Test.stopTest();
		}
	}

	private static void insertChats(){
		List<TimeTracker_StagingLineItem__c> stgRecList = new List<TimeTracker_StagingLineItem__c>();

		TimeTracker_StagingLineItem__c stgRec1 = new TimeTracker_StagingLineItem__c();
		stgRec1.Activity_Name__c = 'SnapEngage Chat';
		stgRec1.Start_Date__c = now.addMinutes(2);
		stgRec1.End_Date__c= now.addMinutes(17);
		stgRecList.add(stgRec1);

		/*TimeTracker_StagingLineItem__c stgRec2 = new TimeTracker_StagingLineItem__c();
		stgRec2.Activity_Name__c = 'Chat1';
		stgRec2.Start_Date__c = now.addDays(16).addMinutes(2);
		stgRec2.End_Date__c= now.addDays(16).addMinutes(17);
		stgRecList.add(stgRec2);

		TimeTracker_StagingLineItem__c stgRec3 = new TimeTracker_StagingLineItem__c();
		stgRec3.Activity_Name__c = 'Chat1';
		stgRec3.Start_Date__c = now.addDays(24).addMinutes(2);
		stgRec3.End_Date__c= now.addDays(24).addMinutes(17);
		stgRecList.add(stgRec3);

		TimeTracker_StagingLineItem__c stgRec4 = new TimeTracker_StagingLineItem__c();
		stgRec4.Activity_Name__c = 'Chat1';
		stgRec4.Start_Date__c = now.addDays(32).addMinutes(2);
		stgRec4.End_Date__c= now.addDays(32).addMinutes(17);
		stgRecList.add(stgRec4);

		TimeTracker_StagingLineItem__c stgRec5 = new TimeTracker_StagingLineItem__c();
		stgRec5.Activity_Name__c = 'Chat1';
		stgRec5.Start_Date__c = now.addDays(40).addMinutes(2);
		stgRec5.End_Date__c= now.addDays(40).addMinutes(17);
		stgRecList.add(stgRec5);*/

		Insert stgRecList;
	}
	

	@isTest
	static void timesheetSubmitTest() {
		init();
		listTimesheets = [SELECT Id, Name, Status__c, Comment__c,OwnerId,Total_Time_Spent__c,Unique_Timesheet_Identifier__c FROM Timesheet__c];
        
        User stdUsr = [SELECT Id, ManagerId FROM USER WHERE Alias = 'testUsr'];
        User stdMgr = TimeTrackerTestHelper.createUser();

		stdUsr.ManagerId = stdMgr.Id;
        
        update stdUsr;
		System.assertEquals(1, listTimesheets.size());
		//System.debug(listTimesheets);
        
        List<Id> tsIds = new List<Id>();
        System.runAs(stdUsr) {
            for(Timesheet__c ts : listTimesheets) {
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Submitting request for approval.');
                req.setObjectId(ts.id);
        
                // Submit on behalf of a specific submitter
                req.setSubmitterId(ts.OwnerId);
        
                // Submit the record to specific process and skip the criteria evaluation
                req.setProcessDefinitionNameOrId('Timesheet_Approval_Process');
                req.setSkipEntryCriteria(true);
        
                // Submit the approval request for the account
                //System.debug('request : '+req);
                Approval.ProcessResult result = Approval.process(req);
        
                // Verify the result
                System.assert(result.isSuccess());
        
                System.assertEquals(
                    'Pending', result.getInstanceStatus(),
                    'Instance Status'+result.getInstanceStatus()
                );
                tsIds.add(ts.Id);
            }
			insertChats();
        }
        //System.debug('listTimesheets : '+listTimesheets);
        System.assertEquals('0:01:00', listTimesheets[0].Total_Time_Spent__c);

        //Assert one Staging-records are present before Batch
		Integer existingStagingRecordsCount = [SELECT COUNT() FROM TimeTracker_StagingLineItem__c];
		System.assertEquals(1,existingStagingRecordsCount);

		//Assert one Time-tracker records are present before Batch
		List<Time_Tracker__c> ttAlreadyPresent = [SELECT Action__c, Timesheet__c, Timesheet_Entry__c,Time_Spent__c FROM Time_Tracker__c];
		//System.debug('ttAlreadyPresent : '+ttAlreadyPresent);
		System.assertEquals(1, ttAlreadyPresent.size());

		Test.startTest();
		TimeTrackerStagingLineItem processStagingRecords = new TimeTrackerStagingLineItem();
		Database.executeBatch(processStagingRecords);
		Test.stopTest();
		//Assert Time-tracker records are created after Batch
		List<Time_Tracker__c> ttInserted = [SELECT Action__c, Timesheet__c, Timesheet_Entry__c,Time_Spent__c FROM Time_Tracker__c];
		//System.debug('ttInserted : '+ttInserted);
		System.assertEquals(2, ttInserted.size());

		//Assert Timesheet will roll-up staging records to timesheet even after ts locked
		listTimesheets = [SELECT Id, Name, Status__c, Comment__c,OwnerId,Total_Time_Spent__c,Unique_Timesheet_Identifier__c FROM Timesheet__c];
		//System.debug('listTimesheets :'+listTimesheets);
		System.assertEquals('0:16:00', listTimesheets[0].Total_Time_Spent__c);

		//Assert Staging-records are deleted after Batch
		Integer stagingRecordsCountAfterBatch = [SELECT COUNT() FROM TimeTracker_StagingLineItem__c];
		System.assertEquals(0,stagingRecordsCountAfterBatch);
	}
}