@isTest(SeeAllData=false)
private class TimeTrackerStagingLineItemHelperTest {

    static Account acc;
    static Contact con;
    static Case caseObj;
    static opportunity oppObj;
    static User usr= [SELECT Id, LastName FROM User WHERE Id=: UserInfo.getUserId()];
    private static Datetime now = System.now();
    static Id tt1_900_S5toS12;
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
    private static void create_TT_S5toS12()
    {
        init();

        Time_Tracker__c reviewtt = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(now.addMinutes(10).getTime()), String.valueOf(now.addMinutes(10).getTime()),
                                                                    TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(now.getTime()), String.valueOf(now.getTime()),
                                                                    caseObj.Id, '',  
                                                                    null, usr.Id);
        reviewtt.Object_Id__c = caseObj.Id;
        reviewtt.Duration__c = 900;
        reviewtt.Parent_Object_Id__c = caseObj.Id;

        // This will execute GenericExcludeImpl
        insert reviewtt;
        System.assert(reviewtt.Id != null);
        tt1_900_S5toS12 = reviewtt.Id;    
    }

	//**********Scenario Test-data 1*****************
	private static void insertChat0_S1(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat0';
		stgRec.Start_Date__c = now;
		stgRec.End_Date__c= now.addMinutes(1);
		insert stgRec;
	}	
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
	private static void insertChat3_S1(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat3';
		stgRec.Start_Date__c = now.addMinutes(4);
		stgRec.End_Date__c= now.addMinutes(11);
		insert stgRec;
	}
	private static void insertChat4_S1(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat4';
		stgRec.Start_Date__c = now.addMinutes(6);
		stgRec.End_Date__c= now.addMinutes(7);
		insert stgRec;
	}
	private static void insertChat5_S1(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat5';
		stgRec.Start_Date__c = now.addMinutes(8);
		stgRec.End_Date__c= now.addMinutes(16);
		insert stgRec;
	}
	private static void insertChat6_S1(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat6';
		stgRec.Start_Date__c = now.addMinutes(9);
		stgRec.End_Date__c= now.addMinutes(14);
		insert stgRec;
	}
	private static void insertChat7_S1(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat7';
		stgRec.Start_Date__c = now.addMinutes(10);
		stgRec.End_Date__c= now.addMinutes(12);
		insert stgRec;
	}
	private static void insertChat8_S1(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat8';
		stgRec.Start_Date__c = now.addMinutes(13);
		stgRec.End_Date__c= now.addMinutes(15);
		insert stgRec;
	}

	private static void setUpData_S1(){
		insertChat0_S1();
		insertChat1_S1();
		insertChat2_S1();
		insertChat3_S1();
		insertChat4_S1();
		insertChat5_S1();
		insertChat6_S1();
		insertChat7_S1();
		insertChat8_S1();
	}

	@isTest static void Test_excludeStagingLineItemTime_Scenario1(){
	 	setUpData_S1();

	 	List<TimeTracker_StagingLineItem__c> stagingRecords = [SELECT Id, Name,OwnerId,Activity_Name__c,End_Date__c,Start_Date__c,Object_Name__c,Object_Id__c,TimeTracker_Associated__c
	 															FROM TimeTracker_StagingLineItem__c
	 															WHERE CreatedDate > YESTERDAY
	 															ORDER BY Start_Date__c];
															
	 	Map<Id,Time_Tracker__c> ttRecordsToInsert = TimeTrackerStagingLineItemHelper.getTimeTrackersInsertList(stagingRecords);	
	 	System.assertEquals(stagingRecords.size(),ttRecordsToInsert.size());

	 	Integer passCount = 0;
	 	for(TimeTracker_StagingLineItem__c stgRec : stagingRecords){
	 		if(stgRec.Activity_Name__c=='Chat0'){
	 			System.assertEquals(60, ttRecordsToInsert.get(stgRec.Id).Duration__c);
	 			passCount++;
	 		} else if(stgRec.Activity_Name__c=='Chat1'){
	 			System.assertEquals(120, ttRecordsToInsert.get(stgRec.Id).Duration__c);
	 			passCount++;
	 		} else if(stgRec.Activity_Name__c=='Chat2'){
	 			System.assertEquals(60, ttRecordsToInsert.get(stgRec.Id).Duration__c);
	 			passCount++;
	 		} else if(stgRec.Activity_Name__c=='Chat3'){
	 			System.assertEquals(180, ttRecordsToInsert.get(stgRec.Id).Duration__c);
	 			passCount++;
	 		} else if(stgRec.Activity_Name__c=='Chat4'){
	 			System.assertEquals(60, ttRecordsToInsert.get(stgRec.Id).Duration__c);
	 			passCount++;
	 		} else if(stgRec.Activity_Name__c=='Chat5'){
	 			System.assertEquals(120, ttRecordsToInsert.get(stgRec.Id).Duration__c);
	 			passCount++;
	 		} else if(stgRec.Activity_Name__c=='Chat6'){
	 			System.assertEquals(120, ttRecordsToInsert.get(stgRec.Id).Duration__c);
	 			passCount++;
	 		} else if(stgRec.Activity_Name__c=='Chat7'){
	 			System.assertEquals(120, ttRecordsToInsert.get(stgRec.Id).Duration__c);
	 			passCount++;
	 		} else if(stgRec.Activity_Name__c=='Chat8'){
	 			System.assertEquals(120, ttRecordsToInsert.get(stgRec.Id).Duration__c);
	 			passCount++;
	 		}
	 	}

	 	System.assertEquals(stagingRecords.size(),passCount);
	} 

	//**********Scenario Test-data 2*****************

	private static void insertChat1_S2(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat1';
		stgRec.Start_Date__c = now;
		stgRec.End_Date__c= now.addMinutes(15);
		insert stgRec;
	}
	private static void insertChat2_S2(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat2';
		stgRec.Start_Date__c = now.addMinutes(5);
		stgRec.End_Date__c= now.addMinutes(12);
		insert stgRec;
	}
	private static void insertChat3_S2(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat3';
		stgRec.Start_Date__c = now.addMinutes(10);
		stgRec.End_Date__c= now.addMinutes(60);
		insert stgRec;
	}
	private static void insertChat4_S2(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat4';
		stgRec.Start_Date__c = now.addMinutes(15);
		stgRec.End_Date__c= now.addMinutes(20);
		insert stgRec;
	}
	private static void insertChat5_S2(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat5';
		stgRec.Start_Date__c = now.addMinutes(25);
		stgRec.End_Date__c= now.addMinutes(40);
		insert stgRec;
	}
	private static void insertChat6_S2(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat6';
		stgRec.Start_Date__c = now.addMinutes(35);
		stgRec.End_Date__c= now.addMinutes(50);
		insert stgRec;
	}
	private static void insertChat7_S2(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat7';
		stgRec.Start_Date__c = now.addMinutes(40);
		stgRec.End_Date__c= now.addMinutes(45);
		insert stgRec;
	}
	private static void insertChat8_S2(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat8';
		stgRec.Start_Date__c = now.addMinutes(55);
		stgRec.End_Date__c= now.addMinutes(70);
		insert stgRec;
	}

	private static void setUpData_S2(){
		insertChat1_S2();
		insertChat2_S2();
		insertChat3_S2();
		insertChat4_S2();
		insertChat5_S2();
		insertChat6_S2();
		insertChat7_S2();
		insertChat8_S2();
	}

	@isTest static void Test_excludeStagingLineItemTime_Scenario2(){
	 	setUpData_S2();

	 	List<TimeTracker_StagingLineItem__c> stagingRecords = [SELECT Id, Name,OwnerId,Activity_Name__c,End_Date__c,Start_Date__c,Object_Name__c,Object_Id__c,TimeTracker_Associated__c
	 															FROM TimeTracker_StagingLineItem__c
	 															WHERE CreatedDate > YESTERDAY
	 															ORDER BY Start_Date__c];
															
	 	Map<Id,Time_Tracker__c> ttRecordsToInsert = TimeTrackerStagingLineItemHelper.getTimeTrackersInsertList(stagingRecords);	
	 	System.assertEquals(stagingRecords.size(),ttRecordsToInsert.size());

	 	Integer passCount = 0;
	 	for(TimeTracker_StagingLineItem__c stgRec : stagingRecords){
	 		if(stgRec.Activity_Name__c=='Chat1'){
	 			System.assertEquals(300, ttRecordsToInsert.get(stgRec.Id).Duration__c);
	 			passCount++;
	 		} else if(stgRec.Activity_Name__c=='Chat2'){
	 			System.assertEquals(300, ttRecordsToInsert.get(stgRec.Id).Duration__c);
	 			passCount++;
	 		} else if(stgRec.Activity_Name__c=='Chat3'){
	 			System.assertEquals(900, ttRecordsToInsert.get(stgRec.Id).Duration__c);
	 			passCount++;
	 		} else if(stgRec.Activity_Name__c=='Chat4'){
	 			System.assertEquals(300, ttRecordsToInsert.get(stgRec.Id).Duration__c);
	 			passCount++;
	 		} else if(stgRec.Activity_Name__c=='Chat5'){
	 			System.assertEquals(600, ttRecordsToInsert.get(stgRec.Id).Duration__c);
	 			passCount++;
	 		} else if(stgRec.Activity_Name__c=='Chat6'){
	 			System.assertEquals(600, ttRecordsToInsert.get(stgRec.Id).Duration__c);
	 			passCount++;
	 		} else if(stgRec.Activity_Name__c=='Chat7'){
	 			System.assertEquals(300, ttRecordsToInsert.get(stgRec.Id).Duration__c);
	 			passCount++;
	 		} else if(stgRec.Activity_Name__c=='Chat8'){
	 			System.assertEquals(900, ttRecordsToInsert.get(stgRec.Id).Duration__c);
	 			passCount++;
	 		}
	 	}

	 	System.assertEquals(stagingRecords.size(),passCount);
	}


	//**********Scenario Test-data 3*****************
	private static void insertChat1_S3(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat1';
		stgRec.Start_Date__c = now.addMinutes(0);
		stgRec.End_Date__c= now.addMinutes(35);
		insert stgRec;
	}
	private static void insertChat2_S3(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat2';
		stgRec.Start_Date__c = now.addMinutes(5);
		stgRec.End_Date__c= now.addMinutes(15);
		insert stgRec;
	}
	private static void insertChat3_S3(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat3';
		stgRec.Start_Date__c = now.addMinutes(10);
		stgRec.End_Date__c= now.addMinutes(25);
		insert stgRec;
	}
	private static void insertChat4_S3(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat4';
		stgRec.Start_Date__c = now.addMinutes(20);
		stgRec.End_Date__c= now.addMinutes(30);
		insert stgRec;
	}		
	private static void setUpData_S3(){
		insertChat1_S3();
		insertChat2_S3();
		insertChat3_S3();
		insertChat4_S3();
	}

	@isTest static void Test_excludeStagingLineItemTime_Scenario3(){
	 	setUpData_S3();

	 	List<TimeTracker_StagingLineItem__c> stagingRecords = [SELECT Id, Name,OwnerId,Activity_Name__c,End_Date__c,Start_Date__c,Object_Name__c,Object_Id__c,TimeTracker_Associated__c
	 															FROM TimeTracker_StagingLineItem__c
	 															WHERE CreatedDate > YESTERDAY
	 															ORDER BY Start_Date__c];
															
	 	Map<Id,Time_Tracker__c> ttRecordsToInsert = TimeTrackerStagingLineItemHelper.getTimeTrackersInsertList(stagingRecords);	
	 	System.assertEquals(stagingRecords.size(),ttRecordsToInsert.size());

	 	Integer passCount = 0;
	 	for(TimeTracker_StagingLineItem__c stgRec : stagingRecords){
	 		if(stgRec.Activity_Name__c=='Chat1'){
	 			System.assertEquals(600, ttRecordsToInsert.get(stgRec.Id).Duration__c);
	 			passCount++;
	 		} else if(stgRec.Activity_Name__c=='Chat2'){
	 			System.assertEquals(300, ttRecordsToInsert.get(stgRec.Id).Duration__c);
	 			passCount++;
	 		} else if(stgRec.Activity_Name__c=='Chat3'){
	 			System.assertEquals(600, ttRecordsToInsert.get(stgRec.Id).Duration__c);
	 			passCount++;
	 		} else if(stgRec.Activity_Name__c=='Chat4'){
	 			System.assertEquals(600, ttRecordsToInsert.get(stgRec.Id).Duration__c);
	 			passCount++;
	 		}
	 	}

	 	System.assertEquals(stagingRecords.size(),passCount);
	}


	//**********Scenario Test-data 4*****************
	private static void insertChat1_S4(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat1';
		stgRec.Start_Date__c = now.addMinutes(0);
		stgRec.End_Date__c= now.addMinutes(30);
		insert stgRec;
	}
	private static void insertChat2_S4(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat2';
		stgRec.Start_Date__c = now.addMinutes(5);
		stgRec.End_Date__c= now.addMinutes(20);
		insert stgRec;
	}
	private static void insertChat3_S4(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat3';
		stgRec.Start_Date__c = now.addMinutes(10);
		stgRec.End_Date__c= now.addMinutes(35);
		insert stgRec;
	}
	private static void insertChat4_S4(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat4';
		stgRec.Start_Date__c = now.addMinutes(15);
		stgRec.End_Date__c= now.addMinutes(40);
		insert stgRec;
	}
	private static void setUpData_S4(){
		insertChat1_S4();
		insertChat2_S4();
		insertChat3_S4();
		insertChat4_S4();
	}

	@isTest static void Test_excludeStagingLineItemTime_Scenario4(){
	 	setUpData_S4();

	 	List<TimeTracker_StagingLineItem__c> stagingRecords = [SELECT Id, Name,OwnerId,Activity_Name__c,End_Date__c,Start_Date__c,Object_Name__c,Object_Id__c,TimeTracker_Associated__c
	 															FROM TimeTracker_StagingLineItem__c
	 															WHERE CreatedDate > YESTERDAY
	 															ORDER BY Start_Date__c];
															
	 	Map<Id,Time_Tracker__c> ttRecordsToInsert = TimeTrackerStagingLineItemHelper.getTimeTrackersInsertList(stagingRecords);	
	 	System.assertEquals(stagingRecords.size(),ttRecordsToInsert.size());

	 	Integer passCount = 0;
	 	for(TimeTracker_StagingLineItem__c stgRec : stagingRecords){
	 		if(stgRec.Activity_Name__c=='Chat1'){
	 			System.assertEquals(300, ttRecordsToInsert.get(stgRec.Id).Duration__c);
	 			passCount++;
	 		} else if(stgRec.Activity_Name__c=='Chat2'){
	 			System.assertEquals(300, ttRecordsToInsert.get(stgRec.Id).Duration__c);
	 			passCount++;
	 		} else if(stgRec.Activity_Name__c=='Chat3'){
	 			System.assertEquals(300, ttRecordsToInsert.get(stgRec.Id).Duration__c);
	 			passCount++;
	 		} else if(stgRec.Activity_Name__c=='Chat4'){
	 			System.assertEquals(1500, ttRecordsToInsert.get(stgRec.Id).Duration__c);
	 			passCount++;
	 		}
	 	}
	 	System.assertEquals(stagingRecords.size(),passCount);
	}

	//********************Scenario-5**************************    
	private static void insertAA1_S5(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'AA1';
		stgRec.Start_Date__c = now.addMinutes(10);
		stgRec.End_Date__c= now.addMinutes(25);
		stgRec.TimeTracker_Associated__c = tt1_900_S5toS12;
		insert stgRec;
	}
	private static void insertChat1_S5(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat1';
		stgRec.Start_Date__c = now.addMinutes(0);
		stgRec.End_Date__c= now.addMinutes(10);
		insert stgRec;
	}
	private static void insertChat2_S5(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat2';
		stgRec.Start_Date__c = now.addMinutes(25);
		stgRec.End_Date__c= now.addMinutes(35);
		insert stgRec;
	}
	private static void setUpData_S5(){
        create_TT_S5toS12();
		insertAA1_S5();
		insertChat1_S5();
		insertChat2_S5();
	}
	@isTest static void Test_excludeStagingLineItemTime_Scenario5(){
	 	setUpData_S5();

	 	List<TimeTracker_StagingLineItem__c> stagingRecords = [SELECT Id, Name,OwnerId,Activity_Name__c,End_Date__c,Start_Date__c,Object_Name__c,Object_Id__c,TimeTracker_Associated__c
	 															FROM TimeTracker_StagingLineItem__c
	 															WHERE CreatedDate > YESTERDAY
	 															ORDER BY Start_Date__c];		
	 	Map<Id,Time_Tracker__c> ttRecordsToInsert = TimeTrackerStagingLineItemHelper.getTimeTrackersInsertList(stagingRecords);	
	 	System.assertEquals(stagingRecords.size(),ttRecordsToInsert.size());

	 	Integer passCount = 0;        
        for(Time_Tracker__c ttRec: ttRecordsToInsert.values()){
            if(ttRec.Id == tt1_900_S5toS12){
                system.assertEquals(900, ttRec.Duration__c);
                passCount++;
            }else if(ttRec.Action__c=='Chat1'){
                system.assertEquals(600, ttRec.Duration__c);
                passCount++;
            }else if(ttRec.Action__c=='Chat2'){
                system.assertEquals(600, ttRec.Duration__c);
                passCount++;
            }
        }
	 	System.assertEquals(stagingRecords.size(), passCount);	 	
	}

	//********************Scenario-6**************************    
	private static void insertAA1_S6(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'AA1';
		stgRec.Start_Date__c = now.addMinutes(10);
		stgRec.End_Date__c= now.addMinutes(25);
		stgRec.TimeTracker_Associated__c = tt1_900_S5toS12;
		insert stgRec;
	}
	private static void insertChat1_S6(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat1';
		stgRec.Start_Date__c = now.addMinutes(0);
		stgRec.End_Date__c= now.addMinutes(15);
		insert stgRec;
	}
	private static void insertChat2_S6(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat2';
		stgRec.Start_Date__c = now.addMinutes(5);
		stgRec.End_Date__c= now.addMinutes(20);
		insert stgRec;
	}
	private static void setUpData_S6(){
        create_TT_S5toS12();
		insertAA1_S6();
		insertChat1_S6();
		insertChat2_S6();
	}
	@isTest static void Test_excludeStagingLineItemTime_Scenario6(){
	 	setUpData_S6();

	 	List<TimeTracker_StagingLineItem__c> stagingRecords = [SELECT Id, Name,OwnerId,Activity_Name__c,End_Date__c,Start_Date__c,Object_Name__c,Object_Id__c,TimeTracker_Associated__c
	 															FROM TimeTracker_StagingLineItem__c
	 															WHERE CreatedDate > YESTERDAY
	 															ORDER BY Start_Date__c];		
	 	Map<Id,Time_Tracker__c> ttRecordsToInsert = TimeTrackerStagingLineItemHelper.getTimeTrackersInsertList(stagingRecords);	
	 	System.assertEquals(stagingRecords.size(),ttRecordsToInsert.size());

	 	Integer passCount = 0;        
        for(Time_Tracker__c ttRec: ttRecordsToInsert.values()){
            if(ttRec.Id == tt1_900_S5toS12){
                system.assertEquals(300, ttRec.Duration__c);
                passCount++;
            }else if(ttRec.Action__c=='Chat1'){
                system.assertEquals(300, ttRec.Duration__c);
                passCount++;
            }else if(ttRec.Action__c=='Chat2'){
                system.assertEquals(900, ttRec.Duration__c);
                passCount++;
            }
        }
	 	System.assertEquals(stagingRecords.size(), passCount);	 	
	}    
	//********************Scenario-7**************************    
	private static void insertAA1_S7(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'AA1';
		stgRec.Start_Date__c = now.addMinutes(10);
		stgRec.End_Date__c= now.addMinutes(25);
		stgRec.TimeTracker_Associated__c = tt1_900_S5toS12;
		insert stgRec;
	}
	private static void insertChat1_S7(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat1';
		stgRec.Start_Date__c = now.addMinutes(0);
		stgRec.End_Date__c= now.addMinutes(20);
		insert stgRec;
	}
	private static void insertChat2_S7(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat2';
		stgRec.Start_Date__c = now.addMinutes(5);
		stgRec.End_Date__c= now.addMinutes(15);
		insert stgRec;
	}
	private static void setUpData_S7(){
        create_TT_S5toS12();
		insertAA1_S7();
		insertChat1_S7();
		insertChat2_S7();
	}
	@isTest static void Test_excludeStagingLineItemTime_Scenario7(){
	 	setUpData_S7();

	 	List<TimeTracker_StagingLineItem__c> stagingRecords = [SELECT Id, Name,OwnerId,Activity_Name__c,End_Date__c,Start_Date__c,Object_Name__c,Object_Id__c,TimeTracker_Associated__c
	 															FROM TimeTracker_StagingLineItem__c
	 															WHERE CreatedDate > YESTERDAY
	 															ORDER BY Start_Date__c];		
	 	Map<Id,Time_Tracker__c> ttRecordsToInsert = TimeTrackerStagingLineItemHelper.getTimeTrackersInsertList(stagingRecords);	
	 	System.assertEquals(stagingRecords.size(),ttRecordsToInsert.size());

	 	Integer passCount = 0;        
        for(Time_Tracker__c ttRec: ttRecordsToInsert.values()){
            if(ttRec.Id == tt1_900_S5toS12){
                system.assertEquals(300, ttRec.Duration__c);
                passCount++;
            }else if(ttRec.Action__c=='Chat1'){
                system.assertEquals(600, ttRec.Duration__c);
                passCount++;
            }else if(ttRec.Action__c=='Chat2'){
                system.assertEquals(600, ttRec.Duration__c);
                passCount++;
            }
        }
	 	System.assertEquals(stagingRecords.size(), passCount);	 	
	}

    //***********Scenario-8*******************
    private static void insertAA1_S8(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'AA1';
		stgRec.Start_Date__c = now.addMinutes(5);
		stgRec.End_Date__c= now.addMinutes(20);
		stgRec.TimeTracker_Associated__c = tt1_900_S5toS12;
		insert stgRec;
	}
	private static void insertChat1_S8(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat1';
		stgRec.Start_Date__c = now.addMinutes(0);
		stgRec.End_Date__c= now.addMinutes(25);
		insert stgRec;
	}
	private static void setUpData_S8(){
        create_TT_S5toS12();
		insertAA1_S8();
		insertChat1_S8();
    }
	@isTest static void Test_excludeStagingLineItemTime_Scenario8(){
	 	setUpData_S8();

	 	List<TimeTracker_StagingLineItem__c> stagingRecords = [SELECT Id, Name,OwnerId,Activity_Name__c,End_Date__c,Start_Date__c,Object_Name__c,Object_Id__c,TimeTracker_Associated__c
	 															FROM TimeTracker_StagingLineItem__c
	 															WHERE CreatedDate > YESTERDAY
	 															ORDER BY Start_Date__c];		
	 	Map<Id,Time_Tracker__c> ttRecordsToInsert = TimeTrackerStagingLineItemHelper.getTimeTrackersInsertList(stagingRecords);	
	 	System.assertEquals(stagingRecords.size(),ttRecordsToInsert.size());

	 	Integer passCount = 0;        
        for(Time_Tracker__c ttRec: ttRecordsToInsert.values()){
            if(ttRec.Id == tt1_900_S5toS12){
                system.assertEquals(1, ttRec.Duration__c);
                passCount++;
            }else if(ttRec.Action__c=='Chat1'){
                system.assertEquals(1500, ttRec.Duration__c);
                passCount++;
            }
        }
	 	System.assertEquals(stagingRecords.size(), passCount);	
	}

    //***********Scenario-9*******************
    private static void insertAA1_S9(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'AA1';
		stgRec.Start_Date__c = now.addMinutes(0);
		stgRec.End_Date__c= now.addMinutes(15);
		stgRec.TimeTracker_Associated__c = tt1_900_S5toS12;
		insert stgRec;
	}
	private static void insertChat1_S9(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat1';
		stgRec.Start_Date__c = now.addMinutes(0);
		stgRec.End_Date__c= now.addMinutes(15);
		insert stgRec;
	}
	private static void setUpData_S9(){
        create_TT_S5toS12();
		insertAA1_S9();
		insertChat1_S9();
    }
	@isTest static void Test_excludeStagingLineItemTime_Scenario9(){
	 	setUpData_S9();

	 	List<TimeTracker_StagingLineItem__c> stagingRecords = [SELECT Id, Name,OwnerId,Activity_Name__c,End_Date__c,Start_Date__c,Object_Name__c,Object_Id__c,TimeTracker_Associated__c
	 															FROM TimeTracker_StagingLineItem__c
	 															WHERE CreatedDate > YESTERDAY
	 															ORDER BY Start_Date__c];		
	 	Map<Id,Time_Tracker__c> ttRecordsToInsert = TimeTrackerStagingLineItemHelper.getTimeTrackersInsertList(stagingRecords);	
	 	System.assertEquals(stagingRecords.size(),ttRecordsToInsert.size());

	 	Integer passCount = 0;        
        for(Time_Tracker__c ttRec: ttRecordsToInsert.values()){
            if(ttRec.Id == tt1_900_S5toS12){
                system.assertEquals(1, ttRec.Duration__c);
                passCount++;
            }else if(ttRec.Action__c=='Chat1'){
                system.assertEquals(900, ttRec.Duration__c);
                passCount++;
            }
        }
	 	System.assertEquals(stagingRecords.size(), passCount);	 	
	}

    //***********Scenario-10*******************
    private static void insertAA1_S10(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'AA1';
		stgRec.Start_Date__c = now.addMinutes(0);
		stgRec.End_Date__c= now.addMinutes(15);
		stgRec.TimeTracker_Associated__c = tt1_900_S5toS12;
		insert stgRec;
	}
	private static void insertChat1_S10(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat1';
		stgRec.Start_Date__c = now.addMinutes(5);
		stgRec.End_Date__c= now.addMinutes(20);
		insert stgRec;
	}
	private static void setUpData_S10(){
        create_TT_S5toS12();
		insertAA1_S10();
		insertChat1_S10();
    }
	@isTest static void Test_excludeStagingLineItemTime_Scenario10(){
	 	setUpData_S10();

	 	List<TimeTracker_StagingLineItem__c> stagingRecords = [SELECT Id, Name,OwnerId,Activity_Name__c,End_Date__c,Start_Date__c,Object_Name__c,Object_Id__c,TimeTracker_Associated__c
	 															FROM TimeTracker_StagingLineItem__c
	 															WHERE CreatedDate > YESTERDAY
	 															ORDER BY Start_Date__c];		
	 	Map<Id,Time_Tracker__c> ttRecordsToInsert = TimeTrackerStagingLineItemHelper.getTimeTrackersInsertList(stagingRecords);	
	 	System.assertEquals(stagingRecords.size(),ttRecordsToInsert.size());

	 	Integer passCount = 0;        
        for(Time_Tracker__c ttRec: ttRecordsToInsert.values()){
            if(ttRec.Id == tt1_900_S5toS12){
                system.assertEquals(300, ttRec.Duration__c);
                passCount++;
            }else if(ttRec.Action__c=='Chat1'){
                system.assertEquals(900, ttRec.Duration__c);
                passCount++;
            }
        }
	 	System.assertEquals(stagingRecords.size(), passCount);	 	
	}
    
    //***********Scenario-11*******************
    private static void insertAA1_S11(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'AA1';
		stgRec.Start_Date__c = now.addMinutes(0);
		stgRec.End_Date__c= now.addMinutes(15);
		stgRec.TimeTracker_Associated__c = tt1_900_S5toS12;
		insert stgRec;
	}
	private static void insertChat1_S11(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat1';
		stgRec.Start_Date__c = now.addMinutes(10);
		stgRec.End_Date__c= now.addMinutes(15);
		insert stgRec;
	}
	private static void setUpData_S11(){
        create_TT_S5toS12();
		insertAA1_S11();
		insertChat1_S11();
    }
	@isTest static void Test_excludeStagingLineItemTime_Scenario11(){
	 	setUpData_S11();

	 	List<TimeTracker_StagingLineItem__c> stagingRecords = [SELECT Id, Name,OwnerId,Activity_Name__c,End_Date__c,Start_Date__c,Object_Name__c,Object_Id__c,TimeTracker_Associated__c
	 															FROM TimeTracker_StagingLineItem__c
	 															WHERE CreatedDate > YESTERDAY
	 															ORDER BY Start_Date__c];		
	 	Map<Id,Time_Tracker__c> ttRecordsToInsert = TimeTrackerStagingLineItemHelper.getTimeTrackersInsertList(stagingRecords);	
	 	System.assertEquals(stagingRecords.size(),ttRecordsToInsert.size());

	 	Integer passCount = 0;        
        for(Time_Tracker__c ttRec: ttRecordsToInsert.values()){
            if(ttRec.Id == tt1_900_S5toS12){
                system.assertEquals(600, ttRec.Duration__c);
                passCount++;
            }else if(ttRec.Action__c=='Chat1'){
                system.assertEquals(300, ttRec.Duration__c);
                passCount++;
            }
        }
	 	System.assertEquals(stagingRecords.size(), passCount);	 	
	}

    //***********Scenario-12*******************
    private static void insertAA1_S12(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'AA1';
		stgRec.Start_Date__c = now.addMinutes(0);
		stgRec.End_Date__c= now.addMinutes(15);
		stgRec.TimeTracker_Associated__c = tt1_900_S5toS12;
		insert stgRec;
	}
	private static void insertChat1_S12(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat1';
		stgRec.Start_Date__c = now.addMinutes(0);
		stgRec.End_Date__c= now.addMinutes(20);
		insert stgRec;
	}
	private static void setUpData_S12(){
        create_TT_S5toS12();
		insertAA1_S12();
		insertChat1_S12();
    }
	@isTest static void Test_excludeStagingLineItemTime_Scenario12(){
	 	setUpData_S12();

	 	List<TimeTracker_StagingLineItem__c> stagingRecords = [SELECT Id, Name,OwnerId,Activity_Name__c,End_Date__c,Start_Date__c,Object_Name__c,Object_Id__c,TimeTracker_Associated__c
	 															FROM TimeTracker_StagingLineItem__c
	 															WHERE CreatedDate > YESTERDAY
	 															ORDER BY Start_Date__c];		
	 	Map<Id,Time_Tracker__c> ttRecordsToInsert = TimeTrackerStagingLineItemHelper.getTimeTrackersInsertList(stagingRecords);	
	 	System.assertEquals(stagingRecords.size(),ttRecordsToInsert.size());

	 	Integer passCount = 0;        
        for(Time_Tracker__c ttRec: ttRecordsToInsert.values()){
            if(ttRec.Id == tt1_900_S5toS12){
                system.assertEquals(1, ttRec.Duration__c);
                passCount++;
            }else if(ttRec.Action__c=='Chat1'){
                system.assertEquals(1200, ttRec.Duration__c);
                passCount++;
            }
        }
	 	System.assertEquals(stagingRecords.size(), passCount); 	
	}
	//********************Scenario-13**************************
	static Id TT1_100_S13;        
    private static void create_TT_S13()
    {
        init();

        //TT record with 600-seconds Duration
        Time_Tracker__c reviewtt1 = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(now.addMinutes(20).getTime()), String.valueOf(now.addMinutes(20).getTime()),
                                                                    TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(now.getTime()), String.valueOf(now.getTime()),
                                                                    caseObj.Id, '',  
                                                                    null, usr.Id);
        reviewtt1.Object_Id__c = caseObj.Id;
        reviewtt1.Duration__c = 100;
        reviewtt1.Parent_Object_Id__c = caseObj.Id;

        // This will execute GenericExcludeImpl
        insert reviewtt1;
        System.assert(reviewtt1.Id != null);
        TT1_100_S13 = reviewtt1.Id;
    }
	private static void insertAA1_S13(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'AA1';
		stgRec.Start_Date__c = now.addMinutes(0);
		stgRec.End_Date__c= now.addMinutes(15);
		stgRec.TimeTracker_Associated__c = TT1_100_S13;
		insert stgRec;
	}
	private static void insertChat1_S13(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat1';
		stgRec.Start_Date__c = now.addMinutes(10);
		stgRec.End_Date__c= now.addMinutes(20);
		insert stgRec;
	}
	private static void setUpData_S13(){
        create_TT_S13();
		insertAA1_S13();
		insertChat1_S13();
	}
	@isTest static void Test_excludeStagingLineItemTime_Scenario13(){
	 	setUpData_S13();

	 	List<TimeTracker_StagingLineItem__c> stagingRecords = [SELECT Id, Name,OwnerId,Activity_Name__c,End_Date__c,Start_Date__c,Object_Name__c,Object_Id__c,TimeTracker_Associated__c
	 															FROM TimeTracker_StagingLineItem__c
	 															WHERE CreatedDate > YESTERDAY
	 															ORDER BY Start_Date__c];		
	 	Map<Id,Time_Tracker__c> ttRecordsToInsert = TimeTrackerStagingLineItemHelper.getTimeTrackersInsertList(stagingRecords);	
	 	System.assertEquals(stagingRecords.size(),ttRecordsToInsert.size());
        system.debug('TT-updated'+ttRecordsToInsert);
	 	Integer passCount = 0;        
        for(Time_Tracker__c ttRec: ttRecordsToInsert.values()){
            if(ttRec.Id == TT1_100_S13){
                system.assertEquals(1, ttRec.Duration__c);
                passCount++;
            }else if(ttRec.Action__c=='Chat1'){
                system.assertEquals(600, ttRec.Duration__c);
                passCount++;
            }
        }

	 	System.assertEquals(stagingRecords.size(), passCount);
	}
    //********************Scenario-14**************************
	static Id TT1_300_S14;
    static Id TT2_600_S14;
    private static void create_TT_S14()
    {
        init();

        //TT record with 300-seconds Duration
        Time_Tracker__c reviewtt1 = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(now.addMinutes(20).getTime()), String.valueOf(now.addMinutes(20).getTime()),
                                                                    TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(now.getTime()), String.valueOf(now.getTime()),
                                                                    caseObj.Id, '',  
                                                                    null, usr.Id);
        reviewtt1.Object_Id__c = caseObj.Id;
        reviewtt1.Duration__c = 300;
        reviewtt1.Parent_Object_Id__c = caseObj.Id;

        // This will execute GenericExcludeImpl
        insert reviewtt1;
        System.assert(reviewtt1.Id != null);
        TT1_300_S14 = reviewtt1.Id;

        //TT record with 600-seconds Duration
        Time_Tracker__c reviewtt2 = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(now.addMinutes(15).getTime()), String.valueOf(now.addMinutes(15).getTime()),
                                                                    TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(now.addMinutes(5).getTime()), String.valueOf(now.addMinutes(5).getTime()),
                                                                    caseObj.Id, '',  
                                                                    null, usr.Id);
        reviewtt2.Object_Id__c = caseObj.Id;
        reviewtt2.Duration__c = 600;
        reviewtt2.Parent_Object_Id__c = caseObj.Id;

        // This will execute GenericExcludeImpl
        insert reviewtt2;
        System.assert(reviewtt2.Id != null);
        TT2_600_S14 = reviewtt2.Id;        
    }
	private static void insertAA1_S14(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'AA1';
		stgRec.Start_Date__c = now.addMinutes(0);
		stgRec.End_Date__c= now.addMinutes(15);
		stgRec.TimeTracker_Associated__c = TT1_300_S14;
		insert stgRec;
	}
	private static void insertAA2_S14(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'AA2';
		stgRec.Start_Date__c = now.addMinutes(5);
		stgRec.End_Date__c= now.addMinutes(15);
		stgRec.TimeTracker_Associated__c = TT2_600_S14;
		insert stgRec;
	}
	private static void insertChat1_S14(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat1';
		stgRec.Start_Date__c = now.addMinutes(10);
		stgRec.End_Date__c= now.addMinutes(15);
		insert stgRec;
	}
	private static void setUpData_S14(){
        create_TT_S14();
		insertAA1_S14();
		insertAA2_S14();
		insertChat1_S14();
	}
	@isTest static void Test_excludeStagingLineItemTime_Scenario14(){
	 	setUpData_S14();

	 	List<TimeTracker_StagingLineItem__c> stagingRecords = [SELECT Id, Name,OwnerId,Activity_Name__c,End_Date__c,Start_Date__c,Object_Name__c,Object_Id__c,TimeTracker_Associated__c
	 															FROM TimeTracker_StagingLineItem__c
	 															WHERE CreatedDate > YESTERDAY
	 															ORDER BY Start_Date__c];		
	 	Map<Id,Time_Tracker__c> ttRecordsToInsert = TimeTrackerStagingLineItemHelper.getTimeTrackersInsertList(stagingRecords);	
	 	System.assertEquals(stagingRecords.size(),ttRecordsToInsert.size());

	 	Integer passCount = 0;        
        for(Time_Tracker__c ttRec: ttRecordsToInsert.values()){
            if(ttRec.Id == TT1_300_S14){
                system.assertEquals(1, ttRec.Duration__c);
                passCount++;
            }else if(ttRec.Id==TT2_600_S14){
                system.assertEquals(300, ttRec.Duration__c);
                passCount++;
            }else if(ttRec.Action__c=='Chat1'){
                system.assertEquals(300, ttRec.Duration__c);
                passCount++;
            }
        }

	 	System.assertEquals(stagingRecords.size(), passCount);
	}
    //********************Scenario-15**************************
	static Id TT1_400_S15;
    static Id TT2_350_S15;
    private static void create_TT_S15()
    {
        init();

        //TT record with 400-seconds Duration
        Time_Tracker__c reviewtt1 = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(now.addMinutes(20).getTime()), String.valueOf(now.addMinutes(20).getTime()),
                                                                    TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(now.getTime()), String.valueOf(now.getTime()),
                                                                    caseObj.Id, '',  
                                                                    null, usr.Id);
        reviewtt1.Object_Id__c = caseObj.Id;
        reviewtt1.Duration__c = 400;
        reviewtt1.Parent_Object_Id__c = caseObj.Id;

        // This will execute GenericExcludeImpl
        insert reviewtt1;
        System.assert(reviewtt1.Id != null);
        TT1_400_S15 = reviewtt1.Id;

        //TT record with 350-seconds Duration
        Time_Tracker__c reviewtt2 = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(now.addMinutes(15).getTime()), String.valueOf(now.addMinutes(15).getTime()),
                                                                    TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(now.addMinutes(5).getTime()), String.valueOf(now.addMinutes(5).getTime()),
                                                                    caseObj.Id, '',  
                                                                    null, usr.Id);
        reviewtt2.Object_Id__c = caseObj.Id;
        reviewtt2.Duration__c = 350;
        reviewtt2.Parent_Object_Id__c = caseObj.Id;

        // This will execute GenericExcludeImpl
        insert reviewtt2;
        System.assert(reviewtt2.Id != null);
        TT2_350_S15 = reviewtt2.Id;        
    }
	private static void insertAA1_S15(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'AA1';
		stgRec.Start_Date__c = now.addMinutes(0);
		stgRec.End_Date__c= now.addMinutes(15);
		stgRec.TimeTracker_Associated__c = TT1_400_S15;
		insert stgRec;
	}
	private static void insertAA2_S15(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'AA2';
		stgRec.Start_Date__c = now.addMinutes(5);
		stgRec.End_Date__c= now.addMinutes(15);
		stgRec.TimeTracker_Associated__c = TT2_350_S15;
		insert stgRec;
	}
	private static void insertChat1_S15(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat1';
		stgRec.Start_Date__c = now.addMinutes(10);
		stgRec.End_Date__c= now.addMinutes(15);
		insert stgRec;
	}
	private static void setUpData_S15(){
        create_TT_S15();
		insertAA1_S15();
		insertAA2_S15();
		insertChat1_S15();
	}
	@isTest static void Test_excludeStagingLineItemTime_Scenario15(){
	 	setUpData_S15();

	 	List<TimeTracker_StagingLineItem__c> stagingRecords = [SELECT Id, Name,OwnerId,Activity_Name__c,End_Date__c,Start_Date__c,Object_Name__c,Object_Id__c,TimeTracker_Associated__c
	 															FROM TimeTracker_StagingLineItem__c
	 															WHERE CreatedDate > YESTERDAY
	 															ORDER BY Start_Date__c];		
	 	Map<Id,Time_Tracker__c> ttRecordsToInsert = TimeTrackerStagingLineItemHelper.getTimeTrackersInsertList(stagingRecords);	
	 	System.assertEquals(stagingRecords.size(),ttRecordsToInsert.size());
		
		Integer passCount = 0;        
        for(Time_Tracker__c ttRec: ttRecordsToInsert.values()){
            if(ttRec.Id == TT1_400_S15){
                system.assertEquals(100, ttRec.Duration__c);
                passCount++;
            }else if(ttRec.Id==TT2_350_S15){
                system.assertEquals(50, ttRec.Duration__c);
                passCount++;
            }else if(ttRec.Action__c=='Chat1'){
                system.assertEquals(300, ttRec.Duration__c);
                passCount++;
            }
        }

	 	System.assertEquals(stagingRecords.size(), passCount);
	}    
    //********************Scenario-16**************************
	static Id TT1_200_S16;
    static Id TT2_400_S16;
    private static void create_TT_S16()
    {
        init();

        //TT record with 200-seconds Duration
        Time_Tracker__c reviewtt1 = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(now.addMinutes(20).getTime()), String.valueOf(now.addMinutes(20).getTime()),
                                                                    TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(now.getTime()), String.valueOf(now.getTime()),
                                                                    caseObj.Id, '',  
                                                                    null, usr.Id);
        reviewtt1.Object_Id__c = caseObj.Id;
        reviewtt1.Duration__c = 200;
        reviewtt1.Parent_Object_Id__c = caseObj.Id;

        // This will execute GenericExcludeImpl
        insert reviewtt1;
        System.assert(reviewtt1.Id != null);
        TT1_200_S16 = reviewtt1.Id;

        //TT record with 400-seconds Duration
        Time_Tracker__c reviewtt2 = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(now.addMinutes(16).getTime()), String.valueOf(now.addMinutes(16).getTime()),
                                                                    TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(now.addMinutes(5).getTime()), String.valueOf(now.addMinutes(5).getTime()),
                                                                    caseObj.Id, '',  
                                                                    null, usr.Id);
        reviewtt2.Object_Id__c = caseObj.Id;
        reviewtt2.Duration__c = 400;
        reviewtt2.Parent_Object_Id__c = caseObj.Id;

        // This will execute GenericExcludeImpl
        insert reviewtt2;
        System.assert(reviewtt2.Id != null);
        TT2_400_S16 = reviewtt2.Id;        
    }
	private static void insertAA1_S16(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'AA1';
		stgRec.Start_Date__c = now.addMinutes(5);
		stgRec.End_Date__c= now.addMinutes(15);
		stgRec.TimeTracker_Associated__c = TT1_200_S16;
		insert stgRec;
	}
	private static void insertAA2_S16(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'AA2';
		stgRec.Start_Date__c = now.addMinutes(5);
		stgRec.End_Date__c= now.addMinutes(20);
		stgRec.TimeTracker_Associated__c = TT2_400_S16;
		insert stgRec;
	}
	private static void insertChat1_S16(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat1';
		stgRec.Start_Date__c = now.addMinutes(0);
		stgRec.End_Date__c= now.addMinutes(10);
		insert stgRec;
	}
	private static void setUpData_S16(){
        create_TT_S16();
		insertAA1_S16();
		insertAA2_S16();
		insertChat1_S16();
	}
	@isTest static void Test_excludeStagingLineItemTime_Scenario16(){
	 	setUpData_S16();

	 	List<TimeTracker_StagingLineItem__c> stagingRecords = [SELECT Id, Name,OwnerId,Activity_Name__c,End_Date__c,Start_Date__c,Object_Name__c,Object_Id__c,TimeTracker_Associated__c
	 															FROM TimeTracker_StagingLineItem__c
	 															WHERE CreatedDate > YESTERDAY
	 															ORDER BY Start_Date__c];		
	 	Map<Id,Time_Tracker__c> ttRecordsToInsert = TimeTrackerStagingLineItemHelper.getTimeTrackersInsertList(stagingRecords);	
	 	System.assertEquals(stagingRecords.size(),ttRecordsToInsert.size());
		
		Integer passCount = 0;        
        for(Time_Tracker__c ttRec: ttRecordsToInsert.values()){
            if(ttRec.Id == TT1_200_S16){
                system.assertEquals(1, ttRec.Duration__c);
                passCount++;
            }else if(ttRec.Id==TT2_400_S16){
                system.assertEquals(100, ttRec.Duration__c);
                passCount++;
            }else if(ttRec.Action__c=='Chat1'){
                system.assertEquals(600, ttRec.Duration__c);
                passCount++;
            }
        }

	 	System.assertEquals(stagingRecords.size(), passCount);
	}        
    //********************Scenario-17**************************    
	static Id TT1_600_S17;
    static Id TT2_600_S17;
    private static void create_TT_S17()
    {
        init();

        //TT record with 600-seconds Duration
        Time_Tracker__c reviewtt1 = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(now.addMinutes(20).getTime()), String.valueOf(now.addMinutes(20).getTime()),
                                                                    TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(now.getTime()), String.valueOf(now.getTime()),
                                                                    caseObj.Id, '',  
                                                                    null, usr.Id);
        reviewtt1.Object_Id__c = caseObj.Id;
        reviewtt1.Duration__c = 600;
        reviewtt1.Parent_Object_Id__c = caseObj.Id;

        // This will execute GenericExcludeImpl
        insert reviewtt1;
        System.assert(reviewtt1.Id != null);
        TT1_600_S17 = reviewtt1.Id;

        //TT record with 600-seconds Duration
        Time_Tracker__c reviewtt2 = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(now.addMinutes(15).getTime()), String.valueOf(now.addMinutes(15).getTime()),
                                                                    TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(now.addMinutes(5).getTime()), String.valueOf(now.addMinutes(5).getTime()),
                                                                    caseObj.Id, '',  
                                                                    null, usr.Id);
        reviewtt2.Object_Id__c = caseObj.Id;
        reviewtt2.Duration__c = 600;
        reviewtt2.Parent_Object_Id__c = caseObj.Id;

        // This will execute GenericExcludeImpl
        insert reviewtt2;
        System.assert(reviewtt2.Id != null);
        TT2_600_S17 = reviewtt2.Id;        
    }
	private static void insertAA1_S17(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'AA1';
		stgRec.Start_Date__c = now.addMinutes(0);
		stgRec.End_Date__c= now.addMinutes(20);
		stgRec.TimeTracker_Associated__c = TT1_600_S17;
		insert stgRec;
	}
	private static void insertAA2_S17(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'AA2';
		stgRec.Start_Date__c = now.addMinutes(5);
		stgRec.End_Date__c= now.addMinutes(15);
		stgRec.TimeTracker_Associated__c = TT2_600_S17;
		insert stgRec;
	}
	private static void insertChat1_S17(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat1';
		stgRec.Start_Date__c = now.addMinutes(10);
		stgRec.End_Date__c= now.addMinutes(25);
		insert stgRec;
	}
	private static void insertChat2_S17(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat2';
		stgRec.Start_Date__c = now.addMinutes(15);
		stgRec.End_Date__c= now.addMinutes(30);
		insert stgRec;
	}
	private static void setUpData_S17(){
        create_TT_S17();
		insertAA1_S17();
		insertAA2_S17();
		insertChat1_S17();
        insertChat2_S17();
	}
	@isTest static void Test_excludeStagingLineItemTime_Scenario17(){
	 	setUpData_S17();

	 	List<TimeTracker_StagingLineItem__c> stagingRecords = [SELECT Id, Name,OwnerId,Activity_Name__c,End_Date__c,Start_Date__c,Object_Name__c,Object_Id__c,TimeTracker_Associated__c
	 															FROM TimeTracker_StagingLineItem__c
	 															WHERE CreatedDate > YESTERDAY
	 															ORDER BY Start_Date__c];		
	 	Map<Id,Time_Tracker__c> ttRecordsToInsert = TimeTrackerStagingLineItemHelper.getTimeTrackersInsertList(stagingRecords);	
	 	System.assertEquals(stagingRecords.size(),ttRecordsToInsert.size());
        system.debug('TT-updated'+ttRecordsToInsert);
	 	Integer passCount = 0;        
        for(Time_Tracker__c ttRec: ttRecordsToInsert.values()){
            if(ttRec.Id == TT1_600_S17){
                system.assertEquals(1, ttRec.Duration__c);
                passCount++;
            }else if(ttRec.Id==TT2_600_S17){
                system.assertEquals(300, ttRec.Duration__c);
                passCount++;
            }else if(ttRec.Action__c=='Chat1'){
                system.assertEquals(300, ttRec.Duration__c);
                passCount++;
            }else if(ttRec.Action__c=='Chat2'){
                system.assertEquals(900, ttRec.Duration__c);
                passCount++;
            }
        }

	 	System.assertEquals(stagingRecords.size(), passCount);
	}
	//********************Scenario-18**************************    
	static Id TT1_200_S18;
    static Id TT2_100_S18;
    private static void create_TT_S18()
    {
        init();

        //TT record with 600-seconds Duration
        Time_Tracker__c reviewtt1 = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(now.addMinutes(20).getTime()), String.valueOf(now.addMinutes(20).getTime()),
                                                                    TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(now.getTime()), String.valueOf(now.getTime()),
                                                                    caseObj.Id, '',  
                                                                    null, usr.Id);
        reviewtt1.Object_Id__c = caseObj.Id;
        reviewtt1.Duration__c = 200;
        reviewtt1.Parent_Object_Id__c = caseObj.Id;

        // This will execute GenericExcludeImpl
        insert reviewtt1;
        System.assert(reviewtt1.Id != null);
        TT1_200_S18 = reviewtt1.Id;

        //TT record with 600-seconds Duration
        Time_Tracker__c reviewtt2 = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(now.addMinutes(15).getTime()), String.valueOf(now.addMinutes(15).getTime()),
                                                                    TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(now.addMinutes(5).getTime()), String.valueOf(now.addMinutes(5).getTime()),
                                                                    caseObj.Id, '',  
                                                                    null, usr.Id);
        reviewtt2.Object_Id__c = caseObj.Id;
        reviewtt2.Duration__c = 100;
        reviewtt2.Parent_Object_Id__c = caseObj.Id;

        // This will execute GenericExcludeImpl
        insert reviewtt2;
        System.assert(reviewtt2.Id != null);
        TT2_100_S18 = reviewtt2.Id;        
    }
    private static void insertAA1_S18(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'AA1';
		stgRec.Start_Date__c = now.addMinutes(0);
		stgRec.End_Date__c= now.addMinutes(20);
		stgRec.TimeTracker_Associated__c = TT1_200_S18;
		insert stgRec;
	}
	private static void insertAA2_S18(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'AA2';
		stgRec.Start_Date__c = now.addMinutes(5);
		stgRec.End_Date__c= now.addMinutes(15);
		stgRec.TimeTracker_Associated__c = TT2_100_S18;
		insert stgRec;
	}
	private static void insertChat1_S18(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat1';
		stgRec.Start_Date__c = now.addMinutes(10);
		stgRec.End_Date__c= now.addMinutes(25);
		insert stgRec;
	}
    
	private static void setUpData_S18(){
        create_TT_S18();
		insertAA1_S18();
		insertAA2_S18();
		insertChat1_S18();
	}
	@isTest static void Test_excludeStagingLineItemTime_Scenario18(){
	 	setUpData_S18();

	 	List<TimeTracker_StagingLineItem__c> stagingRecords = [SELECT Id, Name,OwnerId,Activity_Name__c,End_Date__c,Start_Date__c,Object_Name__c,Object_Id__c,TimeTracker_Associated__c
	 															FROM TimeTracker_StagingLineItem__c
	 															WHERE CreatedDate > YESTERDAY
	 															ORDER BY Start_Date__c];		
	 	Map<Id,Time_Tracker__c> ttRecordsToInsert = TimeTrackerStagingLineItemHelper.getTimeTrackersInsertList(stagingRecords);	
	 	System.assertEquals(stagingRecords.size(),ttRecordsToInsert.size());

        Integer passCount = 0;        
        for(Time_Tracker__c ttRec: ttRecordsToInsert.values()){
            if(ttRec.Id == TT1_200_S18){
                system.assertEquals(1, ttRec.Duration__c);
                passCount++;
            }else if(ttRec.Id==TT2_100_S18){
                system.assertEquals(1, ttRec.Duration__c);
                passCount++;
            }else if(ttRec.Action__c=='Chat1'){
                system.assertEquals(900, ttRec.Duration__c);
                passCount++;
            }
        }
        
	 	System.assertEquals(stagingRecords.size(), passCount);
	} /**/    

	//**********Scenario Test-data 19*****************
	private static void insertChat0_S19(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat0';
		stgRec.Start_Date__c = now;
		stgRec.End_Date__c= now.addMinutes(1);
		insert stgRec;
	}	
	private static void insertChat1_S19(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat1';
		stgRec.Start_Date__c = now.addMinutes(2);
		stgRec.End_Date__c= now.addMinutes(17);
		insert stgRec;
	}
	private static void insertChat2_S19(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat2';
		stgRec.Start_Date__c = now.addMinutes(3);
		stgRec.End_Date__c= now.addMinutes(5);
		insert stgRec;
	}
	private static void insertChat3_S19(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat3';
		stgRec.Start_Date__c = now.addMinutes(4);
		stgRec.End_Date__c= now.addMinutes(11);
		insert stgRec;
	}
	private static void insertChat4_S19(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat4';
		stgRec.Start_Date__c = now.addMinutes(6);
		stgRec.End_Date__c= now.addMinutes(7);
		insert stgRec;
	}
	private static void insertChat5_S19(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat5';
		stgRec.Start_Date__c = now.addMinutes(8);
		stgRec.End_Date__c= now.addMinutes(16);
		insert stgRec;
	}
	private static void insertChat6_S19(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat6';
		stgRec.Start_Date__c = now.addMinutes(9);
		stgRec.End_Date__c= now.addMinutes(14);
		insert stgRec;
	}
	private static void insertChat7_S19(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat7';
		stgRec.Start_Date__c = now.addMinutes(10);
		stgRec.End_Date__c= now.addMinutes(12);
		insert stgRec;
	}
	private static void insertChat8_S19(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat8';
		stgRec.Start_Date__c = now.addMinutes(13);
		stgRec.End_Date__c= now.addMinutes(15);
		insert stgRec;
	}

	private static void setUpData_S19(){
		insertChat0_S19();
		insertChat1_S19();
		insertChat2_S19();
		insertChat3_S19();
		insertChat4_S19();
		insertChat5_S19();
		insertChat6_S19();
		insertChat7_S19();
		insertChat8_S19();
	}

	private static final String STANDARD_PROFILE_NAME = 'Standard User';
	/**
	*	This test method- is replica of Scenario-1 but running for 2-different user 
	*   (1 for user who is running the batch and 2 for user having standard-user profile)
	*/
	@isTest static void Test_excludeStagingLineItemTime_Scenario19(){

		//Create staging records for User-running the batch
	 	setUpData_S19();

	 	//Create staging records for User having Standard-User profile
	 	User stdUsr = TimeTrackerTestHelper.createUser(STANDARD_PROFILE_NAME);
    	system.runAs(stdUsr) {
    		setUpData_S19();
    	}

    	Id batchUserId = UserInfo.getUserId();
    	Id standardUserId = stdUsr.Id;

	 	List<TimeTracker_StagingLineItem__c> stagingRecords = [SELECT Id, Name,OwnerId,Activity_Name__c,End_Date__c,Start_Date__c,Object_Name__c,Object_Id__c,TimeTracker_Associated__c
	 															FROM TimeTracker_StagingLineItem__c
	 															WHERE CreatedDate > YESTERDAY
	 															ORDER BY Start_Date__c];
															
	 	Map<Id,Time_Tracker__c> ttRecordsToInsert = TimeTrackerStagingLineItemHelper.getTimeTrackersInsertList(stagingRecords);	
	 	System.assertEquals(18,ttRecordsToInsert.size());

	 	Integer passCount_batchUser = 0;
	 	Integer passCount_standardUser = 0;
	 	for(TimeTracker_StagingLineItem__c stgRec : stagingRecords){
	 		if(stgRec.Activity_Name__c=='Chat0'){
	 			System.assertEquals(60, ttRecordsToInsert.get(stgRec.Id).Duration__c);
	 			if(ttRecordsToInsert.get(stgRec.Id).OwnerId == batchUserId){
	 					passCount_batchUser++;
 				} else{
 					passCount_standardUser++;
 				}
	 		} else if(stgRec.Activity_Name__c=='Chat1'){
	 			System.assertEquals(120, ttRecordsToInsert.get(stgRec.Id).Duration__c);
	 			if(ttRecordsToInsert.get(stgRec.Id).OwnerId == batchUserId){
	 					passCount_batchUser++;
 				} else{
 					passCount_standardUser++;
 				}
	 		} else if(stgRec.Activity_Name__c=='Chat2'){
	 			System.assertEquals(60, ttRecordsToInsert.get(stgRec.Id).Duration__c);
	 			if(ttRecordsToInsert.get(stgRec.Id).OwnerId == batchUserId){
	 					passCount_batchUser++;
 				} else{
 					passCount_standardUser++;
 				}
	 		} else if(stgRec.Activity_Name__c=='Chat3'){
	 			System.assertEquals(180, ttRecordsToInsert.get(stgRec.Id).Duration__c);
	 			if(ttRecordsToInsert.get(stgRec.Id).OwnerId == batchUserId){
	 					passCount_batchUser++;
 				} else{
 					passCount_standardUser++;
 				}
	 		} else if(stgRec.Activity_Name__c=='Chat4'){
	 			System.assertEquals(60, ttRecordsToInsert.get(stgRec.Id).Duration__c);
	 			if(ttRecordsToInsert.get(stgRec.Id).OwnerId == batchUserId){
	 					passCount_batchUser++;
 				} else{
 					passCount_standardUser++;
 				}
	 		} else if(stgRec.Activity_Name__c=='Chat5'){
	 			System.assertEquals(120, ttRecordsToInsert.get(stgRec.Id).Duration__c);
	 			if(ttRecordsToInsert.get(stgRec.Id).OwnerId == batchUserId){
	 					passCount_batchUser++;
 				} else{
 					passCount_standardUser++;
 				}
	 		} else if(stgRec.Activity_Name__c=='Chat6'){
	 			System.assertEquals(120, ttRecordsToInsert.get(stgRec.Id).Duration__c);
	 			if(ttRecordsToInsert.get(stgRec.Id).OwnerId == batchUserId){
	 					passCount_batchUser++;
 				} else{
 					passCount_standardUser++;
 				}
	 		} else if(stgRec.Activity_Name__c=='Chat7'){
	 			System.assertEquals(120, ttRecordsToInsert.get(stgRec.Id).Duration__c);
	 			if(ttRecordsToInsert.get(stgRec.Id).OwnerId == batchUserId){
	 					passCount_batchUser++;
 				} else{
 					passCount_standardUser++;
 				}
	 		} else if(stgRec.Activity_Name__c=='Chat8'){
	 			System.assertEquals(120, ttRecordsToInsert.get(stgRec.Id).Duration__c);
	 			if(ttRecordsToInsert.get(stgRec.Id).OwnerId == batchUserId){
	 					passCount_batchUser++;
 				} else{
 					passCount_standardUser++;
 				}
	 		}
	 	}

	 	System.assertEquals(9,passCount_batchUser);
	 	System.assertEquals(9,passCount_standardUser);
	}
    //********************Scenario-20**************************
    static Id TT1_200_S20_StandardUser;
    static Id TT2_400_S20_StandardUser;
    private static void create_TT_S20_StandardUser()
    {
        //TT record with 200-seconds Duration
        Time_Tracker__c reviewtt1 = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(now.addMinutes(20).getTime()), String.valueOf(now.addMinutes(20).getTime()),
                                                                    TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(now.getTime()), String.valueOf(now.getTime()),
                                                                    caseObj.Id, '',  
                                                                    null, UserInfo.getUserId());
        reviewtt1.Object_Id__c = caseObj.Id;
        reviewtt1.Duration__c = 200;
        reviewtt1.Parent_Object_Id__c = caseObj.Id;

        // This will execute GenericExcludeImpl
        insert reviewtt1;
        System.assert(reviewtt1.Id != null);
        TT1_200_S20_StandardUser = reviewtt1.Id;

        //TT record with 400-seconds Duration
        Time_Tracker__c reviewtt2 = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(now.addMinutes(16).getTime()), String.valueOf(now.addMinutes(16).getTime()),
                                                                    TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(now.addMinutes(5).getTime()), String.valueOf(now.addMinutes(5).getTime()),
                                                                    caseObj.Id, '',  
                                                                    null, UserInfo.getUserId());
        reviewtt2.Object_Id__c = caseObj.Id;
        reviewtt2.Duration__c = 400;
        reviewtt2.Parent_Object_Id__c = caseObj.Id;

        // This will execute GenericExcludeImpl
        insert reviewtt2;
        System.assert(reviewtt2.Id != null);
        TT2_400_S20_StandardUser = reviewtt2.Id;        
    }
	private static void insertAA1_S20_StandardUser(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'AA1';
		stgRec.Start_Date__c = now.addMinutes(5);
		stgRec.End_Date__c= now.addMinutes(15);
		stgRec.TimeTracker_Associated__c = TT1_200_S20_StandardUser;
		insert stgRec;
	}
	private static void insertAA2_S20_StandardUser(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'AA2';
		stgRec.Start_Date__c = now.addMinutes(5);
		stgRec.End_Date__c= now.addMinutes(20);
		stgRec.TimeTracker_Associated__c = TT2_400_S20_StandardUser;
		insert stgRec;
	}
	private static void insertChat1_S20_StandardUser(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat1';
		stgRec.Start_Date__c = now.addMinutes(0);
		stgRec.End_Date__c= now.addMinutes(10);
		insert stgRec;
	}
	private static void setUpData_S20_StandardUser(){
        create_TT_S20_StandardUser();
		insertAA1_S20_StandardUser();
		insertAA2_S20_StandardUser();
		insertChat1_S20_StandardUser();
	}
    
	static Id TT1_600_S20;
    static Id TT2_600_S20;
    private static void create_TT_S20()
    {
        init();

        //TT record with 600-seconds Duration
        Time_Tracker__c reviewtt1 = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(now.addMinutes(20).getTime()), String.valueOf(now.addMinutes(20).getTime()),
                                                                    TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(now.getTime()), String.valueOf(now.getTime()),
                                                                    caseObj.Id, '',  
                                                                    null, usr.Id);
        reviewtt1.Object_Id__c = caseObj.Id;
        reviewtt1.Duration__c = 600;
        reviewtt1.Parent_Object_Id__c = caseObj.Id;

        // This will execute GenericExcludeImpl
        insert reviewtt1;
        System.assert(reviewtt1.Id != null);
        TT1_600_S20 = reviewtt1.Id;

        //TT record with 600-seconds Duration
        Time_Tracker__c reviewtt2 = TimeTrackerUtility.createTimeTracker(TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(now.addMinutes(15).getTime()), String.valueOf(now.addMinutes(15).getTime()),
                                                                    TimeTrackerConstants.CASE_REVIEW_STR, String.valueOf(now.addMinutes(5).getTime()), String.valueOf(now.addMinutes(5).getTime()),
                                                                    caseObj.Id, '',  
                                                                    null, usr.Id);
        reviewtt2.Object_Id__c = caseObj.Id;
        reviewtt2.Duration__c = 600;
        reviewtt2.Parent_Object_Id__c = caseObj.Id;

        // This will execute GenericExcludeImpl
        insert reviewtt2;
        System.assert(reviewtt2.Id != null);
        TT2_600_S20 = reviewtt2.Id;        
    }
	private static void insertAA1_S20(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'AA1';
		stgRec.Start_Date__c = now.addMinutes(0);
		stgRec.End_Date__c= now.addMinutes(20);
		stgRec.TimeTracker_Associated__c = TT1_600_S20;
		insert stgRec;
	}
	private static void insertAA2_S20(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'AA2';
		stgRec.Start_Date__c = now.addMinutes(5);
		stgRec.End_Date__c= now.addMinutes(15);
		stgRec.TimeTracker_Associated__c = TT2_600_S20;
		insert stgRec;
	}
	private static void insertChat1_S20(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat1';
		stgRec.Start_Date__c = now.addMinutes(10);
		stgRec.End_Date__c= now.addMinutes(25);
		insert stgRec;
	}
	private static void insertChat2_S20(){
		TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
		stgRec.Activity_Name__c = 'Chat2';
		stgRec.Start_Date__c = now.addMinutes(15);
		stgRec.End_Date__c= now.addMinutes(30);
		insert stgRec;
	}
	private static void setUpData_S20_BatchUser(){
        create_TT_S20();
		insertAA1_S20();
		insertAA2_S20();
		insertChat1_S20();
        insertChat2_S20();
	}
	/**
	*	This test method- is replica of Scenario-17 for user running the batch 
	*   and Scenario-16 for user having standard-user profile
	*/
	@isTest static void Test_excludeStagingLineItemTime_Scenario20(){
	 	setUpData_S20_BatchUser();

	 	//Create staging records for User having Standard-User profile
	 	User stdUsr = TimeTrackerTestHelper.createUser(STANDARD_PROFILE_NAME);
    	system.runAs(stdUsr) {
    		setUpData_S20_StandardUser();
    	}
    	Id batchUserId = UserInfo.getUserId();
    	Id standardUserId = stdUsr.Id;

	 	List<TimeTracker_StagingLineItem__c> stagingRecords = [SELECT Id, Name,OwnerId,Activity_Name__c,End_Date__c,Start_Date__c,Object_Name__c,Object_Id__c,TimeTracker_Associated__c
	 															FROM TimeTracker_StagingLineItem__c
	 															WHERE CreatedDate > YESTERDAY
	 															ORDER BY Start_Date__c];		
	 	Map<Id,Time_Tracker__c> ttRecordsToInsert = TimeTrackerStagingLineItemHelper.getTimeTrackersInsertList(stagingRecords);	
	 	System.assertEquals(7,ttRecordsToInsert.size());

	 	Integer passCount_batchUser = 0;
	 	Integer passCount_standardUser = 0;        
        for(Time_Tracker__c ttRec: ttRecordsToInsert.values()){
            
        	if(ttRec.OwnerId==batchUserId){
	            if(ttRec.Id == TT1_600_S20){
	                system.assertEquals(1, ttRec.Duration__c);
	                passCount_batchUser++;
	            }else if(ttRec.Id==TT2_600_S20){
	                system.assertEquals(300, ttRec.Duration__c);
	                passCount_batchUser++;
	            }else if(ttRec.Action__c=='Chat1'){
	                system.assertEquals(300, ttRec.Duration__c);
	                passCount_batchUser++;
	            }else if(ttRec.Action__c=='Chat2'){
	                system.assertEquals(900, ttRec.Duration__c);
	                passCount_batchUser++;
	            }

            } else if(ttRec.OwnerId == standardUserId){
	          	if(ttRec.Id == TT1_200_S20_StandardUser){
	                system.assertEquals(1, ttRec.Duration__c);
	                passCount_standardUser++;
	            }else if(ttRec.Id==TT2_400_S20_StandardUser){
	                system.assertEquals(100, ttRec.Duration__c);
	                passCount_standardUser++;
	            }else if(ttRec.Action__c=='Chat1'){
	                system.assertEquals(600, ttRec.Duration__c);
	                passCount_standardUser++;
	            }
            }
        }

	 	System.assertEquals(3, passCount_standardUser);
	 	System.assertEquals(4, passCount_batchUser);
	}

}