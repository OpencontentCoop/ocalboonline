<?php
require 'autoload.php';

$script = eZScript::instance(array(
    'description' => ("Controlla determinazione"),
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

$class = eZContentClass::fetchByIdentifier('determinazione');
if ($class instanceof eZContentClass) {
    $objects = $class->objectList();

    $cli->warning("*** CONTROLLO ATTRIBUTO OBSOLETO file ***");    
    foreach ($objects as $currentObject) {
        $currentDataMap = $currentObject->dataMap();
        if (isset($currentDataMap['file']) && $currentDataMap['file']->hasContent()){
            $cli->output("Oggetto #" . $currentObject->attribute('id') . ' ' . $currentObject->attribute('name'));
            $cli->output(" - File " . $currentDataMap['file']->toString());

            if (isset($currentDataMap['allegati']) && $currentDataMap['allegati']->hasContent()){            
                $cli->error(" * Controlla se presente in allegati: " . $currentDataMap['allegati']->toString());
            }else{
                list($filePath, $fileName) = explode('|', $currentDataMap['file']->toString());
                $parts = explode( '.', $fileName);
                $suffix = array_pop( $parts );
                $normalizedName = $trans->transformByGroup( implode( '.', $parts), 'identifier' );
                $normalizedName .= '.' . $suffix;

                $tempFile = $tempDir . '/' . $normalizedName;
                $cli->warning(" * Popola allegati con " . $tempFile);
                if (!$dryRun){
                    $cli->output("Eseguo");
                    eZFile::create($normalizedName, $tempDir, file_get_contents($filePath));
                    $currentDataMap['allegati']->fromString($tempFile);
                    $currentDataMap['allegati']->store();

                    $fileSystem->clearCache($currentObject->attribute('id'));
                    eZSearch::addObject($currentObject, true);
                    eZContentCacheManager::clearContentCache($currentObject->attribute('id'));
                }
            }
        }

        eZContentObject::clearCache();
    }
    $cli->warning();

    $cli->warning("*** CONTROLLO ATTRIBUTO OBSOLETO altri_file ***");    
    foreach ($objects as $currentObject) {
        $currentDataMap = $currentObject->dataMap();
        if (isset($currentDataMap['altri_file']) && $currentDataMap['altri_file']->hasContent()){            
            $idList = explode('-', $currentDataMap['altri_file']->toString());

            foreach ($idList as $id) {
                $object = eZContentObject::fetch((int)$id);
                if ($object instanceof eZContentObject){
                    $dataMap = $object->dataMap();
                    foreach ($dataMap as $attribute) {
                        if ($attribute->attribute('data_type_string') == eZBinaryFileType::DATA_TYPE_STRING){
                            list($filePath, $fileName) = explode('|', $attribute->toString());

                            $parts = explode( '.', $fileName);
                            $suffix = array_pop( $parts );
                            $normalizedName = $trans->transformByGroup( implode( '.', $parts), 'identifier' );
                            $normalizedName .= '.' . $suffix;

                            $tempFile = $tempDir . '/' . $normalizedName;
                            if (!$dryRun){
                                eZFile::create($normalizedName, $tempDir, file_get_contents($filePath));
                            }
                            $fileList[$attribute->toString()] = $tempFile;   
                            $relationIdList[] = $object->attribute('id');
                        }
                    }
                }
            }

            if (!empty($fileList)){
                $cli->output("Oggetto #" . $currentObject->attribute('id') . ' ' . $currentObject->attribute('name'));
                foreach ($fileList as $original => $file) {
                    $cli->output(" - File " . $original);
                }
                if (isset($currentDataMap['allegati']) && $currentDataMap['allegati']->hasContent()){            
                    $cli->error(" * Controlla se presente in allegati " . $currentDataMap['allegati']->toString());
                }else{
                    $tempFiles = implode('|', $fileList);
                    $cli->warning(" * Popola allegati con " . $tempFiles);
                    if (!$dryRun){
                        $cli->output("Eseguo");                        
                        $currentDataMap['allegati']->fromString($tempFiles);
                        $currentDataMap['allegati']->store();

                        $fileSystem->clearCache($currentObject->attribute('id'));
                        eZSearch::addObject($currentObject, true);
                        eZContentCacheManager::clearContentCache($currentObject->attribute('id'));
                    }
                }
            }
        }

        eZContentObject::clearCache();
    }
    $cli->warning();
}

$script->shutdown();
