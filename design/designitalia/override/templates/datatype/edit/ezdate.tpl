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
    {run-once}
    {def $base = ezini('eZJSCore', 'LocalScriptBasePath', 'ezjscore.ini')}
    {ezscript_require( 'ezjsc::yui2' )}
    {ezcss_require( concat( '/', $base.yui2, 'calendar/assets/calendar.css' ) )}

    <script type="text/javascript">
        (function () {ldelim}
            YUILoader.addModule({ldelim}
                name: 'datepicker',
                type: 'js',
                fullpath: '{"javascript/ezdatepicker.js"|ezdesign( 'no' )}',
                requires: ["calendar"],
                after: ["calendar"],
                skinnable: false
                {rdelim});

            YUILoader.require(["datepicker"]);

            // Load the files using the insert() method.
            var options = [];
            YUILoader.insert(options, "js");
            {rdelim})();
    </script>
    {/run-once}

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
                           value="{section show=$attribute.content.is_valid}{$attribute.content.day}{/section}"/>
                </div>
                <div class="FlexItem">
                    <input placeholder="{'Month'|i18n( 'design/admin/content/datatype' )}" id="{$id_base}_month"
                           class="Form-input month" type="text" name="{$attribute_base}_date_month_{$attribute.id}" size="3"
                           value="{section show=$attribute.content.is_valid}{$attribute.content.month}{/section}"/>
                </div>
                <div class="FlexItem">
                    <input placeholder="{'Year'|i18n( 'design/admin/content/datatype' )}" id="{$id_base}_year"
                           class="year Form-input" type="text" name="{$attribute_base}_date_year_{$attribute.id}"
                           size="5"
                           value="{section show=$attribute.content.is_valid}{$attribute.content.year}{/section}"/>
                </div>
                <div class="FlexItem">
                    <span class="u-padding-all-s fa fa-calendar" id="{$attribute_base}_date_cal_{$attribute.id}"
                          onclick="showDatePicker( '{$attribute_base}', '{$attribute.id}', 'date' );"
                          style="cursor: pointer;"></span>
                </div>
            </div>

            <div id="{$attribute_base}_date_cal_container_{$attribute.id}" style="display: none; position: absolute;"></div>


        </div>
    {/default}
</fieldset>
{if or($attribute.contentclass_attribute_identifier|eq('data'), $attribute.contentclass_attribute_identifier|eq('data_inizio_validita'))}
    {ezscript_require( array('ezjsc::jquery', 'moment-with-locales.min.js', 'date_atto_albo.js') )}
    <div class="Form-field tipo_archiviazione">        
        <label class="Form-label" for="tipo_archiviazione">Tipologia di archiviazione</label>

        <select id="tipo_archiviazione"
                class="Form-input"
                name="tipo_archiviazione">                
                <option value="riservato">Archivio riservato</option>
                <option value="archiviato">Archivio pubblico</option>                
                <option value="custom">Imposta manualmente</option>
        </select>
    </div>
{/if}