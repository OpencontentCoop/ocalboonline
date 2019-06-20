{def $identifiers = array( 'denominazione_degli_obblighi',
                           'guida_alla_compilazione',
                           'messaggio_di_consiglio',
                           'decorrenza_di_pubblicazione',
                           'aggiornamento',
                           'termine_pubblicazione' )
$group_has_content = false()}

{foreach $node.data_map as $identifier => $attribute}
    {if and( $identifiers|contains( $identifier ), $attribute.has_content )}
        {set $group_has_content = true()}
        {break}
    {/if}
{/foreach}
{if and( $group_has_content, $node.can_create )}
    <div class="Callout Callout--should u-text-r-xs u-margin-top-m">
        <h2 class="u-text-h4">Guida per il redattore</h2>
        <div class="u-color-grey-90 u-text-p">
        {foreach $node.data_map as $identifier => $attribute}
            {if and( $identifiers|contains( $identifier ), $attribute.has_content, $attribute.data_text|ne('') )}
                <div class="Prose u-padding-bottom-l">
                    <strong class="u-text-h5">{$attribute.contentclass_attribute_name}</strong><br/>
                    {attribute_view_gui attribute=$attribute}
                </div>
            {/if}
        {/foreach}
        </div>
    </div>
{/if}  
