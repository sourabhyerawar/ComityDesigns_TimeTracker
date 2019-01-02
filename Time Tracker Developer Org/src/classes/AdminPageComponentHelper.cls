/**
    @ Purpose : Provides assistance to AdminPageComponentController.
                
*/
public class AdminPageComponentHelper {
    
    /**
        @ Purpose     : 1. Receives the object name which is being selected on Admin page while creating custom events for a new custom objects.
                        2. Maps the lookup or master detail fields of selected sobject with time tracker objects when reference of these fields is matched.
        @ Parameter   : String [ Api name of the object ].
        @ Return Type : List<String> [ holds the mapping details of the fields; maximum 255 characters in one element of the list ].
    */  
    public static List<String> getListOfRelationFieldTokens( String strObjectApiName ) {
            
        List<String> listOfRelationFieldTokens = new List<String>();
        if( String.isNotBlank( strObjectApiName ) ) {
            
            Map<String,String> objectReferenceToFieldName = getObjectReferenceTofieldName( strObjectApiName );
            if( !objectReferenceToFieldName.isEmpty() ) {
                
                Map<String,String> ttObjectReferenceToFieldName = getObjectReferenceTofieldName( Schema.SobjectType.Time_Tracker__c.getName() );
                if( !ttObjectReferenceToFieldName.isEmpty() ) {
                    
                    String strObjectFieldName, strTTFieldName;
                    for( String strObjReference : objectReferenceToFieldName.keySet() ) {
                        strTTFieldName = ttObjectReferenceToFieldName.get( strObjReference );
                             
                        if( String.isNotBlank( strTTFieldName ) ) {
                            if( strObjectApiName == strObjReference ) {
                                strObjectFieldName = 'Id';
                            }
                            else {
                                strObjectFieldName = objectReferenceToFieldName.get( strObjReference );
                            }
                            listOfRelationFieldTokens.add( strObjectFieldName + ':' + strTTFieldName );
                        }
                    }
                    TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 'getListOfRelationFieldTokens Before Merge-listOfRelationFieldTokens:-\n' + JSON.serialize( listOfRelationFieldTokens ),
                                              Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() );
                    
                    listOfRelationFieldTokens = mergeListTokens( listOfRelationFieldTokens );
                }
            }
        }
        TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 'getListOfRelationFieldTokens-listOfRelationFieldTokens:-\n' + JSON.serialize( listOfRelationFieldTokens ),
                                              Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() );
        return listOfRelationFieldTokens;
    }
    
    /**
        @ Purpose     : Creates the map of api name of the reference object with api name of its related lookup or master detail field on the given object.
        @ Parameter   : String [ Api name of the object ].
        @ Return Type : Map<String,String> [ E.g, Holds Api name of Account object as key and api name of Account lookup field on given object ].
    */  
    private static Map<String,String> getObjectReferenceTofieldName( String strObjectApiName ) {
        
        Map<String,String> objectReferenceToFieldName = new Map<String,String>();
        if( String.isNotBlank( strObjectApiName ) ) {
            
            List<Schema.DescribeFieldResult> listOfFieldResults = getListOfFieldResults( strObjectApiName );
            if( !listOfFieldResults.isEmpty() ) {
                objectReferenceToFieldName = getObjectReferenceTofieldName( listOfFieldResults );
            }
        }
        TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 'In getObjectReferenceTofieldName-objectReferenceToFieldName:-\n' + JSON.serialize( objectReferenceToFieldName ),
                                              Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() );
        return objectReferenceToFieldName;
    }
    
    /**
        @ Purpose     : Creates the list of field results of all the lookup or master detail fields on the given object.
        @ Parameter   : String [ Api name of the object ].
        @ Return Type : List<Schema.DescribeFieldResult> [ Holds field results of Master detail and lookup fields except system fields ].
    */  
    private static List<Schema.DescribeFieldResult> getListOfFieldResults( String strObjectApiName ) {
        
        List<Schema.DescribeFieldResult> listOfFieldResults = new List<Schema.DescribeFieldResult>();
        if( String.isNotBlank( strObjectApiName ) ) {
            Schema.SobjectType sobjType = Schema.getGlobalDescribe().get( strObjectApiName );
            
            if( sobjType != NULL ) {
                Schema.DescribeSobjectResult sobjResult = sobjType.getDescribe();
                for( Schema.SobjectField sobjField : sobjResult.fields.getMap().values() ) {
                    listOfFieldResults.add( sobjField.getDescribe() );
                }
            }
        }
        return listOfFieldResults;
    }
    
    /**
        @ Purpose     : Creates the map of api name of the reference object with api name of its related lookup or master detail field on the given object.
        @ Parameter   : List<Schema.DescribeFieldResult> [ Holds field results of Master detail and lookup fields except system fields ].
        @ Return Type : Map<String,String> [ E.g, Holds Api name of Account object as key and api name of Account lookup field on given object ].
    */
    private static Map<String,String> getObjectReferenceTofieldName( List<Schema.DescribeFieldResult> listOfFieldResults ) {
        
        Map<String,String> objectReferenceToFieldName = new Map<String,String>();
        if( listOfFieldResults != NULL && !listOfFieldResults.isEmpty() ) {
            
            List<Schema.sObjectType> listOfsObjectTypes;
            for( Schema.DescribeFieldResult fieldResult : listOfFieldResults ) {
                if( checkForLookUpOrMasteDetailField( fieldResult ) ) {
                    listOfsObjectTypes = fieldResult.getReferenceTo();
                    
                    if( listOfsObjectTypes != NULL && !listOfsObjectTypes.isEmpty() ) {
                        objectReferenceToFieldName.put( listOfsObjectTypes.get( 0 ).getDescribe().getName(), fieldResult.getName() );
                    }
                }
            }
        }
        return objectReferenceToFieldName;
    }
    
    /**
        @ Purpose     : Checks if the field is lookup or master detail field.
        @ Parameter   : Schema.DescribeFieldResult [ field result ].
        @ Return Type : Boolean [ TRUE, if field is lookup or master detail field, otherwise FALSE ].
    */
    private static Boolean checkForLookUpOrMasteDetailField( Schema.DescribeFieldResult fieldResult ) {
            
        Boolean isLookupOrMasteDetailField = FALSE;
        if( fieldResult != NULL ) {
            isLookupOrMasteDetailField = String.valueOf( fieldResult.getType() ) == 'REFERENCE' && fieldResult.isPermissionable();
        }
        return isLookupOrMasteDetailField;
    }
    
    /**
        @ Purpose     : 1. Merges the tokens of list 
                        2. Split the tokens by ';' and merge again as long as merge field length is less than 255 characters.
        @ Parameter   : List<String> [ holds mapping of sobject field with field of TimeTracker object ].
        @ Return Type : List<String> [ holds the contents of field mapping; holding maximum 255 characters at one element ].
    */
    private static List<String> mergeListTokens( List<String> listOfRelationFieldTokens ) {
        
        System.debug( 'After mergeListTokens-listOfRelationFieldTokens :-\n' + JSON.serialize( listOfRelationFieldTokens ) );    
        List<String> listOfMergedTokens = new List<String>();
        if( listOfRelationFieldTokens != NULL && !listOfRelationFieldTokens.isEmpty() ) {
            String strRelationShipToken = String.join( listOfRelationFieldTokens, ';' );
            
            if( strRelationShipToken.length() > 255 ) {
                splitTokens( listOfMergedTokens, strRelationShipToken );
            }
            else {
                listOfMergedTokens.add( strRelationShipToken );
            }
        }
        System.debug( 'After mergeListTokens-listOfMergedTokens:-\n' + JSON.serialize( listOfMergedTokens ) );
        return listOfMergedTokens;
    }
    
    /**
        @ Purpose     : Split the tokens by ';' and merge again as long as merge field length is less than 255 characters.
        @ Parameter   : 1. List<String> [ holds mapping of sobject field with field of TimeTracker object ].
                        2. String [ holds the contents which are not merged yet ].
    */
    private static void splitTokens( List<String> listOfMergedTokens, String strTrimmedToken ) {
        
        TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 'In splitTokens listOfMergedTokens :-\n' + JSON.serialize( listOfMergedTokens ),
                                              Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() );
        
        TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 'In splitTokens strTrimmedToken:-\n' + strTrimmedToken,
                                              Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() );
        
        if( String.isNotBlank( strTrimmedToken ) ) {
            Integer intTrimmedTokenSize = strTrimmedToken.length();
            
            Integer intEndTokenIndex = strTrimmedToken.lastIndexOfIgnoreCase( ';', ( intTrimmedTokenSize > 255 ? 255 : intTrimmedTokenSize ) );
            if( intEndTokenIndex == -1 ) {
                intEndTokenIndex = intTrimmedTokenSize;
            }
            
            String strFieldToken = strTrimmedToken.subString( 0, intEndTokenIndex );
            listOfMergedTokens.add( strFieldToken );
            
            Integer intFieldTokenSize = strFieldToken.length();
            if( intFieldTokenSize < intTrimmedTokenSize ) {
                splitTokens( listOfMergedTokens, strTrimmedToken.subString( intFieldTokenSize + 1, intTrimmedTokenSize ) ); 
            }
        }
    }
}