<!--- this is needed because the page reloads on form submit --->
<cfif not isDefined("form.travsearch")>
    <!--- transaction id input --->
    <div id="tid_input">
        <cfform format="html" method="post" preservedata="no" align="left">
            Enter Transaction ID: <cfinput name="tid" type="text" maxlength="9" autofocus>
        </cfform>
    </div>
    <!--- dont show this form if search/select is showing --->
    <script>
        var theDiv = document.getElementById("tid_input");
        theDiv.style.display = '';
    </script>
<cfelse>
    <!--- this means search/select form has been submitted --->
    <cfset trav_id=form.travsearch>
    <!--- get revision number and redirect! --->
    <cfinvoke component="#application.area#.Components.Travelers.TravIDBuilder" method="getRevisionNumber" returnVariable="revisionNum" trav_id="#trav_id#">
    <cfinvoke component="#application.area#.Components.Travelers.TravIDBuilder" method="redirectToTraveler" trav_id="#trav_id#" revisionNum="#revisionNum#">
</cfif>


<!--- ensure cookies are set, tid has been submitted --->
<cfif isDefined("tid") && #tid# neq "" && isNumeric("#tid#") && isDefined("cookie.wca") && isDefined("cookie.action") && isDefined("cookie.loc_id")>
    <!--- check if logs should be updated, update if needed--->
    <cfinvoke component="#application.area#.Components.Travelers.TravIDBuilder" method="shouldUpdateLogs" returnvariable="shouldUpdateLogs" tid="#tid#">
    <cfif shouldUpdateLogs>
        <cfinvoke component="#application.area#.Components.Travelers.TravIDBuilder" method="updateInventory" returnVariable="inv_query" tid="#tid#">
        <cfinvoke component="#application.area#.Components.Travelers.TravIDBuilder" method="updateTransactionLog" tid="#tid#">
    </cfif>

    <!-- build traveler ID-->
    <cfinvoke component="#application.area#.Components.Travelers.TravIDBuilder" method="getTravID" returnVariable="trav_id"
              tid="#tid#" workcenter="#cookie.wca#" action="#cookie.action#">

    <!--- try  to get revision number --->
    <cfinvoke component="#application.area#.Components.Travelers.TravIDBuilder" method="getRevisionNumber" returnVariable="revisionNum" trav_id="#trav_id#">

    <!--- this means there could be many possible TIDs --->
    <cfif "#revisionNum#" eq "">
        <cfinvoke component="#application.area#.Components.Travelers.TravIDBuilder" method="getPossibleTIDs" tid="#tid#" returnvariable="possibleTIDs">

        <cfif #possibleTIDs.recordCount()# GT 0>
            <!--- the following function is reponsible for the real time filtering of the trav id table/form --->
            <script type="text/javascript">
                function filterOptions() {
                    var input, filter, select, options, i;
                    input = document.getElementById('typein');
                    filter = input.value.toUpperCase();
                    select = document.getElementById('TravSearch');
                    options = select.getElementsByTagName('option');
                    for (i = 0; i < options.length; i++) {
                        if (options[i].text.toUpperCase().indexOf(filter) > -1) {
                            options[i].style.display = "";
                        } else {
                            options[i].style.display = "none";
                        }
                    }
                }
            </script>

            <!--- hide the TID entry box --->
            <script>
                var theDiv = document.getElementById("tid_input");
                theDiv.style.display = 'none';
            </script>

            <!--- populate form dropdown with relevant results --->
            <cfform name="travForm" method="post">
                <table align="left">
                    <tr>
                        <td align="left">
                            <cfoutput>Search For:</cfoutput>
                            <input name="typein" id="typein" type="text" autofocus onkeyup="filterOptions(); this.value=this.value.toUpperCase();" />
                            (i.e. Workstation, Component, or Task) <br>
                            <select name="TravSearch" id="TravSearch" size="10" style="width: 550px;" onchange="this.form.submit();">
                                <cfoutput query="possibleTIDs">
                                    <option value="#possibleTIDs.travid#">#possibleTIDs.displayText#</option>
                                </cfoutput>
                            </select>
                        </td>
                    </tr>
                </table>
            </cfform> <br>
        <cfelse>
            <!--- no possible TIDs were found... --->
            <h2> <font size="3" color="red"> Invalid Transaction ID: <cfdump var=#tid#> </h2>
        </cfif>
    <cfelse>
        <!--- this means there is one possible TID --->
        <!--- get revision number and redirect --->
        <cfset "form.travsearch"=#trav_id# & "-" & #revisionNum#>
        <cfinvoke component="#application.area#.Components.Travelers.TravIDBuilder" method="redirectToTraveler" trav_id="#trav_id#" revisionNum="#revisionNum#">
    </cfif>

<cfelseif isDefined("tid") AND #tid# neq "" AND isNumeric("#tid#") AND not (isDefined("cookie.action") OR isDefined("cookie.wca") OR isDefined("cookie.loc_id"))>
    <!--- form submitted but cookies not defined --->
    <h2> <font size="3" color="red"> Ensure cookies are set! <cfdump var=#tid#> </h2>
</cfif>

<!--- footer --->
<h3 style="position: relative; bottom: 0; clear: both; width: 100%; text-align: left; padding: 0px; font-size: 12px; color: black;">
This page is in beta. Contact Valerie Bookwalter or Mike Dickey with any questions or comments.
</h3>
