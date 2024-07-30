<cfcomponent>
    <cffunction name = "return_inventory_log" returnType = "query">
        <cfargument name = "cpname" type = "string" required = "true">
        <cfargument name = "partname" type = "string" required = "true">
        <cfargument name = "inv_transid" type = "string" required = "true">
        <cfquery name = "update_inventory" datasource="#application.FacilityDSN#">
            UPDATE #application.schema#.INV_INVENTORY inv
            SET inv.LOCATIONID = #cookie.loc_id#
            WHERE inv.INVENTORYID = (
                SELECT  i.INVENTORYID 
                FROM    #application.schema#.INV_INVENTORY i, 
                        #application.schema#.INV_TRANSACTIONS t 
                WHERE   t.TRANSACTIONID = #inv_transid#
                AND     i.PARTID = t.PARTID 
                AND     i.CPNID = t.CPNID 
                AND     i.serialnumber = t.SERIALNUMBER)
    </cfquery>
    <cfquery name = "check_results" datasource = "#application.FacilityDSN#">
        SELECT *
        FROM #application.schema#.INV_INVENTORY i,
            #application.schema#.INV_TRANSACTIONS t
        WHERE t.TRANSACTIONID = #inv_transid#
        AND i.PARTID = t.PARTID
        AND i.CPNID = t.CPNID
        AND i.SERIALNUMBER = t.SERIALNUMBER
    </cfquery>
    <cfreturn check_results>
    </cffunction>

</cfcomponent>
