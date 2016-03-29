<cfparam name="url.version" default="0">
<cfparam name="url.path" 	default="#expandPath( "./DocBox-APIDocs" )#">
<cfscript>
	docName = "DocBox-APIDocs";
	// init docbox with default strategy and properites
	docbox = new docbox.DocBox( properties={ 
		projectTitle 	= "DocBox v#url.version#",
		outputDir 		= url.path
	} );
	// generate
	docbox.generate( 
		source=expandPath( "/docbox" ), 
		mapping="docbox", 
		excludes="(coldbox|build\-docbox)" 
	);
</cfscript>
<h1>Done!</h1>
<cfoutput>
<a href="#docName#/index.html">Go to Docs!</a>
</cfoutput>