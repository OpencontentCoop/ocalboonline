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
						"query": settings.query
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
						"lengthChange": false,
						"searching": false,
						"ajax": {url: settings.url},						
						"columns": settings.columns,
						"columnDefs": settings.columnDefs
					}
				}).data('opendataDataTable');

				var currentFilterName = 'state';
				var setCurrentFilter = function(){
				  	var currentFilterValue = $this.find('.state-navigation .defaultbutton').data('state');
				  	fieldsDatatable.settings.builder.filters[currentFilterName] = {
				    	'field': currentFilterName,				    
				    	'operator': 'in',
				    	'value': [currentFilterValue]				    
				  	};
				};          
				setCurrentFilter();

				$this.find('.state-navigation .defaultbutton').on('click', function(e){
	            	e.preventDefault();
		        });
				$this.find('.state-navigation .button').on('click', function(e){
					$this.find('.state-navigation .defaultbutton').removeClass('defaultbutton');
					$(this).addClass('defaultbutton');
					setCurrentFilter();
					fieldsDatatable.loadDataTable();
					e.preventDefault();
				});		        

				fieldsDatatable.loadDataTable();
            });
        }
    });
})(jQuery);
