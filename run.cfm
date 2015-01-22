<!---
Let's generate our default HTML documentation on myself: 
 --->
<cfscript>
	colddoc = createObject("component", "ColdDoc").init();

	strategy = createObject("component", "colddoc.strategy.api.HTMLAPIStrategy").init(expandPath("./docs"), "ColdDoc 1.0");
	colddoc.setStrategy(strategy);

	// Let's give flexibility to user to make choice of the folders within application which need to be documented
	rootFolder = expandPath("/");
	path_mapping = [
		,	{inputDir="#rootFolder#",		inputMapping="colddoc",			recursive="false"}
		,	{inputDir="#rootFolder#\strategy\api",	inputMapping="colddoc.strategy.api",	recursive="true"}
		];

	colddoc.generate(path_mapping);
	
	// Or diretly specify path and mapping to generate function
	//colddoc.generate(expandPath("/colddoc"), "colddoc");
</cfscript>

<h1>Done!</h1>

<a href="docs">Documentation</a>
