# Applications

## Events

- you need an `Application.cfc` file
- events
  - [see here](https://learncfinaweek.com/course/index/section/Application_cfc/item/Application_cfc.html)

## `onApplicationStart`

```javascript
component {
  function onApplicationStart(){
    application.datasource = "my_database"; return true;
  }
}
```

- sets most Application-scoped variables, they live as long as the application

## `onRequest`

```java
component {
  function onRequest( string targetPage ) { // targetPage is the requested template
    try {
      include arguments.targetPage;
    } catch (any e) {
      //handle the exception or errors
    }
  }
}
```

> [!WARNING]
> anything inside a component (between the `<cfcomponent></cfcomponent>` tags or
> the component curly braces) but not inside a function, is part of the implicit
> constructor, and as such will be executed during the instantiation of the
> component.

# The Implicit Constructor

- name: `this.name="";`
- timeout: `this.applicationTimeout = CreateTimeSpan(10, 0, 0, 0); // 10 days`
- custom tag paths: `this.customTagPaths = [ expandPath('/myAppCustomTags') ];`
- per-application mappings: `this.mappings = {"/foo" = expandPath('/com/myCompany/foo') };`
- app-global default data source (if no other one is defined for a query)
  - `this.datasource = "my_datasource";`
- session management
  - `this.sessionManagement = true;`
  - `this.sessionTimeout = CreateTimeSpan(0, 0, 30, 0); //30 minutes`
- [more settings](http://help.adobe.com/en_US/ColdFusion/10.0/CFMLRef/WSc3ff6d0ea77859461172e0811cbec22c24-750b.html)

> [!WARNING] > `Application.cfm` is a sign of old code

> [!NOTE]
> hello

# Example `Application.cfc`

```java
component {

    this.name = "myApplication";
    this.applicationTimeout = CreateTimeSpan(10, 0, 0, 0); //10 days
    this.datasource = "my_datasource";
    this.sessionManagement = true;
    this.sessionTimeout = CreateTimeSpan(0, 0, 30, 0); //30 minutes
    this.customTagPaths = [ expandPath('/myAppCustomTags') ];
    this.mappings = {
        "/foo" = expandPath('/com/myCompany/foo')
    };

    // see also: http://help.adobe.com/en_US/ColdFusion/10.0/CFMLRef/WSc3ff6d0ea77859461172e0811cbec22c24-750b.htmlhttps
    // see also: https://helpx.adobe.com/coldfusion/developing-applications/developing-cfml-applications/designing-and-optimizing-a-coldfusion-application.html

    function onApplicationStart() {
        return true;
    }

    function onSessionStart() {}

    // the target page is passed in for reference,
    // but you are not required to include it
    function onRequestStart( string targetPage ) {}

    function onRequest( string targetPage ) {
        include arguments.targetPage;
    }

    function onRequestEnd() {}

    function onSessionEnd( struct SessionScope, struct ApplicationScope ) {}

    function onApplicationEnd( struct ApplicationScope ) {}

    function onError( any Exception, string EventName ) {}

}
```
