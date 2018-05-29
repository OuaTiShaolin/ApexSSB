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

        for(Integer i=1;i<=300;i++) {
            Case testCase = new Case();
            testCase.Subject = 'Maintenance';
            testCase.Type = 'Other';
            testCase.Status = 'New';
            testCase.Equipment__c = newProduct.Id;
            caseList.add(testCase);
        }
        insert caseList;
        System.assertEquals(300, [SELECT count() FROM Case WHERE Type = 'Other']);
    }
    
    // CLOSE CASES AND SEE IF NEW CASES HAVE BEEN CREATED OF TYPE REPAIR
    @isTest
    static void testMaintenanceRequest(){

        Test.startTest();
        List<Case> caseList = [Select Id, Type, Status from Case LIMIT 300];
        for(Case a : caseList){
            a.Type = 'Repair';
            a.Status = 'Closed';
        }
        update caseList;
        System.assertEquals(300, [SELECT count() FROM Case WHERE Type = 'Repair']);
        System.assertEquals(300, [SELECT count() FROM Case WHERE Type = 'Routine Maintenance']);
        Test.stopTest();
    }
}