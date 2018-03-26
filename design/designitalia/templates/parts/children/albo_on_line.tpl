{def $albo_on_line_handler = object_handler($node).albo_on_line}
{def $current_state =  "in_pubblicazione"
     $current_state_id = false()
     $allowed_states = $albo_on_line_handler.allowed_state_identifiers
     $anonymous_allowed_states = $albo_on_line_handler.anonymous_allowed_state_identifiers}

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
  {foreach $albo_on_line_handler.allowed_states as $state}
      {if or(
          $anonymous_allowed_states|contains($state.identifier),
          and($anonymous_allowed_states|contains($state.identifier)|not, $node.object.can_edit)
      )}
        {if $current_state|eq($state.identifier)} 
          {set $current_state_id = $state.id}
        {/if}
        {def $url = concat($node.url_alias, '/(stato)/', $state.identifier)|ezurl(no)}
        {if $state.identifier|eq('in_pubblicazione')}
          {set $url = $node.url_alias|ezurl(no)}
        {/if}
        <a class="button{if $current_state|eq($state.identifier)} defaultbutton{/if}" href="{$url}">{$state.current_translation.name|wash()}</a>
        {undef $url}
      {/if}
  {/foreach}
</div>

{if $current_state_id}

  {def $page_limit = openpaini( 'GestioneFigli', 'limite_paginazione', 25 )

       $children_count = fetch( 'content', 'list_count', hash( 'parent_node_id', $node.object.main_node_id,
                                                               'attribute_filter', array( array( 'state', "=", $current_state_id ) ) ) )

       $children = fetch( 'content', 'list', hash(  'parent_node_id', $node.object.main_node_id,
                                                    'attribute_filter', array( array( 'state', "=", $current_state_id ) ),
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

{/if}

