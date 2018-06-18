{def $openpa_block = object_handler($block)}
<div class="openpa-widget {$block.view} 
			{if and(is_set($block.custom_attributes.color_style), $block.custom_attributes.color_style|ne(''))}color color-{$block.custom_attributes.color_style}{/if}">
	
	{if $block.name|ne('')}
        <h3 class="openpa-widget-title">{$block.name|wash()}</h3>
    {/if}
    <div class="openpa-widget-content">

		{if and(is_set($openpa_block.error), fetch( 'user', 'has_access_to', hash( 'module', 'openpa', 'function', 'editor_tools' ) ))}
			<div class="alert alert-warning message-warning warning">
				{$openpa_block.error|wash()}
			</div>
		{else}

			{ezscript_require(array(
				'jquery.dataTables.js', 
				'jquery.opendataTools.js',
				'jquery.opendataDataTable.js', 
				'dataTables.bootstrap.js', 
				'dataTables.responsive.min.js', 
				'moment-with-locales.min.js', 
				'moment-timezone-with-data.js', 
				'bootstrap/modal.js',
				'alboonline_block.js'
			))}
			{ezcss_require(array(
				'dataTables.bootstrap.css',
				'responsive.dataTables.min.css'
			))}
			{def $currentLanguage = ezini('RegionalSettings','Locale')}
			<script type="text/javascript" language="javascript" class="init">
		    	moment.locale('it');
		    	$(document).ready(function () {ldelim}
		    		$('#container-{$block.id}').alboOnLine({ldelim}
					  "query": "{$openpa_block.parameters.query}",
					  "group_facet_query_part": "{$openpa_block.parameters.group_facet_query_part}",
					  "url": "{concat('/openpa/data/albo_on_line/', $block.id)|ezurl(no,full)}/",
					  "searching": {if $openpa_block.parameters.searching}true{else}false{/if},
					  "length": {$openpa_block.parameters.length},
					  "openInPopup": {if $block.custom_attributes.open_in_popup}true{else}false{/if},
					  "columns": [
			            {foreach $openpa_block.parameters.columns as $column}			              
			              {ldelim}
			                "data": "{$column.data}",
			                "name": '{$column.name}',
			                "title": '{$column.title|wash(javascript)}',
			                "searchable": {if $column.searchable}true{else}false{/if},
			                "orderable": {if $column.orderable}true{else}false{/if}
			              {rdelim}			              
			              {delimiter},{/delimiter}
			            {/foreach}
			          ],
			          "columnDefs": [
			            {foreach $openpa_block.parameters.fields as $index => $field}
			              {ldelim}
			                "render": function ( data, type, row, meta ) {ldelim}
			                  if (data) {ldelim}
			                      {if is_set($field.matrix_column)}
			                        var result = [];
			                        $.each(data, function () {ldelim}
			                            var row = this;                            
			                            $.each(row, function (index, value) {ldelim}
			                              if (index == '{$field.matrix_column}') {ldelim}
			                                result.push(value);
			                              {rdelim}
			                            {rdelim});                                                    
			                        {rdelim});
			                        return result.join('<br />');
			                      {else}
			                        var link = {if and($block.custom_attributes.show_link, $index|eq(0))}'/content/view/full/'+row.metadata.mainNodeId{else} false{/if};
			                        if (!row.metadata.can_read && link){ldelim}
			                        	link = false;
			                        {rdelim}
			                        var prefix = '';
			                        var suffix = '';
			                        if (link){ldelim}
			                        	prefix = '<div class="alboonline-link">';
			                        	suffix = '</div>';
		                        	{rdelim}
			                        return prefix+opendataDataTableRenderField( 
			                        	'{$field.dataType}', 
			                        	'{$field.template.type}', 
			                        	'{$currentLanguage}', data, type, row, meta, link
		                        	)+suffix;		                        	
			                      {/if}
			                  {rdelim}
			                  return '';
			                {rdelim},
			                "targets": [{$index}]
			              {rdelim}
			              {delimiter},{/delimiter}
			            {/foreach}
			          ]
		    		{rdelim});
	    		{rdelim});
		    </script>
			
			<div id="container-{$block.id}">
		    	
		    	{if count($openpa_block.parameters.state_facets)|gt(0)}
		    	<div class="facet-navigation">
		    	{foreach $openpa_block.parameters.state_facets as $index => $facet_button}
					<a class="button{if $index|eq(0)} defaultbutton{/if}" 
    				   data-field="{$facet_button.field}" 
    				   data-operator="{$facet_button.operator}" 
    				   data-value='{$facet_button.value}'    				   
					   href="#">
						{$facet_button.name|wash()}
					</a>
				{/foreach}
	            </div>
	            {/if}

	            {if count($openpa_block.parameters.group_facets)|gt(0)}
	            <div class="facet-navigation group-facets" style="font-size: .875em;margin-top: 5px">
	            {foreach $openpa_block.parameters.group_facets as $index => $facet_button}
	                {def $show = true()}
	                {if count($openpa_block.parameters.initial_group_facets)|gt(0)}
	                	{set $show = false()}
	                	{foreach $openpa_block.parameters.initial_group_facets as $initial}
	                		{if $initial.name|eq($facet_button.name)}
	                			{set $show = true()}
	                		{/if}
	                	{/foreach}
	                {/if}
	                <a class="button{if $index|eq(0)} defaultbutton{/if}" 
    				   {if $show|not()}style="display:none"{/if}
    				   data-field="{$facet_button.field}" 
    				   data-operator="{$facet_button.operator}" 
    				   data-value='{$facet_button.value}'    				   
					   href="#">
						{$facet_button.name|wash()}
					</a>
					{undef $show}
	            {/foreach}
	            </div>
	            {/if}

	            <div class="table-container"></div>
	            
		    </div>

		{/if}		

    </div>
