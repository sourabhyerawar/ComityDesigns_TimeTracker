/**
 * @description This class consists of helper functions to be used in unit test classes.
 *
 * @created Sep 02, 2015
 */
public with sharing class TimeTrackerTestHelper {

	  // map that holds a mapping of Profile Name to Profile Id
    private static Map<String, Id> ProfileName2Id = new Map<String, Id>();

	  // default profile name to use if one is not provided
    private static final String DEFAULT_PROFILE_NAME = 'System Administrator';

	  // helper method for creating a user object
    private static User createUserObject(String profileName) {
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerTestHelper.createUserObject method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'profileName: ' + profileName,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        Long rand = Crypto.getRandomLong();
        rand = (rand < 0 ? rand * -1 : rand);

        // check if we have retrieved this profile before
        if (String.isNotBlank(profileName) && !ProfileName2Id.containsKey(profileName)) {
            Profile p = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
            ProfileName2Id.put(profileName, p.Id);
        }

        // required fields: Username, Last Name, E-mail, Alias, Nickname, Time Zone, Locale, Email Encoding, Profile, Language
        User u = new User(
            Email = 'testuser@test.sfdc.' + rand,
            Username = 'testuser@test.sfdc.' + rand,
            LastName = 'user' + rand,
            Alias = 'testUsr',
            TimeZoneSidKey = 'America/Denver',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = ProfileName2Id.get(profileName),
            LanguageLocaleKey = 'en_US'
        );

        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerTestHelper.createUserObject method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        return u;
    }

    // helper method for creating user record
    public static User createUser() {
        return createUser(DEFAULT_PROFILE_NAME);
    }

    // helper method for creating user record
    public static User createUser(String profileName) {
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerTestHelper.createUser method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'profileName: ' + profileName,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        User u = createUserObject(profileName);
        try {
            insert u;
        } catch(Exception ex) {
            TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, TimeTrackerUtility.createExceptionLogString(ex),
                Datetime.now(), null, null, null, UserInfo.getUserId());
        }

        // retrieve the user so I have the Id
        u = [SELECT Id, LastName FROM User WHERE Email = : u.Email LIMIT 1];
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerTestHelper.createUser method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'Returned: u: ' + u,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        return u;
    }


    /**
    *   @description -- method to insert records using static resource
    *   @param -- Object name for which the records are to be inserted
    *   @param -- File name in the static resource from which the records are to be loaded
    */
    public static void insertRecordsFromStaticResource(String objectName, String fileName)
    {
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerTestHelper.insertRecordsFromStaticResource method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'objectName: ' + objectName + '; fileName: ' + fileName,
            Datetime.now(), null, null, null, UserInfo.getUserId());
        Schema.SObjectType sObjType = Schema.getGlobalDescribe().get(objectName);
        List<SObject> sObjList = new List<SObject>();
        if(sObjType != null)
        {
            Set<String> sObjFieldsSet = sObjType.getDescribe().fields.getMap().keySet();
            List<StaticResource> resources = [SELECT Name, NamespacePrefix, SystemModstamp, Body FROM StaticResource WHERE Name LIKE :fileName];
            if(resources != null && !resources.isEmpty())
            {
                // code to uncomment if the .csv file is in a .zip file, need to add aome more code as well
                //StaticResource resource = [SELECT Name, NamespacePrefix, SystemModstamp, Body FROM StaticResource WHERE Name LIKE 'Accounts_Records_Zip' LIMIT 1];
                //String prefix = resource.NamespacePrefix;
                //prefix += (String.isEmpty(prefix) ? '' : '__');
                //System.debug(LoggingLevel.Error, '--++--prefix : ' + prefix);
                //String path = '/resource/' + resource.SystemModstamp.getTime() + '/' + fileName;
                //PageReference pg = new PageReference(path);
                //String body = pg.getContent().toString();
                //System.debug(LoggingLevel.Error, '--++--body : ' + body);

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
                                    String fieldName = fieldAPINames[j].removeStart('"').removeEnd('"');
                                    
                                    if( fieldName.endsWithIgnoreCase( '__c' ) ) {
                                        fieldName = TimeTrackerUtility.getNamespace() + fieldName;
                                    }
                                    
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
                TimeTrackerUtility.addLogMessage(LoggingLevel.ERROR, TimeTrackerUtility.createExceptionLogString(ex),
                    Datetime.now(), null, null, null, UserInfo.getUserId());            }
        }
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerTestHelper.insertRecordsFromStaticResource method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
    }

    /**
    *   @description-- method to check whethere adding duplicate custom settings
    *   "Name" field is assumed to be unique
    */
    private static List<TimeTrackerConfigSettings__c> addTimeTrackerConfigSettings(List<TimeTrackerConfigSettings__c> settingRecordsList)
    {
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerTestHelper.addTimeTrackerConfigSettings method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
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

        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerTestHelper.addTimeTrackerConfigSettings method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());

        return settingsToInsert;
    }
}