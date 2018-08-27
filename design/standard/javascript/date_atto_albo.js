$(document).ready(function(){
	moment.locale('it');

	var esecutivita = $('.esecutivita').find('select');

	var tipo_archiviazione = $('.tipo_archiviazione').find('select');
	
	var setEsecutivita = function(value){
		if (value === '1'){
			setDate('data_esecutivita', getDate('data')); 
			setDate('data_efficacia', getDate('data')); 
		}else if (value === '0'){
			setDate('data_esecutivita', getDate('data_iniziopubblicazione').add(11, 'd')); 
			setDate('data_efficacia', getDate('data_iniziopubblicazione').add(11, 'd')); 
		}

		readonlyDate('data_esecutivita');
		readonlyDate('data_efficacia');
	};

	var setArchiviazione = function(value){		
		if(value == 'riservato'){
			setDate('data_finepubblicazione', getDate('data_iniziopubblicazione').add(10, 'd')); 	
			enableDate('data_finepubblicazione');
			readonlyDate('data_finepubblicazione');

			setDate('data_archiviazione', null); 	
			disableDate('data_archiviazione');
			
			// closeDateAttributeGroup();
		}

		if(value == 'archiviato'){
			setDate('data_archiviazione', getDate('data_iniziopubblicazione').add(10, 'd')); 	
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
		}
		
		return moment(day+"-"+month+"-"+year, "DD-MM-YYYY");
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
			
			if (date){
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

	var onModifyData = function(){
		setEsecutivita(esecutivita.val());
	};

	$('.data').find('.day').on('change', function(){
		onModifyData();
	});
	$('.data').find('.month').on('change', function(){
		onModifyData();
	});
	$('.data').find('.year').on('change', function(){
		onModifyData();
	});

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
		tipo_archiviazione.val('riservato').trigger('change');
	}else if (isEmpty('data_finepubblicazione') && !isEmpty('data_archiviazione')){
		tipo_archiviazione.val('archiviato').trigger('change');
	}else{
		tipo_archiviazione.val('custom').trigger('change');
		openDateAttributeGroup();
	}

	if (isEmpty('data_finepubblicazione_trasparenza')){
		var anno_iniziopubblicazione = getDate('data_iniziopubblicazione').year();		
		setDate('data_finepubblicazione_trasparenza', moment("31-12-"+(anno_iniziopubblicazione+5), "DD-MM-YYYY")); 
	}

});