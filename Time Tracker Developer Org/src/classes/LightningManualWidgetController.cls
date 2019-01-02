public class LightningManualWidgetController {

	public static Map<String, TimeTrackerConfigSettings__c > activityToManualSettingsMap = TimeTrackerConfigSettings.getManualSettings();
	
    @AuraEnabled
    public static String getActivityList(String dummy) {
        string  activityList = ManualWidgetHelper.getactivityLst(dummy);
        return System.JSON.serialize(activityList.removeEnd(','));
    }   
    
    @AuraEnabled
    public static String getSobjectSearchFldValue(String sObjectApiName, String searchField, String sObjectRecordId) { 
    	String query = 'SELECT '+ searchField + ' FROM '+ sObjectApiName + ' WHERE id = \''+ String.escapeSingleQuotes(sObjectRecordId)+'\' LIMIT 1';
        List<sObject> sObjectObjList = Database.query(query);
        return System.JSON.serialize(sObjectObjList[0].get(searchField));
    }  
    
    @AuraEnabled
    public static String createTimesheetEntry(String timer, String hiddenTimer, String activityDateStr, String activity,
	String sObjetId, String sObjectValue, String comment) 
	{
        String str = ManualWidgetHelper.doCreateTimesheetEntry(timer, String.valueOf(hiddenTimer), activityDateStr, activity, sObjetId, sObjectValue, comment);
        return str;
    } 
    
    @AuraEnabled
    public static String getSObjectDetailsFromMCS(String selectedActivity) {
    	List<String> showFlds = new List<String>();
    	Boolean isSobjectRequired = false;
    	Boolean isCommentRequired = false;
        
	    if(String.isBlank(selectedActivity)) return null;
	    TimeTrackerConfigSettings__c  currentManualSettings = new TimeTrackerConfigSettings__c();
	    currentManualSettings = activityToManualSettingsMap.get(selectedActivity);
	    String code2Fields = currentManualSettings.Code2__c;
	    String sObjectApiName = currentManualSettings.Code1__c;
        
	    if(sObjectApiName.contains('*')) {
	    	isSobjectRequired = true;
	        sObjectApiName = sObjectApiName.removeEnd('*');
	    }
	    if(currentManualSettings.Text6__c == 'Comment Required'){
	    	isCommentRequired = true;
	    }
        
	    Schema.DescribeSObjectResult objResult = Schema.getGlobalDescribe().get( sObjectApiName ).getDescribe();
	    String sObjectLabel = objResult.getLabel();
	    String sObjectSearchField = '';
	 
	    Map<String, Object> fieldList = (Map<String, Object>)JSON.deserializeUntyped(code2Fields.replace(';',','));
	    List<Object> lstFieldObject = (List<Object>)fieldList.get('fields');	    
	    for(Object eachField :lstFieldObject) {
	        Map<String,Object> eachParsedField = (Map<String,Object>)eachField;
	        if((Boolean)eachParsedField.get('show')) {
	        	showFlds.add((String)eachParsedField.get('field'));   
	        }
	        if((Boolean)eachParsedField.get('search')) {
	            sObjectSearchField = (String)eachParsedField.get('field');
	        }
	    }
	    return '{ "showFields" : ' + System.JSON.serialize(showFlds)+
	    		', "sObjectLabel" :'+ System.JSON.serialize(sObjectLabel) +
    			', "sObjectSearchField" :'+System.JSON.serialize(sObjectSearchField)+   			
    			', "isSobjectRequired" :'+ System.JSON.serialize(isSobjectRequired) +
    			', "isCommentRequired" :'+ System.JSON.serialize(isCommentRequired) +
    			', "sObjectApiName" :'+ System.JSON.serialize(sObjectApiName) +'}';
    } 
    
    @AuraEnabled
    public static String getSObjectRecords(String searchKeyword, String sObjectApiName, String sObjectSearchField, List<String> showFlds) 
    {
    	List<sObject> sObjectRecords ;
	    if(String.isBlank(searchKeyword)) return null;
        
        System.debug('showFlds>> '+ showFlds);
	    System.debug('sObjectApiName : '+sObjectApiName+'sObjectSearchField : '+sObjectSearchField+'sObjectValue:'+searchKeyword);
	    sObjectRecords = TimeTrackerTypeAheadCompCtrl.searchRecords(searchKeyword, sObjectApiName, sObjectSearchField, showFlds, null, null);
	    return System.JSON.serialize(sObjectRecords);
    } 
    
    
    @AuraEnabled
    public static List<ManualLineItem__c> saveManualLineItems(String data) 
	{
        List<ManualLineItem__c> mliList = ManualWidgetHelper.saveManualLineItems(data);
        return mliList;
    } 
    
}