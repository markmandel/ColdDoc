/**
 * Creates documentation for CFCs JavaDoc style via DocBox
 * .
 * You can pass the strategy options by prefixing them with 'strategy-'. So if a strategy takes
 * in a property of 'outputDir' you will pass it as 'strategy-outputdir='
 * Examples
 * {code:bash}
 * docbox run source=/path/to/coldbox mapping=coldbox excludes=tests strategy-outputDir=/output/path strategy-projectTitle="My Docs"
 * {code}
 **/
component extends="commandbox.system.BaseCommand" aliases="" excludeFromHelp=false{

	/**
	* Constructor
	*/
	function init(){
		super.init();

		var mappings = getApplicationSettings().mappings;
		mappings[ "/docbox" ] = getDirectoryFromPath( getMetadata( this ).path );
		application action='update' mappings='#mappings#';

		return this;
	}

	/**
	* Run DocBox to generate your docs
	* @strategy The strategy class to use to generate the docs.
	* @strategy.options docbox.strategy.api.HTMLAPIStrategy,docbox.strategy.uml2tools.XMIStrategy
	* @source Either, the string directory source, OR a JSON array of structs containing 'dir' and 'mapping' key
	* @mapping The base mapping for the folder. Only required if the source is a string
	* @excludes	A regex that will be applied to the input source to exclude from the docs
	* @properties A 
	**/
	function run( 
		string strategy="docbox.strategy.api.HTMLAPIStrategy",
		required string source,
		string mapping,
		string excludes
	){

		// Inflate source from JSON
		if( isJSON( arguments.source ) ){ arguments.source = deserializeJSON( arguments.source ); }
		// Verify mapping?
		if( isSimpleValue( arguments.source ) and ( isNull( arguments.mapping ) OR !len( arguments.mapping ) ) ){
			return error( "The mapping argument was not sent, please send it." );
		}

		// Inflate outputs
		arguments.source = fileSystemUtil.resolvePath( arguments.source );

		// Inflate strategy properties
		var properties = {};
		for( var thisArg in arguments ){
			if( !isNull( arguments[ thisArg ] ) and reFindNoCase( "^strategy\-" , thisArg ) ){
				properties[ listLast( thisArg, "-" ) ] = arguments[ thisArg ];
				//print.yellowLine( "Adding strategy property: #listLast( thisArg, "-" )#" );
			}
		}

		// Resolve Output Dir
		if( structKeyExists( properties, "outputDir" ) ){
			properties.outputDir = fileSystemUtil.resolvePath( properties.outputDir );
		}

		// init docbox with default strategy and properites
		var docbox = new DocBox( strategy=arguments.strategy, properties=properties );
		
		print.yellowLine( "Source: #arguments.source# ")
			.yellowLine( "Mapping: #arguments.mapping#" )
			.yellowLine( "Output: #properties.outputDir#")
			.redLine( "Starting Generation, please wait..." )
			.toConsole();

		// Create mapping
		var mappings = getApplicationSettings().mappings;
		mappings[ "/#arguments.mapping#" ] = arguments.source;
		application action='update' mappings='#mappings#';

		// generate
		docbox.generate( 
			source 		= arguments.source, 
			mapping  	= arguments.mapping, 
			excludes 	= arguments.excludes
		);

		print.greenLine( "Generation complete" );
	}

}