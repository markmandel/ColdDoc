/**
* Abstract base class for general templating strategies
* <br>
* <small><em>Copyright 2015 Ortus Solutions, Corp <a href="www.ortussolutions.com">www.ortussolutions.com</a></em></small>
*/
component doc_abstract="true" accessors="true"{

	/**
	* The function query cache
	*/
	property name="functionQueryCache" type="struct";

	/**
	* The property query cache
	*/
	property name="propertyQueryCache" type="struct";

	// static constants
	variables.static.META_ABSTRACT 	= "doc_abstract";
	variables.static.META_GENERIC 	= "doc_generic";

	/**
	* Constructor
	*/
	AbstractTemplateStrategy function init(){
		setFunctionQueryCache( structNew() );
		setPropertyQueryCache( structnew() );
		return this;
	}
	
	/**
	* Runs the strategy
	*/
	AbstractTemplateStrategy function run(){
		throw(
			type 	= "AbstractMethodException",
			message = "Method is abstract and must be overwritten",
			detail 	= "The method 'run' in  component '#getMetadata( this ).name#' is abstract and must be overwritten"
		);
	}

	/**
	* builds a data structure that shows the tree structure of the packages
	* @return string,struct
	*/
	struct function buildPackageTree( required query qMetadata ){
		var qPackages = new Query( dbtype="query", md=arguments.qMetadata, sql="
			SELECT DISTINCT
				package
			FROM
				md
			ORDER BY
				package" )
			.execute()
			.getResult();

		var tree = {};
		for( var thisRow in qPackages ){
			var node = tree;
			var aPackage = listToArray( thisRow, "." );

			for( var thisPath in aPackage ){
				if( not structKeyExists( node, thisPath ) ){
					node[ thisPath ] = {};
				}
				node = node[ thisPath ];
			}
		}

		return tree;
	}

	/**
	* visit each element on the package tree
	* @packageTree The package tree
	* @startCommand the command to call on each visit
	* @endCommand the command to call on each visit
	* @args the extra arguments to get passed on to the visitor command (name, and fullname get passed by default)
	*/
	private AbstractTemplateStrategy function visitPackageTree(
		required struct packageTree,
		required any startCommand,
		required any endCommand,
		struct args={}

	){
		var startCall 	= arguments.startCommand;
		var endCall 	= arguments.endCommand;

		// default the fullname
		if( NOT StructKeyExists( args, "fullname" ) ){
			arguments.args.fullname = "";
		}

		// iterate over package tree
		for( var key in arguments.packageTree ){
			var thisArgs 		= structCopy( arguments.args );
			thisArgs.name 		= key;
			thisArgs.fullName 	= listAppend( thisArgs.fullName, thisArgs.name, "." );

			startCall( argumentCollection=thisArgs );

			visitPackageTree( arguments.packageTree[ key ], startCall, endCall, thisArgs );

			endCall( argumentCollection=thisArgs );
		}

		return this;
	}

	/**
	* Is the type a privite value
	* @type The cf type
	*/
	private boolean function isPrimitive( required string type ){
		var primitives = "string,date,struct,array,void,binary,numeric,boolean,query,xml,uuid,any,component,function";
		return ListFindNoCase( primitives, arguments.type );
	}

	/**
	* builds a sorted query of function meta
	*/
	query function buildFunctionMetaData( required struct metadata ){
		var qFunctions 	= QueryNew( "name, metadata" );
		var cache 		= getFunctionQueryCache();

		if( StructKeyExists( cache, arguments.metadata.name ) ){
			return cache[ arguments.metadata.name ];
		}
		// if no properties, return empty query
		if( NOT StructKeyExists( arguments.metadata, "functions" ) ){
			return qFunctions;
		}
		// iterate and create
		for( var thisFnc in arguments.metadata.functions ){
			//dodge cfthread functions
			if( NOT JavaCast( "string", thisFnc.name ).startsWith( "_cffunccfthread_" ) ){
				QueryAddRow( qFunctions );
				QuerySetCell( qFunctions, "name", thisFnc.name );
				QuerySetCell( qFunctions, "metadata", safePropertyMeta( thisFnc, arguments.metadata ) );
			}
		}

		var results = getMetaSubQuery( query=qFunctions, orderby="name asc" );
		cache[ arguments.metadata.name ] = results;
		return results;
	}
	
	/**
	* builds a sorted query of property meta
	*/
	query function buildPropertyMetaData( required struct metadata ){
		var qProperties = QueryNew( "name, metadata" );
		var cache 		= getPropertyQueryCache();

		if( StructKeyExists( cache, arguments.metadata.name ) ){
			return cache[ arguments.metadata.name ];
		}
		// if no properties, return empty query
		if( NOT StructKeyExists( arguments.metadata, "properties" ) ){
			return qProperties;
		}
		// iterate and create
		for( var thisProp in arguments.metadata.properties ){
			QueryAddRow( qProperties );
			QuerySetCell( qProperties, "name", thisProp.name );
			QuerySetCell( qProperties, "metadata", safePropertyMeta( thisProp, arguments.metadata ) );
		}

		var results = getMetaSubQuery( query=qProperties, orderby="name asc" );
		cache[ arguments.metadata.name ] = results;
		return results;
	}

	/**
	* Returns the simple object name from a full class name
	* @class The name of the class
	*/
	private string function getObjectName( required class ){
		return ( len( arguments.class ) ?  
				ListGetAt( arguments.class, ListLen( arguments.class, "." ), "." ) :
				arguments.class );
	}

	/**
	* Get a package from an incoming class
	* @class The name of the class
	*/
	private string function getPackage( required class ){
		var objectname  = getObjectName( arguments.class );
		var lenCount 	= Len( arguments.class ) - ( Len( objectname ) + 1 );
	      
	    return ( lenCount gt 0 ? left( arguments.class, lenCount ) : arguments.class );
	}

	/**
    * Whether or not the CFC class exists (does not test for primitives)
    * @qMetaData The metadata query
    * @className The name of the class
    * @package The package the class comes from
    */
    private boolean function classExists( 
    	required query qMetadata,
    	required string className, 
    	required string package 
    ){
    	var resolvedClassName 	= resolveClassName( arguments.className, arguments.package );
		var objectName 			= getObjectName( resolvedClassName );
		var packageName			= getPackage( resolvedClassName );
		var qClass 				= getMetaSubQuery( arguments.qMetaData, "LOWER(package)=LOWER('#packageName#') AND LOWER(name)=LOWER('#objectName#')");

		return qClass.recordCount;
    }
	
	/**
    * Whether a type exists at all - be it class name, or primitive type
    * @qMetaData The metadata query
    * @className The name of the class
    * @package The package the class comes from
    */
    private boolean function typeExists( 
    	required query qMetadata,
    	required string className, 
    	required string package 
    ){
    	return isPrimitive( arguments.className ) OR classExists( argumentCollection=arguments );
    }

    /**
    * Resolves a class name that may not be full qualified
    * @className The name of the class
    * @package The package the class comes from
    */
    private string function resolveClassName( required string className, required string package ){
    	if( ListLen( arguments.className, "." ) eq 1 ){
			arguments.className = arguments.package & "." & arguments.className;
		}
		return arguments.className;
    }

	/**
	* Query of Queries helper
	* @query The metadata query
	* @where The where string
	* @orderby The order by string
	*/
	private query function getMetaSubQuery(
		required query query,
		string where,
		string orderBy
	){
		var q = new Query( dbtype="query", qry=arguments.query );
		var sql = "SELECT * FROM qry";

		if( !isNull( arguments.where ) ){
			sql &= " WHERE #PreserveSingleQuotes( arguments.where )#";
		}

		if( !isNull( arguments.orderBy ) ){
			sql &= " ORDER BY #arguments.orderBy#";
		}
		q.setSQL( sql );

		return q.execute().getResult();
	}

	/**
	* Sets default values on function metadata
	* @func The function metadata
	* @metadata The original metadata
	*/
	private any function safeFunctionMeta( required func, required struct metadata ){
		
		if( NOT StructKeyExists( arguments.func, "returntype" ) ){
			arguments.func.returntype = "any";
		}

		if( NOT StructKeyExists( arguments.func, "access" ) ){
			arguments.func.access = "public";
		}

		// move the cfproperty hints onto functions for accessors/mutators
		if( StructKeyExists( arguments.metadata, "properties" ) ){
			if( Lcase( arguments.func.name ).startsWith( "get" ) AND NOT StructKeyExists( arguments.func, "hint" ) ){
				local.name 		= replaceNoCase( arguments.func.name, "get", "" );
				local.property 	= getPropertyMeta( local.name, arguments.metadata.properties );

				if( structKeyExists( local.property, "hint" ) ){
					arguments.func.hint = "get: " & local.property.hint;
				}

			}
			else if( LCase( arguments.func.name ).startsWith( "set" ) AND NOT StructKeyExists( arguments.func, "hint" ) ){
				local.name 		= replaceNoCase( arguments.func.name, "set", "" );
				local.property 	= getPropertyMeta( local.name, arguments.metadata.properties );

				if( structKeyExists( local.property, "hint" ) ){
					arguments.func.hint = "set: " & local.property.hint;
				}
			}
		}

		// move any argument meta from @foo.bar annotations onto the argument meta
		if( structKeyExists( arguments.func, "parameters" ) ){
			for( local.metaKey in arguments.func ){
				if( ListLen( local.metaKey, "." ) gt  1 ){
					local.paramKey 			= listGetAt( local.metaKey, 1, "." );
					local.paramExtraMeta 	= listGetAt( local.metaKey, 2, "." );
					local.paramMetaValue 	= arguments.func[ local.metaKey ];

					local.len = ArrayLen( arguments.func.parameters );
                    for( local.counter=1; local.counter lte local.len; local.counter++ ){
                    	local.param = arguments.func.parameters[ local.counter ];

						if( local.param.name eq local.paramKey ){
							local.param[ local.paramExtraMeta ] = local.paramMetaValue;
						}
                    }
				}
			}
		}
		return arguments.func;
	}

	/**
	* Sets default values on property metadata
	* @property The property metadata
	* @metadata The original metadata
	*/
	private any function safePropertyMeta( required property, required struct metadata ){
		
		if( NOT StructKeyExists( arguments.property, "type" ) ){
			arguments.property.type = "any";
		}

		if( NOT StructKeyExists( arguments.property, "required" ) ){
			arguments.property.required = false;
		}
		
		if( NOT StructKeyExists( arguments.property, "hint" ) ){
			arguments.property.hint = "";
		}
		
		if( NOT StructKeyExists( arguments.property, "default" ) ){
			arguments.property.default = "";
		}
		
		if( NOT StructKeyExists( arguments.property, "serializable" ) ){
			arguments.property.serializable = true;
		}
		
		return arguments.property;
	}
	
	/**
	* returns the property meta by a given name
	* @name The name of the property
	* @properties The property meta
	*/
	private struct function getPropertyMeta( required string name, required array properties ){
		for( var thisProp in arguments.properties ){
			if( thisProp.name eq arguments.name ){
				return thisProp;
			}
		}
		return {};
	}

	/**
	* Sets a default meta type if not found
	* @param The struct meta
	*/
	private struct function safeParamMeta( required struct param ){
		if( NOT StructKeyExists( arguments.param, "type" ) ){
			arguments.param.type = "any";
		}

		return arguments.param;
	}

	/**
	* Builds a template
	* @path Where to write the template
	* @template The template to write out
	*/
	private AbstractTemplateStrategy function writeTemplate( required string path, required string template ){
		savecontent variable="local.html"{
			include "#arguments.template#";
		}
		fileWrite( arguments.path, local.html );

		return this;
	}

	/**
	* Ensure directory
	* @path The target path
	*/
	private AbstractTemplateStrategy function ensureDirectory( required string path ){
		if( NOT directoryExists( arguments.path ) ){
			directoryCreate( arguments.path );
		}
		return this;
	}

	/**
	* is this class annotated as an abstract class?
	* @class The class name
	* @package The package we are currently in
	*/
	private boolean function isAbstractClass( required string class, required string package ){
		// resolve class name
		arguments.class = resolveClassName( arguments.class, arguments.package );
		// get metadata
		var meta = getComponentMetadata( arguments.class );
		// verify we have abstract class
		if( structKeyExists( meta, variables.static.META_ABSTRACT ) ){
			return meta[ variables.static.META_ABSTRACT ];
		}

		return false;
	}

	/**
	* return an array of generic types associated with this function/argument
	* @meta Either function, or argument metadata
	* @package The package we are currently in
	*/
	private array function getGenericTypes( required struct meta, required string package ){
		var results = [];

		// verify we have the generic annotation
		if( structKeyExists( arguments.meta, variables.static.META_GENERIC ) ){
			var generics = listToArray( arguments.meta[ variables.static.META_GENERIC ] );
			// iterate and resolve
			for( var thisGeneric in generics ){
				if( NOT isPrimitive( thisGeneric ) ){
					arrayAppend( results, resolveClassName( thisGeneric, arguments.package ) );
				}
			} 
		}

		return results;
	}

}