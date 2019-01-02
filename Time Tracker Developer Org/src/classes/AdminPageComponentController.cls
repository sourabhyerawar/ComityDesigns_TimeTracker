public class AdminPageComponentController {

    /*
        * @Author      : abhijeetkurle@comitydesigns.com
        * @Description : Method to return TimeTrackerConfigSettings records.
        * @Params      : type of custom setting required.
        * @Returns     : List of all TimeTrackerConfigSettings__c records.
    */
    @AuraEnabled
    public static String getSettings( String dummy ) {
        
        try {
            String strJsonSettings = removeNameSpace( JSON.serialize( new Settings() ) );
            System.debug( 'getSettings-strJsonSettings:-\n' + strJsonSettings );
            TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 'getSettings-strJsonSettings:-\n' + strJsonSettings, 
                                              Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                            );
            return strJsonSettings;
        } 
        catch( Exception e ) {
            String strExceptionMessage = TimeTrackerUtility.createExceptionLogString( e );
            System.debug( 'getSettings-Exception:-\n' + strExceptionMessage );
            TimeTrackerUtility.addLogMessage( LoggingLevel.ERROR, 'getSettings-Exception:-\n' + strExceptionMessage,
                                              Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                            );
            return NULL;
        }
        finally {
            TimeTrackerUtility.upsertLogRecord();
        }
    }
    
    @AuraEnabled
    public static String getNameSpace() {
        
        String nameSpace;
        List<ApexClass> packageClasses = [ SELECT NamespacePrefix FROM ApexClass WHERE Name = 'TimeTrackerController' ];
        if( !packageClasses.isEmpty() ) {
            nameSpace = packageClasses.get( 0 ).NamespacePrefix;
        }
        System.debug( 'getNameSpace-nameSpace:-\n' + nameSpace );
        TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 'getNameSpace-nameSpace:-\n' + nameSpace, 
                                          Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                        );
        TimeTrackerUtility.upsertLogRecord();
        return nameSpace;
    }

    /*
        * @Author      : sarangp@comitydesigns.com
        * @Description : Method to return TimeTrackerConfigSettings records based on type sent from client side controller.
        * @Params      : type of custom setting required.
        * @Returns     : JSON of list of TimeTrackerConfigSettings__c records of particular type.
    */
    @AuraEnabled
    public static String getConfigSettingDetails( String type ) {
        
        String strJsonConfigSettings = '';
        try {
            List<TimeTrackerConfigSettings__c> listToReturn = getConfigSettings( type );
            strJsonConfigSettings = removeNameSpace( JSON.serialize( listToReturn ) );
            System.debug( 'getConfigSettingDetails-strJsonConfigSettings:-\n' + strJsonConfigSettings );
            TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 'getConfigSettingDetails-strJsonConfigSettings:-\n' + strJsonConfigSettings, 
                                              Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                            );
        }
        catch( Exception e ) {
            String strExceptionMessage = TimeTrackerUtility.createExceptionLogString( e );
            System.debug( 'getConfigSettingDetails-Exception:-\n' + strExceptionMessage );
            TimeTrackerUtility.addLogMessage( LoggingLevel.ERROR, 'getConfigSettingDetails-Exception:-\n' + strExceptionMessage,
                                              Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                            );
        }
        finally {
            TimeTrackerUtility.upsertLogRecord();
        }
        return strJsonConfigSettings;
    }
    
    /*
        * @Author      : sarangp@comitydesigns.com
        * @Description : Method to return TimeTrackerConfigSettings records based on type sent from client side controller.
        * @Params      : type of custom setting required.
        * @Returns     : List of TimeTrackerConfigSettings__c records of particular type.
    */
    private static List<TimeTrackerConfigSettings__c> getConfigSettings( String type ) {
        
        List<TimeTrackerConfigSettings__c> listToReturn = new List<TimeTrackerConfigSettings__c>();
        try {
            for( TimeTrackerConfigSettings__c configSetting : TimeTrackerConfigSettings__c.getAll().values() ) {
                if( type.containsIgnoreCase( configSetting.Type__c ) ) {
                    listToReturn.add( configSetting );
                }
            }
        }
        catch( Exception e ) {
            String strExceptionMessage = TimeTrackerUtility.createExceptionLogString( e );
            System.debug( 'getConfigSettings-Exception:-\n' + strExceptionMessage );
            TimeTrackerUtility.addLogMessage( LoggingLevel.ERROR, 'getConfigSettings-Exception:-\n' + strExceptionMessage,
                                              Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                            );
        }
        System.debug( 'getConfigSettings-listToReturn:-\n' + JSON.serialize( listToReturn ) );
        TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 'getConfigSettings-listToReturn:-\n' + JSON.serialize( listToReturn ), 
                                          Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                        );
        TimeTrackerUtility.upsertLogRecord();
        return listToReturn;
    }
    
    /*
        * @Author      : sarangp@comitydesigns.com
        * @Description : Method to insert Manual/URL type of CS Entry to database.
    */
    @AuraEnabled
    public static String insertConfigSettingEntry( String name, String type, String text1, String text3, String text2, String text5, 
                                                   String text7, String text8, Boolean isBillable, Boolean isReportable, 
                                                   Boolean IsUtilized, Boolean IsActive, String text4,
                                                   String code1, String code2
    ){
        if( type == TimeTrackerConstants.MANUAL_TYPE ) {
            text1= text1.capitalize();
        }
        else if( type == TimeTrackerConstants.OBJECT_SETTINGS && String.isNotBlank( text1 ) && !( text1.containsWhitespace() ) ) {
            Map<String, String> objectDetails = AdminPageComponentController.getObjectPrefixIDAndLable( text1 );
            code1 = objectDetails.get( 'ObjPrefix' );
        }
        
        try {
            TimeTrackerConfigSettings__c newTimeTrackerConfigSettings;
            newTimeTrackerConfigSettings = new TimeTrackerConfigSettings__c
                                           (
                                            Type__c = type,
                                            Name = name,
                                            Text1__c= text1,
                                            Text3__c= text3,
                                            Text2__c= text2,      //TODO: To be determined the mapping for this, Text2__c is temporary
                                            Text5__c=text5,
                                            Text7__c=text7,
                                            Text8__c=text8,
                                            Flag1__c= isBillable,
                                            Flag3__c= isReportable,
                                            Flag2__c= IsUtilized,
                                            Text4__c= text4,
                                            IsActive__c= IsActive,
                                            Code1__c= code1,
                                            Code2__c= code2
                                           );
            System.debug( 'insertConfigSettingEntry-newTimeTrackerConfigSettings:-\n' + JSON.serialize( newTimeTrackerConfigSettings ) );
            TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 
                                              'insertConfigSettingEntry-newTimeTrackerConfigSettings:-\n' + JSON.serialize( newTimeTrackerConfigSettings ), 
                                              Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                            );
            insert newTimeTrackerConfigSettings;
            return 'SUCCESS';
        }
        catch( DMLException e ) {
            String strExceptionMessage = TimeTrackerUtility.createExceptionLogString( e );
            System.debug( 'insertConfigSettingEntry-Exception:-\n' + strExceptionMessage );
            TimeTrackerUtility.addLogMessage( LoggingLevel.ERROR, 'insertConfigSettingEntry-Exception:-\n' + strExceptionMessage,
                                              Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() );
            return e.getDmlMessage( 0 );
        }
        catch( Exception e ) {
            String strExceptionMessage = TimeTrackerUtility.createExceptionLogString( e );
            System.debug( 'insertConfigSettingEntry-Exception:-\n' + strExceptionMessage );
            TimeTrackerUtility.addLogMessage( LoggingLevel.ERROR, 'insertConfigSettingEntry-Exception:-\n' + strExceptionMessage,
                                              Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() );
            return e.getMessage();
        }
        finally {
            TimeTrackerUtility.upsertLogRecord();
        }
    }

    /*
        * @Author      : sarangp@comitydesigns.com
        * @Description : Method to return onject prefix ID based on name of bject
    */
    @AuraEnabled
    public static Map<String,String> getObjectPrefixIDAndLable( String objName ) {
        
        Map<String,String> objDetails = new Map<String,String>();
        Map<String, Schema.SObjectType> m  = Schema.getGlobalDescribe();
        Schema.SObjectType s = m.get( objName );
        
        if( s != NULL ) {
            Schema.DescribeSObjectResult r = s.getDescribe() ;
            String fieldListStr = ''; 
            
            List<Schema.SObjectField> fieldList = r.fields.getMap().values();
            for(Schema.SObjectField field : fieldList) {
                fieldListStr = fieldListStr + field +';';
            } 
            
            system.debug('fieldListStr : '+fieldListStr);
            objDetails.put('ObjPrefix',r.getKeyPrefix());
            objDetails.put('ObjLable', r.getLabel());
            objDetails.put('ObjFields', fieldListStr);
            objDetails.put('ObjPluralLabel', r.getLabelPlural());
        }
        return objDetails;
    }
    
    /*
        * @Author      : sourabhy@comitydesigns.com
        * @Description : Method to return object prefix ID based on name of bject
    */
    @AuraEnabled
    public static Map<String,String> getObjectPrefixIDAndLable( String objName, Boolean fetchRelationDetails ) {
        
        Map<String,String> objDetails = getObjectPrefixIDAndLable( objName );
        //if( fetchRelationDetails == TRUE ) {
            List<String> listOfRelationFieldTokens = AdminPageComponentHelper.getListOfRelationFieldTokens( objName );
            if( !listOfRelationFieldTokens.isEmpty() ) {
                objDetails.put( 'jsonListOfRelationshipTokens', JSON.serialize( listOfRelationFieldTokens ) );
            }
        //}
        System.debug( 'getObjectPrefixIDAndLable-objDetails:\n' + JSON.serialize( objDetails ) );
        TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 'getObjectPrefixIDAndLable-objDetails:\n' + JSON.serialize( objDetails ), 
                                          Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                        );
        TimeTrackerUtility.upsertLogRecord();
        return objDetails;
    }
    
    /*
        * @Author      : sarangp@comitydesigns.com
        * @Description : Method to return list of object names to be traced
        * @Parameters  : Boolean variable to decide if the list to return should omit the already tracked object names, 
                         typically in case of typeahead feature
        * @TODO        : Decide how which all objects to return.
    */
    @AuraEnabled
    public static List<String> getObjectNameList( Boolean removeAlreadyTrackedObj, Boolean includeMandatory ) {
        
        List<String> listOfObjectApiNames;
        try {
            Set<String> setOfObjectApiNames = new Set<String>
                                              {
                                               'Case',
                                               'Account',
                                               'Campaign',
                                               'Contact',
                                               'Contract',
                                               'Event',
                                               'Lead',
                                               'Opportunity',
                                               'Order',
                                               'Task',
                                               'Solution'
                                              };
            
            for ( Schema.SObjectType o : Schema.getGlobalDescribe().values() ) {
                Schema.DescribeSObjectResult objResult = o.getDescribe();
                if( objResult.isCreateable() && objResult.getKeyPrefix() != NULL ) {
                    setOfObjectApiNames.add( objResult.getName() );
                }
            }
            
            removeAlreadyTrackedObj = FALSE;
            if( removeAlreadyTrackedObj ) {
                
                List<TimeTrackerConfigSettings__c> settingList = AdminPageComponentController.getConfigSettings( TimeTrackerConstants.Object_Settings );
                for( TimeTrackerConfigSettings__c setting : settingList ) {
                    if( setOfObjectApiNames.contains( setting.Text1__c ) ) {
                        setOfObjectApiNames.remove( setting.Text1__c );
                    }
                }
            }
            
            listOfObjectApiNames = new List<String>();
            listOfObjectApiNames.addAll( setOfObjectApiNames );
            listOfObjectApiNames.sort();
        }
        catch( Exception e ) {
            String strExceptionMessage = TimeTrackerUtility.createExceptionLogString( e );
            System.debug( 'getObjectNameList-Exception:-\n' + strExceptionMessage );
            TimeTrackerUtility.addLogMessage( LoggingLevel.ERROR, 'getObjectNameList-Exception:-\n' + strExceptionMessage,
                                              Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() );
        }
        System.debug( 'getObjectNameList-listOfObjectApiNames:-\n' + JSON.serialize( listOfObjectApiNames ) );
        TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 
                                          'getObjectNameList-listOfObjectApiNames:-\n' + JSON.serialize( listOfObjectApiNames ), 
                                          Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                        );
        TimeTrackerUtility.upsertLogRecord();
        return listOfObjectApiNames;
    }

    /*
        * @Author      : sarangp@comitydesigns.com
        * @Description : Method to save the values of fields edited on UI
    */
    @AuraEnabled
    public static String updateEditedValues( String strListToUpdate, String strListToReturn ) {
        
        String resultJson = '';
        try {
            List<TimeTrackerConfigSettings__c> listToUpdate;
            listToUpdate = ( List<TimeTrackerConfigSettings__c> ) JSON.deserialize( strListToUpdate, List<TimeTrackerConfigSettings__c>.class );
            System.debug( 'updateEditedValues-listToUpdate:-\n' + JSON.serialize( listToUpdate ) );
            TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 'updateEditedValues-listToUpdate:-\n' + JSON.serialize( listToUpdate ), 
                                              Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                            );
            update listToUpdate;
            
            
            List<TimeTrackerConfigSettings__c> listToReturn;
            listToReturn = ( List<TimeTrackerConfigSettings__c> ) JSON.deserialize( strListToReturn, List<TimeTrackerConfigSettings__c>.class );
            System.debug( 'updateEditedValues-listToReturn:-\n' + JSON.serialize( listToReturn ) );
            TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 'updateEditedValues-listToReturn:-\n' + JSON.serialize( listToReturn ), 
                                              Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                            );

            Set<Id> ttConfigSettingIdSet = new Set<Id>();
            for( TimeTrackerConfigSettings__c ttConfigSettings: listToReturn ) {
                ttConfigSettingIdSet.add( ttConfigSettings.Id );
            }
            
            List<TimeTrackerConfigSettings__c> newTimeTrackerConfigSettingsList = new List<TimeTrackerConfigSettings__c>();
            List<TimeTrackerConfigSettings__c> allUpdatedConfigSettings = TimeTrackerConfigSettings__c.getAll().values();
            for( TimeTrackerConfigSettings__c ttConfigSettings: allUpdatedConfigSettings ) {
                if( ttConfigSettingIdSet.contains( ttConfigSettings.Id ) ) {
                    newTimeTrackerConfigSettingsList.add( ttConfigSettings );
                }
            }
            resultJson = removeNameSpace( JSON.serialize( newTimeTrackerConfigSettingsList ) );
        } 
        catch (DmlException e ) {
            String strExceptionMessage = TimeTrackerUtility.createExceptionLogString( e );
            System.debug( 'updateEditedValues-Exception:-\n' + strExceptionMessage );
            TimeTrackerUtility.addLogMessage( LoggingLevel.ERROR, 'updateEditedValues-Exception:-\n' + strExceptionMessage,
                                              Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() );
            resultJson = 'ERROR '+ e.getDmlMessage( 0 );
        } 
        catch( Exception e ) {
            String strExceptionMessage = TimeTrackerUtility.createExceptionLogString( e );
            System.debug( 'updateEditedValues-Exception:-\n' + strExceptionMessage );
            TimeTrackerUtility.addLogMessage( LoggingLevel.ERROR, 'updateEditedValues-Exception:-\n' + strExceptionMessage,
                                              Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() );
            resultJson = 'ERROR '+ e.getMessage();
        }
        System.debug( 'updateEditedValues:-\n' + resultJson );
        TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 'updateEditedValues:-\n' + resultJson, 
                                          Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                        );
        TimeTrackerUtility.upsertLogRecord();
        return resultJson;
    }

    @AuraEnabled
    public static String deleteConfigSettingRecordList( String strListToDelete, String strListToReturn ) {
        
        String resultJson = '';
        try {
            List<TimeTrackerConfigSettings__c> listToDelete;
            listToDelete = ( List<TimeTrackerConfigSettings__c> ) JSON.deserialize( strlistToDelete, List<TimeTrackerConfigSettings__c>.class );
            System.debug( 'deleteConfigSettingRecordList-listToDelete:-\n' + JSON.serialize( listToDelete ) );
            TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 'deleteConfigSettingRecordList-listToDelete:-\n' + JSON.serialize( listToDelete ), 
                                              Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                            );
            delete listToDelete;
            
            
            List<TimeTrackerConfigSettings__c> listToReturn;
            listToReturn = ( List<TimeTrackerConfigSettings__c> ) JSON.deserialize( strListToReturn, List<TimeTrackerConfigSettings__c>.class );
            System.debug( 'deleteConfigSettingRecordList-listToReturn:-\n' + JSON.serialize( listToReturn ) );
            TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 'deleteConfigSettingRecordList-listToReturn:-\n' + JSON.serialize( listToReturn ), 
                                              Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                            );

            Set<Id> ttConfigSettingIdSet = new Set<Id>();
            for( TimeTrackerConfigSettings__c ttConfigSettings: listToReturn ) {
                ttConfigSettingIdSet.add( ttConfigSettings.Id );
            }
            
            List<TimeTrackerConfigSettings__c> newTimeTrackerConfigSettingsList = new List<TimeTrackerConfigSettings__c>();
            List<TimeTrackerConfigSettings__c> allUpdatedConfigSettings = TimeTrackerConfigSettings__c.getAll().values();
            for( TimeTrackerConfigSettings__c ttConfigSettings: allUpdatedConfigSettings ) {
                if( ttConfigSettingIdSet.contains( ttConfigSettings.Id ) ) {
                    newTimeTrackerConfigSettingsList.add( ttConfigSettings );
                }
            }
            resultJson = removeNameSpace( JSON.serialize( newTimeTrackerConfigSettingsList ) );
        } 
        catch( DmlException e ) {
            String strExceptionMessage = TimeTrackerUtility.createExceptionLogString( e );
            System.debug( 'deleteConfigSettingRecordList-Exception:-\n' + strExceptionMessage );
            TimeTrackerUtility.addLogMessage( LoggingLevel.ERROR, 'deleteConfigSettingRecordList-Exception:-\n' + strExceptionMessage,
                                              Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() );
            resultJson = 'ERROR '+ e.getDmlMessage( 0 );
        } 
        catch( Exception e ) {
            String strExceptionMessage = TimeTrackerUtility.createExceptionLogString( e );
            System.debug( 'deleteConfigSettingRecordList-Exception:-\n' + strExceptionMessage );
            TimeTrackerUtility.addLogMessage( LoggingLevel.ERROR, 'deleteConfigSettingRecordList-Exception:-\n' + strExceptionMessage,
                                              Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() );
            resultJson = 'ERROR '+ e.getMessage();
        }
        System.debug( 'deleteConfigSettingRecordList:-\n' + resultJson );
        TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 'deleteConfigSettingRecordList:-\n' + resultJson, 
                                          Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                        );
        TimeTrackerUtility.upsertLogRecord();
        return resultJson;
    }


    @AuraEnabled
    public static String insertTimeTrackerConfigSettings( String ttconfigSettingsList, Boolean areIdsPresent ) {
        
        // Modified by sourabh@comitydesigns.com on 08/11/2017
        
        String resultJson = '';
        System.debug( 'insertTimeTrackerConfigSettings-ttconfigSettingsList:-\n' + ttconfigSettingsList );
        TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 'insertTimeTrackerConfigSettings-ttconfigSettingsList:-\n' + ttconfigSettingsList, 
                                          Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                        );
        if( String.isBlank( ttconfigSettingsList ) ) {
            resultJson = 'ERROR - ' + 'Sorry, unable to save the records; records were missing. Please try again.';
        }
        
        try {
            List<TimeTrackerConfigSettings__c> listOfConfigSettingsToUpsert = new List<TimeTrackerConfigSettings__c>();
            listOfConfigSettingsToUpsert = ( List<TimeTrackerConfigSettings__c> ) JSON.deserialize( ttconfigSettingsList, List<TimeTrackerConfigSettings__c>.class );
            System.debug( 'insertTimeTrackerConfigSettings-listOfConfigSettingsToUpsert:-\n' + JSON.serialize( listOfConfigSettingsToUpsert ) );
            TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 
                                              'insertTimeTrackerConfigSettings-listOfConfigSettingsToUpsert:-\n' + 
                                              JSON.serialize( listOfConfigSettingsToUpsert ), 
                                              Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                            );
            
            System.debug( 'insertTimeTrackerConfigSettings-listOfConfigSettingsToUpsert:-\n' + JSON.serialize( listOfConfigSettingsToUpsert ) );
            if( !listOfConfigSettingsToUpsert.isEmpty() ) {
                Map<String, TimeTrackerConfigSettings__c> uniqueConfigSettingKeyToRecord = getUniqueConfigSettingKeyToRecord();
                Map<String, TimeTrackerConfigSettings__c> configSettingNameToRecord = getConfigSettingNameToRecord();
                
                if( !uniqueConfigSettingKeyToRecord.isEmpty() || !configSettingNameToRecord.isEmpty() ) {
                    
                    String strUniqueKey = '';
                    for( TimeTrackerConfigSettings__c recordToUpsert : listOfConfigSettingsToUpsert ) {
                        
                        strUniqueKey = getUniqueKeyByType( recordToUpsert );
                        if( uniqueConfigSettingKeyToRecord.containsKey( strUniqueKey ) ) {
                            recordToUpsert.Id = uniqueConfigSettingKeyToRecord.get( strUniqueKey ).Id;
                        }
                        else if( String.isNotBlank( recordToUpsert.Name ) ) {
                            strUniqueKey = recordToUpsert.Name.toLowerCase();
                            if( configSettingNameToRecord.containsKey( strUniqueKey ) ) {
                                recordToUpsert.Id = configSettingNameToRecord.get( strUniqueKey ).Id;
                            }
                        }
                    }
                }
                
                upsert listOfConfigSettingsToUpsert;
                resultJson = removeNameSpace( JSON.serialize( listOfConfigSettingsToUpsert ) );
            }
            else {
                resultJson = 'ERROR - ' + 'Sorry, an unexpected error occurred while parsing the data. Please try again.';
            }
        }
        catch( DmlException e ) {
            String strExceptionMessage = TimeTrackerUtility.createExceptionLogString( e );
            System.debug( 'insertTimeTrackerConfigSettings-Exception:-\n' + strExceptionMessage );
            TimeTrackerUtility.addLogMessage( LoggingLevel.ERROR, 'insertTimeTrackerConfigSettings-Exception:-\n' + strExceptionMessage,
                                              Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() );
            resultJson = 'ERROR - ' + e.getDmlMessage( 0 );
        }
        catch( Exception e ) {
            String strExceptionMessage = TimeTrackerUtility.createExceptionLogString( e );
            System.debug( 'insertTimeTrackerConfigSettings-Exception:-\n' + strExceptionMessage );
            TimeTrackerUtility.addLogMessage( LoggingLevel.ERROR, 'insertTimeTrackerConfigSettings-Exception:-\n' + strExceptionMessage,
                                              Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() );
            resultJson = 'ERROR - ' + e.getMessage();
        }
        System.debug( 'insertTimeTrackerConfigSettings-resultJson:-\n' + resultJson );
        TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 'insertTimeTrackerConfigSettings-resultJson:-\n' + resultJson, 
                                          Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                        );
        TimeTrackerUtility.upsertLogRecord();
        return resultJson;
    }

    /*
        * @Author:          sarangp@comitydesigns.com
        * @Description:     Method to search entities depending on type and searchString and return matched results
        * @Returns:         List of String
    */
    @AuraEnabled
    public static List<String> getMatchingEntities( String searchedEntity, String searchString, Boolean fetchOnlyUnique, Boolean includeMandatory ) {
        
        try {
            List<String> returnList = new List<String>();
            List<String> searchList = new List<String>();

            /*Case where objects are tracked*/
            if( searchedEntity.equals( 'Objects' ) ) {
                searchList = getObjectNameList( fetchOnlyUnique, includeMandatory );
            }

            for( String str:searchList ) {
                if( str.containsIgnoreCase( searchString ) ) {
                    returnList.add( str );
                }
            }
            System.debug( 'getMatchingEntities-returnList:-\n' + JSON.serialize( returnList ) );
            TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 'getMatchingEntities-returnList:-\n' + JSON.serialize( returnList ), 
                                              Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                            );
            return returnList;
        }
        catch( Exception e ) {
            String strExceptionMessage = TimeTrackerUtility.createExceptionLogString( e );
            System.debug( 'getMatchingEntities-Exception:-\n' + strExceptionMessage );
            TimeTrackerUtility.addLogMessage( LoggingLevel.ERROR, 'getMatchingEntities-Exception:-\n' + strExceptionMessage,
                                              Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() );
            return NULL;
        }
        finally {
            TimeTrackerUtility.upsertLogRecord();
        }
    }

    /*
        * @Author      : sarangp@comitydesigns.com
        * @Description : Method to search entities depending on type and searchString and return matched results
        * @Returns     : List of String
    */
    @AuraEnabled
    public static Map<String, Id> getUserAndProfileDetails( String searchedEntity, String searchString ) {
        
        try {
            Map<String, ID> nameToIDMap = new Map<String, Id>();
            
            /*Case where Users are searched*/
            if( searchedEntity.equals( 'User' ) ) {
                nameToIDMap = getTimeTrackerUsers();
            }

            /*Case where Profiles are searched*/
            else if( searchedEntity.equals( 'Profile' ) ) {
                nameToIDMap = getAllProfiles();
            }
            
            Set<String> ownerNameSet = new Set<String>();
            List<TimeTrackerUserSettings__c> existingUserSettings = getListOfUserHierarchySettings();
            
            for( TimeTrackerUserSettings__c setting : existingUserSettings ) {
                ownerNameSet.add( setting.SetupOwner.Name );
            }
            
            for( String str : nameToIDMap.keySet() ) {
                if(! ( str.containsIgnoreCase( searchString ) ) || ownerNameSet.contains( str ) ) {
                    nameToIDMap.remove( str );
                }
            }
            System.debug( 'getUserAndProfileDetails-nameToIDMap:-\n' + JSON.serialize( nameToIDMap ) );
            TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 'getUserAndProfileDetails-nameToIDMap:-\n' + JSON.serialize( nameToIDMap ), 
                                              Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                            );
            return nameToIDMap;
        }
        catch( Exception e ) {
            String strExceptionMessage = TimeTrackerUtility.createExceptionLogString( e );
            System.debug( 'getUserAndProfileDetails-Exception:-\n' + strExceptionMessage );
            TimeTrackerUtility.addLogMessage( LoggingLevel.ERROR, 'getUserAndProfileDetails-Exception:-\n' + strExceptionMessage,
                                              Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() );
            return NULL;
        }
        finally {
            TimeTrackerUtility.upsertLogRecord();
        }
    }

    /*
        * @Author      : sarangp@comitydesigns.com
        * @Description : Method to return list User names belonging to permission sets
        * @Returns     : List of String
    */
    private static Map<String, Id> getTimeTrackerUsers() {
        
        Set<ID> assigneeIDSet = new Set<ID>();
        Map<String, Id> nameToIDMap = new Map<String, Id>();
        
        //Query to get assigneeIDs assigned to the following two permission sets
        for( PermissionSetAssignment permission: [ SELECT AssigneeId
                                                   FROM PermissionSetAssignment
                                                   WHERE 
                                                   PermissionSet.Name IN ( 'Time_Tracker_Admin_Permission_Set', 'Time_Tracker_Permission_Set' ) 
                                                 ]
        ) {
            assigneeIDSet.add( permission.AssigneeId );
        }
        for( User user : [ SELECT ID, Name FROM User WHERE ID IN : assigneeIDSet ] ) {
            nameToIDMap.put( user.Name, user.Id );
        }
        System.debug( 'getTimeTrackerUsers-nameToIDMap:-\n' + JSON.serialize( nameToIDMap ) );
        TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 'getTimeTrackerUsers-nameToIDMap:-\n' + JSON.serialize( nameToIDMap ), 
                                          Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                        );
        TimeTrackerUtility.upsertLogRecord();
        return nameToIDMap;
    }

    /*
        * @Author      : sarangp@comitydesigns.com
        * @Description : Method to return list Profile names in an organisation
        * @Returns     : List of String of profile names
    */
    private static Map<String, ID> getAllProfiles() {
        
        Map<String, ID> nameToIDMap = new Map<String, ID>();
        for( Profile profile: [ SELECT ID, Name FROM Profile ] ) {
            nameToIDMap.put( profile.Name, profile.Id );
        }
        System.debug( 'getAllProfiles-nameToIDMap:-\n' + JSON.serialize( nameToIDMap ) );
        TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 'getAllProfiles-nameToIDMap:-\n' + JSON.serialize( nameToIDMap ), 
                                          Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                        );
        TimeTrackerUtility.upsertLogRecord();
        return nameToIDMap;
    }

    /*
        * @Author      : sarangp@comitydesigns.com
        * @Description : Method to return list of VFPages in org
        * @Returns     : List of String
    */
    @AuraEnabled
    public static List<String> getVFPageList() {
        
        try {
            List<String> VFPageList = new List<String>();
            for( ApexPage page : [ SELECT name FROM ApexPage ] ) {
                VFPageList.add( page.name );
            }
            return VFPageList;
        }
        catch( Exception e ) {
            String strExceptionMessage = TimeTrackerUtility.createExceptionLogString( e );
            System.debug( 'getVFPageList-Exception:-\n' + strExceptionMessage );
            TimeTrackerUtility.addLogMessage( LoggingLevel.ERROR, 'getVFPageList-Exception:-\n' + strExceptionMessage,
                                              Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() );
            return NULL;
        }
        finally {
            TimeTrackerUtility.upsertLogRecord();
        }
    }

    /*
        * @Author      : sarangp@comitydesigns.com
        * @Description : Method to return default values of Hierarchy(TT user settings) settings
        * @Returns     : Instance of TimeTrackerUserSettings__c
    */
    @AuraEnabled
    public static String getHierarchySettings(){
        
        String strHierarchySettings = JSON.serialize( new Settings( TRUE ) );
        strHierarchySettings = removeNameSpace( strHierarchySettings );
        System.debug( 'getHierarchySettings-strHierarchySettings:-\n' + strHierarchySettings );
        TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 'getHierarchySettings-strHierarchySettings:-\n' + strHierarchySettings, 
                                          Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                        );
        TimeTrackerUtility.upsertLogRecord();
        return strHierarchySettings;
    }

    /*
        * @Author      : sarangp@comitydesigns.com
        * @Description : Method to return Hierarchy(TT user settings) settings specific for user/Profile
        * @Returns     : JSON of TimeTrackerUserSettings__c record.
    */
    @AuraEnabled
    public static String getUserHierarchySettings() {
        
        String strJsonUserSettings = JSON.serialize( new Settings( FALSE ) );
        strJsonUserSettings = removeNameSpace( strJsonUserSettings );
        System.debug( 'getUserHierarchySettings-strJsonUserSettings:-\n' + strJsonUserSettings );
        TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 'getUserHierarchySettings-strJsonUserSettings:-\n' + strJsonUserSettings, 
                                          Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                        );
        TimeTrackerUtility.upsertLogRecord();
        return strJsonUserSettings;
    }
    
    /*
        * @Author      : sarangp@comitydesigns.com
        * @Description : Method to return Hierarchy(TT user settings) settings specific for user/Profile
        * @Returns     : List of TimeTrackerUserSettings__c records.
    */
    public static List<TimeTrackerUserSettings__c> getListOfUserHierarchySettings() {
        
        List<TimeTrackerUserSettings__c> listOfUserSettings = new List<TimeTrackerUserSettings__c>();
        try{
            listOfUserSettings = [ SELECT
                                   Name, ChromeExtensionID__c,ClientDebugLevel__c,ClientFailureNotifications__c, 
                                   Max_Duration_In_Minutes__c, Server_Debug__c, Server_Debug_Level__c, 
                                   //StartDayOfWeek__c, StopTrackingAfterCloseCase__c
                                   Weekly_Hours__c, Is_Time_Tracker_Read_Only__c, SetupOwnerId, SetupOwner.Name
                                   FROM TimeTrackerUserSettings__c
                                   WHERE SetupOwnerId NOT IN (SELECT Id FROM Organization) 
                                   // Logic to filter out records that are user/profile specific and skip organisation level settings
                                 ];
        }
        catch( Exception e ) {
            String strExceptionMessage = TimeTrackerUtility.createExceptionLogString( e );
            System.debug( 'getListOfUserHierarchySettings-Exception:-\n' + strExceptionMessage );
            TimeTrackerUtility.addLogMessage( LoggingLevel.ERROR, 
                                              'getListOfUserHierarchySettings-Exception:-\n' + strExceptionMessage,
                                              Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                            );
        }
        System.debug( 'getListOfUserHierarchySettings-listOfUserSettings:-\n' + JSON.serialize( listOfUserSettings ) );
        TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 
                                          'getListOfUserHierarchySettings-listOfUserSettings:-\n' + JSON.serialize( listOfUserSettings ), 
                                          Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                        );
        TimeTrackerUtility.upsertLogRecord();
        return listOfUserSettings;
    }
    
    /*
        * @Author      : sarangp@comitydesigns.com
        * @Description : Method to return default values of Hierarchy(TT user settings) settings
        * @Returns     : Instance of TimeTrackerUserSettings__c
    */
    @AuraEnabled
    public static String upsertSettings( String strJsonRecordToUpdate ) {
        
        Settings orgWideSettings;
        Boolean isSucceeded = FALSE;
        String strMessage = '';
        
        try {
            System.debug( 'upsertSettings-strJsonRecordToUpdate:-\n' + strJsonRecordToUpdate );
            TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 'upsertSettings-strJsonRecordToUpdate:-\n' + strJsonRecordToUpdate, 
                                              Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                            );
                                            
            TimeTrackerUserSettings__c recordToUpdate;
            recordToUpdate = (TimeTrackerUserSettings__c) JSON.deserialize( strJsonRecordToUpdate, TimeTrackerUserSettings__c.class );
            System.debug( 'After-Deserialize-upsertSettings-strJsonRecordToUpdate:-\n' + JSON.serialize( recordToUpdate ) );
            TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 
                                              'After-Deserialize-upsertSettings-strJsonRecordToUpdate:-\n' + JSON.serialize( recordToUpdate ), 
                                              Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                            );
            
            upsert recordToUpdate;
            isSucceeded = TRUE;
            strMessage = 'Record Saved Successfully!';
        }
        catch( Exception e ) {
            String strExceptionMessage = TimeTrackerUtility.createExceptionLogString( e );
            System.debug( 'upsertSettings-Exception:-\n' + strExceptionMessage );
            TimeTrackerUtility.addLogMessage( LoggingLevel.ERROR, 
                                              'upsertSettings-Exception:-\n' + strExceptionMessage,
                                              Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                            );
            strMessage = 'Sorry, an expected error occurred while saving the record, please try again.';                                  
        }
        finally {
            orgWideSettings = new Settings( TRUE );
            orgWideSettings.setStatus( isSucceeded, strMessage );
            strJsonRecordToUpdate = removeNameSpace( JSON.serialize( orgWideSettings ) );
        }
        System.debug( 'upsertSettings-orgWideSettings:-\n' + strJsonRecordToUpdate );
        TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 'upsertSettings-orgWideSettings:-\n' + strJsonRecordToUpdate, 
                                          Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                        );
        TimeTrackerUtility.upsertLogRecord();
        return strJsonRecordToUpdate;
    }

    /*
        * @Author      : sarangp@comitydesigns.com
        * @Description : Method to delete the record of custom setting sent from client side
        * @Returns     : Instance of TimeTrackerUserSettings__c
    */
    @AuraEnabled
    public static String deleteUserSetting( String strJsonRecordToDelete ) {
        
        System.debug( 'deleteUserSetting-strJsonRecordToDelete:-\n' + strJsonRecordToDelete );
        TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 'deleteUserSetting-strJsonRecordToDelete:-\n' + strJsonRecordToDelete, 
                                          Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                        );
        try{
            TimeTrackerUserSettings__c recordToDelete;
            recordToDelete = (TimeTrackerUserSettings__c) JSON.deserialize( strJsonRecordToDelete, TimeTrackerUserSettings__c.class );
            System.debug( 'deleteUserSetting-recordToDelete:-\n' + JSON.serialize( recordToDelete ) );
            TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 'deleteUserSetting-recordToDelete:-\n' + JSON.serialize( recordToDelete ), 
                                              Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                            );
            delete recordToDelete;
            return 'SUCCESS';
        }
        catch( Exception e ) {
            String strExceptionMessage = TimeTrackerUtility.createExceptionLogString( e );
            System.debug( 'deleteUserSetting-Exception:-\n' + strExceptionMessage );
            TimeTrackerUtility.addLogMessage( LoggingLevel.ERROR, 
                                              'deleteUserSetting-Exception:-\n' + strExceptionMessage,
                                              Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                            );
            return e.getMessage();
        }
        finally {
            TimeTrackerUtility.upsertLogRecord();
        }
    }
    
    // TODO : In Subsequent Release
    /*
        @ Author      : sourabhy@comitydesigns.com
        @ Description : Fetches the JSON of Map of Type of Config Setting Table Configuration with the list of its records.  
        @ Return Type : String [ JSON Of Map<String, List<ConfigSettingsDTO>> ].
    */
    /*
    @AuraEnabled
    public static String getJsonOfConfigSettingsTable() {
        
        String strJsonConfigSettingsTable = '';
        try {
            Map<String, List<ConfigSettingsDTO>> settingTypeToRecords = new Map<String, List<ConfigSettingsDTO>>();
            for( Config_Settings_Table_Configuration__c configRecord : [ SELECT API_Name__c, Label__c, Column_Number__c, Width__c, Checkbox_Field__c,
                                                                         Display__c, Used__c, Description__c, Type__c
                                                                         FROM Config_Settings_Table_Configuration__c
                                                                         WHERE Type__c != NULL
                                                                         ORDER BY Type__c ASC NULLS LAST
                                                                         LIMIT 50000
                                                                       ] 
            ) {
                if( !settingTypeToRecords.containsKey( configRecord.Type__c ) ) {
                    settingTypeToRecords.put( configRecord.Type__c, new List<ConfigSettingsDTO>() );
                }
                settingTypeToRecords.get( configRecord.Type__c ).add( new ConfigSettingsDTO( configRecord ) );
            }
            strJsonConfigSettingsTable = removeNameSpace( JSON.serialize( settingTypeToRecords ) );
        }
        catch( Exception e ) {
            TimeTrackerUtility.addLogMessage( LoggingLevel.ERROR, TimeTrackerUtility.createExceptionLogString( e ),
                                              Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() );
        }
        TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 'strJsonConfigSettingsTable:-\n' + strJsonConfigSettingsTable, 
                                          Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                        );
        return strJsonConfigSettingsTable;
    }
    //*/
    
    private static Map<String, TimeTrackerConfigSettings__c> getConfigSettingNameToRecord() {
        
        Map<String, TimeTrackerConfigSettings__c> configSettingNameToRecord = new Map<String, TimeTrackerConfigSettings__c>();
        for( TimeTrackerConfigSettings__c configSettingRecord : TimeTrackerConfigSettings__c.getAll().values() ) {
            configSettingNameToRecord.put( configSettingRecord.Name.toLowerCase(), configSettingRecord );
        }
        System.debug( 'getConfigSettingNameToRecord-configSettingNameToRecord:-\n' + JSON.serialize( configSettingNameToRecord ) );
        TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 
                                          'getConfigSettingNameToRecord-configSettingNameToRecord:-\n' + JSON.serialize( configSettingNameToRecord ),
                                          Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                        );
        TimeTrackerUtility.upsertLogRecord();
        return configSettingNameToRecord;
    }
    
    public static Map<String, TimeTrackerConfigSettings__c> getUniqueConfigSettingKeyToRecord() {
        
        Map<String, TimeTrackerConfigSettings__c> uniqueConfigSettingKeyToRecord = new Map<String, TimeTrackerConfigSettings__c>();
        String strUniqueKey = '';
        for( TimeTrackerConfigSettings__c configSettingRecord : TimeTrackerConfigSettings__c.getAll().values() ) {
            
            strUniqueKey = getUniqueKeyByType( configSettingRecord );
            if( String.isNotBlank( strUniqueKey ) ) {
                uniqueConfigSettingKeyToRecord.put( strUniqueKey, configSettingRecord );
            }
        }
        System.debug( 'getUniqueConfigSettingKeyToRecord:-\n' + JSON.serialize( uniqueConfigSettingKeyToRecord ) );
        TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 
                                          'getUniqueConfigSettingKeyToRecord:-\n' + JSON.serialize( uniqueConfigSettingKeyToRecord ),
                                          Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                        );
        
        TimeTrackerUtility.upsertLogRecord();
        return uniqueConfigSettingKeyToRecord;
    }
    
    private static String getUniqueKeyByType( TimeTrackerConfigSettings__c configSettingRecord ) {
        
        String strUniqueKey = '';
        if( configSettingRecord != NULL && String.isNotBlank( configSettingRecord.Type__c ) ) {
            
            if( configSettingRecord.Type__c == TimeTrackerConstants.CUSTOM_EVENT_TYPE || 
                configSettingRecord.Type__c ==  TimeTrackerConstants.OBJECT_SETTINGS 
            ) {
                if( String.isNotBlank( configSettingRecord.Code1__c ) ) {
                    strUniqueKey = configSettingRecord.Type__c.toLowerCase() + '-' + configSettingRecord.Code1__c;
                }
            }
            else if( configSettingRecord.Type__c == TimeTrackerConstants.URL_PATTERN_TYPE ) {
                if( String.isNotBlank( configSettingRecord.Code1__c ) ) {
                    strUniqueKey = configSettingRecord.Type__c.toLowerCase() + '-' + configSettingRecord.Code1__c.toLowerCase();
                }
            }
            else if( String.isNotBlank( configSettingRecord.Text1__c ) ) {
                strUniqueKey = configSettingRecord.Type__c.toLowerCase() + '-' + configSettingRecord.Text1__c.toLowerCase();
            }
        }
        return strUniqueKey;
    }
    
    @TestVisible
    private class Settings {
        @TestVisible
        Boolean isSucceeded { get; set; }
        
        String strMessage { get; set; }
        
        User User {get; set;}
        
        String OrgId {get; set;}
        
        String BaseUrl {get; set;}
        
        String Namespace {get; set;}
        
        TimeTrackerUserSettings__c UserSettings {get; set;}
        
        TimeTrackerUserSettings__c orgWideSettings { get; set; }
        
        Map<String, TimeTrackerConfigSettings__c> ConfigSettings {get; set;}
        
        List<TimeTrackerUserSettings__c> listOfUserSettings { get; set; }
        
        Map<String, String> ObjectSettings {get; set;}
        
        Map<String, String> ResourceURLs {get; set;}
    
        public Settings() {
            
            this.User = [Select Id, Name, Email, Username, ProfileId From User Where Id=:UserInfo.getUserId()];
            this.OrgId = UserInfo.getOrganizationId();
            
            this.BaseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
            this.setNameSpace();
            
            this.UserSettings = TimeTrackerUserSettings__c.getInstance();
            this.ConfigSettings = TimeTrackerConfigSettings__c.getAll();
        }
        
        public Settings( Boolean isOrgWideSettingsOnly ) {
            
            if( isOrgWideSettingsOnly ) {
                this.orgWideSettings = TimeTrackerUserSettings__c.getOrgDefaults();
            }
            else {
                this.listOfUserSettings = AdminPageComponentController.getListOfUserHierarchySettings();
            }
            this.setNameSpace();
        }
        
        private void setNameSpace() {
            
            List<ApexClass> packageClasses = [ SELECT NamespacePrefix FROM ApexClass WHERE Name = 'TimeTrackerController' ];
            if( !packageClasses.isEmpty() ) {
                this.Namespace = packageClasses.get( 0 ).NamespacePrefix;
            }
        }
        
        private void setStatus( Boolean isSucceeded, String strMessage ) {
            
            if( isSucceeded != NULL ) {
                this.isSucceeded = isSucceeded;
            }
            this.strMessage = strMessage;
        }
    }
    
    private static String removeNameSpace( String strJsonOfListOfConfigSettings ) {
        
        System.debug( 'Before-removeNameSpace-strJsonOfListOfConfigSettings:-\n' + strJsonOfListOfConfigSettings );
        TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 
                                          'Before-removeNameSpace-strJsonOfListOfConfigSettings:-\n' + strJsonOfListOfConfigSettings,
                                          Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                        );
        if( String.isNotBlank( strJsonOfListOfConfigSettings ) && strJsonOfListOfConfigSettings.contains( 'timetracker__' ) ) {
            Map<String,String> fieldNameWithNameSpaceToPlainFieldName;
            fieldNameWithNameSpaceToPlainFieldName = new Map<String,String>
                                                     {
                                                      'timetracker__Text1__c' => 'Text1__c',
                                                      'timetracker__Text2__c' => 'Text2__c',
                                                      'timetracker__Text3__c' => 'Text3__c',
                                                      'timetracker__Text4__c' => 'Text4__c',
                                                      'timetracker__Text5__c' => 'Text5__c',
                                                      'timetracker__Text6__c' => 'Text6__c',
                                                      'timetracker__Text7__c' => 'Text7__c',
                                                      'timetracker__Text8__c' => 'Text8__c',
                                                      
                                                      'timetracker__Code1__c' => 'Code1__c',
                                                      'timetracker__Code2__c' => 'Code2__c',
                                                      
                                                      'timetracker__Flag1__c' => 'Flag1__c',
                                                      'timetracker__Flag2__c' => 'Flag2__c',
                                                      'timetracker__Flag3__c' => 'Flag3__c',
                                                      'timetracker__Flag4__c' => 'Flag4__c',
                                                      
                                                      'timetracker__IsActive__c' => 'IsActive__c',
                                                      'timetracker__Type__c' => 'Type__c',
                                                      
                                                      'timetracker__ChromeExtensionID__c' => 'ChromeExtensionID__c',
                                                      'timetracker__ClientDebugLevel__c' => 'ClientDebugLevel__c',
                                                      'timetracker__ClientFailureNotifications__c' => 'ClientFailureNotifications__c',
                                                      'timetracker__Is_Time_Tracker_Read_Only__c' => 'Is_Time_Tracker_Read_Only__c',
                                                      'timetracker__Max_Duration_In_Minutes__c' => 'Max_Duration_In_Minutes__c',
                                                      'timetracker__Server_Debug__c' => 'Server_Debug__c',
                                                      
                                                      'timetracker__Server_Debug_Level__c' => 'Server_Debug_Level__c',
                                                      'timetracker__StartDayOfWeek__c' => 'StartDayOfWeek__c',
                                                      'timetracker__StopTrackingAfterCloseCase__c' => 'StopTrackingAfterCloseCase__c',
                                                      'timetracker__Weekly_Hours__c' => 'Weekly_Hours__c'
                                                     };
            
            String strPlainFieldName;
            for( String strFieldNameWithNameSpace : fieldNameWithNameSpaceToPlainFieldName.keySet() ) {
                
                if( strJsonOfListOfConfigSettings.contains( strFieldNameWithNameSpace ) ) {
                    strPlainFieldName = fieldNameWithNameSpaceToPlainFieldName.get( strFieldNameWithNameSpace );
                    strJsonOfListOfConfigSettings = strJsonOfListOfConfigSettings.replaceAll( strFieldNameWithNameSpace, strPlainFieldName );
                }
            }
        }
        System.debug( 'After-removeNameSpace-strJsonOfListOfConfigSettings:-\n' + strJsonOfListOfConfigSettings );
        TimeTrackerUtility.addLogMessage( LoggingLevel.DEBUG, 'After-removeNameSpace-strJsonOfListOfConfigSettings:-\n' + strJsonOfListOfConfigSettings,
                                          Datetime.now(), NULL, NULL, NULL, UserInfo.getUserId() 
                                        );
        TimeTrackerUtility.upsertLogRecord();
        return strJsonOfListOfConfigSettings;
    }
}