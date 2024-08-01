<!--- page header--->
<table id="sal2" height="20" border="0" cellpadding="0" cellspacing="0">
	<tr valign="top"><td align="center" class="style8">Set Workcenter/Action/Location ID Cookies</td></tr>
	<tr valign="top"><td><hr></td></tr>
</table>

<!--- get data for location dropdown in correct format --->
<cfquery name="getWCAs" datasource="#application.dsrc#">
  SELECT ACRONYM_ID || ' - ' || ACRONYM_DESC AS ID_DESC, ACRONYM_ID, ACRONYM_DESC
	FROM #application.schema#.TRAV_ACRONYMS
	WHERE ACRONYM_LEVEL = 'WCA'
	AND obs is null
	AND CLOSED IS NULL
	AND RETIRED IS NULL
	ORDER BY ACRONYM_ID
</cfquery>

<!--- get data for action dropdown in correct format --->
<cfquery name="getActions" datasource="#application.dsrc#">
  SELECT ACRONYM_ID || ' - ' || ACRONYM_DESC AS ID_DESC, ACRONYM_ID, ACRONYM_DESC
	FROM #application.schema#.TRAV_ACRONYMS
	WHERE ACRONYM_LEVEL = 'ACTION'
	AND obs is null
	AND CLOSED IS NULL
	AND RETIRED IS NULL
	ORDER BY ACRONYM_ID
</cfquery>

<!--- get location IDs --->
<cfquery name = "getLocIds" datasource = "#application.FacilityDSN#">
  SELECT LOCATIONID
  FROM INV_LOCATIONS
</cfquery>

<!--- dropdowns, executes form_submit.cfm once submitted --->
<cfform format="html" action="submitCookies.cfm" method="post" preservedata="yes">
  Select a workcenter:
  <cfselect name="wca" query="getWCAs" display="ID_DESC" required="Yes" value="ACRONYM_ID" message="Please select a work center."> </cfselect>
  <br>Select an action:
	<cfselect name="action" queryPosition="below" query="getActions" display="ID_DESC" required="Yes" message="Please select an action." value="ACRONYM_ID">
    <option value='NULL'>NULL</option>
	</cfselect><br>
    Select the location ID:
   <cfselect name="loc_id" query="getLocIds" required="No" value="LOCATIONID" multiple="No"></cfselect>
	<br>
	<input type="Submit" value="Submit">
</cfform>
