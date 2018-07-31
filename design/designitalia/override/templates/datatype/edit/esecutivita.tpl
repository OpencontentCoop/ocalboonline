{default attribute_base=ContentObjectAttribute html_class='full'}
{let selected_id_array=$attribute.content}

    <div class="Form-field{if $attribute.has_validation_error} has-error{/if} {$attribute.contentclass_attribute_identifier}">
        {* Always set the .._selected_array_.. variable, this circumvents the problem when nothing is selected. *}
        <input type="hidden" name="{$attribute_base}_ezselect_selected_array_{$attribute.id}" value=""/>
        <label class="Form-label {if $attribute.is_required}is-required{/if}"
               for="ezcoa-{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}">
            {first_set( $contentclass_attribute.nameList[$content_language], $contentclass_attribute.name )|wash}
            {if $attribute.is_information_collector} <em class="collector">{'information collector'|i18n( 'design/admin/content/edit_attribute' )}</em>{/if}
            {if $attribute.is_required} ({'richiesto'|i18n('design/ocbootstrap/designitalia')}){/if}
        </label>

        {if $contentclass_attribute.description}
            <em class="attribute-description">{first_set( $contentclass_attribute.descriptionList[$content_language], $contentclass_attribute.description)|wash}</em>
        {/if}

        <select id="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}"
                class="Form-input ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}"
                name="{$attribute_base}_ezselect_selected_array_{$attribute.id}[]"
                {if $attribute.class_content.is_multiselect}multiple{/if}>
            {section var=Options loop=$attribute.class_content.options}
                <option value="{$Options.item.id}"
                        {if $selected_id_array|contains( $Options.item.id )}selected="selected"{/if}>{$Options.item.name|wash( xhtml )}</option>
            {/section}
        </select>
    </div>
{/let}
{/default}
{ezscript_require( array('ezjsc::jquery', 'moment-with-locales.min.js', 'date_atto_albo.js') )}
    <div class="Form-field tipo_archiviazione">        
        <label class="Form-label" for="tipo_archiviazione">Tipologia di archiviazione</label>

        <select id="tipo_archiviazione"
                class="Form-input"
                name="tipo_archiviazione">                
                <option value="archiviato">Archivio</option>
                <option value="riservato">Area riservata</option>
                <option value="custom">Impostato manualmente</option>
        </select>
    </div>