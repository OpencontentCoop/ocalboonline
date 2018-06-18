<?php
require 'autoload.php';

$script = eZScript::instance(array(
    'description' => ( "Create oggetti_scaduti section" ),
    'use-session' => false,
    'use-modules' => true,
    'use-extensions' => true
));

$script->startup();

$options = $script->getOptions();
$script->initialize();
$script->setUseDebugAccumulators(true);

try {
    $section = eZSection::fetchByIdentifier('alboonline');
    if (!$section instanceof eZSection) {
        $section = new eZSection(array());
        $section->setAttribute('name', 'Albo on line');
        $section->setAttribute('identifier', 'alboonline');
        $section->setAttribute('navigation_part_identifier', 'ezcontentnavigationpart');
        $section->store();
    }

    $script->shutdown();
} catch (Exception $e) {
    $errCode = $e->getCode();
    $errCode = $errCode != 0 ? $errCode : 1; // If an error has occured, script must terminate with a status other than 0
    $script->shutdown($errCode, $e->getMessage());
}
