{def $albo_on_line_handler = object_handler($node)}
{def $current_state =  "in_pubblicazione"
     $allowed_states = $albo_on_line_handler.albo_on_line_allowed_state_identifiers
     $anonymous_allowed_states = $albo_on_line_handler.albo_on_line_anonymous_allowed_state_identifiers}

{if is_set( $view_parameters.stato )}
    {if or(
        $anonymous_allowed_states|contains($view_parameters.stato),
        and($anonymous_allowed_states|contains($view_parameters.stato)|not, $node.object.can_edit)
    )}
        {if $allowed_states|contains($view_parameters.stato)}
            {set $current_state = $view_parameters.stato}
        {/if}
    {/if}
{/if}


<div class="state-navigation m_bottom_20">
  {foreach $albo_on_line_handler.albo_on_line_allowed_states as $state}
      {if fetch( 'content', 'list_count', hash( 'parent_node_id', $node.object.main_node_id,
                                                'attribute_filter', array( array( 'state', "=", $state.identifier ) ) )
      )|gt(0)}
          {if or(
              $anonymous_allowed_states|contains($state.identifier),
              and($anonymous_allowed_states|contains($state.identifier)|not, $node.object.can_edit)
          )}
            <a class="button{if $current_state|eq($state.identifier)} defaultbutton{/if}" href="{$node.url_alias|ezurl(no)}">{$state.current_translation.name|wash()}</a>
          {/if}
      {/if}
  {/foreach}
</div>

{def $page_limit = openpaini( 'GestioneFigli', 'limite_paginazione', 25 )

     $children_count = fetch( 'content', 'list_count', hash( 'parent_node_id', $node.object.main_node_id,
                                                             'attribute_filter', array( array( 'state', "=", $current_state ) ) ) )

     $children = fetch( 'content', 'list', hash(  'parent_node_id', $node.object.main_node_id,
                                                  'attribute_filter', array( array( 'state', "=", $current_state ) )
                                                  'offset', $view_parameters.offset,
                                                  'sort_by', $node.sort_array,
                                                  'limit', $page_limit ) ) }


{if $children_count}
  <div class="content-view-children">
  {foreach $children as $child }
    {node_view_gui view='line' content_node=$child image_class=small}
  {/foreach}
  </div>

  {include name=navigator
       uri='design:navigator/google.tpl'
       page_uri=$node.url_alias
       item_count=$children_count
       view_parameters=$view_parameters
       item_limit=$page_limit}
{else}
 <div class="message-warning">
   <p>Non sono attualmente presenti atti in questa sezione</p>
 </div>
{/if}

