{def $disallow_upload = cond(and($attribute.version|gt(1), $attribute.has_content), true(), false())}
{default attribute_base=ContentObjectAttribute}
    <div class="Form-field{if $attribute.has_validation_error} has-error{/if}">
        <label class="Form-label {if $attribute.is_required}is-required{/if}"
               for="ezcoa-{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}">
            {first_set( $contentclass_attribute.nameList[$content_language], $contentclass_attribute.name )|wash}
            {if $attribute.is_information_collector} <em
                    class="collector">{'information collector'|i18n( 'design/admin/content/edit_attribute' )}</em>{/if}
            {if $attribute.is_required} ({'richiesto'|i18n('design/ocbootstrap/designitalia')}){/if}
        </label>

        {if $contentclass_attribute.description}
            <em class="attribute-description">{first_set( $contentclass_attribute.descriptionList[$content_language], $contentclass_attribute.description)|wash}</em>
        {/if}
        
        {if $attribute.has_content}
        {* Current file. *}
        <div class="u-padding-all-s">
            <button class="btn" type="submit"
                    name="CustomActionButton[{$attribute.id}_delete_binary]"
                    title="{'Remove the file from this draft.'|i18n( 'design/standard/content/datatype' )}"
                    {if $disallow_upload} style="display: none;"{/if}>
                <span class="fa fa-trash"></span>
            </button>
            <a href={concat( 'content/download/', $attribute.contentobject_id, '/', $attribute.id,'/version/', $attribute.version , '/file/', $attribute.content.original_filename|urlencode )|ezurl}>
                {$attribute.content.original_filename|wash( xhtml )} {$attribute.content.mime_type|wash( xhtml )} {$attribute.content.filesize|si( byte )}
            </a>
        </div>
        {/if}

        {* New file. *}
        <div{if $disallow_upload} style="display: none;"{/if}>
        <input type="hidden" name="MAX_FILE_SIZE" value="{$attribute.contentclass_attribute.data_int1}000000"/>
        <input id="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}"
               class="Form-input ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}"
               name="{$attribute_base}_data_binaryfilename_{$attribute.id}" type="file"/>
       </div>

    </div>
{/default}
{undef $disallow_upload}