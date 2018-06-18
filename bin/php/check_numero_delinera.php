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

    foreach ($objects as $currentObject) {
        $currentDataMap = $currentObject->dataMap();
        $cli->output("Oggetto #" . $currentObject->attribute('id') . ' ' . $currentObject->attribute('name'));
        
        $numero = $currentDataMap['numero']->toString();
        $progressivo_albo = $currentDataMap['progressivo_albo']->toString();

        if (empty($numero)){
            $cli->warning(" - $progressivo_albo");
            $currentDataMap['numero']->fromString($progressivo_albo);
            $currentDataMap['numero']->store();

            $fileSystem->clearCache($currentObject->attribute('id'));
            eZSearch::addObject($currentObject, true);
            eZContentCacheManager::clearContentCache($currentObject->attribute('id'));
        }
            
        eZContentObject::clearCache();
    }
    $cli->warning();    
}

$script->shutdown();
