@isTest( SeeAllData = FALSE )
/**
* @description test class for TimeTrackerPostInstall.cls
*/
public class TimeTrackerPostInstallTest {
    
    private static testMethod void testConfigSettingInstallation()
    {
        Test.startTest();
        
        Test.testInstall( new TimeTrackerPostInstall(), null );
        List<TimeTrackerConfigSettings__c> configSettings = TimeTrackerConfigSettings__c.getAll().values();
        System.assertNotEquals(0, configSettings.size(), ' ; List : ' + configSettings);
        
        Test.testInstall( new TimeTrackerPostInstall(), null );
        
        List<TimeTrackerConfigSettings__c> configSettings2 = TimeTrackerConfigSettings__c.getAll().values();
        
        Test.stopTest();
        
        System.assertEquals( configSettings.size(), configSettings2.size(), '; List : ' + configSettings2 );
        System.assertEquals( 40, TimeTrackerUserSettings__c.getOrgDefaults().Weekly_Hours__c );
    }
}