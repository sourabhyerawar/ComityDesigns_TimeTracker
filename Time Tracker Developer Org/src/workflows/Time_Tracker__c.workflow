<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Action_Field_Update</fullName>
        <field>Action__c</field>
        <formula>&quot;Case Comment Review&quot;</formula>
        <name>Action Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Opening_Action_Field_Update</fullName>
        <field>Opening_Action__c</field>
        <literalValue>Case Comment Review</literalValue>
        <name>Opening Action Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Duration</fullName>
        <field>Time_Spent__c</field>
        <formula>&quot;00:00:00&quot;</formula>
        <name>Update Duration</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Idea Comment Review</fullName>
        <actions>
            <name>Action_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Opening_Action_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>Action__c  = &apos;Idea Comment Review&apos; &amp;&amp;  NOT(ISBLANK(Case__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Stop Tracking activities related to case after case close</fullName>
        <actions>
            <name>Update_Duration</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT(ISBLANK(Case__c)) &amp;&amp;  TEXT(Case__r.Status) =&apos;Closed&apos; &amp;&amp;  $Setup.TimeTrackerUserSettings__c.StopTrackingAfterCloseCase__c =true &amp;&amp;  Case__r.ClosedDate &lt; Opening_Activity_Date__c</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
