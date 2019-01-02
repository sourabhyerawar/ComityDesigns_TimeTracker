/**
    @ Purpose : Tests the functionality of ManualTimeTrackerCmpController class.
*/
@IsTest
public class ManualTimeTrackerCmpControllerTest {
    
	// Holds the name of the profile with which this feature to be tested.
    private static final String STANDARD_PROFILE_NAME = 'Standard User';

    @Testsetup static void insertTestData() {
        
		List<TimeTrackerConfigSettings__c> listOfConfigSettings;
		Account recordAccount;
		Contact recordContact;
		Opportunity recordOpportunity;
		Case recordCase;
		CaseComment recordCaseComment;
		
        // Method to install only new TimeTrackerConfigSettings records
        TimeTrackerTestHelper.insertRecordsFromStaticResource( TimeTrackerUtility.getNamespace() + 'TimeTrackerConfigSettings__c',
                                                               'TimeTrackerConfigSettings_Records'
                                                             );
        listOfConfigSettings =  TimeTrackerConfigSettings__c.getAll().values();
        System.debug( 'listOfConfigSettings:-\n' + JSON.serialize( listOfConfigSettings ) );
        System.assertNotEquals( 0, listOfConfigSettings.size() );
        
        recordAccount = new Account( Name = 'Test Lightning Manual Time Tracker Timetracker' );
        INSERT recordAccount;
        System.assertEquals( 1, [ SELECT COUNT() FROM ACCOUNT WHERE ID =: recordAccount.Id ] );
        
        recordContact = new Contact( LastName = recordAccount.Name );
        INSERT recordContact;
        System.assertEquals( 1, [ SELECT COUNT() FROM Contact WHERE ID =: recordContact.Id ] );
        
        recordOpportunity = new Opportunity( Name = recordAccount.Name, 
											 StageName= 'Qualification', 
											 CloseDate = Date.today()
										   );
        INSERT recordOpportunity;
        System.assertEquals( 1, [ SELECT COUNT() FROM Opportunity WHERE ID =: recordOpportunity.Id ] );
        
        recordCase = new Case( Type = 'Other', Status = 'New', Origin = 'Phone', Subject = recordAccount.Name );
        INSERT recordCase;
        System.assertEquals( 1, [ SELECT COUNT() FROM Case WHERE ID =: recordCase.Id ] );
        
        recordCaseComment = new CaseComment( ParentId = recordCase.Id, CommentBody = recordAccount.Name );
        INSERT recordCaseComment;
        System.assertEquals( 1, [ SELECT COUNT() FROM CaseComment WHERE ID =: recordCaseComment.Id ] );
    }
    
    /*
		@ Purpose : Tests the feature of fetching Manual, Miscellaneous, User settings, and Namespace details.
	*/
    public static TestMethod void testGetManualTimeTrackerCmpWrapper() {
        
        User stdUsr = TimeTrackerTestHelper.createUser( STANDARD_PROFILE_NAME );
        System.runAs( stdUsr ) {
            
			List<TimeTrackerConfigSettings__c> listOfManualSettings, listOfMiscellaneousSettings;
			String strToken;
			ManualTimeTrackerCmpWrapper wrapper;
			
            Test.startTest();
			
			listOfManualSettings = ManualTimeTrackerCmpController.getListOfConfigSettings( TimeTrackerConstants.MANUAL_TYPE, TRUE );
			listOfMiscellaneousSettings = ManualTimeTrackerCmpController.getListOfConfigSettings( TimeTrackerConstants.MISCELLANEOUS, TRUE );
			
			// Tests with valid settings. 			
            strToken = ManualTimeTrackerCmpController.getManualTimeTrackerCmpWrapper();
            wrapper = ( ManualTimeTrackerCmpWrapper ) JSON.deserialize( strToken, ManualTimeTrackerCmpWrapper.class );
			System.assert( wrapper.isSucceeded );
			
			// Tests with invalid settings. 
			listOfManualSettings[0].Code2__c = 'Invalid code 2 value for first manual setting';
			UPDATE listOfManualSettings;
			strToken = ManualTimeTrackerCmpController.getManualTimeTrackerCmpWrapper();
            wrapper = ( ManualTimeTrackerCmpWrapper ) JSON.deserialize( strToken, ManualTimeTrackerCmpWrapper.class );
			System.assert( wrapper.isSucceeded );
			
			DELETE listOfMiscellaneousSettings;
			strToken = ManualTimeTrackerCmpController.getManualTimeTrackerCmpWrapper();
            wrapper = ( ManualTimeTrackerCmpWrapper ) JSON.deserialize( strToken, ManualTimeTrackerCmpWrapper.class );
			System.assert( !wrapper.isSucceeded );
			
			DELETE listOfManualSettings;
			strToken = ManualTimeTrackerCmpController.getManualTimeTrackerCmpWrapper();
            wrapper = ( ManualTimeTrackerCmpWrapper ) JSON.deserialize( strToken, ManualTimeTrackerCmpWrapper.class );
			
			Test.stopTest();
			System.assert( !wrapper.isSucceeded );
        }
    }
    
