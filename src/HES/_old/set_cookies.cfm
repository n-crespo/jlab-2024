<cfheader name = "cache-control" value = "no-cache, no-store, must-revalidate">
<cfheader name = "pragma" value="no-cache">
<cfheader name = "expires" value = "#getHttpTimeString(now())#">

<cfquery name = "getWCAs" datasource = "#application.dsrc#">
    SELECT ACRONYM_ID ||' / '|| ACRONYM_DESC as LOCATION_INFO, ACRONYM_ID
    FROM #application.schema#.TRAV_ACRONYMS
    WHERE ACRONYM_LEVEL = 'WCA'
    AND OBS IS NULL
    AND CLOSED IS NULL
    AND RETIRED IS NULL
    ORDER BY ACRONYM_ID
</cfquery>

<cfquery name = "getActions" datasource = "#application.dsrc#">
    SELECT ACRONYM_ID ||' / '|| ACRONYM_DESC as ACTION_INFO, ACRONYM_ID
    FROM #application.schema#.TRAV_ACRONYMS
    WHERE ACRONYM_LEVEL = 'ACTION'
    AND OBS IS NULL
    AND CLOSED IS NULL
    AND RETIRED IS NULL
    ORDER BY ACRONYM_ID
</cfquery>

<cfquery name = "getLocIds" datasource = "#application.FacilityDSN#">
    SELECT LOCATIONID
    FROM INV_LOCATIONS
</cfquery>

<cfform format = "html" action = "">
    WCA Acronym:
    <cfselect name = "getWCA" query = "getWCAs" display="LOCATION_INFO" multiple = "no" value = "ACRONYM_ID">
        <option value = 'NULL'>NULL</option>
    </cfselect>
    <br>Action:
    <cfselect name = "getAction" query = "getActions" display = "ACTION_INFO" multiple = "no" value = "ACRONYM_ID">
        <option value = 'NULL'>NULL</option>
    </cfselect> 
    <br>Location ID:   
    <cfselect name = "getLocId" query = "getLocIds" display = "LOCATIONID" multiple = "no" value = "LOCATIONID">
        <option value = 'NULL'>NULL</option>
    </cfselect>
    <br><input type = "Submit" value = "Submit">
</cfform>
<cfif isDefined("getWCA") && isDefined("getAction") && isDefined("getLocId")>
    <cfcookie name = "wca" value = "#getWCA#" expires = "never">
    <cfcookie name = "action" value = "#getAction#" expires = "never">
    <cfcookie name = "loc_id" value = "#getLocId#" expires = "never">
</cfif>