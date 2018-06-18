<div class="content-view-children">  
{foreach $nodes as $child }                            
  {node_view_gui view='line' show_image='no' content_node=$child.object.main_node}    
{/foreach}
</div>

{include name=navigator
         uri='design:navigator/google.tpl'
         page_uri=$node.url_alias
         item_count=$nodes_count
         view_parameters=$view_parameters
         item_limit=openpaini( 'GestioneFigli', 'limite_paginazione', 25 )}