    /*
		@ Purpose : Tests the search records feature [ type ahead feature of lightning component ].
	*/
	public static TestMethod void testGetSObjectRecords() {
        
        User stdUsr = TimeTrackerTestHelper.createUser( STANDARD_PROFILE_NAME );
        System.runAs( stdUsr ) {
			
			Case recordCase;
			String strToken;
			List<sObject> listOfSObjectRecords;
			
            Test.startTest();
			
			// Tests fetching of list of records when characters are typed in type ahead text field.
			recordCase = [ SELECT ID, CaseNumber, Subject FROM Case LIMIT 1 ];
			
			// Tests with invalid keyword.
			strToken = ManualTimeTrackerCmpController.getSObjectRecords( NULL, NULL, NULL, NULL );
			listOfSObjectRecords = ( List<sObject> ) JSON.deserialize( strToken, List<sObject>.class );
			System.assertEquals( 0, listOfSObjectRecords.size() );
			
			// Tests with valid keyword
            strToken = ManualTimeTrackerCmpController.getSObjectRecords( recordCase.CaseNumber, 'Case', 'CaseNumber', 
																		 new List<String>{ 'CaseNumber', 'Subject' }
																	   );
            listOfSObjectRecords = ( List<sObject> ) JSON.deserialize( strToken, List<sObject>.class );
			Test.stopTest();
			System.assertNotEquals( 0, listOfSObjectRecords.size() );
        }
    }
    
