@isTest (SeeAllData = false)
/**
* @description unit test class for HiddenTimeTrackerController.cls
*/
public class HiddenTimeTrackerControllerTest {
     private static final String STANDARD_PROFILE_NAME = 'Standard User';
     private static String caseId;

    static CaseComment caseComment;
    static Account acc;
    static Contact con;
	static Case caseObj;
    static opportunity oppObj;
	static User usr= [SELECT Id, LastName FROM User WHERE Id=: UserInfo.getUserId()];
	static DateTime dtNow = Datetime.now();
    private static void init()
	{
		// method to install only new TimeTrackerConfigSettings records
		TimeTrackerTestHelper.insertRecordsFromStaticResource(TimeTrackerUtility.getNamespace()
			+ 'TimeTrackerConfigSettings__c',
			'TimeTrackerConfigSettings_Records');
		System.assertNotEquals(0, TimeTrackerConfigSettings__c.getAll().values().size());
		
		acc = new Account(Name = 'Account Test Name');
		caseObj = new Case(Type = 'Other', Status = 'New', Origin = 'Phone');
        oppObj = new opportunity(StageName= 'Qualification', CloseDate = Date.today(), Name	= 'Test opportunity' );
        con = new Contact(LastName = 'Test Lastname');
		insert acc;
        insert con;
		insert caseObj;
        insert oppObj;
        caseComment = new CaseComment(ParentId = caseObj.Id, CommentBody = 'Test Body');
        insert caseComment; 
        System.assert(acc.Id != null && caseObj.id != null);
	}    
     /**
     * This method sets up the TimeTrackerStrategy custom setting data
     * @param the user  to be used for the Case and Timesheet
     * @return void
     */
    private static void setupData(User usrt) {
        Database.SaveResult sr = null;

         //create a Case record
        Case newCase = new Case(OwnerId = usrt.Id);

        //insert the Case record
        sr = Database.Insert(newCase, true);
        // ensure the Case record has an Id
        system.assertNotEquals(null, sr.getId());
        caseId = sr.getId();
    }

   @isTest static void testInsertActivity() {
        User stdUsr = TimeTrackerTestHelper.createUser(STANDARD_PROFILE_NAME);

        system.runAs(stdUsr) {
            //setupData(stdUsr);
			init();
            
        Time_Tracker__c tt = new Time_Tracker__c(Duration__c= 50, Object_Id__c = caseObj.Id, Source__c = 'Console Toolkit',
                Parent_Object_Id__c= caseObj.Id, Action__c='Case Review', Opening_Action__c = 'Case Review', Opening_Activity_Time__c = 1469099914781L, Activity_Time__c =1469099946909L);
		tt.DocumentId__c = caseObj.Id;
        String jtt = JSON.serialize(tt);
        HiddenTimeTrackerController.insertTimeTracker(jtt);

        Time_Tracker__c updt = new Time_Tracker__c(Duration__c= 50, Object_Id__c = caseObj.Id, Source__c = 'Console Toolkit',
                Parent_Object_Id__c= caseObj.Id, Action__c='Case Review', Opening_Action__c = 'Case Review', Opening_Activity_Time__c = 1469099914781L, Activity_Time__c =1469099946909L);
		updt.DocumentId__c = caseObj.Id;
    	updt.New_Record_Document_Id__c = ''+caseObj.Id;
        String updtjson = JSON.serialize(updt);       
		
       	HiddenTimeTrackerController.insertTimeTracker(updtjson);
       
		tt = new Time_Tracker__c(Duration__c= 50, Object_Id__c = caseComment.Id, Source__c = 'Extension', Action__c='Case Comment Save', Opening_Action__c = 'New Case Comment', Opening_Activity_Time__c = 1469099914781L, Activity_Time__c =1469099946909L);
		tt.DocumentId__c = caseObj.Id;
    	tt.New_Record_Document_Id__c = ''+caseObj.Id;
        updtjson = JSON.serialize(tt);  
       
       HiddenTimeTrackerController.insertTimeTracker(updtjson);
            HiddenTimeTrackerController.getSettings('dummy');
        }
    }

    private static void makeJsonObject(JSONGenerator gen, String objType, Id usrId, String action, 
                                              String actionCategory, String cId, Boolean isTimeTrackerLog) {
        gen.writeStartObject();
        gen.writeStringField('objectType', objType);
        gen.writeStringField('activityDate', String.valueOf((DateTime.now()).getTime()));
        gen.writeStringField('clientId', 'a6c13953-21ea-4271-8499-7b988c158400');
        gen.writeStringField('source', TimeTrackerConstants.SYSTEM_STR);
        gen.writeStringField('user', usrId);
        if(isTimeTrackerLog) {
            gen.writeStringField('level', 'i');
            gen.writeFieldName('log');
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writeStringField('message', 'Error');
            gen.writeStringField('url', '');
            gen.writeEndObject();
            gen.writeEndArray();
        } else {
            gen.writeStringField('action', action);
            gen.writeStringField('actionCategory', actionCategory);
            gen.writeStringField('caseId', cId);
        }
        gen.writeEndObject();
    }
}