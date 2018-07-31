$(document).ready(function(){
	moment.locale('it');

	var esecutivita = $('.esecutivita').find('select');

	var tipo_archiviazione = $('.tipo_archiviazione').find('select');
	
	var setEsecutivita = function(value){
		if (value == 1){
			setDate('data_esecutivita', getDate('data')); 
		}else{
			setDate('data_esecutivita', getDate('data_iniziopubblicazione').add(10, 'd')); 
		}
	};

	var setArchiviazione = function(value){
		console.log(value);
		if(value == 'riservato'){
			setDate('data_finepubblicazione', getDate('data_iniziopubblicazione').add(10, 'd')); 	
			setDate('data_archiviazione', null); 	
		}

		if(value == 'archiviato'){
			setDate('data_archiviazione', getDate('data_iniziopubblicazione').add(10, 'd')); 	
			setDate('data_finepubblicazione', null); 	
		}		
	}

	var getDate = function(identifier){
		var container = $('.'+identifier);
		
		var day = container.find('.day').val();
		var month = container.find('.month').val();
		var year = container.find('.year').val();
		
		return moment(day+"-"+month+"-"+year, "DD-MM-YYYY");
	}

	var setDate = function(identifier, date){
		var container = $('.'+identifier);
		
		var day = container.find('.day');
		var month = container.find('.month');
		var year = container.find('.year');
		
		if (date){
			day.val(date.format('DD'));
			month.val(date.format('MM'));
			year.val(date.format('YYYY'));
		}else{
			day.val('');
			month.val('');
			year.val('');
		}
	};

	var isEmpty = function(identifier){
		var container = $('.'+identifier);
		
		var day = container.find('.day');
		var month = container.find('.month');
		var year = container.find('.year');		
		return ($.trim(day.val()).length + $.trim(month.val()).length + $.trim(year.val()).length) === 0;		
	};

	esecutivita.on('change', function(){
		setEsecutivita($(this).val());
	});

	tipo_archiviazione.on('change', function(){
		setArchiviazione($(this).val());
	});


	if (isEmpty('data_esecutivita')){
		setEsecutivita(esecutivita.val());
	}

	if (isEmpty('data_archiviazione') && isEmpty('data_finepubblicazione')){
		setArchiviazione(tipo_archiviazione.val());
	}else if (isEmpty('data_archiviazione') && !isEmpty('data_finepubblicazione')){
		tipo_archiviazione.val('riservato');
	}else if (isEmpty('data_finepubblicazione') && !isEmpty('data_archiviazione')){
		tipo_archiviazione.val('archiviato');
	}else{
		tipo_archiviazione.val('custom');
	}

	if (isEmpty('data_finepubblicazione_trasparenza')){
		var anno_iniziopubblicazione = getDate('data_iniziopubblicazione').year();		
		setDate('data_finepubblicazione_trasparenza', moment("31-12-"+(anno_iniziopubblicazione+5), "DD-MM-YYYY")); 
	}
});