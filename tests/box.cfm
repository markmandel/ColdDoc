<cfscript>
	// init docbox with default strategy and properites
	docbox = new DocBox( properties={ 
		outputDir 		= expandPath( "./output" ),
		projectTitle 	= "ColdBox Docs"
	} );
	// generate
	docbox.generate( source=expandPath("coldbox"), mapping="coldbox" );
</cfscript>
<h1>Done!</h1>
<a href="/output">View Docs</a>
