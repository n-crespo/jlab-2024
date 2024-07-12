# Day 1

## Manipulating Variables

### `cfset`

- `cfset`

```cf
<cfset ThisIs = "fun">
```

### `cfdump`

- show value
  - `<cfdump var = "#ThisIs#">`
- do no evaluations (string)
  - `<cfdump var = "1 + 2"><br>`
- do the evaluation (pound signs)
  - `<cfdump var = "#1 + 2#"><br>`
- combination of both
  - `<cfdump var = "1 + 2 IS #1 + 2#"><br>`
- evaluated + set (no quotes)
  - `<cfset DateToday = now()>`
- concatenate strings (&)
  - `<cfset DateToday = "Today is: " & now()>`

### `cfoutput`

- can only show simple values, not complex things not displayable as text
- note: no quotes but still pound signs
  - `<cfset DateToday = "Today is: #now()#">`
  - `<cfoutput>#DateToday#</cfoutput>`

## Datatypes

### `cfsavecontent`

- `cfsavecontent`

```cf
<cfsavecontent variable="EmailContent">
  Hi. We want to send you a hoverboard. Let us know if you will accept this free
  offer. -Us
</cfsavecontent>

<cfoutput>#EmailContent#</cfoutput>
```

### Dates

[date and time functions](https://helpx.adobe.com/coldfusion/cfml-reference/coldfusion-functions/functions-by-category/date-and-time-functions.html)

- today
  - `<cfset DateToday = now()>`
- days since x
  - `<cfset DaysSinceTurnOfCentury = DateDiff("d", "1/1/2000", now() )>`
- date in 42 days
  - `<cfset FortyTwoDaysFromNow = DateAdd("d", now(), 42 )>`

### Arrays

[array functions](https://helpx.adobe.com/coldfusion/cfml-reference/coldfusion-functions/functions-by-category/array-functions.html)

- one dim array
  - `<cfset ThingsILike = ["Warm Sandy Beaches", "Tropical Drinks", 42]>`
  - `<cfdump var = "#ThingsILike#">`
- create sized array
  - `<cfset ThingsILike = arrayNew(1)>`
- changing items (FIRST INDEX IS 1, not 0) (1-based arrays)
  - `<cfset ThingsILike[1]  = "Warm Sandy Beaches">`
- appending to array
  - `<cfset ArrayAppend( ThingsILike,  "Tropical Drinks")>`

> [!NOTE]
> Every element is an execution zone also, meaning if it isn't in quotes it will
> be evaluated.

- display the array
  - `cfoutput` will not work (array is not easily displayable)
  - you can loop though with `cfloop`
  - `cfloop` takes in:
    - `array` - the array
    - `index` - the name of each item (can be referenced inside)

> [!NOTE]
> Every parameter is a string

```cf
<cfset ThingsILike = ["Warm Sandy Beaches", "Tropical Drinks", 42]>
<cfloop array="#ThingsILike#" index="thing">
    <cfoutput>#thing#</cfoutput>
</cfloop>
```

### Structs

[struct functions](https://helpx.adobe.com/coldfusion/cfml-reference/coldfusion-functions/functions-by-category/structure-functions.html)

- creation (function: `structNew`)
  - `<cfset FruitBasket = structNew()>`
- creation (empty: curly braces)
  - `<cfset FruitBasket = {}>`

```cf
<cfset fruitBasket = {
    "Apple" = "Like",
    "Banana" = "Like",
    "Cherry" = "Dislike"
}>
```

- access items with square brackets (just like arrays)
- key value pairs, key names are strings (in quotes)
- key can also be accessed with dot notation `<cfset FruitBasket.Cherry = "Dislike">`

> [!NOTE]
> Dot notation **_DOES NOT_** preserve case of keys. "One Statement Creation"
> notation will preserve key case if in quotes. If not quoted, will convert all
> to upper case.

- bracket notation also allows for _dynamic key reference_

- display struct contents with `cfloop` and `collection` parameter

```cf
<cfloop collection="#FruitBasket#" item="fruit">
  <cfoutput>I #FruitBasket[fruit]# #fruit#</cfoutput><br />
</cfloop>
```

### `cfquery`

[query functions](https://helpx.adobe.com/coldfusion/cfml-reference/coldfusion-functions/functions-by-category/query-functions.html)
[working with databases](https://helpx.adobe.com/coldfusion/developing-applications/accessing-and-using-data.html)

- called a query
- contain series of columns with rows
- basically a spreadsheet

```cf
<cfquery name="FruitQuery" datasource="fruit">
  SELECT Name, Price
  FROM FruitStore
  WHERE Price < 7
</cfquery>

```

- output with `cfloop` parameter `query`

```

<cfloop query="FruitQuery">
  #FruitQuery.Name# costs #FruitQuery.Price# <br>
</cfloop>
```

- Special Properties:
- `queryname.recordcount`: number of rows
- `queryname.columnlist`: number of columns
- `queryname.currentrow`: What row number are we currently on inside a `cfoutput` or `cfloop`?

## Commenting

- pretty much same as html unless inside of a `cfscript` (I believe this is
  JavaScript)

```code
<!-- I am an HTML Comment-->
<!---  I am a ColdFusion Comment--->

<cfscript>
    // I am a ColdFusion Comment in CFScript for a single line
    /*
        I am a multi-line
        ColdFusion Comment in CFScript
    */
</cfscript>
```

## Scripts vs Tags

[ColdFusion script reference](http://help.adobe.com/en_US/ColdFusion/10.0/Developing/WSc3ff6d0ea77859461172e0811cbec22c24-7feb.html)

### Setting Variables

```code
<cfset variable = "value">

```

- these are the same

```code
<cfscript>
    variable = "value";
</cfscript>
```

### Arrays

```code
<cfset FruitArray = ["apple", "banana", "cherry"]>
```

```code
<cfloop from="1" to="#arrayLen( FruitArray)#" index="i">
    <cfoutput>#FruitArray[i]#</cfoutput>
</cfloop>

```

- these are the same

```code
<cfscript>
    FruitArray = ["apple", "banana", "cherry"];
    for( i=1; i <= arrayLen(FruitArray); i++){
        writeOutput(FruitArray[i]);
    }
</cfscript>
```

## Conditionals

### `cfif`, `cfelse` and `cfelseif`

```code
<cfif expression>
    ..Markup..
<cfelseif another_expression>
    ..More Markup..
<cfelse>
    ..More Markup..
</cfif>
```

- boolean values are all lowercase
- negative values and 0 evaluate to false

```cf
len( myStringVar ); // returns a number
isNull( mySimpleVar ); // returns a Boolean
arrayLen( myArray ); // returns a number
```

- operators:

  - `IS`, `EQUAL`, `EQ`
  - `IS NOT`, `NOT EQUAL`, `NEQ`
  - `GT`, `GREATER THAN`, `LT`, `LESS THAN`, `GTE`, `LTE`
  - `CONTAINS`
  - `DOES NOT CONTAIN`

- script example:

```cf
<cfscript>
    if ( myValue == 'ColdFusion' ) {
        ..code..
    } else if ( myValue != '.NET' ) {
        x = 277;
    } else {
        ..code..
    }
</cfscript>
```

- boolean operators
  - `AND / &&`
  - `OR / ||`
  - `NOT / !`
  - `XOR, EQV`
  - `IMP - implication`
  -

### Switch Case

```cf
<cfswitch expression="#myVar#">
    <cfcase value="1">
        ..code..
    </cfcase>
    <cfcase value="9,10" >
        ..code..
    </cfcase>
    <cfdefaultcase>
        ..finally..
    </cfdefaultcase>
</cfswitch>
```

### Ternary Operator

```cf
x = ( myVar == 1 ) ? 1 : 277;
```
