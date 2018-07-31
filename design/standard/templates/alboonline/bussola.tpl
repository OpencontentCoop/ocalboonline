<h2 class="u-text-h3">Controllo alberatura trasparenza</h3>

{def $root_list = fetch(content, tree, hash('parent_node_id', 1, 
											'class_filter_type', 'include', 
											'class_filter_array', array('trasparenza'),
											'sort_by', array(priority, true())
											))}

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

<h4 class="progress">Controllate <span class="count">0</span> pagine di <span class="total">0</span></h4>

<ul class="errors" style="margin-bottom: 20px"></ul>

<table style="margin-bottom: 20px">
{foreach $root_list as $root}	
		<!--<tr>
			<td></td>
			<td>{$root.name|wash()}</td>
			<td class="detail"></td>
		</tr>-->
		{def $children = fetch(content, list, hash('parent_node_id', $root.node_id, 'class_filter_type', 'include', 'class_filter_array', array('pagina_trasparenza'), 'sort_by', $root.sort_array, 'ignore_visibility', true() ))}
		{foreach $children as $child}
			<tr class="check-warning" data-remote_id="{$child.object.remote_id}">
				<td><i class="fa fa-question"></i></td>
				<td style="padding-left: 20px">
					<a href="{$child.url_alias|ezurl(no)}" target="_blank">
						{$child.name|wash()} {if or($child.is_hidden, $child.is_is_invisible)}<strong>Nascosto</strong>{/if}
					</a>
				</td>
				<td class="detail"></td>
			</tr>
			{def $children1 = fetch(content, list, hash('parent_node_id', $child.node_id, 'class_filter_type', 'include', 'class_filter_array', array('pagina_trasparenza'), 'sort_by', $child.sort_array, 'ignore_visibility', true() ))}
			{foreach $children1 as $child1}
				<tr class="check-warning" data-remote_id="{$child1.object.remote_id}">					
					<td><i class="fa fa-question"></i></td>
					<td style="padding-left: 40px">						
						<a href="{$child1.url_alias|ezurl(no)}" target="_blank">
							{$child1.name|wash()} {if or($child1.is_hidden, $child1.is_is_invisible)}<strong>Nascosto</strong>{/if}
						</a>
					</td>
					<td class="detail"></td>
				</tr>
				{def $children2 = fetch(content, list, hash('parent_node_id', $child1.node_id, 'class_filter_type', 'include', 'class_filter_array', array('pagina_trasparenza'), 'sort_by', $child1.sort_array, 'ignore_visibility', true() ))}
				{foreach $children2 as $child2}
					<tr class="check-warning" data-remote_id="{$child2.object.remote_id}">						
						<td><i class="fa fa-question"></i></td>
						<td style="padding-left: 60px">							
							<a href="{$child2.url_alias|ezurl(no)}" target="_blank">
								{$child2.name|wash()} {if or($child2.is_hidden, $child2.is_is_invisible)}<strong>Nascosto</strong>{/if}
							</a>
						</td>
						<td class="detail"></td>
					</tr>
					{def $children3 = fetch(content, list, hash('parent_node_id', $child2.node_id, 'class_filter_type', 'include', 'class_filter_array', array('pagina_trasparenza'), 'sort_by', $child2.sort_array, 'ignore_visibility', true() ))}
					{foreach $children3 as $child3}
						<tr class="check-warning" data-remote_id="{$child3.object.remote_id}">						
							<td><i class="fa fa-question"></i></td>
							<td style="padding-left: 80px">								
								<a href="{$child3.url_alias|ezurl(no)}" target="_blank">
									{$child3.name|wash()} {if or($child3.is_hidden, $child3.is_is_invisible)}<strong>Nascosto</strong>{/if}
								</a>
							</td>
							<td class="detail"></td>
						</tr>
					{/foreach}
					{undef $children3}
				{/foreach}
				{undef $children2}
			{/foreach}
			{undef $children1}
		{/foreach}
		{undef $children}
{/foreach}
</table>

{ezscript_require(array(	
	'jquery.opendataTools.js',
	'diff.js'	
))}

{literal}
<style type="text/css">	
	.check-danger{background: #f2dede; color: #a94442;}
	.check-warning{background: #fcf8e3; color: #8a6d3b;}
	.detail{font-size: .8em}
</style>
<script type="text/javascript">
	$(document).ready(function(){
		$('#LoadRemote').on('submit', function(e){
			e.preventDefault();
			$('.errors').html('');			

			var remotes = [];

			var showItem = function(browseItem){
				if (browseItem.classIdentifier == 'pagina_trasparenza'){					
					if ($.inArray(browseItem.remoteId, remotes) > -1){
						$('.errors').append('<li class="check-danger" style="padding:10px">La pagina <a href="'+remoteUrl+'/content/view/full/'+browseItem.nodeId+'" target="_blank">' + browseItem.name['ita-IT'] + '</a> è ripetuta (due collocazioni?)</li>');
					}else{
						remotes.push(browseItem.remoteId);
					}
					var row = $('[data-remote_id="'+browseItem.remoteId+'"]');					
					if (row.length == 0){
						$('.errors').append('<li class="check-danger" style="padding:10px">Pagina <a href="'+remoteUrl+'/content/view/full/'+browseItem.nodeId+'" target="_blank">' + browseItem.name['ita-IT'] + '</a> non trovata</li>');
					}else{
						row.removeClass('check-warning');					
						row.find('i').removeClass('fa-question').addClass('fa-spinner fa-spin');
						checkItem(browseItem.remoteId, row);						
					}			
				}
			};

			var checkItem = function(remoteId, row){				
				var count = parseInt($('.progress .count').html());
				count = count + 1;
				$('.progress .count').html(count);
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
							}
						}
						row.find('i').removeClass('fa-spinner fa-spin');
						if (isOk){
							row.find('i').addClass('fa-smile-o');
						}else{
							row.find('i').addClass('fa-frown-o');
							row.find('td.detail').html(error);
						}
					})
				});
			};

			var browse = function(node, limit, offset){
				var params = $.param({
					remote: remoteUrl,
					node: node,
					limit: limit || 100,
					offset: offset || 0
				});				
				$.get('/alboonline/bussola/?remote-browse', params, function(response){
					if (response.error){
						alert(response.error);
					}else{
						showItem(response);
						if (response.children.length > 0){														
							$.each(response.children, function(){
								if (this.classIdentifier == 'pagina_trasparenza'){
									browse(this.nodeId);
								}
							});								
						}
					}					
				})
			};

			var remoteUrl = $('#RemoteUrl').val();
			var remoteRoot = $('#RemoteRootNode').val();
			var totalCount = 0;

			$.get('/alboonline/bussola/?remote-count', $.param({
				remote: remoteUrl,
				subtree: remoteRoot,				
			}), function(response){
				totalCount = response.totalCount;
				$('.progress .total').html(totalCount);
				browse(remoteRoot);		
			});

		});
	});
</script>
{/literal}