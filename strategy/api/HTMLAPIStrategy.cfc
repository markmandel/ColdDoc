/**
* Default Document Strategy for DocBox
* <br>
* <small><em>Copyright 2015 Ortus Solutions, Corp <a href="www.ortussolutions.com">www.ortussolutions.com</a></em></small>
*/
component extends="docbox.strategy.AbstractTemplateStrategy" accessors=true{

	/**
	* The output directory
	*/
	property name="outputDir" type="string";

	/**
	* The project title to use
	*/
	property name="projectTitle" default="Untitled" type="string";

	// Static variables.
	variables.static.TEMPLATE_PATH = "/docbox/strategy/api/resources/templates";
	variables.static.ASSETS_PATH = "/docbox/strategy/api/resources/static";

	/**
	* Constructor
	* @outputDir The output directory
	* @projectTitle The title used in the HTML output
	*/
	HTMLAPIStrategy function init( required outputDir, string projectTitle="Untitled" ){
		super.init();

		variables.outputDir 	= arguments.outputDir;
		variables.projectTitle 	= arguments.projectTitle;

		return this;
	}

	/**
	* Run this strategy
	* @qMetaData The metadata
	*/
	HTMLAPIStrategy function run( required query qMetadata ){
		// copy over the static assets
		directoryCopy( variables.static.ASSETS_PATH, getOutputDir(), true );

		//write the index template
		var args = {
			path 		 = getOutputDir() & "/index.html", 
			template 	 = "#variables.static.TEMPLATE_PATH#/index.cfm", 
			projectTitle = getProjectTitle()
		};
		writeTemplate( argumentCollection=args )
			// Write overview summary and frame
			.writeOverviewSummaryAndFrame( arguments.qMetaData )
			// Write classes frame
			.writeAllClassesFrame( arguments.qMetaData )
			// Write packages
			.writePackagePages( arguments.qMetaData );

		return this;
	}

	/**
	* writes the package summaries
	* @qMetaData The metadata
	*/
	private HTMLAPIStrategy function writePackagePages( required query qMetadata ){
		var currentDir = 0;
		var qPackage = 0;
		var qClasses = 0;
		var qInterfaces = 0;

		// done this way as ACF compat. Does not support writeoutput with query grouping.
		include "#variables.static.TEMPLATE_PATH#/packagePages.cfm";

		return this;
	}

	/**
	* builds the class pages
	* @qPackage the query for a specific package
	* @qMetaData The metadata
	*/
	private HTMLAPIStrategy function buildClassPages( 
		required query qPackage,
		required query qMetadata 
	){
		for( var thisRow in arguments.qPackage ){
			var currentDir 	= getOutputDir() & "/" & replace( thisRow.package, ".", "/", "all" );
			var safeMeta 	= structCopy( thisRow.metadata );

			// Is this a class
			if( safeMeta.type eq "component" ){
				var qSubClass = getMetaSubquery( 
					arguments.qMetaData, 
					"UPPER(extends) = UPPER('#arguments.qPackage.package#.#arguments.qPackage.name#')", 
					"package asc, name asc" 
				);
				var qImplementing = QueryNew("");
			} else {
				//all implementing subclasses
				var qSubClass = getMetaSubquery(
					arguments.qMetaData, 
					"UPPER(fullextends) LIKE UPPER('%:#arguments.qPackage.package#.#arguments.qPackage.name#:%')", 
					"package asc, name asc"
				);
				var qImplementing = getMetaSubquery(
					arguments.qMetaData, 
					"UPPER(implements) LIKE UPPER('%:#arguments.qPackage.package#.#arguments.qPackage.name#:%')", 
					"package asc, name asc"
				);
			}

			// write it out
			writeTemplate(
				path			= currentDir & "/#name#.html",
				template		= "#variables.static.TEMPLATE_PATH#/class.cfm",
				projectTitle 	= getProjectTitle(),
				package 		= arguments.qPackage.package,
				name 			= arguments.qPackage.name,
				qSubClass 		= qSubClass,
				qImplementing 	= qImplementing,
				qMetadata 		= qMetaData,
				metadata 		= safeMeta
			);
		}

		return this;
	}


	/**
	* writes the overview-summary.html
	* @qMetaData The metadata
	*/
	private HTMLAPIStrategy function writeOverviewSummaryAndFrame( required query qMetadata ){
		var qPackages = new Query( dbtype="query", md=arguments.qMetadata, sql="
			SELECT DISTINCT package
			FROM md
			ORDER BY package" )
			.execute()
			.getResult();

		// overview summary
		writeTemplate(
			path			= getOutputDir() & "/overview-summary.html",
			template		= "#variables.static.TEMPLATE_PATH#/overview-summary.cfm",
			projectTitle 	= getProjectTitle(),
			qPackages 		= qPackages
		);

		//overview frame
		writeTemplate(
			path			= getOutputDir() & "/overview-frame.html",
			template		= "#variables.static.TEMPLATE_PATH#/overview-frame.cfm",
			projectTitle	= getProjectTitle(),
			qMetadata 		= arguments.qMetadata
		);

		return this;
	}
	
	/**
	* writes the allclasses-frame.html
	* @qMetaData The metadata
	*/
	private HTMLAPIStrategy function writeAllClassesFrame( required query qMetadata ){
		arguments.qMetadata = getMetaSubquery( query=arguments.qMetaData, orderby="name asc" );

		writeTemplate(
			path 		= getOutputDir() & "/allclasses-frame.html",
			template 	= "#variables.static.TEMPLATE_PATH#/allclasses-frame.cfm",
			qMetaData 	= arguments.qMetaData
		);

		return this;
	}	
}