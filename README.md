```
██████╗  ██████╗  ██████╗██████╗  ██████╗ ██╗  ██╗
██╔══██╗██╔═══██╗██╔════╝██╔══██╗██╔═══██╗╚██╗██╔╝
██║  ██║██║   ██║██║     ██████╔╝██║   ██║ ╚███╔╝ 
██║  ██║██║   ██║██║     ██╔══██╗██║   ██║ ██╔██╗ 
██████╔╝╚██████╔╝╚██████╗██████╔╝╚██████╔╝██╔╝ ██╗
╚═════╝  ╚═════╝  ╚═════╝╚═════╝  ╚═════╝ ╚═╝  ╚═╝
```

# Welcome to DocBox v2.0.0!

DocBox is a fork of the ColdDoc project originally created by Mark Mandel.  Documentation for DocBox can be found on the [GitHub Wiki][1] and in this Readme. The main Git repository and downloads can be found on [GitHub][2].

## LICENSE
Apache License, Version 2.0.

## SYSTEM REQUIREMENTS
- Lucee 4.5+
- ColdFusion 10+

## Instructions
You can use DocBox as a standalone application or install it as a CommandBox command via CommandBox: `box install docbox`.  

### Standalone Application
If you want to use DocBox for document generation in your CFML application, then just drop it into any location and create a `/docbox` mapping to it.  You will then instantiate the `DocBox` generator class with a `strategy` and `properties` for the strategy.

```js
// signature
docbox = new DocBox( strategy="class.path", properties={} );

// create with default strategy
docbox = new DocBox( properties = { 
    projectTitle="My Docs", 
    outputDir="#expandPath( '/docs' )#"
});
```

#### Generating Docs
To generate the documentation you will then execute the `generate()` method on the DocBox object and pass in the following parameters:

#### Generate Params

* `source` : A path to the source location or an array of structs of locations that must have a `dir` and `mapping` key on it.
* `mapping` : The base mapping for the folder source. Used only if `source` is a path
* `excludes` : A regular expression that will be evaluated against all CFCs sent for documentation.  If the regex matches the CFC name and path then the CFC will be excluded from documentation.


```js
docbox.generate( source="/my/path", mapping="coldbox" );

docbox.generate(
    source  = "#expandPath( '/docbox' )",
    mapping = "coldbox",
    excludes = "tests"
);
```

Once the generation finalizes, you will see your beautiful docs!

#### Available Strategies & Properties
* `docbox.strategy.api.HTMLAPIStrategy` - **default**
  * `projectTitle` : The HTML title
  * `outputDir` : The output directory
* `docbox.strategy.uml2tools.XMIStrategy`
  * `outputFile` : The output file

### CommandBox Command
If installed as a command you will get a new namespace called **docbox** with a **Generate** command.  Type `docbox generate help` to see its usage, which is very similar to the instructions above.


----


# CREDITS & CONTRIBUTIONS

Thanks to Mark Mandel for allowing us to fork his project.

I THANK GOD FOR HIS WISDOM FOR THIS PROJECT

## THE DAILY BREAD

"I am the way, and the truth, and the life; no one comes to the Father, but by me (JESUS)" Jn 14:1-12

[1]: https://github.com/Ortus-Solutions/DocBox/wiki
[2]: https://github.com/Ortus-Solutions/DocBox
