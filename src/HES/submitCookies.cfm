<cfif isDefined("form.action") && isDefined("form.wca") && isDefined("form.loc_id")>
  <cfset cookieSetter = createObject("component", "CookieSetter")>
  <cfset cookieSetter.setCookies(
    action = form.action, wca = form.wca, loc_id = form.loc_id
  )>
  <cfinvoke component="CookieSetter" method="showCookies">
<cfelse>
  <h2>Something went wrong...</h2>
  Please make sure you've submitted the cookie setting form. This page should not be accessed directly.
</cfif>
