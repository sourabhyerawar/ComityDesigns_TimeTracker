public with sharing class ManualWidgetHelper {
	public static string  activityLst;
  	public static set<String> activity_actType_map = new set<String>();
  
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
	    System.debug( 'activityLst:-\n' + JSON.serialize( activityLst ) );
	    return activityLst;
  	}
    
    public static String doCreateTimesheetEntry(String timer, String hiddenTimer, String activityDateStr, String activity,
	String sObjetId, String sObjectValue, String comment)
	{
		System.debug('***doCreateTimesheetEntry > ');
        System.debug('***timer > '+timer);
        System.debug('***hiddenTimer > '+hiddenTimer);
        System.debug('***activityDateStr > '+activityDateStr);
        System.debug('***activity > '+activity);
        System.debug('***sObjetId > '+sObjetId);
        System.debug('***sObjectValue > '+sObjectValue);
        System.debug('***comment > '+ comment);
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
		      sObject typeAheadObjectCheck = getSObjectDetailsFromActivityAndSObjectValue(activity, sObjectValue);
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
	
	private static sObject getSObjectDetailsFromActivityAndSObjectValue(String activity, String sObjectValue) {
	    TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerController.getSObjectDetailsFromActivityAndSObjectValue() method.',
	    Datetime.now(), null, null, null, UserInfo.getUserId());
	    TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'activity: ' + activity +', sObjectValue : '+sObjectValue,
	    Datetime.now(), null, null, null, UserInfo.getUserId());
	    
	    sObject sObjectRecord ;
	    if(String.isBlank(activity) || String.isBlank(sObjectValue)) return sObjectRecord;
	    TimeTrackerConfigSettings__c  currentManualSettings = new TimeTrackerConfigSettings__c();
	    currentManualSettings = TimeTrackerConfigSettings.getManualSettings().get(activity);
	    String code2Fields = currentManualSettings.Code2__c;
	    String sObjectApiName = currentManualSettings.Code1__c;
	    String sObjectSearchField = '';
	    if(sObjectApiName.contains('*')) {
	        sObjectApiName = sObjectApiName.substring(0,sObjectApiName.length()-1);
	    }
	    System.debug('code2Fields : '+code2Fields+', '+'sObjectApiName:'+sObjectApiName);
	    Map<String, Object> fieldList = (Map<String, Object>)JSON.deserializeUntyped(code2Fields.replace(';',','));
	    System.debug('fieldList : '+fieldList);
	    // to be implement filter logic
	    List<Object> lstFieldObject = (List<Object>)fieldList.get('fields');
	    for(Object eachField :lstFieldObject) {
	        Map<String,Object> eachParsedField = (Map<String,Object>)eachField;
	        if((Boolean)eachParsedField.get('search')) {
	            sObjectSearchField = (String)eachParsedField.get('field');
	            break;
	        }
	        System.debug('Code2 Field Details:: field : '+eachParsedField.get('field')+', search: '+eachParsedField.get('search')+', show: '+eachParsedField.get('show'));
	    }
	    System.debug('sObjectApiName : '+sObjectApiName+'sObjectSearchField : '+sObjectSearchField+'sObjectValue:'+sObjectValue);
	    sObjectRecord = getSObjectIdFromValue(sObjectApiName, sObjectSearchField, sObjectValue);
	    
	    TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Ended TimeTrackerController.getSObjectDetailsFromActivityAndSObjectValue() method.',
	    Datetime.now(), null, null, null, UserInfo.getUserId());
	    TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'sObjectRecord: ' + sObjectRecord,
	    Datetime.now(), null, null, null, UserInfo.getUserId());
	    return sObjectRecord;
    }
    
    private static String getTimesheetId(String ttId) {
	    String timesheetId='';
	    if(String.isBlank(ttId)) return timesheetId;
	    Time_Tracker__c tt = [ SELECT Timesheet__c FROM Time_Tracker__c WHERE Id=:ttId ];
	    timesheetId = tt.Timesheet__c;
	    return timesheetId;
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
	
	public static List<ManualLineItem__c> saveManualLineItems(String data){
    //system.debug('@@saveManualLineItems'+ data);
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
}