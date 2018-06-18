<?php
require 'autoload.php';

$script = eZScript::instance(array(
    'description' => ("Controlla deliberazione"),
    'use-session' => false,
    'use-modules' => true,
    'use-extensions' => true
));

$script->startup();

$options = $script->getOptions('[dry-run]',
    '',
    array(
        'dry-run' => "Mostra il risultato della conversione"
    )
);
$script->initialize();
$script->setUseDebugAccumulators(true);

$cli = eZCLI::instance();

$db = eZDB::instance();

$fileSystem = new \Opencontent\Opendata\Api\Gateway\FileSystem();

$tempDir = eZDir::path( array( eZSys::cacheDirectory(), 'temp_convert' ) );
eZDir::mkdir($tempDir);

$dryRun = $options['dry-run'];

$trans = eZCharTransform::instance();

$class = eZContentClass::fetchByIdentifier('deliberazione');
if ($class instanceof eZContentClass) {
    $objects = $class->objectList();

    $cli->warning("*** CONTROLLO ATTRIBUTO organo_competente ***");    
    foreach ($objects as $currentObject) {
        $currentDataMap = $currentObject->dataMap();
        if (isset($currentDataMap['organo_competente']) && $currentDataMap['organo_competente']->hasContent()){
            $cli->output("Oggetto #" . $currentObject->attribute('id') . ' ' . $currentObject->attribute('name'));
            $idList = explode('-', $currentDataMap['organo_competente']->toString());
            $newIdList = array();
            foreach ($idList as $id) {
                $related = eZContentObject::fetch((int)$id);
                if ($related instanceof eZContentObject){
                    if ($related->attribute('class_identifier') == 'organo_politico'){
                        $newIdList[] = $related->attribute('id');
                    }
                }                
            }
            $cli->output(" - Ridefinito in " . implode('-', $newIdList));
            if (!$dryRun){
                $currentDataMap['organo_competente']->fromString(implode('-', $newIdList));
                $currentDataMap['organo_competente']->store();

                $fileSystem->clearCache($currentObject->attribute('id'));
                eZSearch::addObject($currentObject, true);
                eZContentCacheManager::clearContentCache($currentObject->attribute('id'));
            }
        }

        eZContentObject::clearCache();
    }
    $cli->warning();    
}

$script->shutdown();
