/**
 * CREATE ROUTINE MAINTAINANCE REQUEST CASES
 * @param       Set  <Id> caseIds : Set of Ids to create MaintainanceRequests
 * @inserts     List <Case> newMRCases : A new list of cases(MaintainanceRequests) based on a list of (previously closed) cases
 */
public class MaintenanceRequestHelper
{

    // CREATE A NEW CASE
    private static case makeNewMRCase ( case originalMRequestCase, Integer daysOfCycle, String subject )
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

    // DETERMINE CASE SUBJECT
    private static string determineSubjectString ( Case originalMRequestCase )
    {
        String subject = String.isBlank( originalMRequestCase.Subject ) ? 'Routine Maintenance Request' : originalMRequestCase.Subject;
        return subject;
    }

    // DETERMINE INTEGER DAYS OF CYCLE
    private static Integer determineDaysOfCycleInteger ( Map<Id, Integer> maintainceCycleByWorkPartIds, case originalMRequestCase )
    {
        Integer daysOfCycle = ( maintainceCycleByWorkPartIds.get( originalMRequestCase.Id ) != null ) ? ( Integer.valueOf( maintainceCycleByWorkPartIds.get
                ( originalMRequestCase.Id ) ) ) : ( 0 );
        return daysOfCycle;
    }

    // INSERT CASE LIST
    private static void insertNewMRCases ( List<Case> newMRCases )
    {
        if ( newMRCases.size( ) > 0 )
        {
            insert newMRCases;
            system.debug( 'INSERT newMRCases.size() = ' + newMRCases.size( ) );
        }
    }

    // MAP THE AMOUNT OF DAYS FROM A CYCLE OF A WORK PARK
    private static Map<Id, Integer> getMapCycleDaysByWorkPart ( Set<Id> caseIds )
    {
        Map<Id, Integer> maintainceCycleByWorkPartIds = new Map<Id, Integer> ( );
        List<Work_Part__c> workParts =
        [
                SELECT
                        Equipment__c,
                        Equipment__r.Maintenance_Cycle__c,
                        Id,
                        LastModifiedDate,
                        Maintenance_Request__c,
                        Name,
                        Quantity__c
                FROM Work_Part__c
                WHERE Maintenance_Request__c IN :caseIds
        ];
        for ( Work_Part__c workPart : workParts )
        {
            maintainceCycleByWorkPartIds.put( workPart.Id, Integer.valueOf( workPart.Equipment__r.Maintenance_Cycle__c ) );
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
        system.debug( 'MaintenanceRequestHelper.updateWorkOrders() = ' + updatedCasesByIds.size( ) );
        Map<Id, Integer> maintainceCycleByWorkPartIds = getMapCycleDaysByWorkPart( updatedCasesByIds.keySet( ) );
        List<Case> newMRCases = new List<Case> ( );
        for ( Case originalMRequestCase : updatedCasesByIds.values( ) )
        {
            case newMaintainanceRequest = makeNewMRCase ( originalMRequestCase, determineDaysOfCycleInteger( maintainceCycleByWorkPartIds,
                    originalMRequestCase ), determineSubjectString( originalMRequestCase ) );
            newMRCases.add( newMaintainanceRequest );
        }
        insertNewMRCases( newMRCases );
    }
}