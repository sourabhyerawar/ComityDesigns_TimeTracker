/**
    @ Purpose : Tests the functionality of class --> AdminPageComponentController
*/
@isTest
public class AdminPageComponentControllerTest {
    
    private static Integer intNoOfRecords = 0;
    
    private static Map<String,String> settingTypeToNamePrefix = new Map<String,String>
                                                                { 
                                                                 'Custom Event' => 'CustomEvent', 
                                                                 'Manual' => 'Manual', 
                                                                 'Miscellaneous' => 'MISCELLANEOUS', 
                                                                 'Object Settings' => TimeTrackerConstants.Object_Settings, 
                                                                 'Strategy' => 'Strategy', 
                                                                 'URLPattern' => 'URLPattern'
                                                                };
    @TestSetup static void insertTestData() {
            
        intNoOfRecords = 2;
        List<TimeTrackerConfigSettings__c> listOfConfigSettings = new List<TimeTrackerConfigSettings__c>();
        
        
        for( Integer intSettingIndex = 0; intSettingIndex < intNoOfRecords; intSettingIndex ++ ) {
            for( String strSettingType : settingTypeToNamePrefix.keySet() ) {
                
                listOfConfigSettings.add
                                     (
                                      new TimeTrackerConfigSettings__c
                                      (
                                       Name = settingTypeToNamePrefix.get( strSettingType ) + '_Test_' + intSettingIndex,
                                       Type__c = strSettingType,
                                       Code1__c = 'Code1__c', Code2__c = 'Code2__c',
                                       Flag1__c = TRUE, Flag2__c = TRUE, Flag3__c = TRUE,
                                       Text1__c = 'Text1__c', Text2__c = 'Text2__c', Text3__c = 'Text3__c', Text4__c = 'Text4__c', 
                                       Text5__c = 'Text5__c', Text6__c = 'Text6__c', Text7__c = 'Text7__c', Text8__c = 'Text8__c',
                                       IsActive__c = TRUE
                                      )
                                     );
            }
        }
        
        insert listOfConfigSettings;
        System.assertEquals( intNoOfRecords * settingTypeToNamePrefix.keySet().size(), TimeTrackerConfigSettings__c.getAll().Values().size() );
    }
    
     public static TestMethod void testGetNameSpace() {
        
        Test.startTest();       
        
        String nameSapce = AdminPageComponentController.getNameSpace();
        
        Test.stopTest();
         
        System.assertNotEquals( '', nameSapce );
    }
    
    public static TestMethod void testGetSettings() {
        
        Test.startTest();       
        
        String strJsonSettings = AdminPageComponentController.getSettings( '' );
        
        Test.stopTest();
        
        System.assertNotEquals( NULL, strJsonSettings );
    }
    
    
    public static TestMethod void testGetConfigSettingDetails() {
        
        String strJsonSettings;
        
        Test.startTest();       
        
        // Testing with Invalid data.
        strJsonSettings = AdminPageComponentController.getConfigSettingDetails( '' );
        System.assertEquals( '[]', strJsonSettings );
        
        // Testing with Valid data.
        strJsonSettings = AdminPageComponentController.getConfigSettingDetails( 'Manual' );
        
        Test.stopTest();
        
        System.assertNotEquals( '[]', strJsonSettings );
    }
    
    public static TestMethod void testInsertConfigSettingEntry() {
        
        String strConfigRecordMessage;
        
        Test.startTest();       
        
        // Testing with Invalid data.
        strConfigRecordMessage = AdminPageComponentController.insertConfigSettingEntry
                                                              (
                                                               '', 'Manual', 'test Text1', 'test Text3', '', 
                                                               'test Text5','test Text7','test Text8',
                                                               TRUE, TRUE, FALSE, TRUE,
                                                               'permissionSetsText','code1', 'code2'
                                                              );
        System.assert( strConfigRecordMessage != 'SUCCESS' );
        
        // Testing with Manual Settings.
        strConfigRecordMessage = AdminPageComponentController.insertConfigSettingEntry
                                                              (
                                                               'Manual_Test_Insertion_New', 'Manual', 'test Text1', 'test Text3', '', 
                                                               'test Text5','test Text7','test Text8',
                                                               TRUE, TRUE, FALSE, TRUE,
                                                               'permissionSetsText','code1', 'code2'
                                                              );
        System.assert( strConfigRecordMessage == 'SUCCESS' );
        
        // Testing with Object Settings.
        strConfigRecordMessage = AdminPageComponentController.insertConfigSettingEntry
                                                              (
                                                               'Object_Settings_Test_Insertion_New', settingTypeToNamePrefix.get( 'Object Settings' ), 
                                                               '001', 'test Text3', '', 
                                                               'test Text5','test Text7','test Text8',
                                                               TRUE, TRUE, FALSE, TRUE,
                                                               'permissionSetsText','code1', 'code2'
                                                              );
                                                              
        Test.stopTest();
        
        System.assert( strConfigRecordMessage == 'SUCCESS' );
    }
    
