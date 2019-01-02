public class TimeTrackerUpdateController {

    private final Time_Tracker__c ttRec;
    public static Boolean isTimeSpentReadOnly{ get;set; }
    
    public List<SelectOption> activities{ get;set; }
    
    //public static Map<String,String> activity_actType_map = new Map<String,String>();
    set<String> activity_actType_map = new set<String>();
    
    public TimeTrackerUpdateController() {
        
    }
    
    public TimeTrackerUpdateController( ApexPages.StandardController controller ) {
        
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Initialting TimeTrackerUpdateController.TimeTrackerUpdateController constructor.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'controller: ' + controller,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        
        if( !Test.isRunningTest() ) {
            Controller.addFields(new List<String>{'Source__c'});
        }
        
        this.ttRec = (Time_Tracker__c)Controller.getRecord();
        System.debug(LoggingLevel.ERROR, '--++--ttRec : ' + ttRec);
        if( ttRec.Source__c != 'Manual' ) {
           ApexPages.Message errTimeTrackerEdit = new ApexPages.Message(ApexPages.Severity.INFO, System.Label.Err_TimeTracker_Edit);
           ApexPages.addMessage(errTimeTrackerEdit);
            //return;
        }
        System.debug('UserInfo.getUserId() : '+UserInfo.getUserId());
        isTimeSpentReadOnly = getIsTimeSpentReadOnlyDetails(UserInfo.getUserId(), UserInfo.getProfileId());
        if(isTimeSpentReadOnly){
            ApexPages.Message errTimeTrackerEdit = new ApexPages.Message(ApexPages.Severity.INFO, System.Label.ERR_Not_Authorize_to_Edit_Time_Tracker);
            ApexPages.addMessage(errTimeTrackerEdit);
        }
        activity_actType_map = TimeTrackerConfigSettings.getManualSettings().keyset();
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'activity_actType_map: ' + activity_actType_map,
            Datetime.now(), null, null, null, UserInfo.getUserId());
            
        List<String> ttlst = new List<String>(activity_actType_map);
        ttlst.sort();
        activities = new List<SelectOption>();
        
        if(ttRec.Opening_Action__c != NULL && activity_actType_map != null && !activity_actType_map.isEmpty()) {
            
            //Check if it is Automated-activity to be edited-if yes add it in list
            if( !activity_actType_map.contains((ttRec.Opening_Action__c)) ){

                activities.add(new SelectOption(ttRec.Opening_Action__c,ttRec.Opening_Action__c));

            }
            for(String activity: ttlst) {
                activities.add(new SelectOption(activity,activity));
            }
        }
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerUpdateController.TimeTrackerUpdateController method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
    }

    private Boolean getIsTimeSpentReadOnlyDetails( String userId, String profileId ) {
        
        Boolean isTimeSpentReadOnly = false;
        try {
            TimeTrackerUserSettings__c recordUserSetting = TimeTrackerUserSettings__c.getValues( userId );
            System.debug( 'recordUserSetting-By-User-Id:-\n' + JSON.serialize( recordUserSetting ) );
            
            if( recordUserSetting == NULL ) {
                recordUserSetting = TimeTrackerUserSettings__c.getInstance( profileId );
                System.debug( 'recordUserSetting-By-Profile-Id:-\n' + JSON.serialize( recordUserSetting ) );
            }
            
            if( recordUserSetting.Is_Time_Tracker_Read_Only__c ) {
                List<PermissionSetAssignment> listPSA = [ SELECT Id, Assignee.Id, PermissionSet.Name 
                                                          FROM PermissionSetAssignment 
                                                          WHERE 
                                                          AssigneeId =: userId 
                                                          AND 
                                                          PermissionSet.Name =: TimeTrackerConstants.TIME_TRACKER_ADMIN_PERMISSION_SET_API_NAME
                                                        ];
                System.debug( 'listPSA:-\n' + JSON.serialize( listPSA ) );
                isTimeSpentReadOnly = listPSA.isEmpty();
            }
        } 
        catch( Exception ex ) {
            TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 
                                              'Exception occured in TimeTrackerUpdateController.getIsTimeSpentReadOnlyDetails method, Details: '+ex,
                                              Datetime.now(), null, null, null, UserInfo.getUserId()
                                            );
        }
        System.debug( 'isTimeSpentReadOnly:-\n' + isTimeSpentReadOnly );
        return isTimeSpentReadOnly;
    }
    
    public PageReference Save(){
        
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerUpdateController.Save method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        try{
            /*
            if(ttRec.Opening_Action__c == TimeTrackerConstants.GENERAL_OTHER && String.isBlank(ttRec.Comment__c) ){
                ApexPages.Message commentReqdError = new ApexPages.Message(ApexPages.Severity.FATAL, System.Label.ERR_Comment_Required);
                ApexPages.addMessage(commentReqdError);
                return null;
            }
            //*/
            System.debug('@@ttRec : '+ttRec);
            if(String.isBlank(ttRec.Time_Spent__c) || !checkTimerFormat(ttRec.Time_Spent__c)){
                ApexPages.Message invalidDuration = new ApexPages.Message(ApexPages.Severity.FATAL, System.Label.ERR_Invalid_duration);
                ApexPages.addMessage(invalidDuration);
                return null;
            }
            update ttRec;
            PageReference pr = new PageReference('/'+ttRec.Id);
            pr.setRedirect(true);
            TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerUpdateController.Save method.',
                Datetime.now(), null, null, null, UserInfo.getUserId());
            return pr;
        }catch(Exception e){
             Apexpages.addMessages(e);
             TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, TimeTrackerUtility.createExceptionLogString(e),
                 Datetime.now(), null, null, null, UserInfo.getUserId());
        }
        finally
        {
            TimeTrackerUtility.upsertLogRecord();
        }
        return null;
    }
    
    private Boolean checkTimerFormat(String timer) {
        
        String timerRegEx = '([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]';
        Pattern MyPattern = Pattern.compile(timerRegEx);
        Matcher MyMatcher = MyPattern.matcher(timer);
        Boolean result = MyMatcher.matches();
        return result;
    }
}