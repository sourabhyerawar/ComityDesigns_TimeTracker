global class TimeTrackerPostInstall implements InstallHandler
{
    private static String message = '';
    global void onInstall(InstallContext context)
    {
        try
        {       
            // method to install only new TimeTrackerConfigSettings records
            insertRecordsFromStaticResource( getNamespace() + 'TimeTrackerConfigSettings__c', TimeTrackerConstants.CONFIG_SETTING_FILE_NAME );
            insertUserSettings();
            scheduleCleanupOrphanRecords();
        }
        catch( Exception ex ) {
            message += ex.getLineNumber() + ': ' + ex.getMessage();
            sendEmailOnInstall(message);
        }
    }

    private static String namespacePrefix;
    private static String getNamespace()
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
    
	private void scheduleCleanupOrphanRecords() {
		
		// RUNS EVERY 1st AND 16th OF MONTH
		String strEveryFortNightCronExpression = '0 0 0 1,16 * ?';
		
		// RUNS EVERY DAY
		String strEveryDayCronExpression = '0 0 0 * * ?';
		
		// CLEANS TIME TRACKER ORPHAN RECORDS
		TimeTrackerScheduledCleanup ttsc = new TimeTrackerScheduledCleanup();
		System.schedule( 'Clean Time Tracker Orphan Records', strEveryFortNightCronExpression, ttsc );
		
		// CLEANS MANUAL TIME TRACKER ORPHAN RECORDS
		TimeTrackerScheduledManualTimeCleanup ttsmtc = new TimeTrackerScheduledManualTimeCleanup();
		System.schedule( 'Clean Manual Time Tracker Orphan Records', strEveryFortNightCronExpression, ttsmtc );
		
		// CLEANS MANUAL TIME TRACKER LOG RECORDS
		TimeTrackerScheduledLogCleanup ttslc = new TimeTrackerScheduledLogCleanup();
		System.schedule( 'Clean Time Tracker Log Records', strEveryDayCronExpression, ttslc );
	}
	
    private static void insertUserSettings() {
        
        TimeTrackerUserSettings__c ttSettings = TimeTrackerUserSettings__c.getOrgDefaults();
        if( ttSettings.Id == null ) {
            insert ( new TimeTrackerUserSettings__c
					 ( ClientDebugLevel__c = 'DEBUG', ClientFailureNotifications__c = TRUE,
					   Server_Debug__c = TRUE, Server_Debug_Level__c = 'DEBUG', Weekly_Hours__c = 40,
					   Max_Duration_In_Minutes__c = 30, ChatterTypingInterval__c = 30
					 )
				   );
            return;
        }

        if( String.isBlank( String.valueOf( ttSettings.Weekly_Hours__c ) ) ) {
            ttSettings.Weekly_Hours__c = 40;
        }
        
        if( String.isBlank( String.valueOf( ttSettings.Max_Duration_In_Minutes__c ) ) )	{
            ttSettings.Max_Duration_In_Minutes__c = 30;
        }
		
		ttSettings.ClientDebugLevel__c = 'DEBUG';
		ttSettings.ClientFailureNotifications__c = TRUE;
		ttSettings.Server_Debug__c = TRUE;
		ttSettings.Server_Debug_Level__c = 'DEBUG';
		ttSettings.ChatterTypingInterval__c = 30;
		
        update ttSettings;
    }
    
    /**
    *   @description -- method to insert records using static resource
    *   @param -- Object name for which the records are to be inserted
    *   @param -- File name in the static resource from which the records are to be loaded
    */
    private static void insertRecordsFromStaticResource(String objectName, String fileName)
    {
        Schema.SObjectType sObjType = Schema.getGlobalDescribe().get(objectName);
        List<SObject> sObjList = new List<SObject>();
        if(sObjType != null)
        {
            Set<String> sObjFieldsSet = sObjType.getDescribe().fields.getMap().keySet();
            List<StaticResource> resources = [SELECT Name, NamespacePrefix, SystemModstamp, Body FROM StaticResource WHERE Name LIKE :fileName];
            message += 'Resource : ' + resources + '\n';
            if(resources != null && !resources.isEmpty())
            {
                Blob recordsBlob = resources[0].Body;
                List<String> recordsStringList = new List<String>();
                if( recordsBlob != NULL ) {
                    String strBlob = recordsBlob.toString();
                    if( strBlob.contains( '\r' ) ) {
                        strBlob = strBlob.replaceAll( '\\r', '' );
                    }
                    strBlob = strBlob.replaceAll( '""', '"' );
                    recordsStringList = strBlob.split( '\n' );
                }
                
                if(recordsStringList != null && recordsStringList.size() > 1)
                {
                    List<String> fieldAPINames = recordsStringList[0].split(',');
                    if(fieldAPINames != null && !fieldAPINames.isEmpty())
                    {
                        for(Integer i = 1; i < recordsStringList.size(); i++)
                        {
                            List<String> values = recordsStringList[i].split(',');
                            SObject sObj = sObjType.newSObject();
                            for(Integer j=0; j < fieldAPINames.size(); j++)
                            {
                                if(String.isNotBlank(fieldAPINames[j])
                                    && values != null && String.isNotBlank(values[j]))
                                {
                                    String fieldName = getNamespace() + fieldAPINames[j].removeStart('"').removeEnd('"');
                                    if(!sObjFieldsSet.contains(fieldName.toLowerCase())) {
                                        fieldName = fieldAPINames[j].removeStart('"').removeEnd('"');
                                    }                                    
                                    Schema.DescribeFieldResult fieldDescribe = sObjType.getDescribe().fields.getMap().get(fieldName).getDescribe();
                                    String value = values[j].removeStart('"').removeEnd('"');
                                    
                                    if(String.isNotBlank(value)
                                        && fieldDescribe != null
                                        && sObjFieldsSet != null
                                        && sObjFieldsSet.contains(fieldName.toLowerCase()))
                                    {
                                                                       
                                        if(Schema.SoapType.Integer == fieldDescribe.getSoapType()) {
                                            sObj.put(fieldName, Integer.valueOf(value));
                                        }
                                        else if(Schema.SoapType.Boolean == fieldDescribe.getSoapType()) {
                                            sObj.put(fieldName, Boolean.valueOf(value));
                                        }
                                        else if(Schema.SoapType.Date == fieldDescribe.getSoapType()) {
                                            sObj.put(fieldName, Date.valueOf(value));
                                        }
                                        else if(Schema.SoapType.DateTime == fieldDescribe.getSoapType()) {
                                            sObj.put(fieldName, DateTime.valueOf(value));
                                        }
                                        else if(Schema.SoapType.Double == fieldDescribe.getSoapType()) {
                                            sObj.put(fieldName, Double.valueOf(value));
                                        }
                                        else if(Schema.SoapType.Id == fieldDescribe.getSoapType()) {
                                            sObj.put(fieldName, Id.valueOf(value));
                                        }
                                        else {
                                            sObj.put(fieldName, String.valueOf(value));
                                        }
                                    }
                                }
                            }
                            sObjList.add(sObj);
                        }
                    }
                }
            }
        }

        // to insert only new custom settings
        sObjList = addTimeTrackerConfigSettings(sObjList);

        if(sObjList != null && !sObjList.isEmpty())
        {
            try {
                Database.SaveResult[] results = Database.insert(sObjList, true);
            }
            catch(Exception ex) {
                message += '\n' + ex.getLineNumber() + ': ' + ex.getMessage() + '\n';
                System.debug(LoggingLevel.Error, 'Exception occurred while inserting TimeTrackerConfig records. : ' + ex.getMessage() + '; Line: ' + ex.getLineNumber());
            }
        }
    }

    /**
    *   @description-- method to check whether adding duplicate custom settings
    *   "Name" field is assumed to be unique
    */
    private static List<TimeTrackerConfigSettings__c> addTimeTrackerConfigSettings(List<TimeTrackerConfigSettings__c> settingRecordsList)
    {
        List<TimeTrackerConfigSettings__c> settingsToInsert;
        if(settingRecordsList != null && !settingRecordsList.isEmpty())
        {
            List<TimeTrackerConfigSettings__c> oldSettingsList = TimeTrackerConfigSettings__c.getAll().values();
            Set<String> oldSettingsSet = new Set<String>();

            for(TimeTrackerConfigSettings__c setting : oldSettingsList) {
                oldSettingsSet.add(setting.Name);
            }

            settingsToInsert = new List<TimeTrackerConfigSettings__c>();
            for(TimeTrackerConfigSettings__c setting : settingRecordsList)
            {
                if(!oldSettingsSet.contains(setting.Name)) {
                    settingsToInsert.add(setting);
                }
            }
        }

        return settingsToInsert;
    }

    private void sendEmailOnInstall(String errMsg) {
        
        Messaging.SingleEmailMessage emailTobeSent = new Messaging.SingleEmailMessage();
        list<String> listEmailMembers = new list<String>();
        listEmailMembers.add(UserInfo.getUserEmail());
        
        //TODO: Remove hardcoded email after checking the error email. Also uncomment the test class.
        emailTobeSent.setToAddresses(listEmailMembers);
        emailTobeSent.setSubject('Package Install E-Mail');
        emailTobeSent.setHtmlBody(errMsg);
        Messaging.SendEmailResult [] r1 = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailTobeSent});
    }
}