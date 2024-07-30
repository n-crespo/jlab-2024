<cfcomponent accessors="true">
  <cffunction name="setCookies" access="remote" returnType="void">
    <cfargument name="action" type="string" required="true">
    <cfargument name="wca" type="string" required="true">
    <cfargument name="loc_id" type="string" required="true">

    <cfcookie name="action" value="#arguments.action#" expires="never">
    <cfcookie name="wca" value="#arguments.wca#" expires="never">
    <cfcookie name="loc_id" value="#arguments.loc_id#" expires="never">
  </cffunction>

  <cffunction name="showCookies" access="remote" returnType="void">
    <center><h1>Cookies have been set!</h1></center>
  </cffunction>
</cfcomponent>
