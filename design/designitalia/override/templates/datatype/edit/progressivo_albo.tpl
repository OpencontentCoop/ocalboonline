{default attribute_base=ContentObjectAttribute  html_class='full' placeholder=false()}
<div class="Form-field{if $attribute.has_validation_error} has-error{/if}">
    <a href="#" class="overview-toggle pull-right hide"><small>Visualizza ultimi atti</small></a>
    <label class="Form-label {if $attribute.is_required}is-required{/if}" for="ezcoa-{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}">
        {first_set( $contentclass_attribute.nameList[$content_language], $contentclass_attribute.name )|wash}
        {if $attribute.is_information_collector} <em class="collector">{'information collector'|i18n( 'design/admin/content/edit_attribute' )}</em>{/if}
        {if $attribute.is_required} ({'richiesto'|i18n('design/ocbootstrap/designitalia')}){/if}
    </label>
    
    <em class="attribute-description">
        {if $contentclass_attribute.description}{first_set( $contentclass_attribute.descriptionList[$content_language], $contentclass_attribute.description)|wash}{/if}
        <span class="runtime-helper"></span>        
    </em>
    
    <input id="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}"
           class="Form-input ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}" type="text" name="{$attribute_base}_data_integer_{$attribute.id}" size="10" value="{$attribute.data_int}" />

    <div class="overview-toggle hide"></div>
</div>
{if $attribute.version|eq(1)}
{ezscript_require(array('jquery.opendataTools.js'))}
{literal}
<script type="text/javascript">
    $(document).ready(function(){
        var tools = $.opendataTools;
        var field = {/literal}$("#ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}"){literal};        
        var helper = field.prev().find('.runtime-helper');
        var overviewToggle = field.parent().find('.overview-toggle');
        if (parseInt(field.val()) == 0){
            helper.html('Attendere caricamento suggerimento progressivo...');
            tools.find('progressivo_albo != 0 sort [progressivo_albo=>desc] limit 1', function(response){
                helper.html('');
                if (response.totalCount > 0){
                    var current = parseInt(response.searchHits[0].data['ita-IT'].progressivo_albo);
                    field.val(++current);
                }else{
                    helper.html('Impossibile calcolare il progressivo successivo');
                }
            });
        }

        overviewToggle.on('click', function(e){
            e.preventDefault();
        });
    });
</script>
{/literal}
{/if}
{/default}
