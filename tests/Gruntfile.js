module.exports = function( grunt ){

	// Default
	grunt.registerTask( "default", [ "watch" ] );

	// Config
	grunt.initConfig( {
		box : grunt.file.readJSON( "../box.json" ),
		http : {
			docbox : {
				options : {
					url: 'http://127.0.0.1:<%= box.defaultPort %>/tests/box.cfm'
				}
			}
		},
		watch : {
			docbox : {
				files : [ '../DocBox.cfc', '../strategy/**/*.*' ],
				tasks : [ "http:docbox" ]
			}
		}

	} );

	// Load Tasks
	require( 'matchdep' )
		.filterDev( 'grunt-*' )
		.forEach( grunt.loadNpmTasks );
};