</div>

{run-once}{literal}
<style>
.dataTables_wrapper .pagination .disabled{display: none !important;}
#albboonline-preview .content-container .extra, #albboonline-preview .Button, #albboonline-preview #editor_tools{display: none !important;}
#albboonline-preview .content-container .withExtra{width: 100% !important;}
[role="button"] {cursor: pointer;}
.modal-open {overflow: hidden;}
.modal {display: none;overflow: hidden;position: fixed;top: 0;right: 0;bottom: 0;left: 0;z-index: 1050;-webkit-overflow-scrolling: touch;outline: 0;}
.modal.fade .modal-dialog {-webkit-transform: translate(0, -25%);-ms-transform: translate(0, -25%);-o-transform: translate(0, -25%);transform: translate(0, -25%);-webkit-transition: -webkit-transform 0.3s ease-out;-o-transition: -o-transform 0.3s ease-out;transition: transform 0.3s ease-out;}
.modal.in .modal-dialog {-webkit-transform: translate(0, 0);-ms-transform: translate(0, 0);-o-transform: translate(0, 0);transform: translate(0, 0);}
.modal-open .modal { overflow-x: hidden;overflow-y: auto;}
.modal-dialog {position: relative;width: auto;margin: 10px;background-color: #ffffff;padding:10px;}
.modal-content {position: relative;      outline: 0;  }
.modal-backdrop {position: fixed;top: 0;right: 0;bottom: 0;left: 0;z-index: 1040;background-color: #000000;}
.modal-backdrop.fade {opacity: 0;filter: alpha(opacity=0);}
.modal-backdrop.in {opacity: 0.5;filter: alpha(opacity=50);}
.modal-header {padding: 0 15px;  min-height: 16.42857143px;  }
.modal-title {margin: 0;line-height: 1.42857143;}
.modal-body {position: relative;padding: 15px;}
.modal-scrollbar-measure {position: absolute;top: -9999px;width: 50px;height: 50px;overflow: scroll;}
.close {float: right;font-size: 35px;font-weight: bold;line-height: 1;color: #000;text-shadow: 0 1px 0 #fff;filter: alpha(opacity=20);opacity: .2;}
button.close {-webkit-appearance: none;padding: 0;cursor: pointer;background: transparent;border: 0;}
.close:hover, .close:focus {color: #000;text-decoration: none;cursor: pointer;filter: alpha(opacity=50);opacity: .5;}
@media (min-width: 768px) {.modal-dialog {width: 600px;margin: 30px auto;}  .modal-sm {width: 300px;}}
@media (min-width: 992px) {.modal-lg {width: 900px;}}
</style>
{/literal}
<div id="albboonline-preview" class="modal fade" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-header">
	        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>	        
	    </div>
        <div class="modal-content"></div>
    </div>
</div>
{/run-once}
