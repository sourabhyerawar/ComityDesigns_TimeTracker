/**
    @ Purpose : Tests the functionality of TimeTrackerTimesheetListCtrlExt class.
*/
@isTest
private class TimeTrackerTimesheetListCtrlExtTest {
    
    private static final String STANDARD_PROFILE_NAME = 'Standard User';
    private static ApexPages.StandardSetController setCont;
    static List<Timesheet__c> listTimesheets;

    private static void initForApproval() {

        // method to install only new TimeTrackerConfigSettings records
        TimeTrackerTestHelper.insertRecordsFromStaticResource( TimeTrackerUtility.getNamespace() + 'TimeTrackerConfigSettings__c',
                                                               'TimeTrackerConfigSettings_Records'
                                                             );
        System.assertNotEquals( 0, TimeTrackerConfigSettings__c.getAll().values().size() );

        Database.SaveResult sr = NULL;
        User stdUsr = TimeTrackerTestHelper.createUser(STANDARD_PROFILE_NAME);

        System.runAs( stdUsr ) {
            
            Test.startTest();
            
            Account acct = new Account( Name = 'Test Account' );
            sr = Database.Insert( acct, TRUE );
            System.assertNotEquals( NULL, sr.getId() );
            String acctid = sr.getId();

            //create a Case record
            Case newCase = new Case( OwnerId = stdUsr.Id );
            newCase.AccountId = acctid;

            //insert the Case record
            sr = Database.Insert( newCase, TRUE );
            // ensure the Case record has an Id
            System.assertNotEquals( NULL, sr.getId() );
            String sObjectId = sr.getId();

            // all information supplied
            String isSuccessful1 = TimeTrackerController.doCreateTimesheetEntry
                                                         ( '00:01:00', '1', DateTime.now().addDays( 8 ).format(),
                                                           TimeTrackerConstants.GENERAL_OTHER, NULL, NULL, 'TrackerComment'
                                                         );
            System.assert( isSuccessful1 == 'TRUE' );

            String isSuccessful2 = TimeTrackerController.doCreateTimesheetEntry
                                                         ( '00:02:15', '2', DateTime.now().addDays( 16 ).format(),
                                                           TimeTrackerConstants.GENERAL_OTHER, NULL, NULL, 'TrackerComment'
                                                         );
            System.assert( isSuccessful2 == 'TRUE' );

            String isSuccessful3 = TimeTrackerController.doCreateTimesheetEntry
                                                         ( '00:03:15', '3', DateTime.now().addDays( 24 ).format(), 
                                                           TimeTrackerConstants.GENERAL_OTHER, NULL, NULL, 'TrackerComment'
                                                         );
            System.assert( isSuccessful3 == 'TRUE' );

            String isSuccessful4 = TimeTrackerController.doCreateTimesheetEntry
                                                         ( '00:04:15', '4', DateTime.now().addDays( 32 ).format(),  
                                                           TimeTrackerConstants.GENERAL_OTHER, NULL, NULL, 'TrackerComment'
                                                         );
            System.assert( isSuccessful4 == 'TRUE' );

            String isSuccessful5 = TimeTrackerController.doCreateTimesheetEntry
                                                         ( '00:01:15', '5', DateTime.now().addDays( 40 ).format(),  
                                                           TimeTrackerConstants.GENERAL_OTHER, NULL, NULL, 'TrackerComment'
                                                         );
            System.assert( isSuccessful5 == 'TRUE' );

            Test.stopTest();
        }
    }
    
    private static void initForRejection() {
        
        // method to install only new TimeTrackerConfigSettings records
        TimeTrackerTestHelper.insertRecordsFromStaticResource( TimeTrackerUtility.getNamespace() + 'TimeTrackerConfigSettings__c',
                                                               'TimeTrackerConfigSettings_Records'
                                                             );
        System.assertNotEquals( 0, TimeTrackerConfigSettings__c.getAll().values().size() );

        Database.SaveResult sr = NULL;
        User stdUsr = TimeTrackerTestHelper.createUser( STANDARD_PROFILE_NAME );

        System.runAs( stdUsr ) {
            
            Test.startTest();
            
            Account acct = new Account( Name = 'Test Account' );
            sr = Database.Insert( acct, TRUE );
            System.assertNotEquals( NULL, sr.getId() );
            String acctid = sr.getId();

            //create a Case record
            Case newCase = new Case( OwnerId = stdUsr.Id );
            newCase.AccountId = acctid;

            //insert the Case record
            sr = Database.Insert( newCase, TRUE );
            System.assertNotEquals( NULL, sr.getId() );
            String sObjectId = sr.getId();

            // all information supplied
            String isSuccessful1 = TimeTrackerController.doCreateTimesheetEntry
                                                         ( '00:01:00', '1', DateTime.now().addDays( 8 ).format(),
                                                           TimeTrackerConstants.GENERAL_OTHER, NULL, NULL, 'TrackerComment'
                                                         );
            System.assert( isSuccessful1 == 'TRUE' );

            String isSuccessful2 = TimeTrackerController.doCreateTimesheetEntry
                                                         ( '00:02:15', '2', DateTime.now().addDays( 16 ).format(),
                                                           TimeTrackerConstants.GENERAL_OTHER, NULL, NULL, 'TrackerComment'
                                                         );
            System.assert( isSuccessful2 == 'TRUE' );

            String isSuccessful3 = TimeTrackerController.doCreateTimesheetEntry
                                                         ( '00:03:15', '3', DateTime.now().addDays( 24 ).format(),
                                                           TimeTrackerConstants.GENERAL_OTHER, NULL, NULL, 'TrackerComment'
                                                         );
            System.assert( isSuccessful3 == 'TRUE' );

            String isSuccessful4 = TimeTrackerController.doCreateTimesheetEntry
                                                         ( '00:04:15', '4', DateTime.now().addDays( 32 ).format(),
                                                           TimeTrackerConstants.GENERAL_OTHER, NULL, NULL, 'TrackerComment'
                                                         );
            System.assert( isSuccessful4 == 'TRUE' );

            String isSuccessful5 = TimeTrackerController.doCreateTimesheetEntry
                                                         ( '00:01:15', '5', DateTime.now().addDays( 40 ).format(),  
                                                           TimeTrackerConstants.GENERAL_OTHER, NULL, NULL, 'TrackerComment'
                                                         );
            System.assert( isSuccessful5 == 'TRUE' );

            Test.stopTest();
        }
    }

