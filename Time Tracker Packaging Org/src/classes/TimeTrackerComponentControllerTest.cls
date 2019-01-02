/**
    @ Purpose : Tests the functionality of the controller --> TimeTrackerComponentControlller.
*/

@isTest
public class TimeTrackerComponentControllerTest {
    
    /*
        @ Purpose : Inserts the data/records requiered for testing.
    */
    @TestSetup static void insertTestData() {
        
        integer intNoOfRecords = 0;
        List<TimeTrackerConfigSettings__c> listOfConfigSettings = new List<TimeTrackerConfigSettings__c>
                                                                  {
                                                                   new TimeTrackerConfigSettings__c
                                                                   (
                                                                    Name = 'STRATEGY_NEW_CASE', Type__c = 'Strategy',
                                                                    Code1__c = 'GenericTimeTrackerImpl',
                                                                    Text1__c = 'New Case', Text2__c = 'Case Work', 
                                                                    Text3__c = 'Case Documentation',
                                                                    IsActive__c = TRUE, Flag1__c = TRUE, Flag2__c = TRUE
                                                                   ),
                                                                   new TimeTrackerConfigSettings__c
                                                                   (
                                                                    Name = 'STRATEGY_CASE_REVIEW', Type__c  = 'Strategy',
                                                                    Code1__c = 'GenericExcludeImpl',
                                                                    Text1__c = 'Case Review', Text2__c = 'Case Work',
                                                                    Text3__c = 'Case Documentation',
                                                                    Text5__c = 'New Case; Edit Case;',
                                                                    IsActive__c = TRUE, Flag1__c = TRUE, Flag2__c = TRUE
                                                                   )
                                                                  };
        intNoOfRecords = listOfConfigSettings.size();
        insert listOfConfigSettings;
        System.assertEquals( intNoOfRecords, [ SELECT COUNT() FROM TimeTrackerConfigSettings__c WHERE Type__c = 'Strategy' ] );
        
        listOfConfigSettings = new List<TimeTrackerConfigSettings__c>
                              {
                               new TimeTrackerConfigSettings__c
                               (
                                Name = 'MISCELLANEOUS_JS_ConsoleError', Type__c = 'Miscellaneous',
                                Code1__c = 'background: #970e02;color:#FFF;padding:5px;border-radius: 5px;line-height: 20px;',
                                IsActive__c = TRUE
                               ),
                               new TimeTrackerConfigSettings__c
                               (
                                Name = 'MISCELLANEOUS_JS_ConsoleInfo', Type__c  = 'Miscellaneous',
                                Code1__c = 'background: #3F51B5;color:#FFF;padding:5px;border-radius: 5px;line-height: 20px;',
                                IsActive__c = TRUE
                               ),
                               new TimeTrackerConfigSettings__c
                               (
                                Name = 'MISCELLANEOUS_JS_ConsoleLog', Type__c   = 'Miscellaneous',
                                Code1__c = 'background: #4ab471;color:#FFF;padding:5px;border-radius: 5px;line-height: 20px;',
                                IsActive__c = TRUE
                               ),
                               new TimeTrackerConfigSettings__c
                               (
                                Name = 'MISCELLANEOUS_JS_ConsoleSF', Type__c    = 'Miscellaneous',
                                Code1__c = 'background: #fcad02;color:#FFF;padding:5px;border-radius: 5px;line-height: 20px;',
                                IsActive__c = TRUE
                               )
                              };
        intNoOfRecords = listOfConfigSettings.size();
        insert listOfConfigSettings;
        System.assertEquals( intNoOfRecords, [ SELECT COUNT() FROM TimeTrackerConfigSettings__c WHERE Type__c = 'Miscellaneous' ] );
    }
    
