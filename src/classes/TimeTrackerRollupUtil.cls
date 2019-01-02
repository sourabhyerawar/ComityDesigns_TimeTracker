/**
* @description an util class for lookup field rollup summary, 
* this class only provides summary for numeric fields (double, integer, decimal primitive types) 
*/
public class TimeTrackerRollupUtil {
	
	/**
	* @description wrapper class to house the field names and desired operation
	*/
	public class FieldDefinition {
        public String operation {get; set;}
        public String childField {get; set;}
        public String parentField {get; set;}
         
        public FieldDefinition (String op, String cFld, String pFld) {
            operation = op;
            childField = cFld;
            parentField = pFld;
        }
    }
     
    /**
	* @description method to rollup
	* @param List<FieldDefinition>: fieldDefinitions
	* @param List<sObject>: records
	* @param String: childObject
	* @param String: childParentLookupField
	* @param String: parentObject
	* @param String: queryFilter
	* @return none
	*/
    public static void rollUpTrigger(List<FieldDefinition> fieldDefinitions, List<sObject> records, String childObject, 
    									String childParentLookupField, String parentObject, String queryFilter) {
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'Started TimeTrackerRollupUtil.rollUpTrigger() method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
        TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'fieldDefinitions: ' + fieldDefinitions + ';records: ' + records
            + ';childObject: ' + childObject + ';childParentLookupField: ' + childParentLookupField + ';parentObject: '
            + parentObject + ';queryFilter: ' + queryFilter,
            Datetime.now(), null, null, null, UserInfo.getUserId());
         
        //Limit the size of list by using Sets which do not contain duplicate
        //elements prevents hitting governor limits
        Set<Id> parentIds = new Set<Id>();
         
        for(sObject so : records) {
            if(so.get(childParentLookupField) != null) {
                parentIds.add((Id)so.get(childParentLookupField));
            }
        }

        if(!parentIds.isEmpty()) {
         
            //populate query text strings to be used in child aggregrator and 
            //parent value assignment
            String fieldsToAggregate = '';
            String parentFields = '';
             
            for(FieldDefinition def : fieldDefinitions) {
                fieldsToAggregate += def.operation + '(' + def.childField + ') ' + ', ';
                parentFields += def.parentField + ', ';
            }
             
            //Using dynamic SOQL with aggergate results to populate parentValueMap
            String aggregateQuery = 'Select ' + fieldsToAggregate + 
    						        childParentLookupField + ' From ' + childObject + ' Where  ' + 
    						        childParentLookupField + ' IN :parentIds ' + queryFilter + ' ' +
    						        'Group By ' + childParentLookupField;

            TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'aggregateQuery: ' + aggregateQuery,
                Datetime.now(), null, null, null, UserInfo.getUserId());
            //Map will contain one parent record Id per one aggregate object
            Map<Id, AggregateResult> parentValueMap = new Map <Id, AggregateResult>();
             
            for(AggregateResult ar : Database.query(aggregateQuery)) {
                parentValueMap.put((Id)ar.get(childParentLookupField), ar);
            }
 
            //list of parent object records to update
            list<sObject> parentsToUpdate = new list<sObject>();

             
            String parentQuery = 'Select ' + parentFields + ' Id ' + ' From ' + parentObject + ' Where Id IN :parentIds';
            TimeTrackerUtility.addLogMessage(LoggingLevel.DEBUG, 'parentQuery: ' + parentQuery,
                Datetime.now(), null, null, null, UserInfo.getUserId());

            //for each affected parent object, retrieve aggregate results and 
            //for each field definition add aggregate value to parent field
            for(sObject so : Database.query(parentQuery)) {

                Integer row = 0; //row counter reset for every parent record
                for(FieldDefinition def : fieldDefinitions) {
                    String field = 'expr' + row.format();
                    AggregateResult ar = parentValueMap.get(so.Id);
                    //ar will be null if no records exist 
                    //(e.g. last record deleted)
                    if(ar != null) { 
                        Decimal value = ((Decimal)ar.get(field) == null ) ? 0 : (Decimal)ar.get(field);
                        so.put(def.parentField, value);
                    } else {
                        so.put(def.parentField, 0);
                    }
                    row += 1; //plus 1 for every field definition after first
                }
                parentsToUpdate.add(so);
            }
             
            //if parent records exist, perform update of all parent records 
            //with a single DML statement
            if(!parentsToUpdate.isEmpty()) {
                update parentsToUpdate;
            }    
        }
        TimeTrackerUtility.addLogMessage(LoggingLevel.INFO, 'End of TimeTrackerRollupUtil.rollUpTrigger() method.',
            Datetime.now(), null, null, null, UserInfo.getUserId());
    }
}