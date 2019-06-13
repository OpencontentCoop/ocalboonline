{if is_set($fields.error)}	
	
	<div class="alert alert-warning message-warning warning">{$fields.error|wash()}</div>

{else}
	
	{def $currentLanguage = ezini('RegionalSettings','Locale')}

    {if count($fields.facets)|gt(0)}
    <div class="state-navigation" data-group="{$fields.group_by}">
    {foreach $fields.facets as $index => $facet_button}
        <a href="#" class="button{if $index|eq(0)} defaultbutton{/if}">{$facet_button|wash()}</a>
    {/foreach}
    </div>
    {/if}
  
    {ezscript_require(array('jquery.dataTables.js', 'jquery.opendataDataTable.js', 'dataTables.bootstrap.js', 'dataTables.responsive.min.js', 'moment-with-locales.min.js', 'moment-timezone-with-data.js'))}
    {ezcss_require(array('dataTables.bootstrap.css','responsive.dataTables.min.css'))}
    
    <script type="text/javascript" language="javascript" class="init">
    moment.locale('it');
    $(document).ready(function () {ldelim}

      var fieldsDatatable = $('#container-{$node.node_id}-{$table_index}').opendataDataTable({ldelim}
        "builder":{ldelim}"query": '{$fields.query}'{rdelim},
        "table":{ldelim}
          "id": 'trasparenza-{$node.node_id}',
          "template": '<table class="table table-striped table-bordered display responsive no-wrap" cellspacing="0" width="100%"></table>'
        {rdelim},
        "datatable":{ldelim}          
          "responsive": true,
          "language":{ldelim}
              "decimal":        "",
              "emptyTable":     "Nessun dato presente nella tabella",
              "info":           "Vista da _START_ a _END_ di _TOTAL_ elementi",
              "infoEmpty":      "Zero elementi",
              "infoFiltered":   "(filtrati da _MAX_ elementi totali)",
              "infoPostFix":    "",
              "thousands":      ",",
              "lengthMenu":     "Visualizza _MENU_ elementi",
              "loadingRecords": "Caricamento...",
              "processing":     "Elaborazione...",
              "search":         "Cerca:",
              "zeroRecords":    "La ricerca non ha portato alcun risultato",
              "paginate": {ldelim}
                  "first":      "Inizio",
                  "last":       "Fine",
                  "next":       "Successivo",
                  "previous":   "Precedente"
              {rdelim},
              "aria": {ldelim}
                  "sortAscending":  ": attiva per ordinare la colonna in ordine crescente",
                  "sortDescending": ": attiva per ordinare la colonna in ordine decrescente"
              {rdelim}
          {rdelim},
          "ajax": {ldelim}url: "{'opendata/api/datatable/search'|ezurl(no,full)}/"{rdelim},
          "lengthMenu": [ 30, 60, 90, 120 ],
          "columns": [
            {foreach $fields.class_fields as $field}
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
            {foreach $fields.class_fields as $index => $field}
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
        {rdelim}
      {rdelim}).data('opendataDataTable');
      
      {if count($fields.facets)|gt(0)}
      var currentFilterName = $('.state-navigation').data('group');
      var setCurrentFilter = function(){ldelim}
          var currentFilterValue = $('.state-navigation .defaultbutton').text();
          fieldsDatatable.settings.builder.filters[currentFilterName] = {ldelim}
            'field': currentFilterName,
            {if $fields.group_by|ends_with('year____dt]')}
            'operator': 'range',
            'value': [currentFilterValue+'-01-01T00:00:00Z',currentFilterValue+'-12-31T00:00:00Z']
            {else}
            'operator': 'in',
            'value': [currentFilterValue]
            {/if}
          {rdelim};
      {rdelim};          
      setCurrentFilter();

      $('.state-navigation .defaultbutton').on('click', function(e){ldelim}
        e.preventDefault();
      {rdelim});

      $('.state-navigation .button').on('click', function(e){ldelim}
        $('.state-navigation .defaultbutton').removeClass('defaultbutton');
        $(this).addClass('defaultbutton');
        setCurrentFilter();
        fieldsDatatable.loadDataTable();
        e.preventDefault();
      {rdelim});
      
      {/if}

      fieldsDatatable.loadDataTable();
    {rdelim});
    </script>
    
    <div id="container-{$node.node_id}-{$table_index}"></div>

{/if}