    public static TestMethod void testGetObjectPrefixIDAndLable() {
        
        Map<String,String> objectDetailsMap = new Map<String,String>();
        
        Test.startTest();       
        
        // Testing with Invalid data.
        objectDetailsMap = AdminPageComponentController.getObjectPrefixIDAndLable( 'Invalid_Test_Object_Name__c' );
        System.assertEquals( 0, objectDetailsMap.keySet().size() );
        
        // Testing with Invalid data.
        objectDetailsMap = AdminPageComponentController.getObjectPrefixIDAndLable( 'Case' );
        System.assertNotEquals( 0, objectDetailsMap.keySet().size() );
        
        objectDetailsMap = AdminPageComponentController.getObjectPrefixIDAndLable( 'Case', true );
        System.assertNotEquals( 0, objectDetailsMap.keySet().size() );
        
        Test.stopTest();
        
        
    }
    
    public static TestMethod void testGetObjectNameList() {
        
        List<String> listOfobjectNames = new List<String>();
        
        Test.startTest();       
        
        // Testing with removing already tracked objects.
        listOfobjectNames = AdminPageComponentController.getObjectNameList( TRUE, TRUE );
        System.assertNotEquals( 0, listOfobjectNames.size() );
        
        // Testing of making objects mandatory.
        listOfobjectNames = AdminPageComponentController.getObjectNameList( FALSE, TRUE );
        
        Test.stopTest();
        
        System.assertNotEquals( 0, listOfobjectNames.size() );
    }
    
    public static TestMethod void testUpdateEditedValues() {
        
        String strJsonSettings = '';
        List<TimeTrackerConfigSettings__c> listOfSettingsToReturn, listOfSettingsToUpdate;
        
        Test.startTest();       
        
        // Testing with invalid JSON parameters
        strJsonSettings = AdminPageComponentController.updateEditedValues( 'Invalid Update List JSON', 'Invalid Return List JSON' );
        System.assert( strJsonSettings.startsWithIgnoreCase( 'ERROR' ) );
        
        // Testing with 2nd invalid JSON parameter alone
        listOfSettingsToUpdate = new List<TimeTrackerConfigSettings__c>();
        strJsonSettings = AdminPageComponentController.updateEditedValues( JSON.serialize( listOfSettingsToUpdate ), 'Invalid Return List JSON' );
        System.assert( strJsonSettings.startsWithIgnoreCase( 'ERROR' ) );
        
        listOfSettingsToReturn = TimeTrackerConfigSettings__c.getAll().values();
        listOfSettingsToUpdate = new List<TimeTrackerConfigSettings__c>();
        listOfSettingsToUpdate.addAll( listOfSettingsToReturn );
        
        // Testing with invalid data in update list
        listOfSettingsToUpdate.add( new TimeTrackerConfigSettings__c ( Name = NULL ) );
        strJsonSettings = AdminPageComponentController.updateEditedValues( JSON.serialize( listOfSettingsToUpdate ), JSON.serialize( listOfSettingsToReturn ) );
        System.assert( strJsonSettings.startsWithIgnoreCase( 'ERROR' ) );
        
        // Testing with valid data in update list
        listOfSettingsToUpdate = new List<TimeTrackerConfigSettings__c>();
        listOfSettingsToUpdate.addAll( listOfSettingsToReturn );
        strJsonSettings = AdminPageComponentController.updateEditedValues( JSON.serialize( listOfSettingsToUpdate ), JSON.serialize( listOfSettingsToReturn ) );
        
        Test.stopTest();
        
        System.assert( !strJsonSettings.startsWithIgnoreCase( 'ERROR' ) );
    }
    
