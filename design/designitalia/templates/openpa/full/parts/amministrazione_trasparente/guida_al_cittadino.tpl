{def $identifiers = array( 'applicabilita',
                           'riferimenti_normativi',
                           'contenuto_obbligo' )
$group_has_content = false()}

{foreach $node.data_map as $identifier => $attribute}
    {if and( $identifiers|contains( $identifier ), $attribute.has_content )}
        {set $group_has_content = true()}
        {break}
    {/if}
{/foreach}
{if $group_has_content}
    <div class="Callout Callout--must u-text-r-xs u-margin-top-m">
        <div class="u-color-grey-90 u-text-p">
            {foreach $node.data_map as $identifier => $attribute}
                {if and( $identifiers|contains( $identifier ), $attribute.has_content, $attribute.data_text|ne('') )}
                    <div class="u-padding-bottom-l">
                        <strong class="u-text-h5">{$attribute.contentclass_attribute_name}</strong><br/>
                        {attribute_view_gui attribute=$attribute}
                    </div>
                {/if}
            {/foreach}
        </div>
    </div>
{/if}
