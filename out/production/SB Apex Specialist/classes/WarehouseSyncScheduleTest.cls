@isTest
public class WarehouseSyncScheduleTest {
    
    @isTest
    static void test() {
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());   		
        String CRON =  '0 0 0 2 8 ? 2020';

        Test.startTest();
        String jobId = System.schedule('testScheduledApex', CRON, new WarehouseSyncSchedule());
        Test.stopTest();

        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                          NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(1 ,[SELECT count() FROM AsyncApexJob]);
        System.assertEquals(CRON,ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
    }
}