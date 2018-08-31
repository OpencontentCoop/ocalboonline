<fieldset class="Form-field{if $attribute.has_validation_error} has-error{/if} {$attribute.contentclass_attribute_identifier}">
    <legend class="Form-label {if $attribute.is_required}is-required{/if}">
        {first_set( $contentclass_attribute.nameList[$content_language], $contentclass_attribute.name )|wash}
        {if $attribute.is_information_collector} <em
                class="collector">{'information collector'|i18n( 'design/admin/content/edit_attribute' )}</em>{/if}
        {if $attribute.is_required} ({'richiesto'|i18n('design/ocbootstrap/designitalia')}){/if}
    </legend>
    {def $base = ezini('eZJSCore', 'LocalScriptBasePath', 'ezjscore.ini')}

    {ezscript_require( 'ezjsc::yui2' )}
    {ezcss_require( concat( '/', $base.yui2, 'calendar/assets/calendar.css' ) )}

    <script>
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
                       class="Form-input day ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}"
                       type="text" name="{$attribute_base}_datetime_day_{$attribute.id}" size="3"
                       value="{section show=$attribute.content.is_valid}{$attribute.content.day}{/section}"/>
                </div>
                <div class="FlexItem">
                    <input placeholder="{'Month'|i18n( 'design/admin/content/datatype' )}" id="{$id_base}_month"
                       class="Form-input month ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}"
                       type="text" name="{$attribute_base}_datetime_month_{$attribute.id}" size="3"
                       value="{section show=$attribute.content.is_valid}{$attribute.content.month}{/section}"/>
                </div>
                <div class="FlexItem">
                    <input placeholder="{'Year'|i18n( 'design/admin/content/datatype' )}" id="{$id_base}_year"
                       class="year Form-input ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}"
                       type="text" name="{$attribute_base}_datetime_year_{$attribute.id}" size="5"
                       value="{section show=$attribute.content.is_valid}{$attribute.content.year}{/section}"/>
                </div>
                <div class="FlexItem">
                <input placeholder="{'Hour'|i18n( 'design/admin/content/datatype' )}" id="{$id_base}_hour"
                       class="Form-input hour u-background-grey-10 ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}"
                       type="text" name="{$attribute_base}_datetime_hour_{$attribute.id}" size="3"
                       value="{section show=$attribute.content.is_valid}{$attribute.content.hour}{/section}"/>
                </div>
                <div class="FlexItem">
                    <input placeholder="{'Minute'|i18n( 'design/admin/content/datatype' )}" id="{$id_base}_minute"
                       class="Form-input minute u-background-grey-10 ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}"
                       type="text" name="{$attribute_base}_datetime_minute_{$attribute.id}" size="3"
                       value="{section show=$attribute.content.is_valid}{$attribute.content.minute}{/section}"/>
                </div>
                {if $attribute.contentclass_attribute.data_int2|eq(1)}
                <div class="FlexItem">
                    <input placeholder="{'Second'|i18n( 'design/standard/content/datatype' )}" id="{$id_base}_second"
                           class="Form-input second u-background-grey-10 ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}"
                           type="text" name="{$attribute_base}_datetime_second_{$attribute.id}" size="3"
                           value="{if $attribute.content.is_valid}{$attribute.content.second}{/if}"/>
                </div>
                {/if}
                <div class="FlexItem">
                    <span class="u-padding-all-s fa fa-calendar"
                          id="{$attribute_base}_datetime_cal_{$attribute.id}" onclick="showDatePicker( '{$attribute_base}', '{$attribute.id}', 'datetime' );"
                          style="cursor: pointer;"></span>
                </div>
            </div>

            <div id="{$attribute_base}_datetime_cal_container_{$attribute.id}" style="display: none; position: absolute;"></div>


        </div>
    {/default}
</fieldset>
