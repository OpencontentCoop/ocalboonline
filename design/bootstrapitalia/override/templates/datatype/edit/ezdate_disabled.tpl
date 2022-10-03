
{default attribute_base='ContentObjectAttribute' html_class='full' placeholder=false()}
    <div class="clearfix {$attribute.contentclass_attribute_identifier}">
        {if $placeholder}<label>{$placeholder}</label>{/if}

        {if ne( $attribute_base, 'ContentObjectAttribute' )}
            {def $id_base = concat( 'ezcoa-', $attribute_base, '-', $attribute.contentclassattribute_id, '_', $attribute.contentclass_attribute_identifier )}
        {else}
            {def $id_base = concat( 'ezcoa-', $attribute.contentclassattribute_id, '_', $attribute.contentclass_attribute_identifier )}
        {/if}

        <div class="form-inline date">
            <input readonly="readonly" style="cursor: not-allowed;" placeholder="{'Day'|i18n( 'design/admin/content/datatype' )}"
                   id="{$id_base}_day" class="day form-control" type="text" name="{$attribute_base}_date_day_{$attribute.id}" size="3"
                   value="{if $attribute.content.is_valid}{$attribute.content.day}{else}{currentdate()|datetime( 'custom', '%d' )}{/if}"/>
            <input readonly="readonly" style="cursor: not-allowed;" placeholder="{'Month'|i18n( 'design/admin/content/datatype' )}"
                   id="{$id_base}_month"  class="month form-control" type="text" name="{$attribute_base}_date_month_{$attribute.id}" size="3"
                   value="{if $attribute.content.is_valid}{$attribute.content.month}{else}{currentdate()|datetime( 'custom', '%m' )}{/if}"/>
            <input readonly="readonly" style="cursor: not-allowed;" placeholder="{'Year'|i18n( 'design/admin/content/datatype' )}"
                   id="{$id_base}_year" class="year form-control" type="text" name="{$attribute_base}_date_year_{$attribute.id}" size="5"
                   value="{if $attribute.content.is_valid}{$attribute.content.year}{else}{currentdate()|datetime( 'custom', '%Y' )}{/if}"/>
        </div>

    </div>
{/default}