    public static TestMethod void testDeleteConfigSettingRecordList() {
        
        String strJsonSettings = '';
        List<TimeTrackerConfigSettings__c> listOfSettingsToReturn, listOfSettingsToDelete;
        
        Test.startTest();       
        
        // Testing with invalid JSON parameters
        strJsonSettings = AdminPageComponentController.deleteConfigSettingRecordList( 'Invalid Delete List JSON', 'Invalid Return List JSON' );
        System.assert( strJsonSettings.startsWithIgnoreCase( 'ERROR' ) );
        
        // Testing with 2nd invalid JSON parameter alone
        listOfSettingsToDelete = new List<TimeTrackerConfigSettings__c>();
        strJsonSettings = AdminPageComponentController.deleteConfigSettingRecordList( JSON.serialize( listOfSettingsToDelete ), 'Invalid Return List JSON' );
        System.assert( strJsonSettings.startsWithIgnoreCase( 'ERROR' ) );
        
        listOfSettingsToReturn = TimeTrackerConfigSettings__c.getAll().values();
        listOfSettingsToDelete = new List<TimeTrackerConfigSettings__c>();
        listOfSettingsToDelete.addAll( listOfSettingsToReturn );
        
        // Testing with valid data in delete list
        listOfSettingsToDelete = new List<TimeTrackerConfigSettings__c>();
        listOfSettingsToDelete.addAll( listOfSettingsToReturn );
        strJsonSettings = AdminPageComponentController.deleteConfigSettingRecordList( JSON.serialize( listOfSettingsToDelete ), JSON.serialize( listOfSettingsToReturn ) );
        
        Test.stopTest();
        
        System.assert( !strJsonSettings.startsWithIgnoreCase( 'ERROR' ) );
    }
    
    public static TestMethod void testInsertTimeTrackerConfigSettings() {
        
        String strJsonSettings = '';
        List<TimeTrackerConfigSettings__c> listOfSettingsToInsert;
        
        Test.startTest();       
        
        // Testing with invalid json of insert list.
        strJsonSettings = AdminPageComponentController.insertTimeTrackerConfigSettings( 'Invalid Insert List JSON', FALSE );
        System.assert( strJsonSettings.startsWithIgnoreCase( 'ERROR' ) );
        
        // Testing with duplicate records.
        listOfSettingsToInsert = new List<TimeTrackerConfigSettings__c>
                                 {
                                  new TimeTrackerConfigSettings__c
                                  (
                                   Name = 'Duplicate Config Setting Record'
                                  )
                                 };
        strJsonSettings = AdminPageComponentController.insertTimeTrackerConfigSettings( JSON.serialize( listOfSettingsToInsert ), TRUE );
        System.assert( strJsonSettings.startsWithIgnoreCase( 'ERROR' ) );
        
        // Testing with valid data in insert list
        listOfSettingsToInsert = new List<TimeTrackerConfigSettings__c>
                                 {
                                  new TimeTrackerConfigSettings__c
                                  (
                                   Name = 'Test_New_Upsert_Entry',
                                   Type__c = 'Manual'
                                  )
                                 };
        strJsonSettings = AdminPageComponentController.insertTimeTrackerConfigSettings( JSON.serialize( listOfSettingsToInsert ), TRUE );
        
        Test.stopTest();
        
        System.assert( !strJsonSettings.startsWithIgnoreCase( 'ERROR' ) );
    }
    
    public static TestMethod void testGetMatchingEntities() {
        
        List<String> listOfObjectNames;
        
        Test.startTest();       
        
        // Testing with invalid data.
        listOfObjectNames = AdminPageComponentController.getMatchingEntities( NULL, NULL, TRUE, TRUE );
        System.assertEquals( NULL, listOfObjectNames );
        
        // Testing with empty data.
        listOfObjectNames = AdminPageComponentController.getMatchingEntities( '', '', TRUE, TRUE );
        System.assertEquals( 0, listOfObjectNames.size() );
        
        // Testing with valid data.
        listOfObjectNames = AdminPageComponentController.getMatchingEntities( 'Objects', 'Case', TRUE, TRUE );
        
        Test.stopTest();
        
        System.assertNotEquals( 0, listOfObjectNames.size() );
    }
    
