{def $remotes_id_list = hash(
    'rappresentazione_grafica',             '5a2189cac55adf79ddfee35336e796fa',
    'consulenti_e_collaboratori',           'b5df51b035ee30375db371af76c3d9fb',
    'incarichi_amminsitrativi_di_vertice',  'efc995388bebdd304f19eef17aab7e0d',
    'dirigenti',                            '9eed77856255692eca75cdb849540c23',
    'tassi_di_assenza',                     'c46fafba5730589c0b34a5fada7f3d07',
    'incarichi_conferiti',                  'b7286a151f027977fa080f78817c895a',
    'atti_di_concessione',                  '90b631e882ab0f966d03aababf3d9f15'
)}

{if $openpa.control_cache.no_cache}
    {set-block scope=root variable=cache_ttl}0{/set-block}
{/if}

{if $openpa.content_tools.editor_tools}
    {include uri=$openpa.content_tools.template}
{/if}

{def $tree_menu = tree_menu( hash( 'root_node_id', $openpa.control_menu.side_menu.root_node.node_id, 'user_hash', $openpa.control_menu.side_menu.user_hash, 'scope', 'side_menu' ))
     $show_left = and( $openpa.control_menu.show_side_menu, count( $tree_menu.children )|gt(0) )}

{def $classi_trasparenza = array( 'pagina_trasparenza' )
     $classi_note_trasparenza = array( 'nota_trasparenza' )

     $nota = fetch( 'content', 'list', hash( 'parent_node_id', $node.node_id,
                                             'class_filter_type', 'include',
                                             'class_filter_array', $classi_note_trasparenza,
                                             'sort_by', array( 'published', false() ),
                                             'limit', 1 ) )

     $conteggio_figli = fetch( 'content', 'list_count', hash( 'parent_node_id', $node.object.main_node_id,
                                                              'sort_by', $node.sort_array,
                                                              'class_filter_type', 'exclude',
                                                              'class_filter_array', $classi_trasparenza|merge( $classi_note_trasparenza ) ) )

     $conteggio_figli_folder = fetch( 'content', 'list_count', hash( 'parent_node_id', $node.object.main_node_id,
                                                                     'sort_by', $node.sort_array,
                                                                     'class_filter_type', 'include',
                                                                     'class_filter_array', array('folder') ) )



     $conteggio_figli_pagina_trasparenza = fetch( 'content', 'list_count', hash( 'parent_node_id', $node.node_id,
                                                                                 'sort_by', $node.sort_array,
                                                                                 'class_filter_type', 'include',
                                                                                 'class_filter_array', $classi_trasparenza ) )}


