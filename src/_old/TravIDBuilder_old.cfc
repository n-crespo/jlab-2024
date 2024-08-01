<cfcomponent>

<!--- returns important query --->
<cffunction name="getTravData" returnType = "query">
    <cfargument name="tid" type="string" required="true">
    <cfquery name = "travData" datasource = "#application.FacilityDSN#">
        Select  min(t2.transactionid) Trans_Id, t2.cpnid projid, cpname, t2.partid, vartype, t2.serialnumber
        from    #application.schema#.inv_Transactions t1,
                #application.schema#.inv_Transactions t2,
                #application.schema#.inv_projectnames pn,
                #application.schema#.inv_parts p
        where   t1.transactionid = <cfqueryparam value=#arguments.tid# cfsqltype="cf_sql_integer">
        and     pn.CPNID = t2.CPNID
        and     p.PARTID = t2.PARTID
        and     t2.partid = t1.partid
        and     t2.serialnumber = t1.serialnumber
        group by t2.cpnid, cpname, t2.partid, vartype, t2.serialnumber
    </cfquery>
    <cfreturn travData>
</cffunction>

<!--- builds traveler ID from transaction ID + cookies --->
<cffunction name = "getTravID" returnType = "string">
    <cfargument name = "tid" type = "string" required = "true">
    <!--- <cfargument name = "workcenter" type = "string" required = "true"> --->
    <!--- <cfargument name = "action" type = "string" required = "true"> --->
    <cfargument name = "comp" type = "boolean" required = "false" default = false>

    <cfinvoke component="TravIDBuilder" method="getTravData" 
              returnvariable="travData" tid="#arguments.tid#"></cfinvoke>
    <!---mike's query--->
    <cfquery name="mike_query" datasource="#application.dsrc#">
    SELECT  DISTINCT max_travs.trav_id travid, max_travs.maxrev rev, vartype acronym
    FROM    adappstst.trav_vars tv,
        (SELECT  TRAV_ID, max(trav_revision) maxrev
            FROM    adappstst.trav_vars
            WHERE   TRAV_ID LIKE '#travData.CPNAME#-#cookie.wca#%'
            OR   TRAV_ID LIKE '#travData.CPNAME#%#cookie.action#%'
            GROUP BY trav_id) max_travs
    WHERE   max_travs.trav_id = tv.trav_id
    AND     max_travs.maxrev = tv.trav_revision
    AND     vartype like '%SN'
    ORDER by travid, acronym
