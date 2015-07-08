<cfscript>
	// Build out data
	local.classTree = {};
	// Loop over classes
	for( local.row in qMetaData ) {
		
		//var class = local.row.name;			
		local.bracketPath = '';
		// Build bracket notation 
		for( local.item in listToArray( local.row.package, '.' ) ) {
			bracketPath &= '[ "#local.item#" ]';
		}
		// Set "deep" struct to create nested data
		local.link = replace( local.row.package, ".", "/", "all") & '/' & local.row.name & '.html';
		local.packagelink = replace( local.row.package, ".", "/", "all") & '/package-summary.html';
		local.searchList = listAppend( local.row.package, local.row.name, '.' );

		evaluate( 'local.classTree#bracketPath#[ "$link" ] = local.packageLink' );
		evaluate( 'local.classTree#bracketPath#[ local.row.name ][ "$class"] = structNew()' );
		evaluate( 'local.classTree#bracketPath#[ local.row.name ][ "$class"].link = local.link' );
		evaluate( 'local.classTree#bracketPath#[ local.row.name ][ "$class"].searchList = local.searchList' );
		evaluate( 'local.classTree#bracketPath#[ local.row.name ][ "$class"].type = local.row.type' );
	}
	
	// Recursive function to output data
	function writeItems( struct startingLevel ) {
		for( var item in startingLevel ) {
			// Skip this key as it isn't a class, just the link for the package.
			if( item == '$link' ) { continue; }
			var itemValue = startingLevel[ item ];
			
			//  If this is a class, output it
			if( structKeyExists( itemValue, '$class' ) ) {
				writeOutput( '<li data-jstree=''{ "type" : "#itemValue.$class.type#" }'' linkhref="#itemValue.$class.link#" searchlist="#itemValue.$class.searchList#" thissort="2">' );
				writeOutput( item );
				writeOutput( '</li>' );
			// If this is a package, output it and its children
			} else {
				var link = '';
				if( structKeyExists( itemValue, '$link' ) ) {
					link = itemValue.$link;
				}
				writeOutput( '<li data-jstree=''{ "type" : "package" }'' linkhref="#link#" searchlist="#item#" thissort="1">' );
				writeOutput( item );
				writeOutput( '<ul>' );
					// Recursive call
					writeItems( itemValue );
				writeOutput( '</ul>' );
				writeOutput( '</li>' );
			}
			
		}
	}
</cfscript>
<cfoutput>
<!DOCTYPE html>
<html lang="en">
<head>
	<title>	overview </title>
	<meta name="keywords" content="overview">
	<cfmodule template="inc/common.cfm" rootPath="">
	<link rel="stylesheet" href="jstree/themes/default/style.min.css" />
</head>

<body>
	<h3><strong>#arguments.projecttitle#</strong></h3>

	<!--- Search box --->
	<input type="text" id="classSearch" placeholder="Search..."><br><br>
	<!--- Container div for tree --->
	<div id="classTree">
		<ul>
			<!--- Output classTree --->
			#writeItems( classTree )#
		</ul>
	</div>
	
	<script src="jstree/jstree.min.js"></script>
	<script language="javascript">
		$(function () { 
			// Initialize tree
			$('##classTree')
				.jstree({
					// Shortcut types to control icons
				    "types" : {
				      "package" : {
				        "icon" : "glyphicon glyphicon-folder-open"
				      },
				      "component" : {
				        "icon" : "glyphicon glyphicon-file"
				      },
				      "interface" : {
				        "icon" : "glyphicon glyphicon-info-sign"
				      }
				    },
				    // Smart search callback to do lookups on full class name and aliases 
				    "search" : {
				    	"show_only_matches" : true,
				    	"search_callback" : function( q, node ) {
				    		q = q.toUpperCase();
				    		var searchArray = node.li_attr.searchlist.split(',');
				    		var isClass = node.li_attr.thissort != 1;
				    		for( var i in searchArray ) {
				    			var item = searchArray[ i ];
				    			// classes must be a super set of the search string, but packages are reversed
				    			// This is so "testbox" AND "run" highlight when you serach for "testbox run"
				    			if( ( isClass && item.toUpperCase().indexOf( q ) > -1 )
				    				|| ( !isClass && q.indexOf( item.toUpperCase() ) > -1 ) ) {
				    				return true;
				    			}
				    		}
				    		return false;
				    	}
				    },
				    // Custom sorting to force packages to the top
				    "sort" : function( id1, id2 ) {
				    			var node1 = this.get_node( id1 );
				    			var node2 = this.get_node( id2 );
				    			// Concat sort to name and use that
					    		var node1String = node1.li_attr.thissort + node1.text;
					    		var node2String = node2.li_attr.thissort + node2.text;
					    		
								return ( node1String > node2String ? 1 : -1);						
				    },
				    "plugins" : [ "types", "search", "sort" ]
				  })
				.on("changed.jstree", function (e, data) {
					var obj = data.instance.get_node(data.selected[0]).li_attr;
					if( obj.linkhref ) {
						window.parent.frames['classFrame'].location.assign( obj.linkhref );						
					}
			});
			
			// Bind search to text box
			var to = false;
			$('##classSearch').keyup(function () {
				if(to) { clearTimeout(to); }
				to = setTimeout(function () {
					var v = $('##classSearch').val();
					$('##classTree').jstree(true).search(v);
				}, 250);
			});
			
		 });
	</script>
</body>
</html>
</cfoutput>