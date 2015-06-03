/**
* Copyright 2015 Ortus Solutions, Corp
* www.ortussolutions.com
* Core DocBox documentation class
*/
component accessors="true"{

	/**
	* The strategy to use for document generation. Must extend docbox.strategy.AbstractTemplateStrategy
	*/
	property name="strategy" doc_generic="docbox.strategy.AbstractTemplateStrategy";

	/**
	* Constructor
	* @strategy The optional strategy to generate the documentation with. This can be a class path or an instance of the strategy. If none is passed then
	* we create the default strategy of 'docbox.strategy.api.HTMLAPIStrategy'
	* @properties The struct of properties to instantiate the strategy with.
	*/
	DocBox function init( 
		any strategy ="docbox.strategy.api.HTMLAPIStrategy",
		struct properties={}
	){
		// if instance?
		if( isObject( arguments.strategy ) ){
			variables.strategy = arguments.strategy;	
		} else {
			// Create it
			variables.strategy = new "#arguments.strategy#"( argumentCollection=arguments.properties );
		}

		return this;
	}

	/**
	* Generate the docs
	* @source Either, the string directory source, OR an array of structs containing 'dir' and 'mapping' key
	* @mapping The base mapping for the folder. Only required if the source is a string
	* @excludes	A regex that will be applied to the input source to exclude from the docs
	*/
	DocBox function generate( 
		required source, 
		string mapping="",
		string excludes=""
	){
		// verify we have a strategy
		if( isNull( variables.strategy ) ){
			throw( 
				type 	= "StrategyNotSetException", 
				message = "No Template Strategy has been set.",
				detail 	= "Create a Template Strategy, and set it with setStrategy() before calling generate() or pass it via the constructor."
			);
		}

		// inflate the incoming input and mappings
		var source = "";
		if( isSimpleValue( arguments.source ) ){
			source = [ { dir = arguments.source, mapping = arguments.mapping } ];
		} else {
			source = arguments.source;
		}

		// build metadata collection
		var qMetaData = buildMetaDataCollection( source, arguments.excludes );

		// run the strategy
		variables.strategy.run( qMetaData );

		return this;
	}

	/************************************ PRIVATE ******************************************/

	/**
	* Clean input path
	* @path The incoming path to clean
	* @inputDir The input dir to clean off
	*/
	private function cleanPath( required path, required inputDir ){
		var currentPath = replace( getDirectoryFromPath( arguments.path ), arguments.inputDir, "" );
        currentPath 	= reReplace( currentPath, "[/\\]", "" );
        currentPath 	= reReplace( currentPath, "[/\\]", ".", "all" );
        return rEReplace( currentPath, "\.$", "" );
	}

	/**
	* Builds the searchable meta data collection
	* @inputSource an array of structs containing inputDir and mapping
	* @excludes	A regex that will be applied to the input source to exclude from the docs
	*/
	query function buildMetaDataCollection( required array inputSource, string excludes="" ){
		var qMetaData = QueryNew( "package,name,extends,metadata,type,implements,fullextends,currentMapping" );
		
		// iterate over input sources
		for( var thisInput in arguments.inputSource ){
			var aFiles = directoryList( thisInput.dir, true, "path", "*.cfc" );

			// iterate over files found
			for( var thisFile in aFiles ){
				// Excludes?
				if( len( arguments.excludes ) && rEFindNoCase( arguments.excludes, thisFile ) ){
					continue;
				}
				// get current path
				var currentPath = cleanPath( thisFile, thisInput.dir );

                // calculate package path according to mapping
                var packagePath = thisInput.mapping;
                if( len( currentPath ) ){
                	packagePath = ListAppend( thisInput.mapping, currentPath, "." );
                } 
                // setup cfc name
                var cfcName = listFirst( getFileFromPath( thisFile ), "." );

                // Core Excludes, don't document the Application.cfc
                if( cfcName == "Application" ){ continue; }

                try{

                	// Get component metadatata
                	var meta = "";
	                if( Len( packagePath ) ){
	                    meta = getComponentMetaData( packagePath & "." & cfcName );
	                } else {
	                    meta = getComponentMetaData( cfcName );
	                }

	                //let's do some cleanup, in case CF sucks.
	                if( Len( packagePath ) AND NOT meta.name contains packagePath ){
						meta.name = packagePath & "." & cfcName;
	                }

	                // Add row
					QueryAddRow( qMetaData );
					// Add contents
	                QuerySetCell( qMetaData, "package",  		packagePath );
	                QuerySetCell( qMetaData, "name", 	 		cfcName );
	                QuerySetCell( qMetaData, "metadata", 		meta );
					QuerySetCell( qMetaData, "type", 	 		meta.type );
					QuerySetCell( qMetaData, "currentMapping", 	thisInput.mapping );
					
					// Get implements
					var implements = getImplements( meta );
					implements = listQualify( arrayToList( implements ), ':' );
					QuerySetCell( qMetaData, "implements", implements );
					
					// Get inheritance
					var fullextends = getInheritance( meta );
					fullextends = listQualify( arrayToList( fullextends ), ':' );
					QuerySetCell( qMetaData, "fullextends", fullextends );

	                //so we cane easily query direct desendents
	                if( StructKeyExists( meta, "extends" ) ){
						if( meta.type eq "interface" ){
							QuerySetCell( qMetaData, "extends", meta.extends[ structKeyList( meta.extends ) ].name );
						} else						{
		                    QuerySetCell( qMetaData, "extends", meta.extends.name );
						}
	                } else {
	                    QuerySetCell( qMetaData, "extends", "-" );
	                }

				}
				catch(Any e){
					trace( 
						type 		= "warn",
						category 	= "docbox",
						inline 		= "true",
						text 		= "Warning! The following script has errors: " & packagePath & cfcName & ". #e.toString()#" 
					);
				}

			} // end qFiles iteration
		} // end input source iteration

		return qMetadata;
	}

	/**
	* Gets an array of the classes that this metadata implements, in order of extension
	* @metadata The metadata to look at
	*/
	private array function getImplements( required struct metadata ){
		var interfaces = {};

		// check if a cfc
		if( arguments.metadata.type neq "component" ){
			return [];
		}
		// iterate
		while( StructKeyExists( arguments.metadata, "extends" ) ){
			if( StructKeyExists( arguments.metadata, "implements" ) ){
				for( var key in arguments.metadata.implements ){
					interfaces[ arguments.metadata.implements[ key ].name ] = 1;
				}
			}
			arguments.metadata = arguments.metadata.extends;
		}
		// get as an array
		interfaces = structKeyArray( interfaces );
		// sort it
		arraySort( interfaces, "textnocase" );

		return interfaces;
	}

	/**
	* Gets an array of the classes that this metadata extends, in order of extension
	* @metadata The metadata to look at
	*/
	private array function getInheritance( required struct metadata ){
		//ignore top level
		var inheritence = [];

		while( StructKeyExists( arguments.metadata, "extends" ) ){
			//manage interfaces
			if( arguments.metadata.type == "interface" ){
				arguments.metadata = arguments.metadata.extends[ structKeyList( arguments.metadata.extends ) ];
			} else {
				arguments.metadata = arguments.metadata.extends;
			}

			arrayPrepend( inheritence, arguments.metadata.name );
		}

		return inheritence;
	}

}