</cfquery>
<cfdump var = "#mike_query#">
 
    <cfset "trav_id" = "">

    <cfif "#travData.CPNAME#" != ''>
        <cfset "trav_id" = "#trav_id#" & "#travData.CPNAME#">
        Project Name: <cfdump var = "#travData.CPNAME#"><br>
        <cfelse>
            Project Name Not Found.<br>
    </cfif>
    <cfif cookie.wca != "NULL">
        <cfset "trav_id" = "#trav_id#" & "-" & "#cookie.wca#">
        WCA: <cfdump var = "#cookie.wca#"> <br>
        <cfelse>
            WCA Not Found. <br>
    </cfif>
    <cfif #arguments.comp#>
        <cfset "trav_id" = "#trav_id#" & "-" & "COMP">
        <cfelse>
        <cfif "#travData.VARTYPE#" != "">
            <cfset "trav_id" = "#trav_id#" & "-" & mid(#travData.VARTYPE#,1,len(#travData.VARTYPE#)-2)>
            Part Name: <cfdump var = "#travData.VARTYPE#"> <br>
        <cfelse>
            Part Name Not Found. <br>
        </cfif>
    </cfif>
    <cfif cookie.action != "NULL">
        <cfset "trav_id" = "#trav_id#" & "-" & cookie.action>
        Action: <cfdump var = "#cookie.action#"> <br>
        <cfelse>
            Action Not Found.<br>
    </cfif>

    <cfreturn trav_id>
</cffunction>

<cffunction name = "getRevisionNumber" returnType = "string">
    <cfargument name = "trav_id" type = "string" required = "true">
    <cfquery name="getRevision" datasource="#application.dsrc#" >
        SELECT MAX(TRAV_REVISION) AS MAX_REVISION
        FROM #application.schema#.TRAV_CONFIG
        WHERE TRAV_ID = <cfqueryparam value="#trim(arguments.trav_id)#" cfsqltype="cf_sql_varchar">
    </cfquery>
    <cfreturn getRevision.MAX_REVISION>
</cffunction>

<cffunction name="getNextTID" returnType="string">
    <cfquery name = "maxTID" datasource = "#application.FacilityDSN#">
        SELECT MAX(TRANSACTIONID) AS MTID
        FROM #application.schema#.INV_TRANSACTIONS
    </cfquery>
    <cfreturn int(#maxTID.MTID#)+1>
</cffunction>

<!--- returns true if logs should be updated --->
<cffunction name = "shouldUpdateLogs" returnType = "boolean">
    <cfargument name = "tid" type = "string" required="true">

    <!--- this grabs the information fron the current transaction log records --->
    <cfquery name="existingLogInfo" datasource="#application.FacilityDSN#">
        SELECT PARTID, SERIALNUMBER
        FROM #application.schema#.INV_TRANSACTIONS
        WHERE TRANSACTIONID = <cfqueryparam value='#arguments.tid#' cfsqltype="cf_sql_integer">
    </cfquery>

    <!--- this checks the inventory for matching records --->
    <cfquery name="checkInventory" datasource="#application.FacilityDSN#">
        SELECT i.INVENTORYID, i.PARTID, i.SERIALNUMBER, i.LOCATIONID
        FROM #application.schema#.INV_INVENTORY i 
        WHERE i.PARTID = <cfqueryparam value="#existingLogInfo.PARTID#" cfsqltype="cf_sql_integer">
        AND i.SERIALNUMBER = <cfqueryparam value="#existingLogInfo.SERIALNUMBER#" cfsqltype="cf_sql_varchar">
    </cfquery>

    <cfif checkInventory.RecordCount() EQ 1>
        <cfif checkInventory.LOCATIONID == #cookie.loc_id#>
            <h2>Part is already in that location. Transaction log has not been updated.</h2>
            <cfreturn false>
        <cfelse> <!--- Part exists and is in a different location, so update --->
            <cfreturn true>
        </cfif>
    <cfelseif checkInventory.RecordCount() GT 1> 
        <!--- this should never happen --->
        <h2>An error occured. Part is duplicated in the inventory.</h2>
        <cfreturn false>
    <cfelseif checkInventory.RecordCount() == 0>
        <!--- this means the part is has already been issed and is no longer in inv_inventory --->
        <h2>
            This part is not in the inventory.  Transaction log has not been updated.
        </h2>
        It may have already been issued. <br>
            <cfreturn false>
    </cfif>
</cffunction>

<cffunction name = "updateTransactionLog">
    <cfargument name = "tid" type = "string" required = "true">
    <cfinvoke component = "TravIDBuilder" method = "getNextTID" returnVariable = "next_tid">

    <cfquery name = "updateTransactionLog" datasource = "#application.FacilityDSN#">
        INSERT INTO #application.schema#.INV_TRANSACTIONS
        SELECT 
            <cfqueryparam value="#next_tid#" cfsqltype="cf_sql_integer">,
            SYSDATE, TRANSTYPESID, <cfqueryparam value='#session.username#' cfsqltype="cf_sql_varchar">,
            TRANSQTY, POID, CPNID, ISSUEDTO, ISSUEDFOR, ASSEMBLY, USERCOMMENT1, USERCOMMENT2, USERCOMMENT3,
            PARTID, SERIALNUMBER, <cfqueryparam value="#cookie.loc_id#" cfsqltype="cf_sql_integer">,
            STATUSCODEID, SPOOL_LENGTH, INVENTORYID, GROUPID, PARTREV
        FROM #application.schema#.INV_TRANSACTIONS
        WHERE TRANSACTIONID = <cfqueryparam value='#arguments.tid#' cfsqltype="cf_sql_varchar">
    </cfquery>

    <cfquery name = "getNewTransactionLog" datasource = "#application.FacilityDSN#">
        SELECT *
        FROM #application.schema#.INV_TRANSACTIONS t
        WHERE t.TRANSACTIONID = <cfqueryparam value="#next_tid#" cfsqltype="cf_sql_integer">
    </cfquery>

    <h2> The transaction log has been updated! The following was inserted: </h2>
    <cfdump var="#getNewTransactionLog#">
</cffunction>

<cffunction name = "updateInventory">
    <cfargument name = "tid" type = "string" required = "true">

    <br>location id cookie: <cfdump var="#cookie.loc_id#"><br>
    <cfquery name="updateInventory" datasource="#application.FacilityDSN#">
        UPDATE #application.schema#.INV_INVENTORY inv
        SET inv.LOCATIONID = <cfqueryparam value="#cookie.loc_id#" cfsqltype="cf_sql_integer">
        WHERE inv.INVENTORYID = (
            SELECT i.INVENTORYID
            FROM #application.schema#.INV_INVENTORY i
            INNER JOIN #application.schema#.INV_TRANSACTIONS t
            ON i.SERIALNUMBER = t.SERIALNUMBER
            AND i.PARTID = t.PARTID
            AND i.CPNID = t.CPNID
            WHERE t.TRANSACTIONID = <cfqueryparam value="#tid#" cfsqltype="cf_sql_integer">
        )
    </cfquery>

    <cfquery name="getUpdatedInventory" datasource="#application.FacilityDSN#">
        SELECT inv.INVENTORYID, inv.LOCATIONID, inv.PARTID, inv.SERIALNUMBER
        FROM #application.schema#.INV_INVENTORY inv
        WHERE inv.INVENTORYID = (
            SELECT i.INVENTORYID
            FROM #application.schema#.INV_INVENTORY i
            INNER JOIN #application.schema#.INV_TRANSACTIONS t
            ON i.SERIALNUMBER = t.SERIALNUMBER
            AND i.CPNID = t.CPNID
            AND i.PARTID = t.PARTID
            WHERE t.TRANSACTIONID = <cfqueryparam value="#tid#" cfsqltype="cf_sql_integer">
        )
    </cfquery>

    <h2>The part's location has been updated in the inventory! The record was updated to this:</h2>
    <cfdump var="#getUpdatedInventory#">
</cffunction>

</cfcomponent>