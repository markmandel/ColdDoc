<cfcomponent hint="Core class for ColdDoc documentation generation framework" output="false">
	<cffunction name="directory_list" access="public" returntype="query" hint="Compatability function that ensures the result from a recursive directory listing is the same accross railo, adobe coldfusion and openbd.">
		<cfargument name="directory" type="string" required="yes">
		<cfargument name="filter_cfc" type="boolean" required="false" default="false">
		<cfset var qFiles = "">
		<cfset var filter = "">

		<cfif server.coldfusion.productname EQ "BlueDragon">
			<cfif arguments.filter_cfc>
				<cfset filter = ".cfc">
			</cfif>
			<cfset qFiles = openbd_cfdirectory(directory=arguments.directory,recurse=true,filter="#filter#")>
		<cfelse>
			<cfif arguments.filter_cfc>
				<cfset filter = "*.cfc">
			</cfif>
			<cfdirectory action="list" directory="#arguments.directory#" recurse="true" name="qFiles" filter="#filter#">
		</cfif>

		<cfreturn qFiles>
	</cffunction>

	<cffunction name="openbd_cfdirectory" access="private" returntype="query" output="false" hint="Returns recursive directory listings on open bluedragon in the same format as Adobe Coldfusion and Railo.">
		<cfargument name="directory" type="string" required="yes">
		<cfargument name="recurse" type="string" required="yes">
		<cfargument name="filter" type="string" required="false" default="">
		<cfset var qResult = queryNew("name,size,type,directory,dateLastModified,attributes,mode")>
		<cfset var qDir = "">
		<cfset var qChild = "">

		<cfdirectory action="list" directory="#arguments.directory#" recurse="false" name="qDir">

		<cfloop query="qDir">
			<cfscript>
			if(arguments.filter EQ "" 	OR 	(qDir.type EQ "File" AND reFindNoCase(arguments.filter,qDir.name)))
			{
				queryaddrow(qResult,1);
				querysetcell(qResult,"name",qDir.name);
				querysetcell(qResult,"size",qDir.size);
				querysetcell(qResult,"type",qDir.type);
				querysetcell(qResult,"directory",qDir.directory);
				querysetcell(qResult,"dateLastModified",qDir.dateLastModified);
				querysetcell(qResult,"attributes",qDir.attributes);
				querysetcell(qResult,"mode",qDir.mode);
			}
			</cfscript>

			<cfif arguments.recurse AND qDir.type EQ "Dir">
				<cfset qChild = openbd_cfdirectory(directory="#qDir.directory#/#qDir.name#",recurse=true,filter="#arguments.filter#")>
				<cfloop query="qChild">
					<cfscript>
					if(arguments.filter EQ "" 	OR 	(qChild.type EQ "File" AND reFindNoCase(arguments.filter,qChild.name)))
					{
						queryaddrow(qResult,1);
						querysetcell(qResult,"name",qChild.name);
						querysetcell(qResult,"size",qChild.size);
						querysetcell(qResult,"type",qChild.type);
						querysetcell(qResult,"directory",qChild.directory);
						querysetcell(qResult,"dateLastModified",qChild.dateLastModified);
						querysetcell(qResult,"attributes",qChild.attributes);
						querysetcell(qResult,"mode",qChild.mode);
					}
					</cfscript>
				</cfloop>
			</cfif>
		</cfloop>

		<cfreturn qResult>
	</cffunction>
</cfcomponent>