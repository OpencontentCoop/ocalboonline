{default attribute_base='ContentObjectAttribute' html_class='full' placeholder=false()}
{if and( $attribute.has_content, $placeholder )}<label>{$placeholder}</label>{/if}
    <small class="d-block runtime-helper text-muted"></small>
    <input {if $placeholder}placeholder="{$placeholder}"{/if} id="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}"
           class="{$html_class}  ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}"
           type="text" name="{$attribute_base}_data_integer_{$attribute.id}" size="10" value="{$attribute.data_int}" />
{/default}

{if $attribute.version|eq(1)}
{literal}
    <script type="text/javascript">
        $(document).ready(function(){
            var tools = $.opendataTools;
            var field = {/literal}$("#ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}"){literal};
            var helper = field.prev();
            if (parseInt(field.val()) === 0){
                helper.html('Attendere caricamento suggerimento progressivo...');
                tools.find('progressivo_albo != 0 and anno = '+(new Date()).getFullYear()+' sort [progressivo_albo=>desc] limit 1', function(response){
                    helper.html('');
                    if (response.totalCount > 0){
                        var current = parseInt(response.searchHits[0].data['ita-IT'].progressivo_albo);
                        field.val(++current);
                    }else{
                        field.val(1);
                    }
                });
            }
        });
    </script>
{/literal}
{/if}