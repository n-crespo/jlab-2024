## Start Server

```
box server start cfengine=adobe@2018`
```

## Close Server

```
box server stop --all
```

## `ormReload()`

After any changes to entity configuration (adding/removing a property, etc.), it
is necessary to call `ormReload()` for it to take affect. During development, it's
common to place this in the `onRequestStart` function of `Application.cfc`.

## Null Values

If `entityLoad()` cannot return an entity, it returns `null`. Check this with
`isNull(object)`

## Dumping Objects

```java
writedump( var=artists, top=2, showudfs=false );
```
