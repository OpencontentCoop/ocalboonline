{if $openpa.control_cache.no_cache}
    {set-block scope=root variable=cache_ttl}0{/set-block}
{/if}

{if $openpa.content_tools.editor_tools}
    {include uri=$openpa.content_tools.template}
{/if}

{def $tree_menu = tree_menu( hash( 'root_node_id', $openpa.control_menu.side_menu.root_node.node_id, 'user_hash', $openpa.control_menu.side_menu.user_hash, 'scope', 'side_menu' ))
     $show_left = and( $openpa.control_menu.show_side_menu, count( $tree_menu.children )|gt(0) )}

{def $trasparenza = $openpa.trasparenza}

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
            {if $trasparenza.has_nota_trasparenza}
                <div class="Callout Callout--could u-text-r-xs u-margin-top-m u-margin-bottom-m">
                    <p class="u-color-grey-90 u-text-p">
                        <em>{attribute_view_gui attribute=$trasparenza.nota_trasparenza.data_map.testo_nota}</em>
                        {include uri="design:parts/toolbar/node_edit.tpl" current_node=$trasparenza.nota_trasparenza}
                        {include uri="design:parts/toolbar/node_trash.tpl" current_node=$trasparenza.nota_trasparenza}
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
            {if and(is_set($trasparenza.remote_id_map[$node.object.remote_id]), 'rappresentazione_grafica'|eq($trasparenza.remote_id_map[$node.object.remote_id]))} 
                {include uri='design:openpa/full/parts/amministrazione_trasparente/grafico_enti_partecipati.tpl'}
            {/if}
            
            <div class="u-margin-top-m u-margin-bottom-m">

                {* Figli di classe pagina_trasaparenza *}
                {if $trasparenza.count_children_trasparenza|gt(0)}
                    
                    {include uri='design:openpa/full/parts/amministrazione_trasparente/children.tpl'
                             nodes = fetch( 'content', 'list', $trasparenza.children_trasparenza_fetch_parameters )
                             nodes_count = $trasparenza.count_children_trasparenza}

                    {if or($trasparenza.count_children|gt(0), $trasparenza.has_table_fields, $trasparenza.has_blocks)}<hr />{/if}

                {/if}

                {* Altri figli nelle varie visualizzazioni *}
                {if or($trasparenza.count_children|gt(0), $trasparenza.has_table_fields, $trasparenza.has_blocks)}

                    {* layout a blocchi *}
                    {if $trasparenza.has_blocks}

                        {attribute_view_gui attribute=$trasparenza.blocks_attribute}

                        {if $trasparenza.count_children_folder|gt(0)}

                            {include uri='design:openpa/full/parts/amministrazione_trasparente/children.tpl'
                                     nodes = fetch( 'content', 'list', $trasparenza.children_folder_fetch_parameters )
                                     nodes_count = $trasparenza.count_children_folder}
                        {/if}


                    {* figli in base a sintassi convenzionale sul campo fields *}
                    {elseif $trasparenza.has_table_fields}

                        {include uri='design:openpa/full/parts/amministrazione_trasparente/children_table_fields.tpl'                                 
                                 nodes_count = $trasparenza.count_children
                                 fields = $trasparenza.table_fields}

                        {if $trasparenza.count_children_folder|gt(0)}

                            {include uri='design:openpa/full/parts/amministrazione_trasparente/children.tpl'
                                     nodes = fetch( 'content', 'list', $trasparenza.children_folder_fetch_parameters )
                                     nodes_count = $trasparenza.count_children_folder}
                        {/if}


                    {* lista dei figli *}
                    {else}

                        {def $figli = fetch( 'content', 'list', $trasparenza.children_fetch_parameters )}

                        {switch match=$trasparenza.remote_id_map[$node.object.remote_id]}

                            {case match=consulenti_e_collaboratori}                            
                                {include uri='design:openpa/full/parts/amministrazione_trasparente/children_table.tpl'
                                         nodes=$figli
                                         nodes_count=$trasparenza.count_children
                                         class='consulenza'}
                            {/case}

                            {case match=incarichi_amminsitrativi_di_vertice}
                                {include uri='design:openpa/full/parts/amministrazione_trasparente/children_table.tpl'
                                         nodes=$figli
                                         nodes_count=$trasparenza.count_children
                                         class='dipendente'}
                            {/case}

                            {case match=dirigenti}
                                {include uri='design:openpa/full/parts/amministrazione_trasparente/children_table.tpl'
                                         nodes=$figli
                                         nodes_count=$trasparenza.count_children
                                         class='dipendente'}
                            {/case}

                            {case match=tassi_di_assenza}
                                {include uri='design:openpa/full/parts/amministrazione_trasparente/children_table.tpl'
                                         nodes=$figli
                                         nodes_count=$trasparenza.count_children
                                         class='tasso_assenza'}
                            {/case}

                            {case match=incarichi_conferiti}
                                {include uri='design:openpa/full/parts/amministrazione_trasparente/children_table.tpl'
                                nodes=$figli
                                nodes_count=$trasparenza.count_children
                                class='incarico'}
                            {/case}

                            {case match=atti_di_concessione}
                                {include uri='design:openpa/full/parts/amministrazione_trasparente/children_table.tpl'
                                         nodes=$figli
                                         nodes_count=$trasparenza.count_children
                                         class=array( 'sovvenzione_contributo', 'determinazione', 'deliberazione' )}
                            {/case}

                            {* default *}
                            {case}
                                {include uri='design:openpa/full/parts/amministrazione_trasparente/children.tpl'
                                         nodes=$figli
                                         nodes_count=$trasparenza.count_children}
                            {/case}
                        {/switch}

                    {/if}
                {/if}

                {if $trasparenza.count_children_extra|gt(0)}
                    {if $node.object.can_create}
                        {editor_warning(
                            concat("Vengono visualizzazi qui i contenuti presenti come figli questa pagina che non sono di classe <em>", $trasparenza.children_extra_exclude_classes|implode(', '), "</em>")
                        )}
                    {/if}  
                    <div class="openpa-widget">
                    {include uri='design:openpa/full/parts/amministrazione_trasparente/children_table.tpl'
                             nodes = fetch( 'content', 'list', $trasparenza.children_extra_fetch_parameters )
                             nodes_count = $trasparenza.count_children_extra
                             title=cond($trasparenza.count_children|gt(0), "Ulteriori documenti", false())
                             class=array()
                             hide_date=true()}    
                    </div>                           
                {/if}

                                
                {if $trasparenza.show_alert}                    
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
