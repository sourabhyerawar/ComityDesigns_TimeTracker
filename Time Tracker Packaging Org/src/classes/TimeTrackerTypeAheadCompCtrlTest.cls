@isTest
public class TimeTrackerTypeAheadCompCtrlTest {
	private static testMethod void testQuery() {
     list<Account> aa = new list<Account>{
       new Account(Name='Test Account', BillingCity='Test City1'),
       new Account(Name='Another Account', BillingCity='Another City'),
       new Account(Name='Third Account', BillingCity='Test City2')
     };
     insert aa;

       // crazy, but you have to fake this
			 list<String> showFields = new list<String>( );
			 String searchField = 'BillingCity';
			 showFields.add(searchField);
      //  list<Id> fixedSearchResults= new list<Id>{aa[0].id, aa[1].id};
      //  Test.setFixedSearchResults(fixedSearchResults);

     Test.startTest();
     list<sObject> accts = TimeTrackerTypeAheadCompCtrl.searchRecords( 'test', 'Account', searchField, showFields, null, null );
     Test.stopTest();

     system.assertEquals(2, accts.size());
     system.assertEquals('Test City1', accts[0].get('BillingCity'));
     system.assertEquals('Test City2', accts[1].get('BillingCity'));
   }
}