# Code Reuse

## Script Functions

> [!NOTE] > `cfparam` exists btw (below)

<!-- prettier-ignore-start -->
```html
<cfparam name="firstName" default="Matt"> // default value + name
<cfparam name="lastName" default="Gifford">
```
<!-- prettier-ignore-end -->

- we can create a function to automatically concatenate the full name
- note: `var` is needed to properly scope the variable `fullName`

<!-- prettier-ignore-start -->

```html
<cfscript>
  public string function getFullName(
    required string firstName = '', // hmm this also has a default value it seems
    required string lastName = '' // note these are `required`
  ){
    var fullName = arguments.firstName & ' ' & arguments.lastName;
    return fullName
  }
</cfscript>
```

- to use the function: (positional or keyword arguments, both work)

```html
<cfset fullName = getFullName( firstName='Matt', lastName='Gifford' )>
<cfset fullName = getFullName( 'Matt', 'Gifford' )>
```

<!-- prettier-ignore-end -->

> [!NOTE]
> When using a function inside of a function, we can use the argument
> `argumentCollection = arguments` inside of the inner function to pass all
> arguments from one function to another.

## WHAT DOES THIS MEAN?

In order to call a function, it needs to be put somewhere. There are a number of
ways to accomplish this. The simplest way is to put it in a .cfm page and call
it.

```html
<cfscript>
  fullName = getFullName( firstName='Matt', lastName='Gifford' ); writeOutput(
  fullName );
</cfscript>
```

Putting the function into the very same .cfm page being used to display our
greeting is not very conducive to code reuse.

## Tag Functions

- this would be in a `.cfm` file (ColdFusion Markup file)

```html
<cffunction name="getFullName" output="false" access="public" returnType="string">
    <cfset var fullName = firstName & " " & lastName>
    <cfreturn fullName>
</cffunction>
```

## Custom Tags

- they live in their own directory and are prefixed with `cf_`
- access attriubutes with `attrubutes.{parameter name}`

> [!NOTE]
> The below would be defined inside of `greeting.cfm`

```html
<cfif thisTag.executionMode EQ "start">
  <!--- Code to execute when the tag is being opened --->
  <cfset fullName = attributes.firstName & " " & attributes.lastName>
  <cfoutput>
    Hello, #fullName#
  </cfoutput>
<cfelse>
  <!--- Code to execute when the tag is being closed --->
</cfif>

<!-- use: -->
<cf_greeting firstName="Matt" lastName="Gifford">
```

- import the custom tag (below)
- the `prefix` argument contains the prefix used to reference the tag (replaces
  standard `cf_`)

<!-- prettier-ignore-start -->
```html
<cfimport prefix="display" taglib="/path/to/tags">
<display:greeting firstName="Matt" lastName="Gifford">
```

<!-- prettier-ignore-end -->

## Includes

- you can use `.cfm` files as function libraries, then include them on any page
  that wants to use those functions

<!-- prettier-ignore-start -->
```html
<cfinclude template="path/to/libraries/greetingCustomizer.cfm">
```
<!-- prettier-ignore-end -->

- optional parameter: `runOnce` (default: `false`, if set to `true`, the
  template will not be processed again for a given request if it has already been
  processed)

- in script form:

<!-- prettier-ignore-start -->

```html
<cfscript>
  include "path/to/libraries/greetingCustomizer.cfm";
  fullName = getFullName( firstName="Matt", lastName="Gifford" );
  writeOutput( fullName );
</cfscript>
```
<!-- prettier-ignore-end -->

- note: using `include` can get messy

## Components

### Defining Components

- modern version of `cfinclude`
- kind of like objects in other programming languages
- `{object name}.cfc` (ColdFusion Component File)
- the below component definition would be inside of `Greeting.cfc`

> [!NOTE]
> The attribute `accessors="true"` automagically creates getters and setters for
> every property of the component. They are accessed with `setPropertyName` and
> `getPropertyName`.

> [!IMPORTANT]
> Function-local variables can be accessed with `variables.{variableName}`.

```java
component accessors="true" {
  property name="firstName" type="string";
  property name="lastName" type="string";

  public Person function init(
    required string firstName,
    required string lastName
  ){
    setFirstName(arguments.firstName);
    setLastName(arguments.lastName);
    return this;
  }

  public string function getFullName(){
    return this.getFirstName() & ' ' & this.getLastName();
  }
}
```

- now we can re-create the Greeting component with a `Person` object as a
  property (and access that object with `getPerson()`)

```java
component accessors="true" {
  property name="person" type="Person";
  property name="baseGreeting" type="string" default="Hello, ";

  public Greeting function init(
    required Person person,
    string baseGreeting = variables.baseGreeting
  ){
    setPerson(arguments.person);
    setBaseGreeting(arguments.baseGreeting);
    return this;
  }

  public string function getFullName(){
    return getPerson().getFullName();
  }

  public string function getGreeting(string baseGreeting = getBaseGreeting()){
    var fullName = this.getFullName(argumentCollection=arguments);
    var greeting = arguments.baseGreeting & fullName;
    return greeting;
  }
}
```

### Using Components

<!-- prettier-ignore-start -->

```html
<cfscript>
  objPerson = new Person(firstName = 'Matt', lastName = 'Gifford');

  objGreeting = new Greeting(person = objPerson );

  writeOutput( objGreeting.getGreeting());
</cfscript>
```

<!-- prettier-ignore-end -->

- note: a `getMemento()` method can be created to store all data in an object
  and put it in a struct.

## Retrieving Components

```html
<cfset artists = entityLoad(
  "artist",
  { firstname: "Jeff" },
  "lastname" )>
```

- returns an array of objects where the artists first name is "Jeff"
- we can now output this array as such:
  - note: if the `invokeImplicitAccessor ` option is true in `Application.cfc`,
    we can use dot notation to access the properties

```html
<cfoutput>
  <h4>#artist.firstName# #artist.lastname# #artist.id#</h4>
  <cfloop array="#artists#" index="artist">
    <cfif artist.hasArt()>
      <ul>
        <cfloop array="#artist.getArt()#" index="art">
          <li>#art.name# #dollarFormat( art.price )#</li>
        </cfloop>
      </ul>
    </cfif>
  </cfloop>
</cfoutput>
```

### With HQL

- returns an array of objects where the artists first name starts with "A"

```java
<cfset artists = ormExecuteQuery(
  "FROM artist
   WHERE firstname like :firstname
   ORDER BY lastname",
  { firstname: "A%"})>
```
