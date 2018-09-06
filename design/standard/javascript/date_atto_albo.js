$(document).ready(function(){
	moment.locale('it');

	var esecutivita = $('.esecutivita').find('select');

	var tipo_archiviazione = $('.tipo_archiviazione').find('select');

	var isBandoOConcorso = $('.data_fine_validita').length > 0;
	
	var setEsecutivita = function(value){
		var setDateValue = getDate('data_iniziopubblicazione').add(11, 'd');		
		if (value === '1'){
			setDate('data_esecutivita', getDate('data')); 
			setDate('data_efficacia', getDate('data')); 
		}else if (value === '0'){
			setDate('data_esecutivita', setDateValue); 
			setDate('data_efficacia', setDateValue); 
		}

		readonlyDate('data_esecutivita');
		readonlyDate('data_efficacia');
	};

	var setArchiviazione = function(value){		
		var setDateValue = getDate('data_iniziopubblicazione').add(10, 'd');
		if (isBandoOConcorso){
			setDateValue = getDate('data_fine_validita').add(1, 'd');
		}
		
		if(value == 'riservato'){
			setDate('data_finepubblicazione', setDateValue); 	
			enableDate('data_finepubblicazione');
			readonlyDate('data_finepubblicazione');

			setDate('data_archiviazione', null); 	
			disableDate('data_archiviazione');
			
			// closeDateAttributeGroup();
		}

		if(value == 'archiviato'){
			setDate('data_archiviazione', setDateValue); 	
			enableDate('data_archiviazione');
			readonlyDate('data_archiviazione');

			setDate('data_finepubblicazione', null); 	
			disableDate('data_finepubblicazione');			
			
			// closeDateAttributeGroup();
		}

		if(value == 'custom'){
			setDate('data_archiviazione', null); 	
			enableDate('data_archiviazione');
			notReadonlyDate('data_archiviazione');
			
			setDate('data_finepubblicazione', null); 	
			enableDate('data_finepubblicazione');
			notReadonlyDate('data_finepubblicazione');
			
			openDateAttributeGroup();			
		}
	}

	var getDate = function(identifier){
		var container = $('.'+identifier);
		if (container.length > 0){
			var day = container.find('.day').val();
			var month = container.find('.month').val();
			var year = container.find('.year').val();
			return moment(day+"-"+month+"-"+year, "DD-MM-YYYY");
		}
		
		return moment("Invalid date", "DD-MM-YYYY");
	}

	var disableDate = function(identifier){
		var container = $('.'+identifier);
		if (container.length > 0){
			var day = container.find('.day').attr("disabled","disabled").css('cursor', 'not-allowed');
			var month = container.find('.month').attr("disabled","disabled").css('cursor', 'not-allowed');
			var year = container.find('.year').attr("disabled","disabled").css('cursor', 'not-allowed');
			container.find('.fa-calendar').hide();
		}
	}

	var enableDate = function(identifier){
		var container = $('.'+identifier);
		if (container.length > 0){
			var day = container.find('.day').removeAttr("disabled").css('cursor', 'default');
			var month = container.find('.month').removeAttr("disabled").css('cursor', 'default');
			var year = container.find('.year').removeAttr("disabled").css('cursor', 'default');
			container.find('.fa-calendar').show();
		}
	}

	var readonlyDate = function(identifier){
		var container = $('.'+identifier);
		if (container.length > 0){
			var day = container.find('.day').attr("readonly","readonly").css('cursor', 'not-allowed');
			var month = container.find('.month').attr("readonly","readonly").css('cursor', 'not-allowed');
			var year = container.find('.year').attr("readonly","readonly").css('cursor', 'not-allowed');
			container.find('.fa-calendar').hide();
		}
	}

	var notReadonlyDate = function(identifier){
		var container = $('.'+identifier);
		if (container.length > 0){
			var day = container.find('.day').removeAttr("readonly").css('cursor', 'default');
			var month = container.find('.month').removeAttr("readonly").css('cursor', 'default');
			var year = container.find('.year').removeAttr("readonly").css('cursor', 'default')
			container.find('.fa-calendar').show();
		}
	}

	var setDate = function(identifier, date){
		var container = $('.'+identifier);
		if (container.length > 0){
			var day = container.find('.day');
			var month = container.find('.month');
			var year = container.find('.year');
			
			if (date && date.isValid()){
				day.val(date.format('DD'));
				month.val(date.format('MM'));
				year.val(date.format('YYYY'));
			}else{
				day.val('');
				month.val('');
				year.val('');
			}
		}
	};

	var isEmpty = function(identifier){
		var container = $('.'+identifier);
		if (container.length > 0){
			var day = container.find('.day');
			var month = container.find('.month');
			var year = container.find('.year');		
			return ($.trim(day.val()).length + $.trim(month.val()).length + $.trim(year.val()).length) === 0;		
		}
	};

	var openDateAttributeGroup = function(){		
		if ($('#accordion-panel-date').css('height') == "0px"){
			$('h2#accordion-header-date').trigger('click');
		}
	}
	var closeDateAttributeGroup = function(){		
		if ($('#accordion-panel-date').css('height') != "0px"){
			$('h2#accordion-header-date').trigger('click');
		}
	}

	$('.data input').on('change', function(){		
		setEsecutivita(esecutivita.val());
	});

	if (isBandoOConcorso){		
		$('.data_fine_validita input').on('change', function(){			
			setArchiviazione(tipo_archiviazione.val());
		});		
	}

	esecutivita.on('change', function(){
		setEsecutivita($(this).val());
	});

	tipo_archiviazione.on('change', function(){
		setArchiviazione($(this).val());
	});


	if (isEmpty('data_esecutivita')){
		setEsecutivita(esecutivita.val());
	}else{
		readonlyDate('data_esecutivita');
	}
	if (isEmpty('data_efficacia')){
		setEsecutivita(esecutivita.val());
	}else{
		readonlyDate('data_efficacia');
	}

	if (isEmpty('data_archiviazione') && isEmpty('data_finepubblicazione')){
		setArchiviazione(tipo_archiviazione.val());
	}else if (isEmpty('data_archiviazione') && !isEmpty('data_finepubblicazione')){
		tipo_archiviazione.val('riservato');
		if (tipo_archiviazione.data('version') == 1){
			tipo_archiviazione.trigger('change');
		}
	}else if (isEmpty('data_finepubblicazione') && !isEmpty('data_archiviazione')){
		tipo_archiviazione.val('archiviato');
		if (tipo_archiviazione.data('version') == 1){
			tipo_archiviazione.trigger('change');
		}
	}else{
		tipo_archiviazione.val('custom').trigger('change');
		openDateAttributeGroup();
	}

	if (isEmpty('data_finepubblicazione_trasparenza')){
		var anno_iniziopubblicazione = getDate('data_iniziopubblicazione').year();		
		setDate('data_finepubblicazione_trasparenza', moment("31-12-"+(anno_iniziopubblicazione+5), "DD-MM-YYYY")); 
	}

});