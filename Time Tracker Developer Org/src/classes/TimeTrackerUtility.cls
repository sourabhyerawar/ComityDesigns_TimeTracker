/**
* @description a class containing Utility methods.
*
*/
global with sharing class TimeTrackerUtility {
    private static Map<String, Schema.SObjectType> sobjectSchemaMap;
    
    /**
    *  @Description : Retrieve the specific Schema.SobjectType for a object so we can inspect it
    */
    public static Map<String, Schema.SObjectType> getAllObjectSchema()
    {
       TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerUtility.getAllObjectSchema method.',
           Datetime.now(), null, null, null, UserInfo.getUserId());
        if(sobjectSchemaMap == null || sobjectSchemaMap.isEmpty())
        {
            sobjectSchemaMap = Schema.getGlobalDescribe();
        }
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerUtility.getAllObjectSchema method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'sobjectSchemaMap: ' + sobjectSchemaMap,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        return sobjectSchemaMap;
     }
    
     /**
        @ Purpose : Returns salesforce base url.
     */
     public static String getSalesforceBaseURL(){
         return URL.getSalesforceBaseUrl().toExternalForm();
     }

     /**
     *  @Description : Get Time-tracker permission sets Id, label and name
     */
     public static Map<Id, String> getTimeTrackerPermissionSetIds(){
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerUtility.getTimeTrackerPermissionSetIds method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
         Map< Id, String> reqMap = new Map<Id,String>();
         List<PermissionSet> reqLst= [SELECT Id,Label,Name FROM PermissionSet WHERE Name IN ( 'Time_Tracker_Permission_Set','Time_Tracker_Admin_Permission_Set')];
         for(PermissionSet ps: reqLst){
             reqMap.put(ps.Id,ps.Label);
         }
         TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerUtility.getTimeTrackerPermissionSetIds method.',
             Datetime.now(), null, null, null, UserInfo.getUserId());
         TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'reqMap: ' + reqMap,
             Datetime.now(), null, null, null, UserInfo.getUserId());
        return reqMap;
     }

     /**
     *  @Description : Method to return all those Permission-set names from Time-tracker product assigned to given user
     */
     public static Set<String> getPermissionSetAssignmentForUser(Id usrId){
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerUtility.getPermissionSetAssignmentForUser method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'usrId: ' + usrId,
            Datetime.now(), null, null, null, UserInfo.getUserId());
         Map<Id, String> prmsets = getTimeTrackerPermissionSetIds();
         set<Id> prmsetsIds = prmsets.keySet();
         List<PermissionSetAssignment> prmSetAssignment = [SELECT AssigneeId,Id,PermissionSetId FROM PermissionSetAssignment WHERE PermissionSetId IN: prmsetsIds  AND AssigneeId =: usrId];
         Set<String> finalNames = new Set<String>();
         for(PermissionSetAssignment psa: prmSetAssignment){
             finalNames.add(prmsets.get(psa.PermissionSetId));
         }
         TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerUtility.getPermissionSetAssignmentForUser method.',
             Datetime.now(), null, null, null, UserInfo.getUserId());
         TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'finalNames: ' + finalNames,
             Datetime.now(), null, null, null, UserInfo.getUserId());
         return finalNames;
     }

    /**
     * @description Method to get all Potential Time-tracker Records for Actions to be excluded using Timestamp
     * @param Time_Tracker__c: strtTT
     * @param Time_Tracker__c: endTT
     * @param String[]: excludeActions
     */
    public static Decimal getExcludeAcionsDuration_UsingTimestampNParentId(Long strtTT, Long endTT, String parentId,Set<String> excludeActions) {
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerUtility.getExcludeAcionsDuration_UsingTimestampNParentId method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'strtTT: ' + strtTT + '; endTT: ' + endTT + '; parentId: '
            + parentId + '; excludeActions: ' + excludeActions,
            Datetime.now(), null, null, null, UserInfo.getUserId());

        Decimal deduct = 0;
         if(parentId!=null && strtTT!=null && endTT!=null) {
            AggregateResult[] groupedResults =  [SELECT SUM(Duration2__c)
                                                   FROM Time_Tracker__c
                                                   WHERE Opening_Action__c IN : excludeActions 
                                                   AND Activity_Time__c >: strtTT
                                                   AND Activity_Time__c <: endTT
                                                   AND Parent_Object_Id__c =: parentId
                                                   AND CreatedById = :UserInfo.getUserId()];

            TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'groupedResults: ' + groupedResults,
                Datetime.now(), null, null, null, UserInfo.getUserId());

            if(groupedResults[0].get('expr0')!=null){
                deduct = (Decimal)groupedResults[0].get('expr0');
            }
        }
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerUtility.getExcludeAcionsDuration_UsingTimestampNParentId method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'deduct: ' + deduct,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        return deduct;
    }
    
    /**
    * @description method to calculate Time-difference between End-event and Start-event
    * @param Time_Tracker__c: closingTTRec
    * @param Time_Tracker__c: openingTTRec
    */
    public static Decimal getDecimalTimeDifference(Time_Tracker__c closingTTRec, Time_Tracker__c openingTTRec){
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerUtility.getDecimalTimeDifference method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'closingTTRec: ' + closingTTRec + ';openingTTRec: ' + openingTTRec,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        Decimal decTimeDiff = 0;
        decTimeDiff = Decimal.valueOf((closingTTRec.Activity_Date__c.getTime()) - (openingTTRec.Activity_Date__c.getTime())) / 1000;

        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerUtility.getDecimalTimeDifference method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'decTimeDiff: ' + decTimeDiff,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        return math.abs(decTimeDiff);
    }

    /**
    * @Description : Method to return set of Exclude-actions from given Comma-separated string.
    */
    public static Set<String> getExcludeActions(String activitySetting_Text5){
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerUtility.getExcludeActions method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'activitySetting_Text5: ' + activitySetting_Text5,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        Set<String> excludeActions = new Set<String>();
        if(String.isBlank(activitySetting_Text5)) return excludeActions;

        for(String action: activitySetting_Text5.split(';')){
            if(String.isBlank(action)) continue;

            excludeActions.add( action.trim() );
        }

        /*excludeActions = activitySetting_Text5.split(';');
        for(integer i=0; i<excludeActions.size();i++){
            if(String.isBlank(excludeActions[i])) continue;

            excludeActions[i] = excludeActions[i].trim();
        }*/
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerUtility.getExcludeActions method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'excludeActions: ' + excludeActions,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        return excludeActions;
    }

    /**
    * @description method to create new Timesheet record
    * @param Date: dt
    * @param Id: userId
    * @return Timesheet__c: t
    */
    public static Timesheet__c createNewTimesheet(Date dt, Id userId, String name) {
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerUtility.createNewTimesheet method.',
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'dt: ' + dt + '; userId:' + userId + '; name: ' + name,
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        String startDayOfWeek = 'Sunday';
        //TimeTrackerUserSettings__c uSettings = TimeTrackerUserSettings__c.getInstance();
        //if(uSettings != null && String.isNotBlank(uSettings.StartDayOfWeek__c)) startDayOfWeek = uSettings.StartDayOfWeek__c;
        Timesheet__c t = new Timesheet__c();
        setTimesheetWeekDays(dt, t);
        setStartAndEndDates(t);
        t.Name = Datetime.newInstance(t.Start_Date__c, Time.newInstance(0,0,0,0)).format(TimeTrackerConstants.TIMESHEET_NAME_DATE_FORMAT) + ' - ' + name;
        t.Status__c =  TimeTrackerConstants.NEW_STR;
        t.User__c = userId;
        t.Unique_Timesheet_Identifier__c = Datetime.newInstance(t.Start_Date__c, Time.newInstance(0,0,0,0)).format(TimeTrackerConstants.TIMESHEET_NAME_DATE_FORMAT) + '-' + userId;
        
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerUtility.createNewTimesheet method.',
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 't: ' + t,
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        return t;
    }
    
    private static void setTimesheetWeekDays(Date dt, Timesheet__c t) {
        Date startDate = dt.toStartofWeek();
        String userStartDayOfWeek = Datetime.newInstance(startDate.year(), startDate.month(), startDate.day()).format('EEEE');
        //String currentDayOfWeek = Datetime.newInstance(dt.year(), dt.month(), dt.day()).format('EEEE');
        
        if(userStartDayOfWeek.equalsIgnoreCase('sunday')){
            t.Sunday__c = startDate;
            t.Monday__c = startDate.addDays(1);
            t.Tuesday__c = startDate.addDays(2);
            t.Wednesday__c = startDate.addDays(3);
            t.Thursday__c = startDate.addDays(4);
            t.Friday__c = startDate.addDays(5);
            t.Saturday__c = startDate.addDays(6);            
        } else if (userStartDayOfWeek.equalsIgnoreCase('monday')){
            t.Sunday__c = startDate.addDays(-1);
            t.Monday__c = startDate;
            t.Tuesday__c = startDate.addDays(1);
            t.Wednesday__c = startDate.addDays(2);
            t.Thursday__c = startDate.addDays(3);
            t.Friday__c = startDate.addDays(4);
            t.Saturday__c = startDate.addDays(5);
        } else if(userStartDayOfWeek.equalsIgnoreCase('saturday')){
            t.Saturday__c = startDate;            
            t.Sunday__c = startDate.addDays(1);
            t.Monday__c = startDate.addDays(2);
            t.Tuesday__c = startDate.addDays(3);
            t.Wednesday__c = startDate.addDays(4);
            t.Thursday__c = startDate.addDays(5);
            t.Friday__c = startDate.addDays(6);
        }
    }
    
    private static void setStartAndEndDates(Timesheet__c t) {
        t.Start_Date__c = t.Sunday__c;
        t.End_Date__c = t.Saturday__c;
    }
    
    /**
    * @description method to create new Timesheet Entry record
    * @param String: activity
    * @param Date: dt
    * @param String: timeSpent
    * @param Id: timesheetId
    * @return Timesheet_Entry__c: tse
    */
    public static Timesheet_Entry__c createNewTimesheetEntry(String activity, Date dt, String timeSpent, Id timesheetId, Id userId) {
        Timesheet_Entry__c tse = new Timesheet_Entry__c();
        tse.Activity__c = activity;
        tse.Activity_Date__c = dt;
        tse.Time_Spent__c = timeSpent;
        tse.Timesheet__c = timesheetId;
        tse.Unique_TimesheetEntry_Identifier__c = Datetime.newInstance(dt, Time.newInstance(0,0,0,0)).format(TimeTrackerConstants.TIMESHEETENTRY_UNIQUE_DATE_FORMAT) + '-' + userId + '-' + activity;

        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'Returned: tse: ' + tse,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        return tse;
    }
    
    /**
    * @description method tp get locked timesheets for current week 
    * @param Date: todaysDate
    * @param Set<Id>: userIdsSet(Set of user-ids to get timesheet-id)
    * @return Map<Id, Timesheet__c>: will return locked timesheets
    */
    public static Map<Id, Timesheet__c> getLockedTimesheets(Date todaysDate, Set<Id> userIdsSet) {
        Map<Id, Timesheet__c> timesheets = new Map<Id, Timesheet__c>();
        Timesheet__c tempTimesheet = new Timesheet__c();
        Set<String> uniqueKeysSet= new Set<String>();
        setTimesheetWeekDays(todaysDate, tempTimesheet);
        setStartAndEndDates(tempTimesheet);
        String timesheetSuffixFormat = Datetime.newInstance(tempTimesheet.Start_Date__c, Time.newInstance(0,0,0,0)).format(TimeTrackerConstants.TIMESHEET_NAME_DATE_FORMAT);

        try {
            for(Id userId: userIdsSet) {
                String uniqueKey =  timesheetSuffixFormat + '-' + userId;
                uniqueKeysSet.add(uniqueKey);
            }
            
            TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'In getLockedTimesheets-UniqueKeysSet: \n ' + uniqueKeysSet,
            Datetime.now(), null, null, null, UserInfo.getUserId());
            
            if(uniqueKeysSet!=null && !uniqueKeysSet.isEmpty()) {
                 timesheets =  new Map<ID, Timesheet__c>([  SELECT Id, Status__c
                                                            FROM Timesheet__c
                                                            WHERE (Status__c = :TimeTrackerConstants.SUBMITTED_STR OR Status__c = :TimeTrackerConstants.APPROVED_STR)
                                                            AND Unique_Timesheet_Identifier__c IN :uniqueKeysSet]);
            }
        } catch( Exception ex) {
            TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'EXCEPTION IN TimeTrackerUtility.getLockedTimesheets(), details: ' + ex,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        }
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'timesheets: ' + timesheets,
        Datetime.now(), null, null, null, UserInfo.getUserId());
        return timesheets;
    }

    /**
    * @description method to create new TimeTracker record
    * @param String: activityDate
    * @param String: clientId
    * @param String: action
    * @param String: actionCategory
    * @param String: caseId
    * @param String: tabId
    * @param String: openingAction
    * @param String: documentId
    * @param String: source
    * @return Time_Tracker__c: tt
    */
    public static Time_Tracker__c createNewTimeTracker(String activityDate, String clientId, String action, String actionCategory,
                                                        String caseId, String tabId, String openingAction, String documentId,
                                                        String source, Id tseId, String userId) {
        Time_Tracker__c tt = new Time_Tracker__c();
        tt.Activity_Date__c = (String.isNotBlank(activityDate)) ? convertDate(activityDate) : system.now();
        //tt.Client_ID__c = (String.isNotBlank(clientId)) ? clientId : null;
        tt.Action__c = (String.isNotBlank(action)) ? action : '';
        tt.Action_Category__c = (String.isNotBlank(actionCategory)) ? actionCategory : '';
        tt.Case__c = (String.isNotBlank(caseId)) ? caseId : null;
        //tt.Tab_ID__c = (String.isNotBlank(tabId)) ? tabId : '';
        tt.Opening_Action__c = (String.isNotBlank(openingAction)) ? openingAction : '';
        tt.DocumentId__c = (String.isNotBlank(documentId)) ? documentId : '';
        tt.Source__c = (String.isNotBlank(source)) ? source : '';

        if(String.isNotBlank(tseId)) {
            tt.Timesheet_Entry__c = tseId;
        }

        if(String.isNotBlank(userId)) {
            tt.User__c = userId;
        }

        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'Returned: tt: ' + tt,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        return tt;
    }

    /**
    * @description method to create new TimeTracker record
    * @param String: activityDate
    * @param String: clientId
    * @param String: action
    * @param String: actionCategory
    * @param String: caseId
    * @param String: tabId
    * @param String: openingAction
    * @param String: documentId
    * @param String: source
    * @return Time_Tracker__c: tt
    */
    public static Time_Tracker__c createTimeTracker(String action, String activityDate, String activityTime,
                                                    String openingAction, String openingActivityDate, String openingActivityTime,
                                                    String caseId, String documentId,
                                                    Id tseId, String userId) {
        Time_Tracker__c tt = new Time_Tracker__c();

        tt.Action__c = (String.isNotBlank(action)) ? action : '';
        tt.Activity_Date__c = (String.isNotBlank(activityDate)) ? convertDate(activityDate) : system.now();
        tt.Activity_Time__c = (String.isNotBlank(activityTime))? Long.valueOf(activityTime): null;

        tt.Opening_Action__c = (String.isNotBlank(openingAction)) ? openingAction : '';
        tt.Opening_Activity_Date__c = (String.isNotBlank(activityDate)) ? convertDate(activityDate) : system.now();
        tt.Opening_Activity_Time__c = (String.isNotBlank(openingActivityTime))? Long.valueOf(openingActivityTime): null;

        tt.Case__c = (String.isNotBlank(caseId)) ? caseId : null;
        tt.DocumentId__c = (String.isNotBlank(documentId)) ? documentId : '';

        if(String.isNotBlank(tseId)) {
            tt.Timesheet_Entry__c = tseId;
        }

        if(String.isNotBlank(userId)) {
            tt.User__c = userId;
        }

        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'Returned: tt: ' + tt,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        return tt;
    }

    /**
    * @description method to convert the Javascript date string to Salesforce Datetime
    * @param String: Javascript date string
    * @return Datetime: value
    */
    public static Datetime convertDate(String dateStr) {
        return DateTime.newInstance(Long.valueOf(dateStr));
    }

    /**
    * @description method to return the namespace prefix
    */
    private static String namespacePrefix;
    @AuraEnabled
    public static String getNamespace()
    {
        if(namespacePrefix == null)
        {
            namespacePrefix = TimeTrackerUtility.class.getName().substringBefore( 'TimeTrackerUtility' );
            if( String.isNotBlank( namespacePrefix ) ) {
                namespacePrefix = namespacePrefix.subString( 0, namespacePrefix.length() - 1 ) + '__';
            }
        }

        return namespacePrefix;
    }
    
    /**
        @ Purpose : Prints the details of exception and returns the same.
    */
    global static String createExceptionLogString(Exception exc){
        String exceptionLog =   'CAUSE::' + exc.getCause() + '\n'
                                +'TYPE::' + exc.getTypeName() + '\n'
                                +'LINE NUMBER::' + exc.getLineNumber() + '\n'
                                +'MESSAGE::' + exc.getMessage() + '\n'
                                +'STACK TRACE::' + exc.getStackTraceString();

        return exceptionLog;
    }
    
    /**
        @ Purpose : Returns the details of the database error.
    */
    global static String createErrorLogString(Database.Error err){
        String errorLog =   'STATUS CODE::' + err.getStatusCode() + '\n'
                            +'MESSAGE::' + err.getMessage() + '\n'
                            +'Fields AFFECTED ERROR CONDITION::' + err.getFields();
        return errorLog;
    }

    /**
    * @description method to retrieve the Timesheet record, if the Timesheet record does not exist then it is created
    * @param Date: todaysDate
    * @param userId: user-Id for which Timesheet-to be returned
    * @return List<Timesheet_Entry__c>: tseList
    */
    public static Id getTimesheetRecordIdForUser(Date todaysDate, Id userId) {
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerUtility.getTimesheetRecordIdForUser method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'todaysDate: ' + todaysDate,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        Id timesheetId = null;
        Database.SaveResult sr = null;
        Timesheet__c tempTimesheet = new Timesheet__c();
        setTimesheetWeekDays(todaysDate, tempTimesheet);
        setStartAndEndDates(tempTimesheet);
        String uniqueKey = Datetime.newInstance(tempTimesheet.Start_Date__c, Time.newInstance(0,0,0,0)).format(TimeTrackerConstants.TIMESHEET_NAME_DATE_FORMAT) + '-' + userId;
        List<Timesheet__c> timesheets = [Select Id, Status__c
                                         From Timesheet__c
                                         Where Unique_Timesheet_Identifier__c = :uniqueKey];
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'timesheets: ' + timesheets,
            Datetime.now(), null, null, null, UserInfo.getUserId());

        if (timesheets != null && !timesheets.isEmpty()) {
            Timesheet__c reqTimesheet = timesheets.get(0);
            if (reqTimesheet.Status__c != TimeTrackerConstants.NEW_STR
                && reqTimesheet.Status__c != TimeTrackerConstants.REJECTED_STR
                && reqTimesheet.Status__c != TimeTrackerConstants.RECALLED_STR) {
                //Error handling to inform user that the timesheet for the period is locked
                // and we cannot add the timesheet
                
                TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Timesheet for Activity-date ' + todaysDate + ' is locked with Status'
                    + reqTimesheet.Status__c, Datetime.now(), null, null, null, UserInfo.getUserId());

            } else {
                timesheetId = reqTimesheet.Id;
            }
        } else {
            // create new Timesheet record for current week
            if(userId!=null){
                String userName = '';
                if(userId!=UserInfo.getUserId()){
                    User usr = [SELECT Name FROM User WHERE Id =: userId];
                    userName = ''+usr.Name;
                } else{
                    userName = UserInfo.getName();
    }

                Timesheet__c timesheet = createNewTimesheet(todaysDate, userId, userName);
                Database.SaveResult srt = Database.insert(timesheet, false);

                if (srt.isSuccess()) {
                    timesheetId = srt.getId();
                }
                else {
                    // Operation failed, so get all errors
                    for(Database.Error err : srt.getErrors()) {

                        String statusCode = '' + err.getStatusCode();
                        //  This scenario later observed in Production when multiple Timesheet's creation was initiated
                        // at same time before any record is commited to Database.
                         if (statusCode.contains('DUPLICATE_VALUE')) {
                            String errorLog = createErrorLogString(err);
                            TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, errorLog, Datetime.now(), null, null, null, UserInfo.getUserId());

                            timesheets = [Select Id, Status__c
                                         From Timesheet__c
                                         Where Unique_Timesheet_Identifier__c = :uniqueKey];
                            if (timesheets != null && !timesheets.isEmpty()) {
                                timesheetId = timesheets.get(0).Id;
                            }
                        } else {
                            String errorLog = createErrorLogString(err);
                            TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, errorLog, Datetime.now(), null, null, null, UserInfo.getUserId());
                        }
                    }
                }
            }
        }
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerUtility.getTimesheetRecordIdForUser method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'Returned: timesheetId: ' + timesheetId,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        return timesheetId;
    }
    
    /**
    * @description method to calculate Time spent in hh:mm:ss format
    * @param: time spent in seconds
    * @return: String as hh:mm:ss
    */
    global static String calculateTimeSpent(Decimal timeSpentInSeconds) {
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerUtility.calculateTimeSpent method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'timeSpentInSeconds: ' + timeSpentInSeconds,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        String retVal = '00:00:00';
        if(timeSpentInSeconds > 0) {
            Integer hours = Integer.valueOf(Math.floor(timeSpentInSeconds/3600));
            Integer minutes = Integer.valueOf(Math.floor((timeSpentInSeconds  - (hours * 3600))/60));
            Integer seconds = Integer.valueOf(timeSpentInSeconds  - (hours * 3600) - (minutes * 60));

            retVal = (hours < 10 ? '0' + String.valueOf(hours) : String.valueOf(hours)) + ':' +
                    (minutes < 10 ? '0' + String.valueOf(minutes) : String.valueOf(minutes)) + ':' +
                    (seconds < 10 ? '0' + String.valueOf(seconds) : String.valueOf(seconds));
        }

        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerUtility.calculateTimeSpent method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'retVal: ' + retVal,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        return retVal;
    }

    public static List<ManualLineItem__c> mItemsForUser = new List<ManualLineItem__c>();
    
    /**
        @ Purpose : 1. Returns the list of Manual Line Items created by logged in user except today's records.
                    2. And the records whose ids are not stored in MIL field of the received time tracker record.
    */
    public static List<ManualLineItem__c> getPast1DayManualLineItemsForUser(Time_Tracker__c tt){

      if(mItemsForUser.isEmpty()){
        List<String> mliIds = splitManualLineItems(tt);
        mItemsForUser = [ SELECT Id,Engage_Time__c, Disengage_Time__c 
                          FROM ManualLineItem__c 
                          WHERE CreatedById = :UserInfo.getUserId() AND Engage_Time__c = LAST_N_DAYS:1 AND Id NOT IN :mliIds
                        ];
      }
      return mItemsForUser;
    }
    
    /**
        @ Purpose : Split the contents of MLI field of time tracker record by ';' and returns the list of string tokens.
    */
    public static List<String> splitManualLineItems(Time_Tracker__c tt) {
        if(String.isBlank(tt.MLI__c)) return new List<String>();
        List<String> mliItemIds = (List<String>)  tt.MLI__c.split(';');
        return mliItemIds;
    }
    
    /**
        @ Purpose : 1. Returns the list of Manual Line Items created by logged in user except today's records.
                    2. And the records whose ids are not stored in MIL field of the received time tracker record.
    */
    global static Decimal excludeManualLineItemTime(Time_Tracker__c tt, Datetime startTime) {
        
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerUtility.excludeManualLineItemTime method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'tt: ' + tt + '; startTime: ' + startTime,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        Decimal finalDuration = 0;
        Decimal duration = tt.Duration__c;
        Datetime endTime = tt.Activity_Date__c;
        Decimal excludeTime = 0;
		
        // Added this code snippet to exclude time in lightning experience too.
        if( startTime == NULL && tt.Action_Closed__c == TRUE ) {
            startTime = tt.Activity_Date__c.addSeconds( - Integer.valueOf( tt.Duration__c ) );
        }
        
        try {
            if(startTime == null || endTime == null) return duration;
            // List<ManualLineItem__c> mItems = [SELECT Engage_Time__c, Disengage_Time__c FROM ManualLineItem__c WHERE CreatedById = :UserInfo.getUserId()];
            List<ManualLineItem__c> mItems = getPast1DayManualLineItemsForUser(tt);
            
            TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'In excludeManualLineItemTime-mItems: \n ' + mItems,
            Datetime.now(), null, null, null, UserInfo.getUserId());

            if(mItems == null || mItems.isEmpty()) return duration;

            Long startTimeLg =  startTime.getTime();
            Long endTimeLg =  endTime.getTime();
			
            for(ManualLineItem__c mi : mItems){
      
                Long engageTimeLg =  mi.Engage_Time__c.getTime();
                Long disEngageTimeLg = mi.Disengage_Time__c.getTime();
                
                if(startTime > mi.Engage_Time__c && endTime < mi.Disengage_Time__c) {
                    duration = 0;
                    break;
                }

                if(startTime < mi.Engage_Time__c && endTime < mi.Engage_Time__c ||
                   startTime > mi.Disengage_Time__c && endTime > mi.Disengage_Time__c) continue;

                if(startTime < mi.Engage_Time__c  && endTime > mi.Disengage_Time__c) {
                    excludeTime += (disEngageTimeLg - engageTimeLg);
                } else if (startTime < mi.Engage_Time__c  && endTime < mi.Disengage_Time__c){
                    excludeTime += (endTimeLg - engageTimeLg);
                } else if(startTime > mi.Engage_Time__c && endTime > mi.Disengage_Time__c){
                    excludeTime += (disEngageTimeLg - startTimeLg);
                }
            }
        }catch(Exception e){
            String logString = createExceptionLogString(e);
            TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, logString, Datetime.now(), null, null, null, UserInfo.getUserId());
        }    
		finalDuration = duration - (excludeTime/1000);
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerUtility.excludeManualLineItemTime method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'finalDuration: ' + finalDuration,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        return (finalDuration < 0 ? 0 : finalDuration);
    }


    /**
    * @description method to add log messages to the Time_Tracker_Log__c record
    * @param: String message
    * @return: void
    */
    private static Time_Tracker_Log__c logObj;
    private static Map<LoggingLevel, Integer> levelVsPriorityMap = new Map<LoggingLevel, Integer>{
        LoggingLevel.INFO => 1,
        LoggingLevel.DEBUG => 2,
        LoggingLevel.ERROR => 3
    };
    private static LoggingLevel userSetLoggingLevel;
    private static Integer logMaxLength = Schema.getGlobalDescribe().get(getNamespace() + 'Time_Tracker_Log__c')
    .getDescribe().fields.getMap().get(getNamespace() + 'Log__c').getDescribe().getLength();
    private static String logMessage = '';
    
    
    /**
        @ Purpose : Forms Time Tracker Log record based on the values provided to this method as parameters.
    */
    global static void addLogMessage(LoggingLevel level, String message, Datetime activityDate, String docId, String objectId,
                                     String source, Id userId)
    {
        TimeTrackerUserSettings__c userSetting = TimeTrackerUserSettings__c.getInstance();
        
        if(level != null
            && String.isNotBlank(message)
            && userSetting != null
            && userSetting.Server_Debug__c
            && String.isNotBlank(userSetting.Server_Debug_Level__c))
        {
            for(LoggingLevel lev : LoggingLevel.values())
            {
                if(userSetting.Server_Debug_Level__c.equalsIgnoreCase(String.valueOf(lev))) {
                    userSetLoggingLevel = lev;
                }
            }
            if(levelVsPriorityMap.containsKey(level)
                && userSetLoggingLevel != null
                && levelVsPriorityMap.containsKey(userSetLoggingLevel)
                && levelVsPriorityMap.get(level) >= levelVsPriorityMap.get(userSetLoggingLevel))
            {
                if(logObj == null) {
                    logObj = new Time_Tracker_Log__c();
                }
                logObj.Activity_Date__c = activityDate;
                logObj.Document_Id__c = docId;
                logMessage = (String.isNotBlank(logMessage) ? (logMessage + '\n') : '')
                    + '[' + level + ']:'
                    + message;
                if(String.isNotBlank(logMessage) && logMessage.length() > (2 * logMaxLength)) {
                    logMessage = logMessage.substring(logMessage.length() - (2*logMaxLength - 1));
                }
                // multiplied by 2 because we have two long text fields to save the log message
                logObj.Object_Id__c = objectId;
                logObj.User__c = userId;
                logObj.Source__c = source;
            }
        }
    }
    
    /**
        @ Purpose : Creates or Updates Time tracker log record based on the its id.
    */
    public static void upsertLogRecord()
    {
        if(logObj == null) {
            return;
        }
        else if(String.isNotBlank(logMessage))
        {
            if(logMessage.length() > logMaxLength) {
                logObj.Log__c = logMessage.substring(0, logMaxLength - 1);
                logObj.Log2__c = logMessage.substring(logMaxLength);
            }
            else {
                logObj.Log__c = logMessage;
                logObj.Log2__c = '';
            }
            System.debug(LoggingLevel.ERROR, '--++--logObj.Log__c : ' + logObj.Log__c);
            try {
                Database.UpsertResult result = Database.Upsert(logObj);
                if(!result.isSuccess()) {
                    
                    System.debug('Error while inserting TimeTrackerLog record: ' + result.getErrors());
                }
            }
            catch(Exception ex) {
                System.debug('Error while inserting TimeTrackerLog record: [' + ex.getLineNumber() + ']: ' + ex.getMessage());
            }
        }
    }
    
    /**
        @ Purpose : Generates a Time Tracker record based on Staging Line Item record.
    */
    public static Time_Tracker__c createTTFromStagingRecord(TimeTracker_StagingLineItem__c sli, Decimal excludeActivityDuration){
        Time_Tracker__c ttRec = new Time_Tracker__c();

        //Set TimeTracker records Owner value as Staging-line-item Createdy-by field value
        ttRec.OwnerId = sli.OwnerId;

        //Copy details from Staging-line-item record
        ttRec.Action__c = sli.Activity_Name__c;
        ttRec.Opening_Action__c = sli.Activity_Name__c;

        ttRec.Object_Id__c = (sli.Object_Id__c!=null?sli.Object_Id__c:null);
        ttRec.Object_Name__c = (sli.Object_Name__c!=null?sli.Object_Name__c:null);

        ttRec.Activity_Date__c = sli.End_Date__c;
        ttRec.Activity_Time__c = sli.End_Date__c.getTime();

        ttRec.Opening_Activity_Date__c = sli.Start_Date__c;
        ttRec.Opening_Activity_Time__c = sli.Start_Date__c.getTime();

        ttRec.DocumentId__c = sli.Id;

        //Assign duration remained after exclude-duration
        ttRec.Duration__c = ((ttRec.Activity_Time__c - ttRec.Opening_Activity_Time__c)/1000) - excludeActivityDuration;

        return ttRec;        
    }
}