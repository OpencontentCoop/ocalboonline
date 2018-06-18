<h2 class="u-text-h3">Controllo alberatura trasparenza</h3>

<form id="LoadRemote">
	<div class="Form-field Form-field--withPlaceholder Grid u-background-white u-margin-bottom-l">
		<input type="text" 
			   id="RemoteUrl" 
			   class="Form-input Grid-cell u-sizeFill u-text-r-s u-color-black u-text-r-xs" 
			   required="" 
			   name="RemoteUrl" 
			   placeholder="Url del modello" 
			   value="https://vallarsa.upipa.opencontent.it">
		<input type="text" 
			   id="RemoteRootNode" 
			   class="Form-input Grid-cell u-sizeFill u-text-r-s u-color-black u-text-r-xs" 
			   required="" 
			   placeholder="Nodo radice del modello" 
			   name="RemoteRootNode" 
			   value="23830">
		<button type="submit" 
				value="cerca" 
				name="LoadRemoteButton" 
				class="Grid-cell u-sizeFit button" 
				title="Avvia">
			Controlla
		</button>
	</div>
</form>

<ul id="data"></ul>

{ezscript_require(array(	
	'jquery.opendataTools.js',
	'diff.js'	
))}

{literal}
<style type="text/css">
	#data ul {margin-left: 20px}	
	#data ul li:not(:last-child){border-bottom: 1px solid #ccc}
	#data li span {display: block;padding:10px}
	#data li span.check-danger{background: #f2dede; color: #a94442;}
	#data li span.check-warning{background: #fcf8e3; color: #8a6d3b;}
</style>
<script type="text/javascript">
	$(document).ready(function(){
		$('#LoadRemote').on('submit', function(e){
			e.preventDefault();

			$('#data').html('');

			var sortList = function(list){
			    list.children('li').sort(sort_li).appendTo(list);
				function sort_li(a, b) {
					return ($(b).data('position')) < ($(a).data('position')) ? 1 : -1;
				}
			    list.children('li').each(function(){
					$(this).children('ul').each(function(){
			    		sortList($(this));
		    		});		
			    });		    
			};

			var displayItem = function(container, name, remoteId, priority){
				var item = $('<li data-position="'+priority+'" data-remote="'+remoteId+'"><span>'+name+' <i class="fa fa-spinner fa-spin"></i> </span></li>');
				checkItem(item);
				container.append(item);

				return item;
			};

			var checkItem = function(item){
				var remoteId = item.data('remote');
				var params = $.param({
					remote: remoteUrl,
					id: remoteId
				});
				$.get('/alboonline/bussola/?remote-read', params, function(remote){
					$.get('/alboonline/bussola/?local-read&id='+remoteId, function(local){
						var isOk = true;
						var level;
						var error;
						if (local.error){
							isOk = false;
							error = 'Contenuto locale non presente';
							level = 'danger';
						}else{
							var difference = diff.getDiff(remote.data['ita-IT'], local.data['ita-IT']);
							if ($.isEmptyObject(difference) === false){
								isOk = false;
								error = 'Differenze negli attributi ' + Object.keys(difference).join(', ');								
								level = 'warning';
								console.log(remote.data['ita-IT'], local.data['ita-IT']);
							}
						}
						if (isOk){
							item.children('span').find('i').removeClass('fa-spinner fa-spin').addClass('fa-smile-o');
						}else{
							item.children('span').addClass('check-'+level).find('i').removeClass('fa-spinner fa-spin').addClass('fa-frown-o');
							item.children('span').append('<small>'+error+'</small>');
						}
					})
				});
			};

			var browse = function(index, container, node, limit, offset){
				var params = $.param({
					remote: remoteUrl,
					node: node,
					limit: limit || 100,
					offset: offset || 0
				});
				var priority = index || 0;		
				$.get('/alboonline/bussola/?remote-browse', params, function(response){
					if (response.error){
						alert(response.error);
					}else{
						var item = displayItem(container, response.name['ita-IT'], response.remoteId, priority);						
						if (response.children.length > 0){
							var childrenContainer = $('<ul></ul>');
							item.append(childrenContainer);
							$.each(response.children, function(index){
								if (this.classIdentifier == 'pagina_trasparenza'){
									browse(index, childrenContainer, this.nodeId);
								}
							});								
						}
					}					
				})
			};

			var remoteUrl = $('#RemoteUrl').val();
			var remoteRoot = $('#RemoteRootNode').val();

			browse(0, $('#data'), remoteRoot);
			sortList($('#data'))

		});
	});
</script>
{/literal}