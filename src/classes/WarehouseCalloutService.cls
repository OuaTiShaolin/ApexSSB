/**
 * SYNC WAREHOUSE STOCK
 * @upserts List<Product2> equipments
 */
public with sharing class WarehouseCalloutService
{
    Private static Http http = new Http ( );
    Private static HttpRequest request = new HttpRequest ( );
    public static String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment'; // normally a custom setting

    Private static void makeWarehouseRequest(){
        request.setEndpoint( WAREHOUSE_URL );
        request.setMethod( 'GET' );
    }

    @future ( callout=true )
    public static void runWarehouseEquipmentSync ( )
    {
        makeWarehouseRequest();
        HttpResponse response = http.send( request );
        if ( response.getStatusCode( ) == 200 )
        {
            List<Object> equipmentsJSONObjects = ( List<Object> ) JSON.deserializeUntyped( response.getBody( ) );
            List<Product2> equipments = new List<Product2> ( );
            for ( Object obj : equipmentsJSONObjects )
            {
                Map<String, Object> objectByFieldName = ( Map<String, Object> ) obj;
                system.debug( 'objectByFieldName = ' + objectByFieldName );
                Product2 equipment = createEquipment( objectByFieldName );
                equipments.add( equipment );
            }
            if ( equipments.size( ) > 0 )
            {
                System.debug( 'UPSERT equipments.size() = ' + equipments.size( ) );
                upsert equipments;
            }
        }
    }

    // CREATE A PRODUCT2
    private static Product2 createEquipment ( Map<String, Object> objectByFieldName )
    {
        Product2 equipment = new Product2 ( );
        equipment.Name = ( String ) objectByFieldName.get( 'name' );
        equipment.Cost__c = ( Integer ) objectByFieldName.get( 'cost' );
        equipment.Current_Inventory__c = ( Integer ) objectByFieldName.get( 'quantity' );
        equipment.Maintenance_Cycle__c = ( Integer ) objectByFieldName.get( 'maintenanceperiod' );
        equipment.Replacement_Part__c = ( Boolean ) objectByFieldName.get( 'replacement' );
        equipment.Lifespan_Months__c = ( Integer ) objectByFieldName.get( 'lifespan' );
        // External ID : equipment.Warehouse_SKU__c
        equipment.Warehouse_SKU__c = ( String ) objectByFieldName.get( 'sku' );
        equipment.ProductCode = ( String ) objectByFieldName.get( '_id' );
        return equipment;
    }
}