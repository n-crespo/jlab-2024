# Data Handling

## Dump the Query

```html
// with a script
<cfscript>
  myquery = QueryExecute('SELECT * FROM artists', [], {datasource =
  'cfartgallery'});
</cfscript>

// with tags
<cfquery name="myQuery" datasource="cfartgallery">
  SELECT * FROM artists
</cfquery>

// dump it
<cfdump var="#myQuery#"></cfdump>
```

- The second parameter (an empty array in this case) can replace a "?" inside the query (see below)

```html
<cfset myquery1 = QueryExecute("select * from art where ARTID < ?", [4] ,qoptions)>
```

- It can also be a struct/key value pairs

```html
<cfset myquery2 = QueryExecute("select * from art where ARTID < :artid and artistid=:aid ", {artid={value=100}, aid=2} ,qoptions)>
```

- The third parameter contains query options
  - `datasource`
  - `cachename`
  - `dbtype`
  - `disableAutoGenKeys`
- ex: (used above)

```html
<cfset
  qoptions="{"
  result="myresult"
  ,
  datasource="artGallery"
  ,
  fetchclientinfo="yes"
  }
></cfset>
```

## Output the Query

- directly output the array

```html
<cfoutput query="myQuery">
  #myquery.CurrentRow# - #myquery.email# - #myquery.firstname# -
  #myquery.lastname#<br />
</cfoutput>
```

## Get Data from the Query

- append query results to an array

```html
<cfset artistArray = []>
<cfloop query="myQuery">
    <cfset arrayappend(artistArray, myquery.lastname & ', ' & myQuery.firstname)>
</cfloop>
```

## Group Query Output

- first we have to sort it

```html
<cfset myquery = QueryExecute(' SELECT * FROM art ORDER BY issold', [], {datasource = 'cfartgallery'})>
```

- `group` describes the row we want

```html
<cfoutput Query="myQuery" group="issold">
    <p>
        Sold ?: #YesNoFormat(myQuery.issold)#:<br>
        <blockquote>
            <cfoutput>
                #myQuery.artname#: #DollarFormat(myQuery.price)#<br>
            </cfoutput>
        </blockquote>
    </p>
    <hr>
</cfoutput>
```

## Avoiding SQL Injection

- with a script
- query parameters like value and datasource replace the `?` in the script
- this kinda sucks

```html
<cfscript>
  myquery = QueryExecute ("select * from Artists where firstname=?",
  ["#form.name#"], {datasource="cfartgallery"});;
</cfscript>
```

- with tags (this seems correct)
  - note the `cfqueryparam` that inserts something into the query with the
    `value` parameter while also specifying the type with the `cfsqltype`
    parameter

```html
<cfquery name="myQuery" datasource="cfartgallery">
    SELECT * FROM artists
    WHERE firstname = <cfqueryparam value="#form.name#" cfsqltype="cf_sql_varchar">
    DROP
</cfquery>
```

- the `IN` clause
  - specifies a query parameter as a list/struct with certain attributes
  - essentially the same as an `=` in the tag example above but is more explicit

```html
// with a script (semicolon + parentheses needed)
<cfscript>
    myquery = QueryExecute ("SELECT * FROM artists WHERE artistid IN (:ids)",
    {ids={value='#form.ids#',list=true}}, {datasource="cfartgallery"});
</cfscript>

// with tags (`IN` keyword + parentheses needed)
<cfquery name="myQuery" datasource="cfartgallery">
    SELECT * FROM artists
    WHERE artistid IN (<cfqueryparam value="#form.ids#" list="true">)
</cfquery>
```

## Query Caching

- query results are stored for reuse
- below example caches results for 1 hour
- doesn't really work for dynamic queries

```html
// script
<cfscript>
  myquery = QueryExecute(' SELECT * FROM artists', [], {datasource =
  'cfartgallery', cachedwithin='#createTimespan(0,1,0,0)#'});
</cfscript>

// tags
<cfquery
  name="myQuery"
  datasource="cfartgallery"
  cachedwithin="#createTimespan(0,1,0,0)#"
>
  SELECT * FROM artists
</cfquery>
```

## Dynamic Queries

- queries that change at runtime
- below code simply adds more to query if firstname or lastname are present

```html
// tags
<cfquery name="myQuery" datasource="cfartgallery">
    SELECT firstname, lastname, email FROM artists
    WHERE 1 = 1
     <cfif structkeyExists(form, 'firstname') and len(form.firstname)>
        AND firstname = <cfqueryparam value="#form.firstname#" cfsqltype="cf_sql_varchar">
    </cfif>
    <cfif structkeyExists(form, 'lastname') and len(form.lastname)>
        AND lastname = <cfqueryparam value="#form.lastname#" cfsqltype="cf_sql_varchar">
    </cfif>
</cfquery>
```

## Limited Query Results

- specify the maxrows to display (in output command)

```html
<cfoutput query="myQuery" maxrows="100">
  #myquery.CurrentRow# - #myquery.email# - #myquery.firstname# -
  #myquery.lastname#<br />
</cfoutput>
```

- specify rows to return directly (in query command) (more efficient)

```html
<cfquery name="myQuery" datasource="cfartgallery" maxrows="100">
  SELECT firstname, lastname, email FROM artists
</cfquery>
```

## Insertion and Identity Retrieval

- when the ID of an inserted row is needed:
- note the `result=` parameter that contains a dumpable structure of data that
  includes the ID of the inserted row

```html
// with tags
<cfquery result="qryResult" datasource="cfartgallery">
    INSERT INTO art
    (
        artistsID, artName, description, isSold, largeImage, mediaID, price
    )
    VALUES
    (
        <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="1">,
        <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="Test Item">,
        <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="Test Desc">,
        <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="1">,
        <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="img.png">,
        <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="1">,
        <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="1">
    )
</cfquery>

// with a script
<cfscript>
    QueryExecute(
        'INSERT INTO art ( artistsID, artName, description, isSold, largeImage, mediaID, price ) VALUES ( ?,?,?,?,?,?,? )',
        [ 1, 'test item', 'test desc', 1, 'img.png', 1, 1 ],
        { datasource = 'cfartgallery', result="qryResult" }
    );
</cfscript>
<cfdump var="#qryResult#">
```

## XML

- [see here](https://learncfinaweek.com/course/index/section/Data_Handling/item/XML.html)

## JSON

- [see here](https://learncfinaweek.com/course/index/section/Data_Handling/item/JSON.html)

## Update a Record

```java
transaction {
    artist = entityLoad( "artist", 100, true );
    artist.firstname = "Fred";
}
```

## Delete a Record

```java
transaction {
    artist = entityLoad( "artist", 100, true );
    entityDelete( artist );
}
```
