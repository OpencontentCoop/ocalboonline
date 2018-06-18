moment.locale('it');
;(function($){
    $.fn.extend({
        alboOnLine: function(options) {
            this.defaultOptions = {};

            var settings = $.extend({}, this.defaultOptions, options);

            return this.each(function() {
                var $this = $(this);

				var fieldsDatatable = $this.find('.table-container').opendataDataTable({
					"builder":{
						"query": ''
					},
					"table":{
					  "id": 'table-'+$this.attr('id'),
					  "template": '<table class="table table-striped table-bordered display responsive no-wrap" cellspacing="0" width="100%"></table>'
					},
					"datatable":{          
						"responsive": true,
						"language":{
							"decimal":        "",
							"emptyTable":     "Non sono attualmente presenti atti in questa sezione",
							"info":           "Vista da _START_ a _END_ di _TOTAL_ elementi",
							"infoEmpty":      "",
							"infoFiltered":   "(filtrati da _MAX_ elementi totali)",
							"infoPostFix":    "",
							"thousands":      ",",
							"lengthMenu":     "Visualizza _MENU_ elementi",
							"loadingRecords": "Caricamento...",
							"processing":     "Elaborazione...",
							"search":         "Cerca:",
							"zeroRecords":    "La ricerca non ha portato alcun risultato",
							"paginate": {
								"first":      "Inizio",
								"last":       "Fine",
								"next":       "Successivo",
								"previous":   "Precedente"
							},
							"aria": {
								"sortAscending":  ": attiva per ordinare la colonna in ordine crescente",
								"sortDescending": ": attiva per ordinare la colonna in ordine decrescente"
							}
						},
						"order": [[ 0, 'desc' ]],
						"pageLength": settings.length,
						"lengthChange": false,
						"searching": settings.searching,
						"ajax": {url: settings.url},						
						"columns": settings.columns,
						"columnDefs": settings.columnDefs
					}
				}).on( 'draw.dt', function ( e, datatableSettings, json ) {
					if (settings.openInPopup){
						$('.alboonline-link a').on('click', function(e){
							e.preventDefault();
							var modal = $('#albboonline-preview');
							var $this = $(this);
							modal.find('.modal-content').html('<em>Attendere caricamento...</em>');							
							modal.modal();
							modal.find('.modal-content').load('/layout/set/modal'+$(this).attr('href'));							
							modal.find('.extra').hide()
							modal.find('.content-container .content').removeClass('withExtra');
						});
					}
				}).on('xhr.dt', function ( e, datatableSettings, json, xhr ) {
					//$this.find('.group-facets a').hide();
					//$.opendataTools.find()
					// if (json.facets.length){
					// 	$.each(json.facets, function(){
					// 		var field = this.name;
					// 		var values = this.data;
					// 		$this.find('.group-facets a[data-field="'+field+'"]').each(function(){
					// 			var value = $(this).data('value');
					// 			if (values[value]){
					// 				$(this).show();
					// 			}
					// 		});
					// 	});
					// }
				}).data('opendataDataTable');
				
				var setCurrentFilters = function(){
				  	$this.find('.facet-navigation').each(function(){
						var currentFilterName = $(this).find('.defaultbutton').data('field');
						var currentFilterOperator = $(this).find('.defaultbutton').data('operator');
						var currentFilterValue = $(this).find('.defaultbutton').data('value');
					  	fieldsDatatable.settings.builder.filters[currentFilterName] = {
					    	'field': currentFilterName,				    
					    	'operator': currentFilterOperator,
					    	'value': currentFilterValue
					  	};
				  	});				  	
				};          
				setCurrentFilters();

				$this.find('.facet-navigation .defaultbutton').on('click', function(e){
	            	e.preventDefault();
		        });
				$this.find('.facet-navigation .button').on('click', function(e){
					$(this).parent().find('.defaultbutton').removeClass('defaultbutton');
					$(this).addClass('defaultbutton');
					setCurrentFilters();
					fieldsDatatable.loadDataTable();
					e.preventDefault();
				});		        

				fieldsDatatable.loadDataTable();
            });
        }
    });
})(jQuery);
