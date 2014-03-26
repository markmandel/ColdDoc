<!DOCTYPE html>
 <html>
 	<head>
 		<title>ColdDocs Generator</title>
		<style type='text/css'>
			* {
				font-family:Verdana, Geneva, Arial, Helvetica, sans-serif;
			}
		</style>
	</head>
<body>
	<cfscript>
		source = "../FolderToRead"; // The source code folder we are generating documentation for
		mapping = "foldertoread"; // The folder name used for mapping
		docPath = "./Docs/DocExportFolder"; // The location of where we are putting the documentation
		
		colddoc = createObject("component", "ColdDoc").init();
		WriteOutput("<strong>Initializing ColdDoc</strong><br />");
		
		strategy = createObject("component", "colddoc.strategy.api.HTMLAPIStrategy").init(expandPath(docPath), "ColdDoc 1.0");
		colddoc.setStrategy(strategy);
		
		WriteOutput("<strong>Creating ColdDoc</strong><br />");
		WriteOutput("------Source: '<strong>" & source & "</strong>'<br />");
		WriteOutput("------Mapping: '<strong>" & mapping & "</strong>'<br />");
		WriteOutput("------Doc Path: '<strong>" & docPath & "</strong>'<br /><br />");
		
		colddoc.generate(expandPath(source), mapping);
	</cfscript>
	<cfoutput>
	<h2>Done!</h2>
	
	<a href="#docPath#/">Link to Documentation</a>
	
	</cfoutput>
</body>
</html>