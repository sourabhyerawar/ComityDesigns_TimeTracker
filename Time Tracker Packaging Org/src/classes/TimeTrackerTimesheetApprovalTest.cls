@isTest
public class TimeTrackerTimesheetApprovalTest {
  private static final String STANDARD_PROFILE_NAME = 'Standard User';
  static List<Timesheet__c> listTimesheets;
    
  	private static void init() {
		// method to install only new TimeTrackerConfigSettings records
		TimeTrackerTestHelper.insertRecordsFromStaticResource(TimeTrackerUtility.getNamespace()
		+ 'TimeTrackerConfigSettings__c',
		'TimeTrackerConfigSettings_Records');
		System.assertNotEquals(0, TimeTrackerConfigSettings__c.getAll().values().size());

		Database.SaveResult sr = null;
		User stdUsr = TimeTrackerTestHelper.createUser(STANDARD_PROFILE_NAME);
        
		system.runAs(stdUsr) {
			Test.startTest();
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
			String isSuccessful1 = TimeTrackerController.doCreateTimesheetEntry('00:01:00', '1',
			DateTime.now().addDays(8).format(),	TimeTrackerConstants.GENERAL_OTHER,
			null, null, 'TrackerComment');
			system.assertEquals('true', isSuccessful1);

			String isSuccessful2 = TimeTrackerController.doCreateTimesheetEntry('00:02:15', '2',
			DateTime.now().addDays(16).format(),	TimeTrackerConstants.GENERAL_OTHER,
			null, null, 'TrackerComment');
			system.assertEquals('true', isSuccessful2);

			String isSuccessful3 = TimeTrackerController.doCreateTimesheetEntry('00:03:15', '3',
			DateTime.now().addDays(24).format(),	TimeTrackerConstants.GENERAL_OTHER,
			null, null, 'TrackerComment');
			system.assertEquals('true', isSuccessful3);

			String isSuccessful4 = TimeTrackerController.doCreateTimesheetEntry('00:04:15', '4',
			DateTime.now().addDays(32).format(),	TimeTrackerConstants.GENERAL_OTHER,
			null, null, 'TrackerComment');
			system.assertEquals('true', isSuccessful4);

			String isSuccessful5 = TimeTrackerController.doCreateTimesheetEntry('00:01:15', '5',
			DateTime.now().addDays(40).format(),	TimeTrackerConstants.GENERAL_OTHER,
			null, null, 'TrackerComment');
			system.assertEquals('true', isSuccessful5);

			Test.stopTest();
		}
	}
    
    @isTest
	static void test_bulkApproveOrReject() {
		init();
		listTimesheets = [SELECT Id, Name, Status__c, Comment__c,OwnerId FROM Timesheet__c];
        
        User stdUsr = [SELECT Id, ManagerId FROM USER WHERE Alias = 'testUsr'];
        User stdMgr = TimeTrackerTestHelper.createUser();

		stdUsr.ManagerId = stdMgr.Id;
        
        update stdUsr;
		//System.debug('listTimesheets : '+listTimesheets);

		// Create an bulk approval request for the Timesheet
		Set<Id> tsIds = new Set<Id>();
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
                Approval.ProcessResult result = Approval.process(req);
        
                // Verify the result
                System.assert(result.isSuccess());
        
                System.assertEquals(
                    'Pending', result.getInstanceStatus(),
                    'Instance Status'+result.getInstanceStatus()
                );
                tsIds.add(ts.Id);
            }
        }
        
        system.runAs(stdMgr) {
			Map<String, Object> mapAppResponse = TimeTrackerTimesheetApproval.bulkApproveOrReject(tsIds, 'Approve', 'Test Comment');
            //System.debug('mapAppResponse : '+mapAppResponse);
			System.assertEquals('200',	mapAppResponse.get('status'));
        }
	}
}