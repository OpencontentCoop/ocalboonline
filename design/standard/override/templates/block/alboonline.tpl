<div class="openpa-widget {$block.view} {if and(is_set($block.custom_attributes.color_style), $block.custom_attributes.color_style|ne(''))}color color-{$block.custom_attributes.color_style}{/if}">
	{if $block.name|ne('')}
        <h3 class="openpa-widget-title">{$block.name|wash()}</h3>
    {/if}
    <div class="openpa-widget-content">

	{def $fields = $block.custom_attributes.fields}
	{def $current_node = fetch(content, node, hash( node_id, $block.custom_attributes.node_id))}	
	{if and($fields, $current_node)}

		{ezscript_require(array('jquery.dataTables.js', 'jquery.opendataDataTable.js', 'dataTables.bootstrap.js', 'dataTables.responsive.min.js', 'moment-with-locales.min.js', 'moment-timezone-with-data.js', 'alboonline_block.js'))}
	    {ezcss_require(array('dataTables.bootstrap.css','responsive.dataTables.min.css'))}

		{def $fieldsParts = $fields|explode( '|' )}
	    {def $index = 0
    	  	 $group_by = false()}

	  	{if $fieldsParts[0]|begins_with('group_by')}
	    	{set $index = 1}
	    	{def $groupParts = $fieldsParts[0]|explode(':')}
	    	{set $group_by = $groupParts[1]}
	    {/if}
	    
	    {def $class = api_class($fieldsParts[$index]|trim())}
	    {set $index = $index|inc()}
	    
	    {def $identifiers = $fieldsParts[$index]|explode( ',' )}
	    {set $index = $index|inc()}

	    {def $depth = cond( is_set($fieldsParts[$index]), $fieldsParts[$index], false() )}
	    
	    {def $currentLanguage = ezini('RegionalSettings','Locale')
	         $depth_query_part = ''}

		{if is_set($class.identifier)}
		    
		    {if is_numeric($depth)}
		      {set $depth_query_part = concat('raw[meta_depth_si] range [', $current_node.depth, ',', $current_node.depth|sum($depth), '] and ')}
		    {/if}
		    
		    {def $class_fields = array()
		         $identifierParts = array()}
		    {foreach $identifiers as $identifier}
		      {set $identifierParts = $identifier|explode('.')}
		      {foreach $class.fields as $field}
		        {if $identifierParts[0]|eq($field.identifier)}
		          {if and( $field.dataType|eq('ezmatrix'), is_set($identifierParts[1]) )}
		            {set $field = $field|merge(hash('matrix_column',$identifierParts[1]))}
		          {/if}
		          {set $class_fields = $class_fields|append($field)}
		        {/if}
		      {/foreach}
		    {/foreach}

	        {def $query = concat($depth_query_part, " classes [",$class.identifier,"] subtree [",$current_node.node_id,"]")}

	        {def $facet_buttons = array()}
	        {if $group_by}            
	            {def $facets_search = api_search(concat($query, ' limit 1 facets [', $group_by, '|alpha|100]'))}            
	            
	            {if is_set($facets_search.facets[0].data)}
	                {foreach $facets_search.facets[0].data as $key => $value}
	                    {if $group_by|ends_with('year____dt]')}
	                        {set $key = $key|explode('-01-01T00:00:00Z')|implode('')}
	                    {/if}
	                    {set $facet_buttons = $facet_buttons|append($key)}
	                {/foreach}
	                {if or($group_by|eq('anno'), $group_by|ends_with('dt]'))}
	                    {set $facet_buttons = $facet_buttons|reverse}
	                {/if}
	            {/if}
	        {/if}
		    
		    {run-once}
		    {literal}
		    <style>.dataTables_wrapper .pagination .disabled{display: none !important;}</style>
		    {/literal}
		    {/run-once}

		    <script type="text/javascript" language="javascript" class="init">
		    	moment.locale('it');
		    	$(document).ready(function () {ldelim}
		    		$('#container-{$block.id}').alboOnLine({ldelim}
					  "query": "{$query}",
					  "url": "{'opendata/api/datatable/search'|ezurl(no,full)}/",
					  "searching": {if and(is_set($block.custom_attributes.show_search),$block.custom_attributes.show_search|eq('1'))}true{else}false{/if},
					  "length": {if $block.custom_attributes.limit|ne('')}{$block.custom_attributes.limit}{else}10{/if},
					  "columns": [
			            {foreach $class_fields as $field}
			              {def $title = $field.name[$currentLanguage]}
			              {if is_set($field.matrix_column)}
			                {foreach $field['template']['format'][0][0] as $columnIdentifier => $columnName}
			                  {if $columnIdentifier|eq($field.matrix_column)}
			                    {set $title = concat( $title, $columnName|explode('string (')|implode(' (') )}
			                    {break}
			                  {/if}
			                {/foreach}
			              {/if}
			              {ldelim}
			                "data": "data.{$currentLanguage}.{$field.identifier}",
			                "name": '{$field.identifier}',
			                "title": '{$title|wash(javascript)}',
			                "searchable": {if and($field.isSearchable|eq(true()), $field.dataType|ne('ezmatrix'))}true{else}false{/if}, {*@todo ricercabilità per sottoelemento matrice*}
			                "orderable": {if and($field.isSearchable|eq(true()), $field.dataType|ne('ezmatrix'))}true{else}false{/if}
			              {rdelim}
			              {undef $title}
			              {delimiter},{/delimiter}
			            {/foreach}
			          ],
			          "columnDefs": [
			            {foreach $class_fields as $index => $field}
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
			                        return opendataDataTableRenderField( '{$field.dataType}', '{$field.template.type}', '{$currentLanguage}', data, type, row, meta {if $index|eq(0)},'/content/view/full/'+row.metadata.mainNodeId{/if});
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
		    	
		    	{def $albo_on_line_handler = object_handler($current_node).albo_on_line}
		    	<div class="state-navigation">
		    	{foreach $albo_on_line_handler.allowed_states as $index => $state}
					{if or(
					  $albo_on_line_handler.anonymous_allowed_state_identifiers|contains($state.identifier),
					  and($albo_on_line_handler.anonymous_allowed_state_identifiers|contains($state.identifier)|not, $current_node.object.can_edit)
					)}					
						<a href="#" class="button{if $index|eq(0)} defaultbutton{/if}" data-field="state" data-operator="in" data-value='["{$state.id}"]'>{$state.current_translation.name|wash()}</a>										
					{/if}
				{/foreach}
	            </div>
	            {undef $albo_on_line_handler}

	            {if count($facet_buttons)|gt(0)}
	            <div class="state-navigation" style="font-size: .875em;">
	            {foreach $facet_buttons as $index => $facet_button}
	                <a class="button{if $index|eq(0)} defaultbutton{/if}" 
    				   {if $group_by|ends_with('year____dt]')}
    				   data-field="{$group_by}" data-operator="range" data-value='["{concat($facet_button,'-01-01T00:00:00Z')}","{concat($facet_button,'-12-31T23:59:00Z')}"]'
    				   {else}
    				   data-field="{$group_by}" data-operator="in" data-value='["{$facet_button}"]'
    				   {/if}
					   href="#">{$facet_button|wash()}</a>
	            {/foreach}
	            </div>
	            {/if}

	            <div class="table-container"></div>
	            
		    </div>

		    {undef $class_fields $identifierParts $query}

		{elseif fetch( 'user', 'has_access_to', hash( 'module', 'openpa', 'function', 'editor_tools' ) )}
			<div class="alert alert-warning message-warning warning">
				Classe {$fieldsParts[0]} non trovata
			</div>
		{/if}

		{undef $fields $current_node $fieldsParts $index $class $identifiers $depth $currentLanguage $depth_query_part}
	{/if}

    </div>
</div>