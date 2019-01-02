public with sharing class TimeTrackerTypeAheadCompCtrl {
    
    /**
        @ Purpose    : Returns the list of sobject records.
        @ Parameters : 1. String [ SOQL - SELECT Statement ].
                       2. String [ Object API Name ].
                       3. String [ Filter field api name ].
                       4. List<String> [ List holds api name of the fields to be fetched ].
                       5. String [ Filter statement - WHERE clause ].
                       6. String [ record limit ].
    */
    @RemoteAction
    public static list<sObject> searchRecords( String queryString, String objectName, String searchField, 
                                               list<String> showFields, String filter, String recordLimit
    ) {
        String showFieldsStr = String.escapeSingleQuotes( String.join( showFields, ',' ) );

        queryString = String.escapeSingleQuotes(queryString);
        if( String.isBlank(queryString) || String.isBlank(objectName) || 
            String.isBlank(searchField) || String.isBlank(showFieldsStr) || queryString.length() < 2
        ) {
            return null;
        }
        
        if( String.isBlank( recordLimit ) ) {
            recordLimit = '5';
        }
        
        //Validate filter method
        //filter = String.escapeSingleQuotes(filter);
        String searchFieldSoql;
        if( searchField == 'ID' ) {
            searchFieldSoql = searchField + '=\'' + queryString + '\' ';
        }
        else {
            searchFieldSoql = searchField + ' LIKE \'%' + queryString + '%\' ';
        }
        
        String soqlQuery = ' ';
        if( String.isNotBlank( filter ) ) {
            soqlQuery = 'SELECT Id, ' + showFieldsStr +
                        ' FROM ' + objectName +
                        ' WHERE ' + searchFieldSoql +
                        ' AND ' + filter +
                        ' LIMIT ' + recordLimit;
        } 
        else {
            soqlQuery = 'SELECT Id, ' + showFieldsStr +
                        ' FROM ' + objectName +
                        ' WHERE ' + searchFieldSoql +
                        ' LIMIT ' + recordLimit;
        }
        
        List<sObject> results = new List<sObject>();
        try {
            results = Database.query( soqlQuery );
        }
        catch (QueryException e) {
            TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 
                                              'Exception in TimeTrackerTypeAheadCompCtrl.searchRecords() method, SOQL Srtring : ' + 
                                              soqlQuery + ', QueryException : '+ e, 
                                              Datetime.now(), null, null, null, UserInfo.getUserId()
                                            );
            return null;
        }
        return results;
    }
}