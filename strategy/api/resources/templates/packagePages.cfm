<cfoutput query="arguments.qMetaData" group="package">
	<cfscript>
		currentDir = getOutputDir() & "/" & replace( package, ".", "/", "all" );
		ensureDirectory( currentDir );
		qPackage 	= getMetaSubquery( arguments.qMetaData, "package = '#package#'", "name asc" );
		qClasses 	= getMetaSubquery( qPackage, "type='component'", "name asc");
		qInterfaces = getMetaSubquery( qPackage, "type='interface'", "name asc");

		writeTemplate(
			path			= currentDir & "/package-summary.html",
			template		= "#variables.static.TEMPLATE_PATH#/package-summary.cfm",
			projectTitle 	= getProjectTitle(),
			package 		= package,
			qClasses 		= qClasses,
			qInterfaces 	= qInterfaces
		);

		writeTemplate(
			path			= currentDir & "/package-frame.html",
			template		= "#variables.static.TEMPLATE_PATH#/package-frame.cfm",
			projectTitle 	= getProjectTitle(),
			package 		= package,
			qClasses 		= qClasses,
			qInterfaces 	= qInterfaces);

		buildClassPages( qPackage, arguments.qMetadata );
	</cfscript>
</cfoutput>