/* H8 Editable Related List 
*
* VersionL 1.0
*
* Authors:     phil@hyphen8.com
*              david.bradburn@hyphen8.com
*
* Updates:     06/03/2020 - Initial version
*
*/

public class h8_ERL_Controller {

     @AuraEnabled(cacheable=true)
     public static Map<String, Map<String, List<SObject>>> getsObjectInfo(String metadataName, String theId){

          Map<String, Map<String, List<SObject>>> mapReturnData =  new Map<String, Map<String, List<SObject>>>();
          String sobjectAPIName;

          String getId = theId;
          String soqlStatement = 'SELECT id,';
     
          id parentId = theId;

          system.debug('metadataname is  ' + metadataname);
          system.debug('theId is  ' + theId);

          String parentObject = parentId.getsobjecttype().getDescribe().getName();

          String result = '';
          
          Map<String, List<sobject>> mapAllData = new Map<String, List<sobject>>();
          JSONGenerator jsonGen = JSON.createGenerator(true);
          jsonGen.writeStartArray();

          for(H8_ERL_Data__mdt H8_ERL_Data : [SELECT Id, SObjectField__r.QualifiedAPIName, SObjectField__r.DataType, SObjectField__r.MasterLabel, SObject__c, SObject__r.QualifiedAPIName, Editable__c, order__c
                                                  FROM H8_ERL_Data__mdt 
                                                  WHERE SObject__r.MasterLabel = :metadataName                                   
                                                  AND  Visible__c = true
                                                  AND  Parent_SObject__c = null
                                                  ORDER BY order__c ASC]){
               String fieldType;
               sobjectAPIName = String.valueof(H8_ERL_Data.SObject__r.QualifiedAPIName);                                      

               soqlStatement += H8_ERL_Data.SObjectField__r.QualifiedAPIName + ',';
               fieldType = 'text';
          
               system.debug('H8_ERL_Data.SObjectField__r.DataType ' + H8_ERL_Data.SObjectField__r.DataType);

               if(H8_ERL_Data.SObjectField__r.DataType.contains('Text') || H8_ERL_Data.SObjectField__r.DataType.contains('Name')) {
                    fieldType = 'text';
               }

               if(H8_ERL_Data.SObjectField__r.DataType.containsIgnoreCase('Email')){
                    fieldType = 'email';
               }

               if(H8_ERL_Data.SObjectField__r.DataType.containsIgnoreCase('Url')){
                    fieldType = 'url';
               }

               if(H8_ERL_Data.SObjectField__r.DataType.containsIgnoreCase('Number')){
                    fieldType = 'number';
               }
               
               if(H8_ERL_Data.SObjectField__r.DataType.containsIgnoreCase('Currency')){
                    fieldType = 'currency';
               }

               if(H8_ERL_Data.SObjectField__r.DataType.containsIgnoreCase('Date')){
                    fieldType = 'date';
               }

               if(H8_ERL_Data.SObjectField__r.DataType.containsIgnoreCase('phone')){
                    fieldType = 'phone';
               }

               if(H8_ERL_Data.SObjectField__r.DataType.containsIgnoreCase('checkbox')){
                    fieldType = 'boolean';
               }

               if(H8_ERL_Data.SObjectField__r.DataType.containsIgnoreCase('percent')){
                    fieldType = 'percent';
               }
           
                 
               jsonGen.writeStartObject();
         
               jsonGen.writeStringField('label', H8_ERL_Data.SObjectField__r.MasterLabel);
          
               jsonGen.writeStringField('type',  fieldType);
          
               jsonGen.writeStringField('fieldName', H8_ERL_Data.SObjectField__r.QualifiedAPIName);
        
               if(H8_ERL_Data.Editable__c){
                    jsonGen.writeStringField('editable', 'true' );
               }
          
               jsonGen.writeEndObject();
          }

          jsonGen.writeEndArray();

          soqlStatement = soqlStatement.removeEnd(',');

          system.debug('soqlStatement is ' + soqlStatement);

          H8_ERL_Data__mdt H8_ERL_Datawhereclause = [SELECT SObjectField__r.QualifiedAPIName, SObject__r.QualifiedAPIName
                                                            FROM H8_ERL_Data__mdt
                                                            WHERE SObject__r.MasterLabel =  :metadataName
                                                            AND Parent_SObject__r.QualifiedAPIName = :parentObject];

          soqlStatement += ' FROM ' + H8_ERL_Datawhereclause.SObject__r.QualifiedAPIName + ' WHERE ' + H8_ERL_Datawhereclause.SObjectField__r.QualifiedAPIName + ' = :getId';
        
                   
          List<sObject> sobjList = Database.query(soqlStatement);

     
          String dataColumns = jsonGen.getAsString();

          sobjectAPIName += ';' +  H8_ERL_Datawhereclause.SObjectField__r.QualifiedAPIName;

          mapAllData.put(dataColumns, sobjList);

          // New Map defined key = Contact, value is the map of the columns and data
          mapReturnData.put(sobjectAPIName, mapAllData);

          system.debug('mapAllData is ' + mapAllData);

          return mapReturnData;

     }  
}