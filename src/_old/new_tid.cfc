<cfcomponent>
    <cffunction name = "get_new_tid" returnType = "string">
        <cfquery name = "maxtid" datasource = "#application.FacilityDSN#">
            SELECT MAX(TRANSACTIONID) AS MTID
            FROM #application.schema#.INV_TRANSACTIONS
        </cfquery>
        <cfreturn int(#maxtid.MTID#)+1>
    </cffunction>
</cfcomponent>
