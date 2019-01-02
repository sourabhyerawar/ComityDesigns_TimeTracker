/**
    @ Purpose : 1. Tests the functionality of 'TimeTrackerCustomLabels' class.
*/

@IsTest
public class TimeTrackerCustomLabelsTest {
    
    public static TestMethod void testGetCustomLabelNameToValue() {
        
        Test.startTest();
        
        // Passing NULL to a custom label category.
        System.assertEquals( NULL, TimeTrackerCustomLabels.getCustomLabelNameToValue( NULL ) );
        
        List<String> listOfCustomLabelCategories = new List<String>
                                                  {
                                                   'AP Label',
                                                   'Error',
                                                   'Label',
                                                   'Success'
                                                  };
                                                  
        for( String CustomLabelCategory : listOfCustomLabelCategories ) {
            Map<String,String> customLabelNameToValue = TimeTrackerCustomLabels.getCustomLabelNameToValue( CustomLabelCategory );
            System.assertNotEquals( NULL, customLabelNameToValue );
        }
        Test.stopTest();
        
        // Passing invalid value to a custom label category.
        System.assertEquals( NULL, TimeTrackerCustomLabels.getCustomLabelNameToValue( 'Invalid Custom Label Category' ) );
    }
}