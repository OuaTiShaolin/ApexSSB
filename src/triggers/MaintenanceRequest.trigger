/**
 * Create routine maintenance request cases after closing cases of certain types.
 */
trigger MaintenanceRequest on Case (before update, after update)
{
    Map<Id, Case> updatedCasesByIds = new Map<Id, Case> ( );
    if ( Trigger.isUpdate && Trigger.isAfter )
    {
        system.debug( 'MaintenanceRequest() = ' + Trigger.new.size( ) );
        for ( Case oldCase : Trigger.new )
        {
            if ( oldCase.IsClosed && ( oldCase.Type.equals( 'Repair' ) || oldCase.Type.equals( 'Routine Maintenance' ) ) )
            {
                updatedCasesByIds.put( oldCase.Id, oldCase );
            }
        }
        MaintenanceRequestHelper.updateWorkOrders( updatedCasesByIds );
        system.debug( 'updatedCasesByIds.size()' + updatedCasesByIds.size( ) );
    }
}