<fieldset class="Form-field{if $attribute.has_validation_error} has-error{/if} {$attribute.contentclass_attribute_identifier}">
    <legend class="Form-label {if $attribute.is_required}is-required{/if}">
        {first_set( $contentclass_attribute.nameList[$content_language], $contentclass_attribute.name )|wash}
        {if $attribute.is_information_collector} <em
                class="collector">{'information collector'|i18n( 'design/admin/content/edit_attribute' )}</em>{/if}
        {if $attribute.is_required} ({'richiesto'|i18n('design/ocbootstrap/designitalia')}){/if}
    </legend>

    {if $contentclass_attribute.description}
        <em class="attribute-description">{first_set( $contentclass_attribute.descriptionList[$content_language], $contentclass_attribute.description)|wash}</em>
    {/if}

    {default attribute_base='ContentObjectAttribute' html_class='full' placeholder=false()}
        <div class="clearfix">
            {if $placeholder}<label>{$placeholder}</label>{/if}

            {if ne( $attribute_base, 'ContentObjectAttribute' )}
                {def $id_base = concat( 'ezcoa-', $attribute_base, '-', $attribute.contentclassattribute_id, '_', $attribute.contentclass_attribute_identifier )}
            {else}
                {def $id_base = concat( 'ezcoa-', $attribute.contentclassattribute_id, '_', $attribute.contentclass_attribute_identifier )}
            {/if}

            <div class="u-flex">
                <div class="FlexItem">
                    <input placeholder="{'Day'|i18n( 'design/admin/content/datatype' )}" id="{$id_base}_day"
                           class="Form-input day" type="text" name="{$attribute_base}_date_day_{$attribute.id}" size="3"
                           readonly="readonly" style="cursor: not-allowed;"
                           value="{if $attribute.content.is_valid}{$attribute.content.day}{else}{currentdate()|datetime( 'custom', '%d' )}{/if}"/>
                </div>
                <div class="FlexItem">
                    <input placeholder="{'Month'|i18n( 'design/admin/content/datatype' )}" id="{$id_base}_month"
                           class="Form-input month" type="text" name="{$attribute_base}_date_month_{$attribute.id}" size="3"
                           readonly="readonly" style="cursor: not-allowed;" 
                           value="{if $attribute.content.is_valid}{$attribute.content.month}{else}{currentdate()|datetime( 'custom', '%m' )}{/if}"/>                           
                </div>
                <div class="FlexItem">
                    <input placeholder="{'Year'|i18n( 'design/admin/content/datatype' )}" id="{$id_base}_year"
                           class="year Form-input" type="text" name="{$attribute_base}_date_year_{$attribute.id}"
                           size="5"
                           readonly="readonly" style="cursor: not-allowed;"
                           value="{if $attribute.content.is_valid}{$attribute.content.year}{else}{currentdate()|datetime( 'custom', '%Y' )}{/if}"/>
                           
                </div>

            </div>

        </div>
    {/default}
</fieldset>
