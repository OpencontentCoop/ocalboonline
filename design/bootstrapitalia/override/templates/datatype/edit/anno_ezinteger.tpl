{default attribute_base=ContentObjectAttribute  html_class='full' placeholder=false()}
    {def $anno_corrente = currentdate()|datetime( 'custom', '%Y' )
         $anno_pregresso = $anno_corrente|sub(10)
         $anni = array()}
    {for $anno_pregresso to $anno_corrente as $anno}
        {set $anni = $anni|append($anno)}
    {/for}
    {set $anni = $anni|reverse()}
    <select id="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}"
            class="form-control ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}"
            name="{$attribute_base}_data_integer_{$attribute.id}">
        {foreach $anni as $anno}
        <option value="{$anno}" {if $attribute.data_int|eq( $anno )}selected="selected"{/if}>{$anno|wash( xhtml )}</option>
        {/foreach}
    </select>
    {undef $anno_corrente $anno_pregresso $anni}
{/default}