    public static TestMethod void testGetUserAndProfileDetails() { 
    
        Map<String, ID> entityNameToId = new Map<String, ID>();
        
        Test.startTest();
        
        // Assign Any Time Tracker Permission set to this user.
        List<PermissionSet> listOfPermissionSets = [ SELECT ID FROM PermissionSet WHERE Name IN ( 'Time_Tracker_Admin_Permission_Set' ) ];
        PermissionSetAssignment permissionAssignment = new PermissionSetAssignment
                                                       (
                                                        AssigneeId = UserInfo.getUserId(),
                                                        PermissionSetId = listOfPermissionSets.get( 0 ).Id
                                                       );
        Database.insert( permissionAssignment, FALSE );
        
        // Testing when entity is Profile.
        entityNameToId = AdminPageComponentController.getUserAndProfileDetails( 'Profile', 'System Administrator' );
        System.assertNotEquals( 0, entityNameToId.size() );
        
        // Testing when entity is User.
        entityNameToId = AdminPageComponentController.getUserAndProfileDetails( 'User', UserInfo.getName() );
        
        Test.stopTest();
        
        System.assertNotEquals( 0, entityNameToId.size() );
    }
    
    public static TestMethod void testGetVFPageList() { 
    
        List<String> listOfVfPages = new List<String>();
        
        Test.startTest();
        
        listOfVfPages = AdminPageComponentController.getVFPageList();
        
        Test.stopTest();
        
        System.assertNotEquals( 0, listOfVfPages.size() );
    }
    
    public static TestMethod void testGetHierarchySettings() { 
    
        String strJsonUserSettings = '';
        
        Test.startTest();
        
        strJsonUserSettings = AdminPageComponentController.getHierarchySettings();
        
        Test.stopTest();
        
        System.assertNotEquals( NULL, strJsonUserSettings );
    }
    
    public static TestMethod void testGetUserHierarchySettings() {
        
        String strJsonUserSettings = '';
        
        Test.startTest();
        
        strJsonUserSettings = AdminPageComponentController.getUserHierarchySettings();
        
        Test.stopTest();
        
        System.assertNotEquals( NULL, strJsonUserSettings );
    }
    
    public static TestMethod void testUpsertAndDeleteSettings() {
        
        String strStatusMessage = '';
        AdminPageComponentController.Settings settingsMessage;
        TimeTrackerUserSettings__c userSettings;
        
        Test.startTest();
        
        // Upserting record with invalid data.
        strStatusMessage = AdminPageComponentController.upsertSettings( JSON.serialize( userSettings ) );
        System.assert( strStatusMessage != 'SUCCESS' );
        
        // Upserting record with valid data.
        userSettings = new TimeTrackerUserSettings__c
                       (
                        Name = 'Time Tracker User Settings ( Test User )', 
                        SetupOwnerId = UserInfo.getUserId(), 
                        Weekly_Hours__c = 40, ChromeExtensionID__c = 'bbmcpbdcihggdbbcbcakllcdbecmkjim', 
                        ClientDebugLevel__c = 'INFO', ClientFailureNotifications__c = TRUE, 
                        Server_Debug_Level__c = 'INFO', Max_Duration_In_Minutes__c = 40,  
                        Server_Debug__c = TRUE, StopTrackingAfterCloseCase__c = TRUE, 
                        Is_Time_Tracker_Read_Only__c = FALSE 
                       );
        
        strStatusMessage = AdminPageComponentController.upsertSettings( JSON.serialize( userSettings ) );
        settingsMessage = (AdminPageComponentController.Settings)JSON.deserialize(strStatusMessage, AdminPageComponentController.Settings.class);
        system.debug('>> settingsMessage'+settingsMessage.isSucceeded);
        System.assert( settingsMessage.isSucceeded == true );
        
        // Deleting record with invalid data.
        userSettings = NULL;
        strStatusMessage = AdminPageComponentController.deleteUserSetting( JSON.serialize( userSettings ) );
        System.assert( strStatusMessage != 'SUCCESS' );
        
        // Deleting record with record id.
        userSettings = TimeTrackerUserSettings__c.getInstance();
        strStatusMessage = AdminPageComponentController.deleteUserSetting( JSON.serialize( userSettings ) );
        
        Test.stopTest();
        
        System.assert( strStatusMessage == 'SUCCESS' );
    }
}