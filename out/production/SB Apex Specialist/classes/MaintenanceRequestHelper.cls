public class MaintenanceRequestHelper
{
    //documentatie

    public static void updateWorkOrders ( )
    {
    }

    // CREATE A NEW CASE
    private static case createNewCase ( case originalMRequestCase, Integer daysOfCycle, String subject )
    {
        Date today = Date.today( );
        Date dueDate = Date.today( ).addDays( daysOfCycle );
        Case newMaintainanceRequest = new Case ( );
        newMaintainanceRequest.Vehicle__c = originalMRequestCase.Vehicle__c;
        newMaintainanceRequest.Equipment__c = originalMRequestCase.Equipment__c;
        newMaintainanceRequest.Type = 'Routine Maintenance';
        newMaintainanceRequest.Subject = subject;
        newMaintainanceRequest.Date_Reported__c = today;
        newMaintainanceRequest.Date_Due__c = dueDate;
        newMaintainanceRequest.Status = 'New';
        newMaintainanceRequest.Product__c = originalMRequestCase.Product__c;
        newMaintainanceRequest.AccountId = originalMRequestCase.AccountId;
        newMaintainanceRequest.ContactId = originalMRequestCase.ContactId;
        newMaintainanceRequest.AssetId = originalMRequestCase.AssetId;
        newMaintainanceRequest.Origin = originalMRequestCase.Origin;
        newMaintainanceRequest.Reason = originalMRequestCase.Reason;
        return newMaintainanceRequest;
    }

    // MAP THE AMOUNT OF DAYS FROM A CYCLE OF A WORK PARK
    Private static Map<Id, Integer> mapCycleDaysByWorkPart(Set<Id> caseIds){
        Map<Id, Integer> maintainceCycleByWorkPartIds = new Map<Id, Integer> ( );
        List<Work_Part__c> workParts =
        [
                SELECT
                        Equipment__c,
                        Id,
                        LastModifiedDate,
                        Maintenance_Request__c,
                        Name,
                        Quantity__c
                FROM Work_Part__c
                WHERE Maintenance_Request__c IN :caseIds
        ];
        if ( workParts.size( ) > 0 )
        {
            for ( Work_Part__c workPart : workParts )
            {
                maintainceCycleByWorkPartIds.put( workPart.Id, Integer.valueOf( workPart.Equipment__r.Maintenance_Cycle__c ) );
            }
        }
        List<Product2> equipments =
        [
                SELECT
                        Cost__c,
                        Current_Inventory__c,
                        Description,
                        Family,
                        Id,
                        Lifespan_Months__c,
                        Maintenance_Cycle__c,
                        Name,
                        ProductCode,
                        Replacement_Part__c,
                        Warehouse_SKU__c
                FROM Product2
        ];
        for ( Product2 requestProduct2 : equipments )
        {
            if ( requestProduct2 != null )
            {
                if ( requestProduct2.Maintenance_Cycle__c != null )
                {
                    maintainceCycleByWorkPartIds.put( requestProduct2.Id, Integer.valueOf( requestProduct2.Maintenance_Cycle__c ) );
                }
            }
        }
        return maintainceCycleByWorkPartIds;
    }

    // CREATE ROUTINE CASES OUT OF CASES
    public static void updateWorkOrders ( Map<Id, Case> updatedCasesByIds )
    {
        system.debug( 'MaintenanceRequestHelper.updateWorkOrders() = ' + updatedCasesByIds.size() );
        Set<Id> updatedCaseIds = updatedCasesByIds.keySet( );
        Map<Id, Integer> maintainceCycleByWorkPartIds = mapCycleDaysByWorkPart(updatedCaseIds);
        system.debug( 'maintainceCycleByWorkPartIds = ' + maintainceCycleByWorkPartIds );

        List<Case> newCases = new List<Case> ( );
        for ( Case originalMRequestCase : updatedCasesByIds.values( ) )
        {
            // DETERMINE CASE VALUES
            String subject = String.isBlank( originalMRequestCase.Subject ) ? 'Routine Maintenance Request' : originalMRequestCase.Subject;
            Integer daysOfCycle = ( maintainceCycleByWorkPartIds.get( originalMRequestCase.Id ) != null ) ? ( Integer.valueOf( maintainceCycleByWorkPartIds.get
                    ( originalMRequestCase.Id ) ) ) : ( 0 );
            // ACTUAL CREATION OF NEW CASE
            case newMaintainanceRequest = createNewCase( originalMRequestCase, daysOfCycle, subject );
            newCases.add( newMaintainanceRequest );
        }
        if ( newCases.size( ) > 0 )
        {
            insert newCases;
            system.debug( 'INSERT newCases.size() = ' + newCases.size( ) );
        }
    }
}