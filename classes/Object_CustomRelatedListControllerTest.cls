@isTest
public class Object_CustomRelatedListControllerTest {
	@TestSetup
    static void setup(){
        //Create parent object
        ObjectA__c objA = new ObjectA__c();
        insert objA;
        
        //Create two child of object A
        List<ObjectB__c> listObjB = new List<ObjectB__c>{new ObjectB__c(ObjectA__c=objA.id), new ObjectB__c(ObjectA__c=objA.id)};
		insert listObjB;
        
        //Create one child ObjC 
        ObjectC__c objC = new ObjectC__c(ObjectB__c=listObjB[0].id);
        insert objC;
    }
    
    @isTest 
    static void testPageSize() {
        System.assertEquals(5, Object_CustomRelatedListController.getPageSize());
        
        Integer newPageSize = 10;
        CustomRelatedListSettings__c customRelListSet = new CustomRelatedListSettings__c(Number_of_Rows__c=newPageSize);
        insert customRelListSet;
        
        System.assertEquals(10, Object_CustomRelatedListController.getPageSize());
    }
    
    @isTest
    static void testNextScenario() {
        //Create a Custom setting with pageSize equals = 2
        Integer pageSize = 2;
        CustomRelatedListSettings__c customRelListSet = new CustomRelatedListSettings__c(Number_of_Rows__c = pageSize);
        //getRecords(String recordObjAId, Integer pageSize,  String firstRecordName, String lastRecordName, String action)
        
        //Get parent object ID
        ObjectA__c objA = [SELECT ID FROM ObjectA__c LIMIT 1];
        
        //Total of records (child + grandchild)
        Integer numOfObjB = [SELECT COUNT() FROM ObjectB__c WHERE ObjectA__r.id = : objA.id];
        Integer numOfObjC = [SELECT COUNT() FROM ObjectC__c WHERE ObjectB__r.ObjectA__r.id = : objA.id];
        Integer totalOfRecords = numOfObjB + numOfObjC;
               
        
        Object_CustomRelatedListController.DataWrapper resp1 = (Object_CustomRelatedListController.DataWrapper)JSON.deserialize( Object_CustomRelatedListController.getRecords(String.valueOf(objA.id), pageSize, '', '', 'next'), Object_CustomRelatedListController.DataWrapper.class);
        System.assertEquals(totalOfRecords, resp1.dataSize);
        System.assertEquals(pageSize, resp1.listOfRecords.size());
        System.debug('RGPB : ' + resp1.listOfRecords);
        ObjectB__c firstChild = (ObjectB__c)resp1.listOfRecords[0];
        ObjectB__c lastChild = (ObjectB__c)resp1.listOfRecords[resp1.listOfRecords.size()-1];
        
        Object_CustomRelatedListController.DataWrapper resp2 = (Object_CustomRelatedListController.DataWrapper)JSON.deserialize( Object_CustomRelatedListController.getRecords(String.valueOf(objA.id), pageSize, firstChild.Name, lastChild.Name , 'next'), Object_CustomRelatedListController.DataWrapper.class);
        System.assertEquals(totalOfRecords, resp2.dataSize);
        System.assertEquals(totalOfRecords-pageSize, resp2.listOfRecords.size());
        
        //Decidir se devo ainda validar o cenário de existiram apenas C's
    }
    
    @isTest
    static void testPreviousScenario() {
        //Create a Custom setting with pageSize equals = 2
        Integer pageSize = 2;
        CustomRelatedListSettings__c customRelListSet = new CustomRelatedListSettings__c(Number_of_Rows__c = pageSize);
        
        //Get parent object ID
        ObjectA__c objA = [SELECT ID FROM ObjectA__c LIMIT 1];
        
        //Get the list of the first two ObjectB records
        List<ObjectB__c> listOfObjectB = [SELECT id, Name FROM ObjectB__c WHERE ObjectA__c = :objA.id LIMIT :pageSize];
        
        //Get the only record C created in the Setup (which is the lastRecord in the custom related list)
        ObjectC__c objC = [SELECT ID, Name FROM ObjectC__c ORDER BY Name Desc LIMIT 1];
        
        Object_CustomRelatedListController.DataWrapper resp1 = (Object_CustomRelatedListController.DataWrapper)JSON.deserialize( Object_CustomRelatedListController.getRecords(String.valueOf(objA.id), pageSize, '', objC.Name, 'previous'), Object_CustomRelatedListController.DataWrapper.class);
        ObjectB__c firstChild = (ObjectB__c)resp1.listOfRecords[0];
        ObjectB__c lastChild = (ObjectB__c)resp1.listOfRecords[resp1.listOfRecords.size()-1];
        System.assertEquals(pageSize, resp1.listOfRecords.size());
        System.assertEquals(listOfObjectB[0].Name, firstChild.Name);
        System.assertEquals(listOfObjectB[1].Name, lastChild.Name);      
    }
    
}