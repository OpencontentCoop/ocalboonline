{def $disallow_upload = cond(and($attribute.version|gt(1), $attribute.has_content), true(), false())}
{default attribute_base=ContentObjectAttribute}

{if $attribute.content}
    <button class="btn btn-sm btn-danger"{if $disallow_upload} style="display: none;"{/if} type="submit" name="CustomActionButton[{$attribute.id}_delete_binary]"  title="{'Remove the file from this draft.'|i18n( 'design/standard/content/datatype' )}">
        <span class="fa fa-trash"></span>
    </button>
    <a href="{concat( 'content/download/', $attribute.contentobject_id, '/', $attribute.id,'/version/', $attribute.version , '/file/', $attribute.content.original_filename|urlencode )|ezurl(no)}">
        {$attribute.content.original_filename|wash( xhtml )} {$attribute.content.mime_type|wash( xhtml )} {$attribute.content.filesize|si( byte )}
    </a>
{else}
    <div class="form-group"{if $disallow_upload} style="display: none;"{/if}>
        <input type="hidden" name="MAX_FILE_SIZE" value="{$attribute.contentclass_attribute.data_int1}000000"/>
        <input id="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}"
               class="form-control-file ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}"
               name="{$attribute_base}_data_binaryfilename_{$attribute.id}"
               type="file" />
    </div>
{/if}
{/default}
{undef $disallow_upload}