    /*
        @ Purpose : Tests the functionality of getting object details and custom settings.
    */
    public static TestMethod void testGetObjectDetailsAndCustomSettings() {

        String strJsonSettings;
        TimeTrackerComponentWrapper wrapper;
        TimeTrackerComponentWrapper.ObjectWrapper objWrapper;

        Test.startTest();       
		
        // Covers code for instances declared.
        wrapper = new TimeTrackerComponentWrapper();
        objWrapper = new TimeTrackerComponentWrapper.ObjectWrapper();
		        
        // Tests with valid data.
        strJsonSettings = TimeTrackerComponentController.getObjectDetailsAndCustomSettings();
        wrapper = ( TimeTrackerComponentWrapper ) JSON.deserialize( strJsonSettings, TimeTrackerComponentWrapper.class );
        
        System.assertNotEquals( 0, wrapper.listOfStrategySettings.size() );
        System.assertNotEquals( 0, wrapper.listOfMiscellaneousSettings.size() );
        System.assertNotEquals( 0, wrapper.listOfObjectWrappers.size() );
		
        Test.stopTest();

        System.assertEquals( TRUE, wrapper.isSucceeded );
    }
    
    /*
        @ Purpose : Tests the functionality of inserting time tracker record.
    */
    public static TestMethod void testInsertTimeTracker() {

        String strJsonTimeTracker, strDocumentId;
        TimeTrackerComponentWrapper wrapper;
        Time_Tracker__c ttRecord;
        DateTime dt = DateTime.now();

        Test.startTest();       

        // Tests with no record.
        strJsonTimeTracker = TimeTrackerComponentController.insertTimeTracker( NULL );
        wrapper = ( TimeTrackerComponentWrapper ) JSON.deserialize( strJsonTimeTracker, TimeTrackerComponentWrapper.class );
        System.assertEquals( FALSE, wrapper.isSucceeded );
        
        // Tests with 'null' record.
        strJsonTimeTracker = TimeTrackerComponentController.insertTimeTracker( JSON.serialize( ttRecord ) );
        wrapper = ( TimeTrackerComponentWrapper ) JSON.deserialize( strJsonTimeTracker, TimeTrackerComponentWrapper.class );
        System.assertEquals( FALSE, wrapper.isSucceeded );
        
        // Tests with empty record.
        ttRecord = new Time_Tracker__c();
        strJsonTimeTracker = TimeTrackerComponentController.insertTimeTracker( JSON.serialize( ttRecord ) );
        wrapper = ( TimeTrackerComponentWrapper ) JSON.deserialize( strJsonTimeTracker, TimeTrackerComponentWrapper.class );
        System.assertEquals( TRUE, wrapper.isSucceeded );
        
        // Tests with opening record
        strDocumentId = '8659b5b2-4948-4ce1-957b-ad5083bd2ad8';
        ttRecord = new Time_Tracker__c
                   (
                    Action__c = 'New Case',
                    Activity_Date__c = dt,
                    Activity_Time__c = dt.getTime(),
                    DocumentId__c = strDocumentId,
                    Source__c = 'Lightning Component'
                   );
        strJsonTimeTracker = TimeTrackerComponentController.insertTimeTracker( JSON.serialize( ttRecord ) );
        wrapper = ( TimeTrackerComponentWrapper ) JSON.deserialize( strJsonTimeTracker, TimeTrackerComponentWrapper.class );
        System.assertEquals( TRUE, wrapper.isSucceeded );
        
        // Tests with closing record
        dt.addSeconds( 60 );
        ttRecord = new Time_Tracker__c
                   (
                    Action__c = 'Case Save',
                    Activity_Date__c = dt,
                    Activity_Time__c = dt.getTime(),
                    Opening_Activity_Time__c = wrapper.ttRecord.Activity_Time__c,
                    Duration__c = ( dt.getTime() - wrapper.ttRecord.Activity_Time__c ) * 0.001,
                    DocumentId__c = strDocumentId,
                    Opening_Action__c = 'New Case',
                    Source__c = 'Lightning Component'
                   );
        strJsonTimeTracker = TimeTrackerComponentController.insertTimeTracker( JSON.serialize( ttRecord ) );
        wrapper = ( TimeTrackerComponentWrapper ) JSON.deserialize( strJsonTimeTracker, TimeTrackerComponentWrapper.class );
        System.assertEquals( TRUE, wrapper.isSucceeded );
        
        Test.stopTest();

        System.assertNotEquals( 0, [ SELECT COUNT() FROM Time_Tracker__c 
                                     WHERE DocumentId__c =: strDocumentId 
                                     AND 
                                     Duration__c != NULL 
                                   ] 
                              );
    }
}