/**
* @description an Apex controller class for HiddenTimeTrackerForm page
*
* @created on Aug 19, 2015
*/
global with sharing class HiddenTimeTrackerController {
    /**
* @description method to upsert the TimeTracker and TimeTrackerLog records
* @param String: inputJson
* @return String: json string
*/
    @RemoteAction
    global static void insertTimeTracker(String inputJson) {
        system.debug(LoggingLevel.ERROR,'@@inputJson'+ inputJson);
        if(String.isBlank(inputJson))  return;
        
        try {
            Time_Tracker__c tt = (Time_Tracker__c) JSON.deserialize(inputJson, Time_Tracker__c.class);
            if(tt == null) return;
            //tt.Action__c = String.isNotBlank(tt.Action__c) ? tt.Action__c : getAction(tt);
            //tt.Opening_Action__c = String.isNotBlank(tt.Opening_Action__c) ? tt.Opening_Action__c : getAction(tt);
            tt.Activity_Date__c = tt.Activity_Time__c != null ? DateTime.newInstance((Long) tt.Activity_Time__c) : System.now();
            tt.Opening_Activity_Date__c = tt.Opening_Activity_Time__c  != null ? DateTime.newInstance((Long) tt.Opening_Activity_Time__c ) : null;
            tt.Parent_Object_Id__c = String.isNotBlank(tt.Parent_Object_Id__c) ? tt.Parent_Object_Id__c : findParentId(tt);
            tt.Object_Name__c = getObjectName(tt.Object_Id__c);
            tt.Parent_Object_Name__c = getObjectName(tt.Parent_Object_Id__c);
            
            // Check if the New Record Document Id exists. If so, Update the time tracker with the related Object and Parent Id.
            if(String.isNotBlank(tt.New_Record_Document_Id__c)) updateTimeTracker(tt);
            
            system.debug('tt===='+tt);
            insert tt;
            system.debug('tt.Id=='+tt.Id);
        } catch(Exception e){
            System.debug('Failed to insert time tracker records:::'+e);
        }
        
        // If Time Tracker Log exists then insert; 
    }
    
    private static void updateTimeTracker(Time_Tracker__c tt) {
        List<Time_Tracker__c> ttList = new List<Time_Tracker__c>();
        List<String> documentIds = tt.New_Record_Document_Id__c.split(',');
        try {
            List<Time_Tracker__c> closedRecords = [SELECT Id, Object_Id__c, Parent_Object_Id__c 
                                  FROM Time_Tracker__c 
                                  WHERE Action_Closed__c = true 
                                  AND DocumentId__c IN :documentIds
                                  AND Opening_Activity_Time__c >= :tt.Opening_Activity_Time__c
                                  AND Activity_Time__c <= :tt.Activity_Time__c
                                  AND CreatedById =:UserInfo.getUserId()];
            system.debug('closedRecords==='+closedRecords);
            for(Time_Tracker__c closedRecord : closedRecords){
                closedRecord.Object_Id__c = tt.Object_Id__c;
                closedRecord.Parent_Object_Id__c = tt.Parent_Object_Id__c;
                closedRecord.Object_Name__c = tt.Object_Name__c;
                closedRecord.Parent_Object_Name__c = tt.Parent_Object_Name__c;
                ttList.add(closedRecord);
            }
            update ttList;
            system.debug('update tList=='+ttList);
        } catch(Exception e){
            System.debug('Failed to update time tracker records:::'+e);
        }
    }
    
    private static String getObjectName(String objStr){
        if(String.isBlank(objStr)) return null;
        try {
            Id objId = (Id) (objStr);    
            return objId.getSobjectType().getDescribe().getLabel();    
        } catch (Exception e){
            system.debug('Id is not valid: ' + e.getMessage());
        }
        return null;        
    }   
    
    private static Id findParentId(Time_Tracker__c tt) {
        system.debug('findParentId ==='+tt);
        if(String.isBlank(tt.Object_Id__c)) return null;
        Map<String, List<TimeTrackerConfigSettings__c>> objNameMap = TimeTrackerConfigSettings.getSettingsByType('Object Settings', 'Text1__c');
        Map<String, List<TimeTrackerConfigSettings__c>> prefixMap = TimeTrackerConfigSettings.getSettingsByType('Object Settings', 'Code1__c');
        system.debug('objNameMap ===' + objNameMap);
        system.debug('prefixMap ===' +prefixMap);
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
        system.debug('soql==='+soql);
        SObject sObj = Database.query(soql); 
        if(sObj == null) return null;
        
        return (Id) sObj.get(fieldName);
    } 
    
    @RemoteAction
    global static String getSettings(String dummy) {
        try {
            return JSON.serialize(new Settings());
        } catch(Exception e){
            System.debug('Failed to insert time tracker records:::'+e);
        }
        return null;
    }
    
    private class Settings {
        User User {get; set;}
        String OrgId {get; set;}
        String BaseUrl {get; set;}
        String Namespace {get; set;}
        TimeTrackerUserSettings__c UserSettings {get; set;}
        Map<String, TimeTrackerConfigSettings__c> ConfigSettings {get; set;}
        
        public Settings() {
            
            User = [Select Id, Name, Email, Username, ProfileId From User Where Id=:UserInfo.getUserId()];
            OrgId = UserInfo.getOrganizationId();
            BaseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
            
            Namespace = HiddenTimeTrackerController.class.getName().substringBefore( 'HiddenTimeTrackerController' );
            if( String.isNotBlank( Namespace ) ) {
                Namespace = Namespace.subString( 0, Namespace.length() - 1 ) + '__';
            }
            
            UserSettings = TimeTrackerUserSettings__c.getInstance();
            ConfigSettings = TimeTrackerConfigSettings__c.getAll();
        }
    }

    @RemoteAction
    global static String insertActivity(String inputJson){
        return 'This method is deprecated';
    }   
}