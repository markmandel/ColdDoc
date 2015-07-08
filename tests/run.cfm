<cfscript>
	// init docbox with default strategy and properites
	docbox = new docbox.DocBox( properties={ 
		outputDir 		= expandPath( "./output" ),
		projectTitle 	= "DocBox v2.0.1"
	} );
	// generate
	docbox.generate( source=expandPath("/docbox"), mapping="docbox", excludes="coldbox" );
</cfscript>
<h1>Done!</h1>
<a href="output">View Docs</a>
