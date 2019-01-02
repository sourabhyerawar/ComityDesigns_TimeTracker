global class TimeTrackerController {
    
    public static string  activityLst;
    public static set<String> activity_actType_map = new set<String>();
    
    
    /**
@ Purpose : Returns a list of Text1__c field values from TimeTracker Config settings of type 'Manual'.
*/
    @RemoteAction
    public static string getactivityLst(String dummy){
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerController.getactivityLst() method.',
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        activityLst = '';
        activity_actType_map = TimeTrackerConfigSettings.getManualSettings().keySet();
        List<String> ttlst = new List<String>(activity_actType_map);
        ttlst.sort();
        if(activity_actType_map != null && !activity_actType_map.isEmpty()) {
            for(String activity: ttlst) {
                activityLst = activityLst + activity + ',';
            }
        }
        return activityLst;
    }
    
    /**
@ Purpose : This method returns the list of instances of ActivitySettings class. Each instance holds Activity name and its related Object label.
*/
    @RemoteAction
    public static List<ActivitySettings> getObjectMap(String dummy){
        
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerController.getObjectMap() method.',
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        List<ActivitySettings> listActivitySettings = new List<ActivitySettings>();
        Map<String, TimeTrackerConfigSettings__c> manualSettings = TimeTrackerConfigSettings.getManualSettings();
        for(TimeTrackerConfigSettings__c act : manualSettings.values()){
            String activityName = act.Text1__c;
            String displaySObject = act.Code1__c;
            String displaySObjectLable = '';
            if(String.isNotEmpty(displaySObject) && displaySObject.endsWith('*')){
                displaySObject = displaySObject.removeEnd('*');
            }
            displaySObjectLable = getObjectLableFromObjectApi(displaySObject);
            ActivitySettings activityObj = new ActivitySettings(activityName, displaySObjectLable);
            listActivitySettings.add(activityObj);
        }
        System.debug( 'listActivitySettings:-\n' + JSON.serialize( listActivitySettings ) );
        return listActivitySettings;
    }
    
    private static String getObjectLableFromObjectApi(String sObjectApiName){
        String sObjectFieldLable = '';
        if (String.isNotBlank(sObjectApiName)) {
            for ( Schema.SObjectType o : Schema.getGlobalDescribe().values() ) {
                Schema.DescribeSObjectResult objResult = o.getDescribe();
                if(objResult.getName() == sObjectApiName) {
                    sObjectFieldLable = objResult.getLabel();
                    break;
                }
            }
            //System.debug('sObjectFieldLable : '+sObjectFieldLable);
        }
        return sObjectFieldLable;
    }
    
    @deprecated
    @RemoteAction
    global static Boolean createTimesheetEntry(String timer, String hiddenTimer, String activityDateInMs, String activity,
                                               String caseId, String caseNumber, String accountId, String accountName,
                                               String comment)
    {
        return false;
    }
    
    /**
@ Purpose : Returns the case number from its id.
*/
    @RemoteAction
    global static String getCaseNoFromCaseId(String caseId){
        
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerController.getCaseNoFromCaseId() method.',
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'caseId: ' + caseId,
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        List<Case> givenCase = new List<Case>();
        String caseNo = '';
        if(String.isNotBlank(caseId)){
            givenCase = [SELECT Id, CaseNumber FROM Case WHERE Id = :caseId LIMIT 1];
            caseNo = givenCase.get(0).CaseNumber;
        }
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerController.getCaseNoFromCaseId() method.',
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'Returned: caseNo: ' + caseNo,
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        return caseNo;
    }
    
    
    /**
@ Purpose : Creates Manual Line items based on engage and disengage time.
*/
    @RemoteAction
    global static List<ManualLineItem__c> saveManualLineItems(String data){
        
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerController.saveManualLineItems() method.',
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'data: ' + data,
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        List<ManualLineItem__c> manualLineItems = new List<ManualLineItem__c>();
        try {
            for(Object obj : (List<Object>) JSON.deserializeUntyped(data)) {
                Map<String, Object> objMap = (Map<String, Object>) obj;
                ManualLineItem__c mli = new ManualLineItem__c();
                mli.Engage_Time__c = objMap.containsKey('Engage_Time__c') ? TimeTrackerUtility.convertDate(String.valueOf(objMap.get('Engage_Time__c'))) : null;
                mli.Disengage_Time__c = objMap.containsKey('Disengage_Time__c') ? TimeTrackerUtility.convertDate(String.valueOf(objMap.get('Disengage_Time__c'))) : null;
                manualLineItems.add(mli);
            }
            //System.debug('manualLineItems  :  '+manualLineItems);
            insert manualLineItems;
        } catch(Exception e) {
            TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, TimeTrackerUtility.createExceptionLogString(e),
                                             Datetime.now(), null, null, null, UserInfo.getUserId());
        }
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerController.saveManualLineItems() method.',
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'Returned: manualLineItems: ' + manualLineItems,
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        return manualLineItems;
    }
    
    
    /**
@ Purpose : Creates Manual Line items based on engage and disengage time.
*/
    @RemoteAction
    public static String doCreateTimesheetEntry(String timer, String hiddenTimer, String activityDateStr, String activity,
                                                String sObjetId, String sObjectValue, String comment)
    {
        
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerController.doCreateTimesheetEntry() method.',
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, '@@ timer::'+timer+' hiddenTimer::'+hiddenTimer+' activityDateStr::'+ activityDateStr+' activity::'+activity
                                         +' sObjetId::'+sObjetId+' sObjectValue::'+sObjectValue+' comment::'+comment,
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        
        String retVal = TimeTrackerConstants.FALSE_TEXT;
        try
        {
            TimeTrackerConfigSettings__c activityDetails  = TimeTrackerConfigSettings.getactivityvsActivityDetails().get(activity);
            TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Activity Details Returned for Activity: '+ activity + '::'+ activityDetails,
                                             Datetime.now(), null, null, null, UserInfo.getUserId());
            TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'Activity Datetime: '+ activityDateStr,
                                             Datetime.now(), null, null, null, UserInfo.getUserId());
            
            String actionCategory = activityDetails.Text3__c;
            if(String.isBlank(activityDateStr)) { return TimeTrackerConstants.ERROR_OCCURRED_TEXT; }
            Datetime activityDate = TimeTrackerLocaleToDateFormat.convertStringToDate(activityDateStr);
            
            Time_Tracker__c tt = new Time_Tracker__c();
            tt.Action__c = activity;
            tt.Opening_Action__c = activity;
            tt.Action_Category__c = actionCategory;
            tt.Source__c = TimeTrackerConstants.MANUAL_STR;
            tt.Action_Closed__c = true;
            tt.User__c = UserInfo.getUserId();
            tt.Duration__c = (String.isNotBlank(hiddenTimer)) ? Integer.valueOf(hiddenTimer) : 0;
            tt.Time_Spent__c = String.isNotBlank(timer) ? timer : '';
            tt.Activity_Time__c = activityDate.getTime();
            tt.Activity_Date__c = activityDate;
            tt.Comment__c = String.isNotBlank(comment) && (comment.length() > 255) ? comment.substring(0, 254) : comment;
            
            //Values from Custom-settings
            tt.IsBillable__c = activityDetails.Flag1__c;
            tt.IsUtilized__c = activityDetails.Flag2__c;
            tt.Non_Reportable__c = activityDetails.Flag3__c;
            System.debug('TT : '+tt);
            //Validate sObject using code2 and code1 fields from manual custom settings
            sObject typeAheadObjectCheck = getSObjectDetailsFromActivityAndSObjectValue(activity, sObjetId);
            if(String.isNotBlank(sObjectValue)){
                if(typeAheadObjectCheck==null) {
                    tt.Object_Id__c = sObjetId;
                    return System.Label.ERR_Invalid_SObject; 
                } else tt.Object_Id__c = typeAheadObjectCheck.Id;
            }
            System.debug('typeAheadObjectCheck : '+typeAheadObjectCheck);
            TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Manual Activity TimeTracker record to be inserted ::' + tt,
                                             Datetime.now(), null, null, null, UserInfo.getUserId());
            
            Database.SaveResult sr = Database.insert(tt, false);
            System.debug('sr : '+sr);
            if(sr.isSuccess()) {
                retVal = TimeTrackerConstants.TRUE_TEXT;
                //Check whether timesheet for current week is locked
                String timesheet = getTimesheetId(sr.getId());
                if(String.isBlank(timesheet)) retVal = TimeTrackerConstants.LOCKED_TEXT;
            } else {
                if(String.valueOf(sr.getErrors()).contains(TimeTrackerConstants.ERROR_TIMESHEET_LOCKED)) 
                    retVal = TimeTrackerConstants.LOCKED_TEXT;
                else{
                    TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, String.valueOf(sr.getErrors()),
                                                     Datetime.now(), null, null, null, UserInfo.getUserId());
                    retVal = TimeTrackerConstants.FALSE_TEXT;
                }
            }
        } catch(Exception ex) {
            retVal = TimeTrackerConstants.FALSE_TEXT;
            TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, TimeTrackerUtility.createExceptionLogString(ex),
                                             Datetime.now(), null, null, null, UserInfo.getUserId());
        } finally {
            TimeTrackerUtility.upsertLogRecord();
        }
        
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Ended TimeTrackerController.doCreateTimesheetEntry() method.',
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'Returned: retVal: ' + retVal,
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        
        return retVal;
    }
    
    private static String getTimesheetId(String ttId) {
        String timesheetId='';
        if(String.isBlank(ttId)) return timesheetId;
        Time_Tracker__c tt = [ SELECT Timesheet__c FROM Time_Tracker__c WHERE Id=:ttId ];
        timesheetId = tt.Timesheet__c;
        return timesheetId;
    }
    
    @TestVisible
    private static sObject getSObjectDetailsFromActivityAndSObjectValue(String activity, String sObjetId) {
        
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerController.getSObjectDetailsFromActivityAndSObjectValue() method.',
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'activity: ' + activity +', sObjetId : '+sObjetId,
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        
        sObject sObjectRecord ;
        if(String.isBlank(activity) || String.isBlank(sObjetId)) return sObjectRecord;
        TimeTrackerConfigSettings__c  currentManualSettings = new TimeTrackerConfigSettings__c();
        currentManualSettings = TimeTrackerConfigSettings.getManualSettings().get(activity);
        String code2Fields = currentManualSettings.Code2__c;
        String sObjectApiName = currentManualSettings.Code1__c;
        String sObjectSearchField = '';
        if(sObjectApiName.endsWith('*')) {
            sObjectApiName = sObjectApiName.substring(0,sObjectApiName.length()-1);
        }
        
        try {
            Id recordId = ID.valueOf( sObjetId );
            SobjectType sobjType = recordId.getSObjectType();
            String strRecordObjectApiName = sobjType.getDescribe().getName();
            if( strRecordObjectApiName == sObjectApiName ) {
                sObjectRecord = sobjType.newSObject();
                sObjectRecord.put( 'Id', sObjetId );
            }
        }
        catch( Exception e ) {
            TimeTrackerUtility.addLogMessage( LoggingLevel.INFO, 'Exceptione while validating sObject record-' + e.getMessage(),
                                             Datetime.now(), null, null, null, UserInfo.getUserId()
                                            );
        }
        
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Ended TimeTrackerController.getSObjectDetailsFromActivityAndSObjectValue() method.',
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'sObjectRecord: ' + sObjectRecord,
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        return sObjectRecord;
    }
    
    /**
* @description method to upsert the TimeTracker and TimeTrackerLog records
* @param String: inputJson
* @return String: json string
*/
    
    @AuraEnabled
    global static String createTimeTracker( String strTimeTrackerRecordJson ) {
        
        insertTimeTracker( strTimeTrackerRecordJson );
        return 'Success';
    }
    
    @RemoteAction
    global static void insertTimeTracker(String inputJson) {
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerController.insertTimeTracker() method.',
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'inputJson: ' + inputJson,
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        //system.debug('@@insertTimeTracker'+inputJson);
        if(String.isBlank(inputJson))  return;
        
        try {
            Time_Tracker__c tt = (Time_Tracker__c) JSON.deserialize(inputJson, Time_Tracker__c.class);
            if(tt == null) return;
            tt.Activity_Date__c = tt.Activity_Time__c != null ? DateTime.newInstance((Long) tt.Activity_Time__c) : System.now();
            tt.Opening_Activity_Date__c = tt.Opening_Activity_Time__c  != null ? DateTime.newInstance((Long) tt.Opening_Activity_Time__c ) : null;
            tt.Parent_Object_Id__c = String.isNotBlank(tt.Parent_Object_Id__c) ? tt.Parent_Object_Id__c : findParentId(tt);
            tt.Object_Name__c = getObjectName(tt.Object_Id__c);
            tt.Parent_Object_Name__c = getObjectName(tt.Parent_Object_Id__c);
            // Special Case: Idea Comment and Case Comment share same object prefix and we're checking if case as the parent object Id then change the action to Case Comment Review
            tt.Action__c = String.isNotBlank(tt.Action__c) && tt.Action__c.equalsIgnoreCase('Idea Comment Review') && String.isNotBlank(tt.Parent_Object_Id__c) && tt.Parent_Object_Id__c.startsWith('500') ? 'Case Comment Review' : tt.Action__c;
            tt.Opening_Action__c = String.isNotBlank(tt.Opening_Action__c) && tt.Opening_Action__c.equalsIgnoreCase('Idea Comment Review') && String.isNotBlank(tt.Parent_Object_Id__c) && tt.Parent_Object_Id__c.startsWith('500') ? 'Case Comment Review' : tt.Opening_Action__c;
            
            // Check if the New Record Document Id exists. If so, Update the time tracker with the related Object and Parent Id.
            if(String.isNotBlank(tt.New_Record_Document_Id__c)) updateTimeTracker(tt);
            //system.debug('tt===='+tt);
            insert tt;
            //system.debug('tt.Id=='+tt.Id);
            TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerController.insertTimeTracker() method.',
                                             Datetime.now(), null, null, null, UserInfo.getUserId());
        } catch(Exception e){
            TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, TimeTrackerUtility.createExceptionLogString(e),
                                             Datetime.now(), null, null, null, UserInfo.getUserId());
        }
        finally
        {
            TimeTrackerUtility.upsertLogRecord();
        }
        // If Time Tracker Log exists then insert;
    }
    
    private static void updateTimeTracker(Time_Tracker__c tt) {
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerController.updateTimeTracker() method.',
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'tt: ' + tt,
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        List<Time_Tracker__c> ttList = new List<Time_Tracker__c>();
        List<String> documentIds = tt.New_Record_Document_Id__c.split(',');
        try {
            List<Time_Tracker__c> closedRecords = [SELECT Id, Object_Id__c, Parent_Object_Id__c
                                                   FROM Time_Tracker__c
                                                   WHERE Action_Closed__c = true
                                                   AND DocumentId__c IN :documentIds
                                                   AND CreatedById =:UserInfo.getUserId()];
            //system.debug('closedRecords==='+closedRecords);
            for(Time_Tracker__c closedRecord : closedRecords){
                closedRecord.Object_Id__c = tt.Object_Id__c;
                closedRecord.Parent_Object_Id__c = tt.Parent_Object_Id__c;
                closedRecord.Object_Name__c = tt.Object_Name__c;
                closedRecord.Parent_Object_Name__c = tt.Parent_Object_Name__c;
                ttList.add(closedRecord);
            }
            update ttList;
            //system.debug('update tList=='+ttList);
        } catch(Exception e){
            TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, TimeTrackerUtility.createExceptionLogString(e),
                                             Datetime.now(), null, null, null, UserInfo.getUserId());
        }
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerController.updateTimeTracker() method.',
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
    }
    
    private static String getObjectName(String objStr){
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerController.getObjectName() method.',
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'objStr: ' + objStr,
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        if(String.isBlank(objStr)) return null;
        try {
            Id objId = (Id) (objStr);
            return objId.getSobjectType().getDescribe().getLabel();
        } catch (Exception e){
            TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, TimeTrackerUtility.createExceptionLogString(e),
                                             Datetime.now(), null, null, null, UserInfo.getUserId());
        }
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerController.getObjectName() method.',
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        return null;
    }
    
    private static Id findParentId(Time_Tracker__c tt) {
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerController.findParentId() method.',
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'tt: ' + tt,
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        //system.debug('findParentId ==='+tt);
        if(String.isBlank(tt.Object_Id__c)) return null;
        Map<String, List<TimeTrackerConfigSettings__c>> objNameMap = TimeTrackerConfigSettings.getSettingsByType('Object Settings', 'Text1__c');
        Map<String, List<TimeTrackerConfigSettings__c>> prefixMap = TimeTrackerConfigSettings.getSettingsByType('Object Settings', 'Code1__c');
        //system.debug('objNameMap ===' + objNameMap);
        //system.debug('prefixMap ===' +prefixMap);
        String objName = null;
        String fieldName = null;
        for(String key: prefixMap.keySet()) {
            if(tt.Object_Id__c.startsWith(key)){
                List<TimeTrackerConfigSettings__c> ttcsList = prefixMap.get(key);
                if(ttcsList.isEmpty()) continue;
                objName = ttcsList[0].Text1__c;
                fieldName = ttcsList[0].Text2__c;
                break;
            }
        }
        if(String.isBlank(objName) || String.isBlank(fieldName)) {
            for(String key: objNameMap.keySet()) {
                String idObjName = ((Id) (tt.Object_Id__c)).getSobjectType().getDescribe().getName();
                if(String.isNotBlank(idObjName) && idObjName.equalsIgnoreCase(key)) {
                    List<TimeTrackerConfigSettings__c> ttcsList = objNameMap.get(key);
                    if(ttcsList.isEmpty()) continue;
                    objName = ttcsList[0].Text1__c;
                    fieldName = ttcsList[0].Text2__c;
                    break;
                }
            }
        }
        if(String.isBlank(objName) || String.isBlank(fieldName)) {
            return null;
        }
        Id objId = (Id) (tt.Object_Id__c);
        String soql = 'SELECT ' + fieldName + ' FROM ' + objName + ' WHERE Id = \'' + objId + '\'';
        //system.debug('soql==='+soql);
        
        //  Added try-catch block by Sourabh
        // To handle the exception in order to create a Time Tracker record regardless of the parent id of the record.
        // For Example, if Email message record does not have a parent id, 
        // earlier code was being failed to create a TT record due to the error--> List has no rows for assignment. [ Line no-406 ]
        try {
            SObject sObj = Database.query(soql);
            TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'sObj: ' + sObj,
                                             Datetime.now(), null, null, null, UserInfo.getUserId());
            if(sObj == null) return null; TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerController.findParentId() method.',
                                                                           Datetime.now(), null, null, null, UserInfo.getUserId());
            
            return (Id) sObj.get(fieldName);
        }
        catch( Exception e ) {
            TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, 'TimeTrackerController.findParentId - ' + TimeTrackerUtility.createExceptionLogString(e),
                                             Datetime.now(), null, null, null, UserInfo.getUserId());
        }
        return NULL;
    }
    
    private static Map<String, String> getObjectSettings() {
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerController.getObjectSettings() method.',
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        Map<String, String> prefixToObjectNameMap = new Map<String, String>();
        try {
            for(Schema.SObjectType stype : Schema.getGlobalDescribe().values()){
                Schema.DescribeSObjectResult r = stype.getDescribe();
                if(String.isNotBlank(r.getKeyPrefix())) prefixToObjectNameMap.put(r.getKeyPrefix(), r.getLabel());
            }
            TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'Returned: prefixToObjectNameMap: ' + prefixToObjectNameMap,
                                             Datetime.now(), null, null, null, UserInfo.getUserId());
            return prefixToObjectNameMap;
        } catch(Exception e){
            TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, TimeTrackerUtility.createExceptionLogString(e),
                                             Datetime.now(), null, null, null, UserInfo.getUserId());
        }
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerController.getObjectSettings() method.',
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        return null;
    }
    
    /*
@ Purpose : Returns the instance of Settings class in json format.
*/
    @RemoteAction
    global static String getSettings(String dummy) {
        try {
            return JSON.serialize(new Settings());
        } catch(Exception e){
            TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, TimeTrackerUtility.createExceptionLogString(e),
                                             Datetime.now(), null, null, null, UserInfo.getUserId());
        }
        return null;
    }
    
    /**
@ Purpose : Creates a map of static resource name with its url based on the text1__c field of Time Tracker config settings of type 'Custom Events'.
*/
    public static Map<String, String> getResourceURLs(){
        
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerController.getResourceURLs() method.',
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        Map<String, List<TimeTrackerConfigSettings__c>> ttSettings = TimeTrackerConfigSettings.getSettingsByType('Custom Event', 'Text1__c');
        Map<String, String> resourceNameToURL = new Map<String, String>();
        
        // Fetching the resource
        for(StaticResource resource: [SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = :ttSettings.keySet()]){
            String namespace = resource.NamespacePrefix;
            String url = '/resource/' + resource.SystemModStamp.getTime() + '/' + (namespace != null && namespace != '' ? namespace + '__' : '') + resource.Name;
            resourceNameToURL.put(resource.Name, url);
        }
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerController.getResourceURLs() method.',
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'Returned: resourceNameToURL: ' + resourceNameToURL,
                                         Datetime.now(), null, null, null, UserInfo.getUserId());
        return resourceNameToURL;
    }
    
    /**
@ Purpose : Returns the sobject record based on the id, object name and field names received as parameters.
*/
    @RemoteAction
    public static sObject getSObjectFieldsFromId(String objectId, String sObjectName, List<String> showFields){
        
        String soqlString='';
        sObject sObjectObj ;
        
        if(showFields.size() < 1 ) return sObjectObj;
        String showFieldsStr = String.escapeSingleQuotes( String.join( showFields, ',' ) );
        try {
            soqlString = ' SELECT Id, ' + showFieldsStr +
                ' FROM ' + sObjectName +
                ' WHERE Id =: objectId';
            //System.debug('soqlString : '+soqlString);
            sObjectObj = Database.query(soqlString);
        } catch(QueryException ex) {
            TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'Exception in TrackerController.getSObjectFieldsFromId() method, SOQL String : '+soqlString+', QueryException : ' + ex,
                                             Datetime.now(), null, null, null, UserInfo.getUserId());
        }
        return sObjectObj;
    }
    
    private static sObject getSObjectIdFromValue(String sObjectName, String searchField, String sObjectValue) {
        String soqlString='';
        sObject sObjectObj;
        List<sObject> sObjectObjList;
        
        if(String.isBlank(sObjectName) || String.isBlank(searchField) || String.isBlank(sObjectValue)) return sObjectObj;
        
        try {
            sObjectValue = sObjectValue.trim();
            // to be implement for multiple show fields
            soqlString = ' SELECT Id FROM '+sObjectName+' WHERE '+ searchField + ' = \'' + sObjectValue+'\'';
            //System.debug('###########soqlString'+soqlString);
            sObjectObjList = Database.query(soqlString);
        } catch(QueryException ex) {
            System.debug('Exception ex : '+ex);
            TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'Exception in TrackerController.getSObjectFieldsFromId() method, SOQL String : '+soqlString+', QueryException : ' + ex,
                                             Datetime.now(), null, null, null, UserInfo.getUserId());
        }
        //System.debug('###########sObjectObj'+sObjectObjList[0]);
        if(sObjectObjList!=null && !sObjectObjList.isEmpty())
            sObjectObj = sObjectObjList[0];
        
        return sObjectObj;
    }
    
    private class Settings {
        User User {get; set;}
        String OrgId {get; set;}
        String BaseUrl {get; set;}
        String Namespace {get; set;}
        TimeTrackerUserSettings__c UserSettings {get; set;}
        Map<String, TimeTrackerConfigSettings__c> ConfigSettings {get; set;}
        Map<String, String> ObjectSettings {get; set;}
        Map<String, String> ResourceURLs {get; set;}
        
        public Settings() {
            
	    User = [Select Id, Name, Email, Username, ProfileId From User Where Id=:UserInfo.getUserId()];
            OrgId = UserInfo.getOrganizationId();
            BaseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
            
            Namespace = TimeTrackerController.class.getName().substringBefore( 'TimeTrackerController' );
            if( String.isNotBlank( Namespace ) ) {
                Namespace = Namespace.subString( 0, Namespace.length() - 1 );
            }
            
            UserSettings = TimeTrackerUserSettings__c.getInstance();
            ConfigSettings = TimeTrackerConfigSettings__c.getAll();
            ObjectSettings = getObjectSettings();
            ResourceURLs = getResourceURLs();
        }
    }
    
    @TestVisible
    private class ActivitySettings {
        String activityName { get; set; }
        String displaySObjectLable { get; set; }
        
        ActivitySettings(String activityName, String displaysObjectLable) {
            this.activityName = activityName;
            this.displaySObjectLable = displaysObjectLable;
        }
    }
}