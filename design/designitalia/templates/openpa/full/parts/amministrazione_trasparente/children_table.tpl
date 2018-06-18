{* template per visualizzazione tabellare per i figli di pagina_trasparenza
   le variabili attese sono:
   - nodes: array di ezcontentobjectrenode
   - nodes_count: intero conteggio totale (in caso di fetch con parametro limit)
   - class: stringa o array classi da visualizzare
*}

{if count( $nodes )}
    
    {if $class|is_array()}
        
        {* tabella generica di oggetti di classi di vario tipo *}
        <div class="table-responsive">
            <table class="table table-striped">
                <caption>Elenco di {$node.name|wash()}</caption>
                <thead>
                    <tr>
                        <th>Link al dettaglio</th>
                        <th>Data di pubblicazione</th>
                    </tr>
                </thead>
                <tbody>
                    {foreach $nodes as $item}
                    <tr>
                        {def $item_url_alias = cond($item.class_identifier|eq('folder'), $item.url_alias, $item.object.main_node.url_alias)}
                        <td><a href={$item_url_alias|ezurl()} title="Vai al dettaglio di {$item.name|wash()}">{$item.name|wash()}</a></td>
                        <td>{$item.object.published|l10n(date)} {if $item.object.modified|gt(sum($item.object.published,86400))}<br />
                            <span class="f_size_small">Ultima modifica: <strong>{$item.object.modified|l10n(date)}</strong>{/if}</span></td>
                        {undef $item_url_alias}
                    </tr>
                    {/foreach}            
                </tbody>
            </table>
        </div>
    
    {elseif $class|is_string()}
    
        {* tabelle orientate alle classi *}
        {switch match=$class}
            
            {* dipendente *}
            {case match='dipendente'}
            <div class="table-responsive">
                <table class="table table-striped">
                    <caption>Elenco di {$node.name|wash()}</caption>
                    <thead>
                        <tr>
                            <th>Nominativo</th>
                            <th>Qualifica</th>
                            <th>Data di pubblicazione</th>                         
                        </tr>
                    </thead>
                    <tbody>
                        {foreach $nodes as $item}
                        <tr>
                            <td><a href={$item.url_alias|ezurl()} title="Vai al dettaglio di {$item.name|wash()}">{$item.name|wash()}</a></td>
                            <td>
                                {def $roles = fetch( 'openpa', 'ruoli', hash( 'dipendente_object_id', $item.contentobject_id ) )}
                                {foreach $roles as $role}
                                    {$role.name|wash()}
                                    {delimiter}, {/delimiter}
                                {/foreach}
                                {undef $roles}
                            </td>
                            <td>{$item.object.published|l10n(date)} {if $item.object.modified|gt(sum($item.object.published,86400))}<br />
                                <span class="f_size_small ">Ultima modifica: <strong>{$item.object.modified|l10n(date)}</strong></span>{/if}</td>                           
                        </tr>
                        {/foreach}            
                    </tbody>
                </table>    
            </div>         
            {/case}
            
            {* generica mostra gli attributi principali *}
            {case}
            <div class="table-responsive">
                <table class="table table-striped">
                    <caption>Elenco di {$node.name|wash()}</caption>
                    <thead>
                        <tr>
                            <th>Link al dettaglio</th>
                            <th>Data di pubblicazione</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach $nodes as $item}
                        <tr>
                            {def $item_url_alias = cond($item.class_identifier|eq('folder'), $item.url_alias, $item.object.main_node.url_alias)}
                            <td><a href={$item_url_alias|ezurl()} title="Vai al dettaglio di {$item.name|wash()}">{$item.name|wash()}</a></td>
                            <td>{$item.object.published|l10n(date)} {if $item.object.modified|gt(sum($item.object.published,86400))}<br />
                                <span class="f_size_small ">Ultima modifica: <strong>{$item.object.modified|l10n(date)}</strong></span>{/if}</td>
                            {undef $item_url_alias}
                        </tr>
                        {/foreach}            
                    </tbody>
                </table> 
            </div>       
            {/case}
            
        {/switch}
    {/if}
    
{include name=navigator
         uri='design:navigator/google.tpl'
         page_uri=$node.url_alias
         item_count=$nodes_count
         view_parameters=$view_parameters
         item_limit=openpaini( 'GestioneFigli', 'limite_paginazione', 25 )}    

{/if}
