public class TimeTrackerTriggerHelper {
    private static Map<String, List<TimeTrackerConfigSettings__c>> actionStrategyMap = TimeTrackerConfigSettings.getSettingsByType(TimeTrackerConstants.STRATEGY_TYPE, TimeTrackerConstants.TEXT1_FIELD); 
    
    /**
     * Method to associate Timesheet-entries (Will create Timesheet and Timesheet-entries if not present)
     * */
    public static void associateTimesheetEntriesAndCustomSettingDetails(List<Time_Tracker__c> newList){
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerTriggerHelper.associateTimesheetEntriesAndCustomSettingDetails method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'newList: ' + newList,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        system.debug('associateTimesheetEntriesAndCustomSettingDetails start===');
        try {
            Map<Id,Map<Date, Map<String, Timesheet_Entry__c>>> userdateTseMap = TimeTrackerTriggerUtility.getUserSpecificDatevsActivityCategoryvsTimesheetEntries(newList);
            TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, '###########'+userdateTseMap,
            Datetime.now(), null, null, null, UserInfo.getUserId());

            if(userdateTseMap!=null && !userdateTseMap.isEmpty()){
                //get Timesheet Entry records Map with Activity-date as key and Acvitiy vs Timesheet-entry map for each Activity-date
                //Map<Date, Map<String, Timesheet_Entry__c>> dateTseMap = TimeTrackerTriggerUtility.getMapOfDatevsActivityCategoryvsTimesheetEntries(newList);
                //system.debug('In Before-Update timesheet-entry map'+dateTseMap);
                //associate the TimeTracker record with Timesheet Entry record
                //if(!dateTseMap.isEmpty()) {

                //Get Map of Activity-details:
                Map<String, TimeTrackerConfigSettings__c> mapOfActivityDetails = TimeTrackerConfigSettings.getactivityvsActivityDetails();

                for(Time_Tracker__c closingTTRec : newList) {

                    Map<Date, Map<String, Timesheet_Entry__c>> dateTseMap = userdateTseMap.get(closingTTRec.OwnerId);

                    if(dateTseMap!=null && !dateTseMap.isEmpty()) {
                    //Get activity-date for record
                    Date activityDate = Date.newInstance(closingTTRec.Activity_Date__c.year(), closingTTRec.Activity_Date__c.month(), closingTTRec.Activity_Date__c.day());

                    //Get activity detail from TimeTrackerConfigSettings
                    TimeTrackerConfigSettings__c activityDetails = mapOfActivityDetails.get(closingTTRec.Opening_Action__c);

                    //Associate Timesheet-Entry and Timesheet
                    if(activityDetails!=null ) {
        
                        //Check Activity falls under Cancel-type Action-category
                        if(String.isNotBlank(activityDetails.Text7__c) && closingTTRec.Action__c.equalsIgnoreCase(activityDetails.Text7__c)){
                            closingTTRec.Timesheet_Entry__c = dateTseMap.get(activityDate).get(activityDetails.Text8__c).Id;
                            closingTTRec.Timesheet__c =  dateTseMap.get(activityDate).get(activityDetails.Text8__c).Timesheet__c;
                        } else if(dateTseMap.get(activityDate).get(activityDetails.Text3__c)!=null){
                            closingTTRec.Timesheet_Entry__c = dateTseMap.get(activityDate).get(activityDetails.Text3__c).Id;
                            closingTTRec.Timesheet__c =  dateTseMap.get(activityDate).get(activityDetails.Text3__c).Timesheet__c;
                        }

                        //Set Is Billable & Utilized fields
                        closingTTRec.IsBillable__c = activityDetails.Flag1__c;
                        closingTTRec.IsUtilized__c = activityDetails.Flag2__c;
                        closingTTRec.Non_Reportable__c = activityDetails.Flag3__c;
                        closingTTRec.Action_Category__c = activityDetails.Text2__c;
                            }

                    }
                }
                //}
            }
        } catch(Exception ex) {
            TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, TimeTrackerUtility.createExceptionLogString(ex),
                Datetime.now(), null, null, null, UserInfo.getUserId());
        }
        system.debug('##Associated'+ newList);
        system.debug('associateTimesheetEntriesAndCustomSettingDetails End===');
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerTriggerHelper.associateTimesheetEntriesAndCustomSettingDetails method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
    }

    /**
    *   @Description : Method to create Staging records
    */
    public static void createStagingRecords(List<Time_Tracker__c> newList) {
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerTriggerHelper.createStagingRecords method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'newList: ' + newList,
            Datetime.now(), null, null, null, UserInfo.getUserId());

        try{
                List<TimeTracker_StagingLineItem__c> stagingRecordsToInsert = new List<TimeTracker_StagingLineItem__c>();
                //Get Map of Activity-details:
                Map<String, TimeTrackerConfigSettings__c> mapOfActivityDetails = TimeTrackerConfigSettings.getactivityvsActivityDetails();

                for(Time_Tracker__c closingTTRec : newList) {

                    //Get activity detail from TimeTrackerConfigSettings
                    TimeTrackerConfigSettings__c activityDetails = mapOfActivityDetails.get(closingTTRec.Opening_Action__c);

                    //Add Staging record if Flag-4(Create staging record) is set and Flag-3(Non-reportable) is Not-set
                    if(activityDetails!=null && activityDetails.Flag4__c && !activityDetails.Flag3__c) {
                            TimeTracker_StagingLineItem__c stgRec = new TimeTracker_StagingLineItem__c();
                            stgRec.Activity_Name__c = closingTTRec.Opening_Action__c;
                            stgRec.Start_Date__c = closingTTRec.Opening_Activity_Date__c;
                            stgRec.End_Date__c= closingTTRec.Activity_Date__c;
                            stgRec.TimeTracker_Associated__c = closingTTRec.Id;
                            //stgRec.Object_Name__c = String.isNotBlank(closingTTRec.Object_Name__c)?closingTTRec.Object_Name__c:'';
                            //stgRec.Object_Id__c = String.isNotBlank(closingTTRec.Object_Id__c)?closingTTRec.Object_Id__c:null;
                            stagingRecordsToInsert.add(stgRec);
                    }
                }

            //Insert list of Staging-records
            Database.SaveResult[] srList = Database.insert(stagingRecordsToInsert, false);

            // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                           TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, 'Successfully Inserted Staging records',
                            Datetime.now(), null, null, null, UserInfo.getUserId());
                    }
                    else {
                        // Operation failed, so get all errors
                        for(Database.Error err : sr.getErrors()) {
                            TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, TimeTrackerUtility.createErrorLogString(err),
                                Datetime.now(), null, null, null, UserInfo.getUserId());
                        }
                    }
                }

        }catch(Exception ex){
            TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, TimeTrackerUtility.createExceptionLogString(ex),
                Datetime.now(), null, null, null, UserInfo.getUserId());
        }

        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerTriggerHelper.createStagingRecords method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
    }

    private static void buildRelatedObjectsMap(Map<String, List<Id>> objNameToIdList, Time_Tracker__c tt, String objType, String fieldName) {
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerTriggerHelper.buildRelatedObjectsMap method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'objNameToIdList: ' + objNameToIdList + '; tt: ' + tt
            + ';objType: ' + objType + ';fieldName: ' + fieldName,
            Datetime.now(), null, null, null, UserInfo.getUserId());

            try{
                Id ObjOrParentObjId = (Id) tt.get(fieldName);
                if(objNameToIdList.containsKey(objType)) {
                    objNameToIdList.get(objType).add(ObjOrParentObjId);
                } else {
                    objNameToIdList.put(objType, (new List<Id> { ObjOrParentObjId }));
                }
            }catch(Exception ex){
                TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, TimeTrackerUtility.createExceptionLogString(ex),
                    Datetime.now(), null, null, null, UserInfo.getUserId());
            }
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerTriggerHelper.buildRelatedObjectsMap method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
    }
    private static void createMapOfRelatedObjects(List<Time_Tracker__c> newList,Map<String, List<Id>> objNameToIdList){
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerTriggerHelper.createMapOfRelatedObjects method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());

        for(Time_Tracker__c tt: newList) {
            String objId = tt.Object_Id__c;
            String parentId = tt.Parent_Object_Id__c;

            //Check for Object-Id
            if(String.isNotBlank(objId)) {
                TimeTrackerConfigSettings__c objSettings = getRequiredObjectSettingFromPrefixMap(objId);
                if (objSettings!=null) {
                    buildRelatedObjectsMap(objNameToIdList, tt, objSettings.Text1__c, TimeTrackerConstants.OBJECTID_FIELD);
                }
            }

            //Check for Parent-Object-Id
            if(String.isNotBlank(parentId) && !parentId.equals(objId)){
                TimeTrackerConfigSettings__c objSettings = getRequiredObjectSettingFromPrefixMap(parentId);
                if (objSettings!=null) {
                    buildRelatedObjectsMap(objNameToIdList, tt, objSettings.Text1__c, TimeTrackerConstants.PARENT_OBJECTID_FIELD);
                }
            }
        }

        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerTriggerHelper.createMapOfRelatedObjects method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'Returned: objNameToIdList: ' + objNameToIdList,
            Datetime.now(), null, null, null, UserInfo.getUserId());
    }
    private static Map<String,String> getFieldMappings(TimeTrackerConfigSettings__c objSetting){
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerTriggerHelper.getFieldMappings method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'objSetting: ' + objSetting,
            Datetime.now(), null, null, null, UserInfo.getUserId());

        String txt4 = (String.isBlank(objSetting.Text4__c))?'':(objSetting.Text4__c.endsWith(';'))?objSetting.Text4__c:objSetting.Text4__c+';';
        String txt5 = (String.isBlank(objSetting.Text5__c))?'':(objSetting.Text5__c.endsWith(';'))?objSetting.Text5__c:objSetting.Text5__c+';';
        //Concatinate Text4 and Text5
        String allRawFields =  txt4 + txt5;

        //Create Map of Fields-to-be-fetched-From-Given-Object vs Fields-to-be-set-in-timetracker
        Map<String,String> fieldAPINameVsFieldInTimeTracker = new Map<String,String>();
        List<String> mapEntries = allRawFields.split(';');
        for(String mapEntry : mapEntries){
            if (String.isBlank(mapEntry)) continue;
            try{
                //Separate Lookup-field and Field-to-Update
                List<String> mapEntryDetail = mapEntry.split(':');
                if(String.isBlank(mapEntryDetail.get(0)) || String.isBlank(mapEntryDetail.get(1))){
                    TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Skipping fieldAPINameVsFieldInTimeTracker-entry for'+mapEntry,
                        Datetime.now(), null, null, null, UserInfo.getUserId());
                    continue;
                }
                fieldAPINameVsFieldInTimeTracker.put(mapEntryDetail.get(0),mapEntryDetail.get(1));
            } catch(Exception ex){
                TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Skipping fieldAPINameVsFieldInTimeTracker-entry(due to Exception) for'+mapEntry,
                    Datetime.now(), null, null, null, UserInfo.getUserId());
            }
        }
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerTriggerHelper.getFieldMappings method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'Returned: getFieldMappings: ' + fieldAPINameVsFieldInTimeTracker,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        return fieldAPINameVsFieldInTimeTracker;
    }
    private static Map<Id, SObject> getRelatedObjects(List<Time_Tracker__c> newList) {
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerTriggerHelper.getRelatedObjects method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'newList: ' + newList + ' \nObjNameVsFieldMapping:::' + ObjNameVsFieldMapping,
            Datetime.now(), null, null, null, UserInfo.getUserId());

        Map<String, List<Id>> objNameToIdList = new Map<String, List<Id>>();
        // This will fill objNameToIdList-Map
        createMapOfRelatedObjects(newList,objNameToIdList);

        Map<Id, SObject> relatedSObjectMap = new Map<Id, SObject>();

        //Iterate for All Objects we are interested In
        for(String objType :objNameToIdList.keyset()){

            if(allObjectSettings!=null){
                TimeTrackerConfigSettings__c objSetting = allObjectSettings.get(objType).get(0);
                if(objSetting!=null){

                    //Get Field-mapping for given Object
                    Map<String,String> fieldAPINameVsFieldInTimeTracker = getFieldMappings(objSetting);
                    //Update ObjectName-vs-FieldMapping Map
                    ObjNameVsFieldMapping.put(objType, fieldAPINameVsFieldInTimeTracker);

                    //Create Query
                    String allFields = '';
                    List<Id> idSet =  objNameToIdList.get(objType);
                    for(String fieldAPIName :fieldAPINameVsFieldInTimeTracker.keyset()){
                        if('id'.equalsIgnoreCase(fieldAPIName)) continue;
                        allFields += ','+fieldAPIName;
                    }
                    String query = 'SELECT Id ' + allFields + ' FROM ' + objType + ' WHERE ID IN : idSet';
                    TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Final Query for Object:'+objType+'>>>'+query,
                        Datetime.now(), null, null, null, UserInfo.getUserId());

                    //Make SOQL-call
                    try{
                        List<sobject> sobjLst = Database.query(query);
                        //Update Related-Sobject-Map with SOQL-result
                        for(sobject sobj: sobjLst){
                            relatedSObjectMap.put((ID)sobj.get('Id'),sobj);
                        }
                    }catch(Exception ex){
                        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, TimeTrackerUtility.createExceptionLogString(ex),
                                Datetime.now(), null, null, null, UserInfo.getUserId());
                    }
                }
            }
        }

        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerTriggerHelper.getRelatedObjects method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'Returned: relatedSObjectMap: ' + relatedSObjectMap,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        return relatedSObjectMap;
    }
    private static TimeTrackerConfigSettings__c getRequiredObjectSettingFromPrefixMap(String objId){
        for(String key: prefixMap.keySet()) {
            if(objId.startsWith(key)){
                List<TimeTrackerConfigSettings__c> prefix = prefixMap.get(key);
                TimeTrackerConfigSettings__c objSettings = prefix.get(0);
                return objSettings;
            }
        }
        return null;
    }

    private static Map<String, List<TimeTrackerConfigSettings__c>> prefixMap;
    private static Map<String, List<TimeTrackerConfigSettings__c>> allObjectSettings;
    private static Map<String,Map<String,String>> ObjNameVsFieldMapping = new Map<String, Map<String,String>>();
    private static Map<Id, SObject>  relatedSObjectMap;
    /**
    *   @Description : Method to fill up the Case,Account,Lead etc lookup fields
    */
    public static void populateLookupsFields(List<Time_Tracker__c> newList) {
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerTriggerHelper.populateLookupsFields method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'newList: ' + newList,
            Datetime.now(), null, null, null, UserInfo.getUserId());

        try{
            //Get required Maps
            prefixMap = TimeTrackerConfigSettings.getSettingsByType(TimeTrackerConstants.OBJECT_SETTINGS, TimeTrackerConstants.CODE1_FIELD);
            allObjectSettings = TimeTrackerConfigSettings.getSettingsByType(TimeTrackerConstants.OBJECT_SETTINGS, TimeTrackerConstants.TEXT1_FIELD);

            if(allObjectSettings==null || prefixMap==null){
                TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'Returning TimeTrackerTriggerHelper.populateLookupsFields: Either prefixMap or allObjectSettings is null' + ' \nallObjectSettings::::' +allObjectSettings + ' \nprefixMap'+prefixMap,
                    Datetime.now(), null, null, null, UserInfo.getUserId());
                return;
            }

            //Get related Objects
            relatedSObjectMap = getRelatedObjects(newList);

            for(Time_Tracker__c tt: newList){
                //Object-Id
                if(String.isNotBlank(tt.Object_Id__c)){
                    TimeTrackerConfigSettings__c objSettings = getRequiredObjectSettingFromPrefixMap(tt.Object_Id__c);
                    //Populate all remaining feild based on Object-setting configuration
                    if (objSettings!=null) {
                       populateRelatedObjectLookupFields(tt,(String)objSettings.get(TimeTrackerConstants.TEXT1_FIELD),TimeTrackerConstants.OBJECTID_FIELD);
                    }
                }
                //Parent-Object-Id
                if(String.isNotBlank(tt.Parent_Object_Id__c)) {
                    TimeTrackerConfigSettings__c objSettings = getRequiredObjectSettingFromPrefixMap(tt.Parent_Object_Id__c);
                    //Populate all remaining feild based on Object-setting configuration
                    if (objSettings!=null) {
                       populateRelatedObjectLookupFields(tt,(String)objSettings.get(TimeTrackerConstants.TEXT1_FIELD),TimeTrackerConstants.PARENT_OBJECTID_FIELD);
                    }
                }
            }
        }catch(Exception ex){
            TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, TimeTrackerUtility.createExceptionLogString(ex),
                                Datetime.now(), null, null, null, UserInfo.getUserId());
        }
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerTriggerHelper.populateLookupsFields method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
    }

    private static void populateRelatedObjectLookupFields(Time_Tracker__c tt,String ObjectName,String ObjOrParentId) {
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerTriggerHelper.populateRemainingObjectLookupFields method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'tt: ' + tt + ' ObjectName>>>>'+ObjectName+ ' ObjOrParentId>>>>'+ObjOrParentId ,
            Datetime.now(), null, null, null, UserInfo.getUserId());


                try{
                    String objId = (String) tt.get(ObjOrParentId);
                    Sobject sobj = relatedSObjectMap.get(objId);

                    if(sobj==null){
                        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerTriggerHelper.populateRemainingObjectLookupFields method.(sobj for given Object/Parent-Object-Id is Null)',
                            Datetime.now(), null, null, null, UserInfo.getUserId());
                        return;
                    }

                    Map<String,String> FieldMappingForObject = ObjNameVsFieldMapping.get(ObjectName);
                    for(String sobjfield: FieldMappingForObject.keyset()){
                        String ttField = FieldMappingForObject.get(sobjfield);

                        try{
                            //Ignore if TimeTracker-field already contains some value
                            if(String.isBlank((String) tt.get(ttField))){
                                //Simple-field
                                if(!sobjfield.contains('.')){
                                    tt.put(ttField,sobj.get(sobjfield));
                                }else{
                                    List<String> fieldDetails = sobjfield.split('\\.');
                                    Sobject sobjFinal = sobj;
                                    //Traverse the sobjects
                                    for(integer i=0;i<(fieldDetails.size()-1);i++){
                                        sobjFinal = sobjFinal.getSobject(fieldDetails.get(i));
                                    }
                                    String fieldName = fieldDetails.get(fieldDetails.size()-1);
                                    if( sobjFinal != NULL ) {
                                    	tt.put(ttField,sobjFinal.get(fieldName));
                                    }
                                }
                            }
                        }catch(Exception ex){
                            TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, TimeTrackerUtility.createExceptionLogString(ex)+'(Confirm Field is present on TimeTracker)',
                                Datetime.now(), null, null, null, UserInfo.getUserId());
                        }
                    }
                }catch(Exception ex){
                    TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, TimeTrackerUtility.createExceptionLogString(ex),
                        Datetime.now(), null, null, null, UserInfo.getUserId());
                }
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerTriggerHelper.populateRemainingObjectLookupFields method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
    }


    /**
    *   @Description : Method to Calculate and exclude time on Activity
    */
    public static void calculateDurationAndExcludeTime(List<Time_Tracker__c> newList) {
         TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerTriggerHelper.calculateDurationAndExcludeTime method.',
             Datetime.now(), null, null, null, UserInfo.getUserId());
         TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'newList: ' + newList,
             Datetime.now(), null, null, null, UserInfo.getUserId());
             
        
        System.debug( 'calculateDurationAndExcludeTime-newList:-\n' + JSON.serialize( newList ) );
        try{
            List<String> documentIds = new List<String>();
            List<Time_Tracker__c> openingTimeTrackers = new List<Time_Tracker__c>();
            //system.debug('@@actionStrategyMap'+actionStrategyMap);
            for(Time_Tracker__c tt: newList)
            {
                //System.debug(LoggingLevel.ERROR, '--++--tt : ' + tt);
                if(String.isBlank(tt.Opening_Action__c) || !actionStrategyMap.containsKey(tt.Opening_Action__c) || actionStrategyMap.get(tt.Opening_Action__c).isEmpty())
                { continue; }

                if(String.isNotBlank(tt.DocumentId__c)) {
                    documentIds.add(tt.DocumentId__c);
                    continue;
                }
            }
            
            System.debug( 'documentIds:-\n' + JSON.serialize( documentIds ) );
            
            Map<String, Map<String, Time_Tracker__c>> openingActionMap = buildOpeningActionMap(documentIds);
            System.debug( 'openingActionMap:-\n' + JSON.serialize( openingActionMap ) );
            
            TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'openingActionMap: ' + openingActionMap,
                Datetime.now(), null, null, null, UserInfo.getUserId());
                
            for( Time_Tracker__c closingRecord: newList ) {
                //system.debug('Processing closing Record===='+closingRecord);
                // Process only Closing Actions
                if (String.isBlank(closingRecord.Opening_Action__c)) { continue; }

                Time_Tracker__c openingActionRecord = null;
                if (openingActionMap.containsKey(closingRecord.Opening_Action__c) && openingActionMap.get(closingRecord.Opening_Action__c) != null && !openingActionMap.get(closingRecord.Opening_Action__c).isEmpty()) {
                    // Get the Opening Record
                    Map< String, Time_Tracker__c > ttMap = openingActionMap.get(closingRecord.Opening_Action__c);
                    openingActionRecord = ttMap.get(closingRecord.DocumentId__c);
                }
                //system.debug('closingRecord.Opening_Action__c===='+closingRecord.Opening_Action__c);

                // Get associated Strategy-class instance
                String strTrimmedOpeningAction = closingRecord.Opening_Action__c;
                if( String.isNotBlank( strTrimmedOpeningAction ) ) {
                    strTrimmedOpeningAction = strTrimmedOpeningAction.trim();
                }
                TimeTracker timeTrackerObj = new TimeTracker( strTrimmedOpeningAction );
                //system.debug('REQUIRED Strategy::' + timeTrackerObj);

                // Call the strategy class for duration calculation.
                timeTrackerObj.processStrategy(closingRecord, openingActionRecord);

                // Add the Opening Time Tracker Records to the List for deletion
                if(openingActionRecord != null) { openingTimeTrackers.add(openingActionRecord); }
            }
            System.debug( 'openingTimeTrackers:-\n' + JSON.serialize( openingTimeTrackers ) );
            
            // Delete the Opening Time Tracker Records
            if(!openingTimeTrackers.isEmpty()) { deleteOpeningRecords(openingTimeTrackers); }
        } catch(Exception ex){
            TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, TimeTrackerUtility.createExceptionLogString(ex),
                Datetime.now(), null, null, null, UserInfo.getUserId());
        }
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerTriggerHelper.calculateDurationAndExcludeTime method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
    }

    private static Map<String, Map<String, Time_Tracker__c>> buildOpeningActionMap(List<String> documentIds) {
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerTriggerHelper.buildOpeningActionMap method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'documentIds: ' + documentIds,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        Map<String, Map<String, Time_Tracker__c>> openingActionMap = new Map<String, Map<String, Time_Tracker__c>>();
        for(Time_Tracker__c tt :[SELECT Id, Action__c, Object_Id__c, Parent_Object_Id__c, Opening_Action__c, DocumentId__c, Activity_Date__c, Activity_Time__c
                                 FROM Time_Tracker__c
                                 WHERE DocumentId__c IN :documentIds
                                 AND Opening_Action__c = null
                                 AND Action_Closed__c = false
                                 AND CreatedById = :UserInfo.getUserId()]) {
                                     if(openingActionMap.containsKey(tt.Action__c)){
                                         openingActionMap.get(tt.Action__c).put(tt.DocumentId__c, tt);
                                     } else {
                                         openingActionMap.put(tt.Action__c, new Map<String, Time_Tracker__c> { tt.DocumentId__c => tt});
                                     }
                                 }
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerTriggerHelper.buildOpeningActionMap method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'Returned: openingActionMap: ' + openingActionMap,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        return openingActionMap;
    }

    private static void deleteOpeningRecords(List<Time_Tracker__c> ttList) {
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerTriggerHelper.deleteOpeningRecords method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'ttList: ' + ttList,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        try {
            delete ttList;
        } catch(Exception ex) {
            TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, TimeTrackerUtility.createExceptionLogString(ex),
                Datetime.now(), null, null, null, UserInfo.getUserId());
        }
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerTriggerHelper.deleteOpeningRecords method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
    }

    public static void rollUpNewTimesheetEntries(List<Time_Tracker__c> newList) {
        
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerTriggerHelper.rollUpNewTimesheetEntries method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'newList: ' + newList,
            Datetime.now(), null, null, null, UserInfo.getUserId());
      //  system.debug('@@rollUpNewTimesheetEntries entered.');
        String namespacePrefix = TimeTrackerUtility.getNamespace();

        try {
            // Roll up the duration to Timsheet Entry record(s)
            List<TimeTrackerRollupUtil.FieldDefinition> fieldDefinitions =
                new List<TimeTrackerRollupUtil.FieldDefinition> {
                    new TimeTrackerRollupUtil.FieldDefinition('SUM', namespacePrefix + 'Duration2__c', namespacePrefix + 'Tracked_Duration__c')
                };

            String queryFilter = 'AND ' + namespacePrefix + 'Action_Closed__c = true '
                                 +'AND ' + namespacePrefix + 'Non_Reportable__c = false';

            // roll up to Timesheet Entry
            TimeTrackerRollupUtil.rollUpTrigger(fieldDefinitions, newList, namespacePrefix + 'Time_Tracker__c',
                                                namespacePrefix + 'Timesheet_Entry__c', namespacePrefix + 'Timesheet_Entry__c',
                                                queryFilter);
        }catch(Exception ex) {
            TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, TimeTrackerUtility.createExceptionLogString(ex),
                Datetime.now(), null, null, null, UserInfo.getUserId());
        }
        //system.debug('@@rollUpNewTimesheetEntries exit.');
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerTriggerHelper.rollUpNewTimesheetEntries method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
    }

    public static void rollUpOldTimesheetEntries(List<Time_Tracker__c> newList, Map<Id,Time_Tracker__c> oldMap){
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerTriggerHelper.rollUpOldTimesheetEntries method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'newList: ' + newList + '; oldMap: ' + oldMap,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        //system.debug('@@rollUpOldTimesheetEntries entered.');
        String namespacePrefix = TimeTrackerUtility.getNamespace();

        try{
            // Roll up the duration to Timsheet Entry record(s)
            List<TimeTrackerRollupUtil.FieldDefinition> fieldDefinitions =
                new List<TimeTrackerRollupUtil.FieldDefinition> {
                    new TimeTrackerRollupUtil.FieldDefinition('SUM', namespacePrefix + 'Duration2__c', namespacePrefix + 'Tracked_Duration__c')
                };

            String queryFilter = 'AND ' + namespacePrefix + 'Action_Closed__c = true '
                                 +'AND ' + namespacePrefix + 'Non_Reportable__c = false';

            //Update Older Timesheet-Entries
            List<Time_Tracker__c> forOlderTSEtoUpdate = new List<Time_Tracker__c>();
            for(Time_Tracker__c tt : newList) {
                Time_Tracker__c olderTT = oldMap.get(tt.Id);
                if( tt.Timesheet_Entry__c != olderTT.Timesheet_Entry__c){
                    forOlderTSEtoUpdate.add(olderTT);
                }
            }

            if(forOlderTSEtoUpdate!=null && forOlderTSEtoUpdate.size()>0) {
                // roll up to Timesheet Entry
                TimeTrackerRollupUtil.rollUpTrigger(fieldDefinitions, forOlderTSEtoUpdate, namespacePrefix + 'Time_Tracker__c',
                                                    namespacePrefix + 'Timesheet_Entry__c', namespacePrefix + 'Timesheet_Entry__c',
                                                    queryFilter);
            }
        }catch(Exception ex) {
            TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, TimeTrackerUtility.createExceptionLogString(ex),
                Datetime.now(), null, null, null, UserInfo.getUserId());
        }

        //system.debug('@@rollUpOldTimesheetEntries exit.');
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerTriggerHelper.rollUpOldTimesheetEntries method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
    }

    public static void dumpTimeTrackerDetails(List<Time_Tracker__c> newList){
      TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerTriggerHelper.dumpTimeTrackerDetails method.',
          Datetime.now(), null, null, null, UserInfo.getUserId());
      TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'newList: ',
          Datetime.now(), null, null, null, UserInfo.getUserId());
      //system.debug('@@dumpTimeTrackerDetails entered.');
      String namespacePrefix = TimeTrackerUtility.getNamespace();

      for(Time_Tracker__c ttObj : newList){
        String strSobjects = '';
          if(Trigger.isInsert) {
            strSobjects = 'INSERTED BY USER :' + UserInfo.getUserId() + ' AND OWNER:' + ttObj.OwnerId;
          } else if(Trigger.isUpdate){
            strSobjects = 'UPDATED BY USER :' + UserInfo.getUserId() + ' AND OWNER:' + ttObj.OwnerId;
          }
          Time_Tracker__c ttTempObj = ttObj;
          ttTempObj.Time_Tracker_Dump__c = '';
          strSobjects += '\n' + JSON.Serialize(ttTempObj) + '\n\n';
          if(strSobjects.length()<131072)
              ttObj.Time_Tracker_Dump__c = strSobjects;
      }
      //system.debug('@@dumpTimeTrackerDetails exit.' + newList);
      TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerTriggerHelper.dumpTimeTrackerDetails method.',
          Datetime.now(), null, null, null, UserInfo.getUserId());
    }

    public static void validateManualTimeTrackerRecords(List<Time_Tracker__c> newList) {
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerTriggerHelper.validateManualTimeTrackerRecords method.',
          Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'newList: '+newList,
          Datetime.now(), null, null, null, UserInfo.getUserId());
        System.debug('@@validateManualTimeTrackerRecords entered: '+newList);
        Map<String, TimeTrackerConfigSettings__c> manualSettings = TimeTrackerConfigSettings.getManualSettings();

        for(Time_Tracker__c ttObj : newList) {
            if(ttObj.Source__c==TimeTrackerConstants.MANUAL_STR) {
                System.debug('@@ttObj: '+ttObj);
                TimeTrackerConfigSettings__c activitySettings = manualSettings.get(ttObj.Opening_Action__c);
                System.debug('@@activitySettings: '+activitySettings);
                Boolean commentrequiredFlag = String.isNotBlank(activitySettings.Text6__c) 
                    && activitySettings.Text6__c.replace(' ', '').toLowerCase() == 'commentrequired' 
                    && String.isBlank(ttObj.Comment__c);
                Boolean sObjectrequiredFlag = String.isNotBlank(activitySettings.Code1__c) 
                    && activitySettings.Code1__c.endsWith('*') && String.isBlank(ttObj.Object_Id__c);
                if(commentrequiredFlag) {
                    ttObj.addError('Comment field is required for time tracker with Acivity : '+ ttObj.Opening_Action__c);
                }
                /*if(sObjectrequiredFlag) {
                    ttObj.addError('SObject field is required for time tracker with Acivity'+ ttObj.Opening_Action__c);
                }*/
                System.debug('@@validateManualTimeTrackerRecords exit. commentrequiredFlag:' + commentrequiredFlag /*+ ', sObjectrequiredFlag: '+sObjectrequiredFlag*/);
            }
        }
        
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerTriggerHelper.validateManualTimeTrackerRecords method.',
          Datetime.now(), null, null, null, UserInfo.getUserId());

    }
}