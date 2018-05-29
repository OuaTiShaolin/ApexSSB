global class WarehouseSyncSchedule implements Schedulable
{
    global void execute ( SchedulableContext sc )
    {
        WarehouseCalloutService.runWarehouseEquipmentSync();  
    }
}