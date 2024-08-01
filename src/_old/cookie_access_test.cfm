<cfif isDefined("cookie.wca") && isDefined("cookie.action")>
    Location Cookie:
    <cfoutput>#cookie.wca#</cfoutput>
    <br> Action Cookie:
    <cfoutput>#cookie.action#</cfoutput>
</cfif>

