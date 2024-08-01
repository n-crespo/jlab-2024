<cfcomponent>

<!--- returns important query --->
<cffunction name="getTravData" returnType="query">
    <cfargument name="tid" type="string" required="true">
    <cfquery name="travData" datasource="#application.FacilityDSN#">
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

<cffunction name="getPossibleTIDs" returnType="query">
    <cfargument name="tid" type="string" required="true">
    <cfinvoke method="getTravData" returnvariable="travData" tid="#arguments.tid#">

    <!---mike's query to match possible traveler IDs--->
    <cfquery name="possibleTIDs" datasource="#application.dsrc#">
        SELECT DISTINCT 
            max_travs.trav_id travid, 
            vartype acronym,
            max_travs.maxrev rev, 
            TRIM(max_travs.trav_id) || ' (' || TRIM(vartype) || ')' AS displayText
        FROM 
        adappstst.trav_header th,
        adappstst.trav_vars tv,
            (SELECT TRAV_ID, max(trav_revision) maxrev
                FROM adappstst.trav_vars
                WHERE TRAV_ID LIKE '#travData.CPNAME#-#cookie.wca#%'
                <cfif cookie.action eq "NULL">
                    OR
                <cfelse>
                    AND
                </cfif>
                TRAV_ID LIKE '#travData.CPNAME#%#cookie.action#%'
                GROUP BY trav_id) max_travs
        WHERE max_travs.trav_id = tv.trav_id
        AND max_travs.maxrev = tv.trav_revision
        AND vartype like '%SN'
        ORDER by travid, acronym
    </cfquery>

    <cfreturn possibleTIDs>
</cffunction>

<!--- builds traveler ID from transaction ID + cookies --->
<cffunction name= "getTravID" returnType="string">
    <cfargument name="tid" type="string" required="true">

    <cfinvoke method="getTravData" returnvariable="travData" tid="#arguments.tid#">
    <cfset "trav_id" = "">
    <cfif "#travData.CPNAME#" != ''>
        <cfset "trav_id" = "#trav_id#" & "#travData.CPNAME#">
    </cfif>
    <cfif cookie.wca != "NULL">
        <cfset "trav_id" = "#trav_id#" & "-" & "#cookie.wca#">
    </cfif>
    <cfif "#travData.VARTYPE#" != "">
        <cfset "trav_id" = "#trav_id#" & "-" & mid(#travData.VARTYPE#,1,len(#travData.VARTYPE#)-2)>
    </cfif>
    <cfif cookie.action != "NULL">
        <cfset "trav_id" = "#trav_id#" & "-" & cookie.action>
    </cfif>
    <cfreturn trav_id>
</cffunction>

<cffunction name="getRevisionNumber" returnType="string">
    <cfargument name="trav_id" type="string" required="true">
    <cfquery name="getRevision" datasource="#application.dsrc#" >
        SELECT MAX(TRAV_REVISION) AS MAX_REVISION
        FROM #application.schema#.TRAV_CONFIG
        WHERE TRAV_ID = <cfqueryparam value="#trim(arguments.trav_id)#" cfsqltype="cf_sql_varchar">
    </cfquery>
    <cfreturn getRevision.MAX_REVISION>
</cffunction>

<cffunction name="getNextTID" returnType="string">
    <cfquery name="maxTID" datasource="#application.FacilityDSN#">
        SELECT MAX(TRANSACTIONID) AS MTID
        FROM #application.schema#.INV_TRANSACTIONS
    </cfquery>
    <cfreturn int(#maxTID.MTID#)+1>
</cffunction>

<!--- returns true if logs should be updated --->
<cffunction name="shouldUpdateLogs" returnType="boolean">
    <cfargument name="tid" type="string" required="true">

    <!--- this grabs the information fron the current transaction log records --->
    <cfquery name="existingLogInfo" datasource="#application.FacilityDSN#">
        SELECT PARTID, SERIALNUMBER
        FROM #application.schema#.INV_TRANSACTIONS
        WHERE TRANSACTIONID = <cfqueryparam value='#arguments.tid#' cfsqltype="cf_sql_integer">
    </cfquery>

    <!--- if the TID is invalid, the above query will return empty values --->
    <cfif "#existingLogInfo.RecordCount()#" eq 1>
        <!--- this checks the inventory for matching records --->
        <cfquery name="checkInventory" datasource="#application.FacilityDSN#">
            SELECT i.INVENTORYID, i.PARTID, i.SERIALNUMBER, i.LOCATIONID
            FROM #application.schema#.INV_INVENTORY i 
            WHERE i.PARTID = <cfqueryparam value="#existingLogInfo.PARTID#" cfsqltype="cf_sql_integer">
            AND i.SERIALNUMBER = <cfqueryparam value="#existingLogInfo.SERIALNUMBER#" cfsqltype="cf_sql_varchar">
        </cfquery>

        <cfif checkInventory.RecordCount() EQ 1>
            <cfif checkInventory.LOCATIONID == #cookie.loc_id#>
                <!--- Part is already in that location. Transaction log has not been updated. --->
                <cfreturn false>
            <cfelse> <!--- Part exists and is in a different location, so update --->
                <cfreturn true>
            </cfif>
        <cfelseif checkInventory.RecordCount() GT 1> 
            <!--- this should never happen, means part is duplicated in the inventory --->
            <cfreturn false>
        <cfelseif checkInventory.RecordCount() == 0>
            <!--- this means the part is has already been issued and is no longer in inv_inventory --->
            <cfreturn false>
        </cfif>
    <cfelse>
        <cfreturn false>
    </cfif>
</cffunction>

<cffunction name="updateTransactionLog">
    <cfargument name="tid" type="string" required="true">
    <cfinvoke method="getNextTID" returnVariable="next_tid">

    <cfquery name="updateTransactionLog" datasource="#application.FacilityDSN#">
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

    <cfquery name="getNewTransactionLog" datasource="#application.FacilityDSN#">
        SELECT *
        FROM #application.schema#.INV_TRANSACTIONS t
        WHERE t.TRANSACTIONID = <cfqueryparam value="#next_tid#" cfsqltype="cf_sql_integer">
    </cfquery>

</cffunction>

<cffunction name="updateInventory">
    <cfargument name="tid" type="string" required="true">

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

</cffunction>

<cffunction name="redirectToTraveler">
    <cfargument name="trav_id" type="string" required="true">
    <cfargument name="revisionNum" type="string" required="true">

    <!--- this is needed for redirection --->
    <cfquery name="GetMaxPage" datasource="#application.dsrc#">
        SELECT TRAV_MAX_PAGE as MAXPAGE 
        FROM TRAV_HEADER
        WHERE TRAV_REVISION = '#revisionNum#'
        AND TRAV_ID = '#trav_id#'
    </cfquery>

    <!-- separate project name-->
    <cfset delimiterPosition = Find("-", "#trav_id#")>
    <cfset CPname = Left('#trav_id#', delimiterPosition - 1)>
    <cfset redirectURL = "/" & application.area & "/Travelers/TRAVELER_FORM.cfm?project=" & CPName & "&area=" & CPName & "&system=" & cookie.wca & "&TRAV_ID=" & trav_id & "&TRAV_REVISION=" & revisionNum & "&page=1&maxpage=" & GetMaxPage.MAXPAGE & "&TRAV_SEQ_NUM=-1&travstat=n&serialnum=">

    <!--- this is where the redirection happens --->
    <cflocation url="#redirectURL#" addtoken="no">  
</cffunction>

</cfcomponent>