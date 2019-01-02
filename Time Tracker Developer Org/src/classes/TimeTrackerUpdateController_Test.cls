@isTest (SeeAllData = false)
//Unit-test for TimeTrackerUpdateController
public class TimeTrackerUpdateController_Test {
  private static User usr= [SELECT Id, LastName FROM User WHERE Id=: UserInfo.getUserId()];
  private static String caseId;
  private static Database.SaveResult sr = null;
  private static DateTime dtNow = Datetime.now();

    private static void setup()
    {  
        TimeTrackerUserSettings__c ttUserSettingsInstance = new TimeTrackerUserSettings__c
                            (
                                                     SetUpOwnerId = UserInfo.getProfileId(),
                                                     Is_Time_Tracker_Read_Only__c = TRUE,
                                                     ClientDebugLevel__c = 'INFO',
                                                     Max_Duration_In_Minutes__c = 100,
                                                     Server_Debug__c = TRUE,
                                                     Server_Debug_Level__c = 'INFO',
                                                     Weekly_Hours__c = 40   
                                                    );
    insert ttUserSettingsInstance;
        
    // method to install only new TimeTrackerConfigSettings records
    TimeTrackerTestHelper.insertRecordsFromStaticResource(TimeTrackerUtility.getNamespace()
      + 'TimeTrackerConfigSettings__c',
      'TimeTrackerConfigSettings_Records');
    System.assertNotEquals(0, TimeTrackerConfigSettings__c.getAll().values().size());
        
        //create a Case record
        Case newCase = new Case(OwnerId = usr.Id);
        //insert the Case record
        sr = Database.Insert(newCase, true);
        caseId = sr.getId();   
    }

    @isTest static void testManualTimeTracker() {
  
        setup();
      
        Integer rand = Crypto.getRandomInteger();
        rand = (rand < 0 ? rand * -1 : rand);
        String randomId = String.valueOf(rand);
              
        //Config-setting
        TimeTrackerTestHelper.insertRecordsFromStaticResource('TimeTrackerConfigSettings__c', 'TimeTrackerConfigSettings_Records');      

            
        Time_Tracker__c manualTTRec= TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(dtNow.getTime()), String.valueOf(dtNow.getTime()),
                                                                                TimeTrackerConstants.CASE_REVIEW_STR + ' End', String.valueOf(dtNow.addMinutes(-5).getTime()),String.valueOf(dtNow.addMinutes(-5).getTime()),
                                                                                caseId, caseId,  
                                                                                null, usr.Id);
        manualTTRec.Duration__c = 300;
        
        

        // insert the TimeTracker record with start action
        sr = Database.insert(manualTTRec);

        // ensure the TimeTracker record has an Id
        system.assertNotEquals(null, sr.getId());

        Test.startTest();
          PageReference pgRef = Page.TimeTrackerUpdate;
           Test.setCurrentPageReference (pgRef);
          ApexPages.StandardController stdTT = new ApexPages.StandardController(manualTTRec);
           TimeTrackerUpdateController myPgCont = new TimeTrackerUpdateController(stdTT);
          manualTTRec.Action__c = 'Email';
                        
          myPgCont.save();
      
          
        Test.stopTest();
       
        Time_Tracker__c activity = [SELECT Duration__c FROM Time_Tracker__c WHERE Id=: sr.getId()];
        system.assertEquals(300, activity.Duration__c);
    }
    
    @isTest static void testErrorMessage() {
        
        //Test error message when Opening_Action__c is null
       Time_Tracker__c manualTTRec1= TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.GENERAL_OTHER, String.valueOf(dtNow.getTime()), String.valueOf(dtNow.getTime()),
                                                                                TimeTrackerConstants.GENERAL_OTHER, String.valueOf(dtNow.addMinutes(-5).getTime()),String.valueOf(dtNow.addMinutes(-5).getTime()),
                                                                                caseId, caseId,  
                                                                                null, usr.Id);
       manualTTRec1.Duration__c = 20;
       manualTTRec1.Comment__c = 'Hello'; 
        // insert the TimeTracker record with start action
        sr = Database.insert(manualTTRec1);

        // ensure the TimeTracker record has an Id
        system.assertNotEquals(null, sr.getId());

        Test.startTest();
          PageReference pgRef = Page.TimeTrackerUpdate;
           Test.setCurrentPageReference (pgRef);
          ApexPages.StandardController stdTT = new ApexPages.StandardController(manualTTRec1);
           TimeTrackerUpdateController myPgCont = new TimeTrackerUpdateController(stdTT);
          //manualTTRec1.Action__c = 'Email';
          
        System.debug('myPgCont : '+myPgCont);
        System.debug('myPgCont opening action : '+myPgCont);
        
          myPgCont.save();
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
     System.assertNotEquals(0, pageMessages.size());
          
        Test.stopTest();
        
        //Test error message when activity is general other
    } 
}