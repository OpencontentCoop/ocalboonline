{def $disallow_upload = cond(and($attribute.version|gt(1), $attribute.content|count()), true(), false())}
{default attribute_base=ContentObjectAttribute}
    <div class="Form-field{if $attribute.has_validation_error} has-error{/if}">
    <label class="Form-label {if $attribute.is_required}is-required{/if}"
           for="ezcoa-{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}">
        {first_set( $contentclass_attribute.nameList[$content_language], $contentclass_attribute.name )|wash}
        {if $attribute.is_information_collector} <em
                class="collector">{'information collector'|i18n( 'design/admin/content/edit_attribute' )}</em>{/if}
        {if $attribute.is_required} ({'richiesto'|i18n('design/ocbootstrap/designitalia')}){/if}
    </label>

        {def $file_count = 0}

        {if $attribute.has_content}
            <table class="list" cellpadding="0" cellspacing="0">
                <tr>
                    <th>
                        File allegati:
                        <button class="btn btn-default pull-right" type="submit"
                                {if $disallow_upload} style="display: none;"{/if}
                                name="CustomActionButton[{$attribute.id}_delete_binary]" title="Rimuovi tutti i file">
                            Elimina tutti i file
                        </button>
                    </th>
                </tr>
                {foreach $attribute.content as $file}
                    <tr>
                        <td>
                            <button class="ocmultibutton btn btn-link" type="submit"
                                    name="CustomActionButton[{$attribute.id}_delete_multibinary][{$file.filename}]"
                                    title="Rimuovi questo file" 
                                    {if $disallow_upload} style="display: none;"{/if}>
                                    <i class="fa fa-trash"></i>
                                </button>
                            <a href={concat( 'ocmultibinary/download/', $attribute.contentobject_id, '/', $attribute.id,'/', $attribute.version , '/', $file.filename ,'/file/', $file.original_filename|urlencode )|ezurl}>
                                {$file.original_filename|wash( xhtml )}&nbsp;({$file.filesize|si( byte )})
                            </a>
                        </td>
                    </tr>
                {/foreach}
            </table>
        {else}
            <p>Nessun file caricato.</p>
        {/if}

        <div{if $disallow_upload} style="display: none;"{/if}>
        {if $attribute.has_content}
            {set $file_count = $attribute.content|count()}
        {/if}
        {if or($file_count|lt( $attribute.contentclass_attribute.data_int2 ), $attribute.contentclass_attribute.data_int2|eq(0) )}
            <div class="block clearfix u-cf">
                <label class="ocmultilabel hide"
                       for="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}">{'New file for upload'|i18n( 'design/standard/content/datatype' )}:
                </label>
                <input type="hidden" name="MAX_FILE_SIZE" value="{$attribute.contentclass_attribute.data_int1}000000"/>
                <input id="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}"
                       class="box ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier} pull-left"
                       name="{$attribute_base}_data_multibinaryfilename_{$attribute.id}" type="file"/>                
                <input class="ocmultibutton btn btn-default pull-left" type="submit"
                       name="CustomActionButton[{$attribute.id}_upload_multibinary]" value="Allega file"
                       title="Allega il file"/>
            </div>
        {/if}
        </div>

    </div>
{/default}
{undef $disallow_upload}