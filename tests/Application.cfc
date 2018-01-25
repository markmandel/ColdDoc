/**
* Copyright 2015 Ortus Solutions, Corp
* www.ortussolutions.com
**************************************************************************************
*/
component{

	this.name = "DocBox Testing Suite";
	// any mappings go here, we create one that points to the root called test.
	this.mappings[ "/tests" ] = getDirectoryFromPath( getCurrentTemplatePath() );
	rootPath = REReplaceNoCase( this.mappings[ "/tests" ], "tests(\\|/)", "" );
	this.mappings[ "/docbox" ] = rootPath;
	this.mappings[ "/coldbox" ] = getDirectoryFromPath( getCurrentTemplatePath() ) & "coldbox";

}