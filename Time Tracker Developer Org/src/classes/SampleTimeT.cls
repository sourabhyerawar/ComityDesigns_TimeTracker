public class SampleTimeT {
    static Account acc;
    static Contact con;
    static Case caseObj;
    static opportunity oppObj;
    static User usr= [SELECT Id, LastName FROM User WHERE Id=: UserInfo.getUserId()];
    static DateTime dtNow = Datetime.now();
    static Id b4Stage;
    static Id tt2;
    static Id tt100;
    static Id tt300;
    static Id tt600;
    private static void init()
    {
        // method to install only new TimeTrackerConfigSettings records
        TimeTrackerTestHelper.insertRecordsFromStaticResource(TimeTrackerUtility.getNamespace()
            + 'TimeTrackerConfigSettings__c',
            'TimeTrackerConfigSettings_Records');
        System.assertNotEquals(0, TimeTrackerConfigSettings__c.getAll().values().size());

        TimeTrackerUserSettings__c userSet = new TimeTrackerUserSettings__c();
        userSet.Server_Debug_Level__c = 'Debug';
        insert userSet;
        System.assert(userSet.Id != null);
        
        acc = new Account(Name = 'Account Test Name');
        caseObj = new Case(Type = 'Other', Status = 'New', Origin = 'Phone');
        oppObj = new opportunity(StageName= 'Qualification', CloseDate = Date.today(), Name = 'Test opportunity' );
        con = new Contact(LastName = 'Test Lastname');
        insert acc;
        insert con;
        insert caseObj;
        insert oppObj;
        System.assert(acc.Id != null && caseObj.id != null);
    }
    private static void test_Simple()
    {
        init();

        Time_Tracker__c reviewtt13 = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(dtNow.addMinutes(10).getTime()), String.valueOf(dtNow.addMinutes(10).getTime()),
                                                                    TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(dtNow.getTime()), String.valueOf(dtNow.getTime()),
                                                                    caseObj.Id, '',  
                                                                    null, usr.Id);
        reviewtt13.Object_Id__c = caseObj.Id;
        reviewtt13.Duration__c = 100;
        reviewtt13.Parent_Object_Id__c = caseObj.Id;

        
        // This will execute GenericExcludeImpl
        insert reviewtt13;
        System.assert(reviewtt13.Id != null);
        tt100 = reviewtt13.Id;  
        //b4Stage = reviewtt13.Id;
        
        Time_Tracker__c reviewtt14_1 = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(dtNow.addMinutes(10).getTime()), String.valueOf(dtNow.addMinutes(10).getTime()),
                                                                    TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(dtNow.getTime()), String.valueOf(dtNow.getTime()),
                                                                    caseObj.Id, '',  
                                                                    null, usr.Id);
        reviewtt14_1.Object_Id__c = caseObj.Id;
        reviewtt14_1.Duration__c = 300;
        reviewtt14_1.Parent_Object_Id__c = caseObj.Id;

        
        // This will execute GenericExcludeImpl
        insert reviewtt14_1;
        System.assert(reviewtt14_1.Id != null);
        tt300 = reviewtt14_1.Id;
        
        Time_Tracker__c reviewtt14_2 = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(dtNow.addMinutes(10).getTime()), String.valueOf(dtNow.addMinutes(10).getTime()),
                                                                    TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(dtNow.getTime()), String.valueOf(dtNow.getTime()),
                                                                    caseObj.Id, '',  
                                                                    null, usr.Id);
        reviewtt14_2.Object_Id__c = caseObj.Id;
        reviewtt14_2.Duration__c = 600;
        reviewtt14_2.Parent_Object_Id__c = caseObj.Id;

        
        // This will execute GenericExcludeImpl
        insert reviewtt14_2;
        System.assert(reviewtt14_2.Id != null);
        tt600 = reviewtt14_2.Id;
        

        //Second-TT record
        Time_Tracker__c reviewtt2 = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(dtNow.addMinutes(10).getTime()), String.valueOf(dtNow.addMinutes(10).getTime()),
                                                                    TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(dtNow.getTime()), String.valueOf(dtNow.getTime()),
                                                                    caseObj.Id, '',  
                                                                    null, usr.Id);
        reviewtt2.Object_Id__c = caseObj.Id;
        reviewtt2.Duration__c = 600;
        reviewtt2.Parent_Object_Id__c = caseObj.Id;

        // This will execute GenericExcludeImpl
        insert reviewtt2;
        System.assert(reviewtt2.Id != null);
        tt2 = reviewtt2.Id;

        //TT record with 100-seconds Duration
        Time_Tracker__c reviewtt100 = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(dtNow.addMinutes(10).getTime()), String.valueOf(dtNow.addMinutes(10).getTime()),
                                                                    TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(dtNow.getTime()), String.valueOf(dtNow.getTime()),
                                                                    caseObj.Id, '',  
                                                                    null, usr.Id);
        reviewtt100.Object_Id__c = caseObj.Id;
        reviewtt100.Duration__c = 100;
        reviewtt100.Parent_Object_Id__c = caseObj.Id;

        // This will execute GenericExcludeImpl
        insert reviewtt100;
        System.assert(reviewtt100.Id != null);
        tt100 = reviewtt100.Id;        
    }
    
   /* private static void insertAA1_S17(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'AA1';
		stgRec.Start_Date__c = now.addMinutes(0);
		stgRec.End_Date__c= now.addMinutes(15);
		stgRec.TimeTracker_Associated__c = tt100;
		insert stgRec;
	}

	 private static void insertAA1_S14(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'AA1';
		stgRec.Start_Date__c = now.addMinutes(0);
		stgRec.End_Date__c= now.addMinutes(15);
		stgRec.TimeTracker_Associated__c = tt300;
		insert stgRec;
	}



	}**/
    
   
     private static void insertAA1_S13(){
    	TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'AA1';
		stgRec.Start_Date__c = now.addMinutes(0);
		stgRec.End_Date__c= now.addMinutes(15);
		stgRec.TimeTracker_Associated__c = tt100;
		insert stgRec;
    }
    
    private static void insertAA1_S14(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'AA1';
		stgRec.Start_Date__c = now.addMinutes(0);
		stgRec.End_Date__c= now.addMinutes(15);
		stgRec.TimeTracker_Associated__c = tt300;
		insert stgRec;
	}
    
    private static void insertAA2_S14(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'AA2';
		stgRec.Start_Date__c = now.addMinutes(5);
		stgRec.End_Date__c= now.addMinutes(15);
		stgRec.TimeTracker_Associated__c = tt600;
		insert stgRec;
	}
    
    private static void insertAA1_S15(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'AA1';
		stgRec.Start_Date__c = now.addMinutes(0);
		stgRec.End_Date__c= now.addMinutes(15);
		stgRec.TimeTracker_Associated__c = tt300;
		insert stgRec;
	}
    
    private static void insertAA2_S15(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'AA2';
		stgRec.Start_Date__c = now.addMinutes(5);
		stgRec.End_Date__c= now.addMinutes(15);
		stgRec.TimeTracker_Associated__c = tt600;
		insert stgRec;
	}
    
     private static void insertAA1_S16(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'AA1';
		stgRec.Start_Date__c = now.addMinutes(0);
		stgRec.End_Date__c= now.addMinutes(15);
		stgRec.TimeTracker_Associated__c = tt100;
		insert stgRec;
	}
    
    private static void insertAA2_S17(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'AA2';
		stgRec.Start_Date__c = now.addMinutes(5);
		stgRec.End_Date__c= now.addMinutes(15);
		stgRec.TimeTracker_Associated__c = tt600;
		insert stgRec;
	}
	
	private static Datetime now = System.now();
	    private static void insertChat1_S2(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat1';
		stgRec.Start_Date__c = now;
		stgRec.End_Date__c= now.addMinutes(15);
		insert stgRec;
	}
}