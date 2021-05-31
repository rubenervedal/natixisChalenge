public class Object_CustomRelatedListController {
    /*
     * Method used to retrieve the number of elements to display in one page
    */ 
    @AuraEnabled
    public static Integer getPageSize(){
    	CustomRelatedListSettings__c customRelListSet = CustomRelatedListSettings__c.getOrgDefaults();
        if (customRelListSet!=null && customRelListSet.Number_of_Rows__c!=null) {
            return Integer.valueOf(customRelListSet.Number_of_Rows__c);
        } else {
            return 5; //Default value in case of none configured value in CustomRelatedListSettings__c
        }
    }
	/*
	 * Get Child and grandchild records (childs have priority than grandchild)
	 * @param recordObjAId id of recordA (where the Lightning Component is being shown)
	 * @pageSize number of rows displayed in page
	 * @lastRecordName name of lastRecord show in previous search
	*/
    @AuraEnabled
    public static String getRecords(String recordObjAId, Integer pageSize,  String firstRecordName, String lastRecordName, String action){
        DataWrapper response = new dataWrapper();
        List<ObjectB__c> listObjectB = new List<ObjectB__c>();
        List<ObjectC__c> listObjectC = new List<ObjectC__c>();
        
        //Queries to retrieve the number of records that are connected to Object A record
        Integer numOfObjB = [SELECT COUNT() FROM ObjectB__c WHERE ObjectA__r.id = : recordObjAId];
        Integer numOfObjC = [SELECT COUNT() FROM ObjectC__c WHERE ObjectB__r.ObjectA__r.id = : recordObjAId];
        response.dataSize = numOfObjB + numOfObjC;
        
        if (action=='next' || String.isBlank(action)) {
            //Determine the type of object in the end of the list
        	String objectToSearch = lastRecordName?.SubStringBefore('-');
            
            //Caso de ir para a proxima pagina e ultimo record ter sido do objecto B
            if(String.isBlank(objectToSearch) || objectToSearch=='B') { 
                listObjectB = [SELECT Id, Name FROM ObjectB__c WHERE ObjectA__r.id = : recordObjAId AND Name>:lastRecordName ORDER BY Name LIMIT :pageSize];
                //If size of previous query is lower than the number of records that we are showing in one page and if we have some records of Object C connected to A, those values should be retrieve
                if(listObjectB.size() < pageSize && numOfObjC!=0) {
                    listObjectC = [SELECT Id, Name FROM ObjectC__c WHERE ObjectB__r.ObjectA__r.id = : recordObjAId ORDER BY Name LIMIT :(pageSize-listObjectB.size()) ];
                }
            } else {
                listObjectC = [SELECT Id, Name FROM ObjectC__c WHERE ObjectB__r.ObjectA__r.id = : recordObjAId AND Name>:lastRecordName ORDER BY Name LIMIT :pageSize]; 
            }
            response.listOfRecords.addall(listObjectB);
        	response.listOfRecords.addall(listObjectC);
        } else {
            //Determine the type of object in the top of the list
        	String objectToSearch = firstRecordName?.SubStringBefore('-');
            
            //If the object in the top of the list is type B, it is only needed to retrieve records of object B
            if(objectToSearch=='B') { 
                listObjectB = [SELECT Id, Name FROM ObjectB__c WHERE ObjectA__r.id = : recordObjAId AND Name<:firstRecordName ORDER BY Name DESC LIMIT :pageSize];
            } else {
                listObjectC = [SELECT Id, Name FROM ObjectC__c WHERE ObjectB__r.ObjectA__r.id = : recordObjAId AND Name<:firstRecordName ORDER BY Name DESC LIMIT :pageSize];
                 //If size of previous query is lower than the number of records that we are showing in one page and if we have some records of Object B connected to A, those values should be retrieve
                if(listObjectC.size() < pageSize && numOfObjC!=0) {
                    listObjectB = [SELECT Id, Name FROM ObjectB__c WHERE ObjectA__r.id = : recordObjAId ORDER BY Name DESC LIMIT :(pageSize-listObjectC.size())  ];
                }
            }
            addAllInReversed(listObjectB, response.listOfRecords);
            addAllInReversed(listObjectC, response.listOfRecords);
        }
        
        
        System.debug('response:'+ response);
        return JSON.serialize(response, true);
    }
    
	/*
	* Add elements in a reverse way
 	* @param lisToAdd contains all elements to add in destinationList
	* @param destinationList list where the elements will be added in a reverse way
 	*/    
    private static void addAllInReversed(List<sObject> listToAdd, List<sObject> destinationList) {
        for(Integer i = listToAdd.size() - 1; i >= 0; i--){
   			destinationList.add(listToAdd[i]);
		}
    }
    
    /*
     * Class used to transfer data from Apex Controller to Aura component
    */
    public class DataWrapper {
        public Integer dataSize;
       	public List<sObject> listOfRecords = new List<sObject>(); 
    }
}