    /*
		@ Purpose : Tests the insert feature of Time Tracker and Manual Line Items.
	*/
	public static TestMethod void testInsertTimeTracker() {
        
        User stdUsr = TimeTrackerTestHelper.createUser( STANDARD_PROFILE_NAME );
        System.runAs( stdUsr ) {
			
			Case recordCase;
			ManualTimeTrackerCmpWrapper.TimeTrackerWrapper ttWrapper;
            ManualTimeTrackerCmpWrapper wrapper;
			String strToken;
			DateTime now = System.now();
			
            Test.startTest();
			
			recordCase = [ SELECT ID, CaseNumber, Subject FROM Case LIMIT 1 ];
			
			// Tests with no data
			strToken = ManualTimeTrackerCmpController.insertTimeTrackerWithManualLineItems( NULL );
			wrapper = ( ManualTimeTrackerCmpWrapper ) JSON.deserialize( strToken, ManualTimeTrackerCmpWrapper.class );
			System.assert( !wrapper.isSucceeded );
			
			// Tests with empty data
			strToken = JSON.serialize( ttWrapper );
			strToken = ManualTimeTrackerCmpController.insertTimeTrackerWithManualLineItems( strToken );
			wrapper = ( ManualTimeTrackerCmpWrapper ) JSON.deserialize( strToken, ManualTimeTrackerCmpWrapper.class );
			System.assert( !wrapper.isSucceeded );
			
			// Tests with invalid data
			strToken = 'Invalid JSON of Time Tracker Wrapper';
			strToken = ManualTimeTrackerCmpController.insertTimeTrackerWithManualLineItems( strToken );
			wrapper = ( ManualTimeTrackerCmpWrapper ) JSON.deserialize( strToken, ManualTimeTrackerCmpWrapper.class );
			System.assert( !wrapper.isSucceeded );
			
			// Tests with invalid manual activity type
			ttWrapper = new ManualTimeTrackerCmpWrapper.TimeTrackerWrapper();
			ttWrapper.strActivitySubType = 'Invalid Manual Activity';
			strToken = JSON.serialize( ttWrapper );
			strToken = ManualTimeTrackerCmpController.insertTimeTrackerWithManualLineItems( strToken );
			wrapper = ( ManualTimeTrackerCmpWrapper ) JSON.deserialize( strToken, ManualTimeTrackerCmpWrapper.class );
			System.assert( !wrapper.isSucceeded );
			
			// Tests with empty activity date time
			ttWrapper = new ManualTimeTrackerCmpWrapper.TimeTrackerWrapper();
			ttWrapper.strActivitySubType = 'Break';
			strToken = JSON.serialize( ttWrapper );
			strToken = ManualTimeTrackerCmpController.insertTimeTrackerWithManualLineItems( strToken );
			wrapper = ( ManualTimeTrackerCmpWrapper ) JSON.deserialize( strToken, ManualTimeTrackerCmpWrapper.class );
			System.assert( !wrapper.isSucceeded );
			
			// Tests with invalid activity date time
			ttWrapper = new ManualTimeTrackerCmpWrapper.TimeTrackerWrapper();
			ttWrapper.strActivitySubType = 'Break';
			ttWrapper.strActivityDateTime = 'invalid activity date time';
			strToken = JSON.serialize( ttWrapper );
			strToken = ManualTimeTrackerCmpController.insertTimeTrackerWithManualLineItems( strToken );
			wrapper = ( ManualTimeTrackerCmpWrapper ) JSON.deserialize( strToken, ManualTimeTrackerCmpWrapper.class );
			System.assert( !wrapper.isSucceeded );
			
			// Tests with valid details but no manual entries
			ttWrapper = new ManualTimeTrackerCmpWrapper.TimeTrackerWrapper();
			ttWrapper.strTrackedTime = '00:00:15';
			ttWrapper.strTrackedDuration = '15';
			ttWrapper.strActivityDateTime = '06/18/2018 02:35 PM';
			ttWrapper.strActivitySubType = 'Break';
			ttWrapper.strObjectId = recordCase.Id;
			ttWrapper.strComments = 'Test';
			strToken = JSON.serialize( ttWrapper );
			strToken = ManualTimeTrackerCmpController.insertTimeTrackerWithManualLineItems( strToken );
			wrapper = ( ManualTimeTrackerCmpWrapper ) JSON.deserialize( strToken, ManualTimeTrackerCmpWrapper.class );
			System.assert( wrapper.isSucceeded );
			
			// Tests with valid details
			ttWrapper = new ManualTimeTrackerCmpWrapper.TimeTrackerWrapper();
			ttWrapper.strTrackedTime = '00:00:15';
			ttWrapper.strTrackedDuration = '15';
			ttWrapper.strActivityDateTime = '06/18/2018 02:35 PM';
			ttWrapper.strActivitySubType = 'Break';
			ttWrapper.strObjectId = recordCase.Id;
			ttWrapper.strComments = 'Test';
			ttWrapper.listOfManualLineItems.add( new ManualLineItem__c
												 (
												  Disengage_Time__c = now,
												  Engage_Time__c = now.addSeconds( -15 )
												 )
											   );
			strToken = JSON.serialize( ttWrapper );
			strToken = ManualTimeTrackerCmpController.insertTimeTrackerWithManualLineItems( strToken );
			wrapper = ( ManualTimeTrackerCmpWrapper ) JSON.deserialize( strToken, ManualTimeTrackerCmpWrapper.class );
			
			Test.stopTest();
			System.assert( wrapper.isSucceeded );
        }
    }
}