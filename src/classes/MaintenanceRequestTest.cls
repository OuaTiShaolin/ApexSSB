@isTest
public class MaintenanceRequestTest {

    @testsetup
    static void setupTestData (){
        List<Case> caseList = new List<Case>();
        Product2 newProduct = new Product2();
        newProduct.Cost__c = 5;
        newProduct.Maintenance_Cycle__c = 365;
        newProduct.Lifespan_Months__c = 12;
        newProduct.Name = 'Window sweeper';
        newProduct.Replacement_Part__c = true;
        newProduct.Warehouse_SKU__c = '100009';
        newProduct.Current_Inventory__c = 20;
        insert newProduct;
        System.assertEquals(1, [SELECT count() FROM Product2 WHERE Name = 'Window sweeper']);

        for(Integer i=1;i<=250;i++) {
            Case testCase = new Case();
            testCase.Subject = 'Maintenance';
            testCase.Status = 'New';
            testCase.Type = 'Other';
            testCase.Equipment__c = newProduct.Id;
            caseList.add(testCase);
        }
        insert caseList;
        Work_Part__c work_part = new Work_Part__c();
        work_part.Equipment__c = newProduct.Id;
        work_part.Maintenance_Request__c = caseList[0].Id;
        insert work_part;

        System.assertEquals(250, [SELECT count() FROM Case WHERE Type = 'Other']);
    }
    
    // CLOSE CASES AND SEE IF NEW CASES HAVE BEEN CREATED OF TYPE REPAIR
    @isTest
    static void testMaintenanceRequest(){

        Test.startTest();
        List<Case> caseList = [Select Id, Type, Status from Case LIMIT 250];
        for(Case a : caseList){
            a.Type = 'Repair';
            a.Status = 'Closed';
        }
        update caseList;
        System.assertEquals(250, [SELECT count() FROM Case WHERE Type = 'Repair']);
        System.assertEquals(250, [SELECT count() FROM Case WHERE Type = 'Routine Maintenance']);
        Test.stopTest();
    }
}