    @isTest
    static void test_approveAll() {
        
        initForApproval();
        listTimesheets = [ SELECT ID, Name, Status__c, Comment__c, Total_Seconds__c, OwnerId FROM Timesheet__c ];
        User stdUsr = [ SELECT ID, ManagerId FROM USER WHERE Alias = 'testUsr' ];
        
        User stdMgr = TimeTrackerTestHelper.createUser();
        stdUsr.ManagerId = stdMgr.Id;
        update stdUsr;
        
        Set<ID> tsIds = new Set<ID>();
        String paramString = '';
        for( Timesheet__c ts: listTimesheets ) { 
            paramString += ( paramString == ''? '' : ',' ) + ts.Id; 
        }
        
        
        System.runAs( stdUsr ) {
            for( Timesheet__c ts : listTimesheets ) {
                
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments( 'Submitting request for approval.' );
                req.setObjectId( ts.id );

                // Submit on behalf of a specific submitter
                req.setSubmitterId(ts.ownerId);

                // Submit the record to specific process and skip the criteria evaluation
                req.setProcessDefinitionNameOrId( 'Timesheet_Approval_Process' );
                req.setSkipEntryCriteria( TRUE );

                // Submit the approval request for the account
                Approval.ProcessResult result = Approval.process( req );

                // Verify the result
                System.assert( result.isSuccess() );

                System.assertEquals( 'Pending', result.getInstanceStatus(), 'Instance Status' + result.getInstanceStatus() );
                tsIds.add( ts.Id );
            }
        }

        System.runAs( stdMgr ) {
            PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'Time_Tracker_Admin_Permission_Set'];
			Insert new PermissionSetAssignment(AssigneeId = stdMgr.id, PermissionSetId = ps.Id );
            setCont = new ApexPages.StandardSetController( listTimesheets );
            setCont.setSelected(listTimesheets);
            Test.setCurrentPageReference( new PageReference( 'Page.TimesheetBulkApproval' ) );
            System.currentPageReference().getParameters().put( 'params', paramString );
            TimeTrackerTimesheetListCtrlExt listCtrl = new TimeTrackerTimesheetListCtrlExt( setCont );
            listCtrl.listOfTimesheetsToUpdate = listTimesheets;
            listCtrl.approveAll();
            System.assertEquals( TRUE, listCtrl.areButtonsDisabled );
        }
    }

    @isTest
    static void test_rejectAll() {
    
        initForRejection();
        listTimesheets = [ SELECT ID, Name, Status__c, Comment__c, OwnerId,Total_Seconds__c FROM Timesheet__c ];
        User stdUsr = [ SELECT ID, ManagerId FROM USER WHERE Alias = 'testUsr' ];
        
        User stdMgr = TimeTrackerTestHelper.createUser();
        stdUsr.ManagerId = stdMgr.Id;
        update stdUsr;
        
        Set<ID> tsIds = new Set<ID>();
        String paramString='';
        for( Timesheet__c ts: listTimesheets ) { 
            paramString += ( paramString == '' ? '' : ',' ) + ts.Id; 
        }

        // Create an bulk approval request for the Timesheet
        System.runAs( stdUsr ) {
            for( Timesheet__c ts : listTimesheets ) {
                
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments( 'Submitting request for approval.' );
                req.setObjectId( ts.id );

                // Submit on behalf of a specific submitter
                req.setSubmitterId( ts.OwnerId );

                // Submit the record to specific process and skip the criteria evaluation
                req.setProcessDefinitionNameOrId( 'Timesheet_Approval_Process' );
                req.setSkipEntryCriteria( TRUE );

                // Submit the approval request for the account
                Approval.ProcessResult result = Approval.process( req );

                // Verify the result
                System.assert( result.isSuccess() );

                System.assertEquals( 'Pending', result.getInstanceStatus(), 'Instance Status' + result.getInstanceStatus() );
                tsIds.add( ts.Id );
            }
        }

        System.runAs( stdMgr ) {
            PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'Time_Tracker_Admin_Permission_Set'];
			Insert new PermissionSetAssignment(AssigneeId = stdMgr.id, PermissionSetId = ps.Id );
            setCont = new ApexPages.StandardSetController( listTimesheets );
            setCont.setSelected(listTimesheets);
            Test.setCurrentPageReference( new PageReference( 'Page.TimesheetBulkApproval' ) );

            System.currentPageReference().getParameters().put( 'params', paramString );
            TimeTrackerTimesheetListCtrlExt listCtrl = new TimeTrackerTimesheetListCtrlExt( setCont );
            listCtrl.listOfTimesheetsToUpdate = listTimesheets;
            listCtrl.rejectAll();

            System.assertEquals( TRUE, listCtrl.areButtonsDisabled );
        }
    }
}