<div class="openpa-full class-{$node.class_identifier}">
    <div class="title">
        {include uri='design:openpa/full/parts/node_languages.tpl'}
        <h2>{$node.name|wash()}</h2>
    </div>
    <div class="content-container">
        <div class="content{if or( $show_left, $openpa.control_menu.show_extra_menu )} withExtra{/if}">

            {* Guida al cittadino *}
            {include name = guida_al_cittadino
                     node = $node
                     uri = 'design:openpa/full/parts/amministrazione_trasparente/guida_al_cittadino.tpl'}

            {* Guida al redattore *}
            {include name = guida_al_cittadino
                     node = $node
                     uri = 'design:openpa/full/parts/amministrazione_trasparente/guida_al_redattore.tpl'}


            {* Nota: visualizzazione e modifica/creazione di una sola nota *}
            {if $nota|count()|gt(0)}
                <div class="Callout Callout--could u-text-r-xs u-margin-top-m u-margin-bottom-m">
                    <p class="u-color-grey-90 u-text-p">
                        <em>{attribute_view_gui attribute=$nota[0].data_map.testo_nota}</em>
                        {include uri="design:parts/toolbar/node_edit.tpl" current_node=$nota[0]}
                        {include uri="design:parts/toolbar/node_trash.tpl" current_node=$nota[0]}
                    </p>
                </div>
            {elseif $node.object.can_create}
                <div class="Callout Callout--could u-text-r-xs u-margin-top-m u-margin-bottom-m">
                <form method="post" action="{'content/action'|ezurl(no)}">
                    <input type="hidden" name="ContentLanguageCode" value="{ezini( 'RegionalSettings', 'ContentObjectLocale', 'site.ini')}" />
                    <input type="hidden" name="HasMainAssignment" value="1" />
                    <input type="hidden" name="ClassIdentifier" value="nota_trasparenza" />
                    <input type="hidden" name="ContentObjectID" value="{$node.contentobject_id}" />
                    <input type="hidden" name="NodeID" value="{$node.node_id}" />
                    <input type="hidden" name="ContentNodeID" value="{$node.node_id}" />
                    <input class="btn btn-primary" type="submit" name="NewButton" value="Aggiungi nota" />
                </form>
                </div>
            {/if}

            {* Rappresentazione grafica (esclusa dal conteggio figli) *}
            {if $node.object.remote_id|eq($remotes_id_list.rappresentazione_grafica)} 
                {include uri='design:openpa/full/parts/amministrazione_trasparente/grafico_enti_partecipati.tpl'}
            {/if}
            
            <div class="u-margin-top-m u-margin-bottom-m">

                {* Figli di classe pagina_trasaparenza *}
                {if $conteggio_figli_pagina_trasparenza|gt(0)}
                    {def $figli_pagina_trasparenza = fetch( 'content', 'list', hash( 'parent_node_id', $node.node_id,
                                                                                     'sort_by', $node.sort_array,
                                                                                     'offset', $view_parameters.offset,
                                                                                     'limit', openpaini( 'GestioneFigli', 'limite_paginazione', 25 ),
                                                                                     'class_filter_type', 'include',
                                                                                     'class_filter_array', $classi_trasparenza ) )}
                    {include uri='design:openpa/full/parts/amministrazione_trasparente/children.tpl'
                             nodes=$figli_pagina_trasparenza
                             nodes_count=$conteggio_figli_pagina_trasparenza}

                    {if or($conteggio_figli|gt(0), $node|has_attribute('fields'), $node|has_attribute('fields_blocks'))}<hr />{/if}

                {/if}

                {* Altri figli nelle varie visualizzazioni *}
                {if or($conteggio_figli|gt(0), $node|has_attribute('fields'), $node|has_attribute('fields_blocks'))}

                    {* layout a blocchi *}
                    {if $node|has_attribute('fields_blocks')}

                        {attribute_view_gui attribute=$node|attribute('fields_blocks')}

                        {if $conteggio_figli_folder|gt(0)}

                            {def $figli_folder = fetch( 'content', 'list', hash( 'parent_node_id', $node.object.main_node_id,
                                                                                 'sort_by', $node.sort_array,
                                                                                 'offset', $view_parameters.offset,
                                                                                 'limit', openpaini( 'GestioneFigli', 'limite_paginazione', 25 ),
                                                                                 'class_filter_type', 'include',
                                                                                 'class_filter_array', array('folder') ) )}

                            {include uri='design:openpa/full/parts/amministrazione_trasparente/children.tpl'
                                     nodes=$figli_folder
                                     nodes_count=$conteggio_figli_folder}
                        {/if}


                    {* figli in base a sintassi convenzionale sul campo fields *}
                    {elseif $node|has_attribute('fields')}

                        {include uri='design:openpa/full/parts/amministrazione_trasparente/children_table_fields.tpl'                                 
                                 nodes_count=$conteggio_figli
                                 fields=$node.data_map.fields.content}

                        {if $conteggio_figli_folder|gt(0)}

                            {def $figli_folder = fetch( 'content', 'list', hash( 'parent_node_id', $node.object.main_node_id,
                                                                                 'sort_by', $node.sort_array,
                                                                                 'offset', $view_parameters.offset,
                                                                                 'limit', openpaini( 'GestioneFigli', 'limite_paginazione', 25 ),
                                                                                 'class_filter_type', 'include',
                                                                                 'class_filter_array', array('folder') ) )}

                            {include uri='design:openpa/full/parts/amministrazione_trasparente/children.tpl'
                                     nodes=$figli_folder
                                     nodes_count=$conteggio_figli_folder}
                        {/if}


                    {* lista dei figli *}
                    {else}

                        {def $figli = fetch( 'content', 'list', hash( 'parent_node_id', $node.object.main_node_id,
                                                                      'sort_by', $node.sort_array,
                                                                      'offset', $view_parameters.offset,
                                                                      'limit', openpaini( 'GestioneFigli', 'limite_paginazione', 25 ),
                                                                      'class_filter_type', 'exclude',
                                                                      'class_filter_array', $classi_trasparenza|merge( $classi_note_trasparenza ) ) )}

                        {* In base al remoteid vengono caricate le visualizzazioni tabellari o normali *}
                        {switch match=$node.object.remote_id}

                            {* Consulenti e collaboratori *}
                            {case match=$remotes_id_list.consulenti_e_collaboratori}
                                {include uri='design:openpa/full/parts/amministrazione_trasparente/children_table.tpl'
                                         nodes=$figli
                                         nodes_count=$conteggio_figli
                                         class='consulenza'}
                            {/case}

                            {* Incarichi amminsitrativi di vertice *}
                            {case match=$remotes_id_list.incarichi_amminsitrativi_di_vertice}
                                {include uri='design:openpa/full/parts/amministrazione_trasparente/children_table.tpl'
                                         nodes=$figli
                                         nodes_count=$conteggio_figli
                                         class='dipendente'}
                            {/case}

                            {* Dirigenti *}
                            {case match=$remotes_id_list.dirigenti}
                                {include uri='design:openpa/full/parts/amministrazione_trasparente/children_table.tpl'
                                         nodes=$figli
                                         nodes_count=$conteggio_figli
                                         class='dipendente'}
                            {/case}

                            {* Tassi di assenza *}
                            {case match=$remotes_id_list.tassi_di_assenza}
                                {include uri='design:openpa/full/parts/amministrazione_trasparente/children_table.tpl'
                                         nodes=$figli
                                         nodes_count=$conteggio_figli
                                         class='tasso_assenza'}
                            {/case}

                            {* Incarichi conferiti e autorizzati ai dipendenti *}
                            {case match=$remotes_id_list.incarichi_conferiti}
                                {include uri='design:openpa/full/parts/amministrazione_trasparente/children_table.tpl'
                                nodes=$figli
                                nodes_count=$conteggio_figli
                                class='incarico'}
                            {/case}

                            {* Atti di concessione *}
                            {case match=$remotes_id_list.atti_di_concessione}
                                {include uri='design:openpa/full/parts/amministrazione_trasparente/children_table.tpl'
                                         nodes=$figli
                                         nodes_count=$conteggio_figli
                                         class=array( 'sovvenzione_contributo', 'determinazione', 'deliberazione' )}
                            {/case}

                            {* visualizzazione figli default *}
                            {case}
                                {include uri='design:openpa/full/parts/amministrazione_trasparente/children.tpl'
                                         nodes=$figli
                                         nodes_count=$conteggio_figli}
                            {/case}
                        {/switch}

                    {/if}
                {/if}

                
                {* logica per esporre alert *}
                {if and( 
                    $conteggio_figli_pagina_trasparenza|eq(0),
                    $conteggio_figli|eq(0),
                    count($nota)|eq(0),
                    $node|has_attribute('fields_blocks')|eq(false()),
                    $node.object.remote_id|ne($remotes_id_list.rappresentazione_grafica),
                    openpaini('Trasparenza', 'MostraAvvisoPaginaVuota', 'disabled')|eq('enabled')
                )}                    
                    <div class="alert alert-warning">
                        <p>Sezione in allestimento</p>
                    </div>
                {/if}

            </div>

        </div>

        {include uri='design:openpa/full/parts/section_left.tpl'}
    </div>
    {if $openpa.content_date.show_date}
        {include uri=$openpa.content_date.template}
    {/if}
</div>
