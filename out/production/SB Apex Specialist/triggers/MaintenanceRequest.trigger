trigger MaintenanceRequest on Case (before update, after update)
{
    // Create routine cases after closing cases.
    Map<Id, Case> updatedCasesByIds = new Map<Id, Case> ( );
    if ( Trigger.isUpdate )
    {
        if ( Trigger.isAfter )
        {
            system.debug( 'MaintenanceRequest() = ' + Trigger.new.size( ) );
            for ( Case oldCase : Trigger.new )
            {
                if ( oldCase.IsClosed && ( oldCase.Type.equals( 'Repair' ) || oldCase.Type.equals( 'Routine Maintenance' ) ) )
                {
                    updatedCasesByIds.put( oldCase.Id, oldCase );
                }
            }
            system.debug( 'updatedCasesByIds.size()' + updatedCasesByIds.size( ) );
            MaintenanceRequestHelper.updateWorkOrders( updatedCasesByIds );
        }
    }
}