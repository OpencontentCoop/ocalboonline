<?php
require 'autoload.php';

use Opencontent\Opendata\Rest\Client\HttpClient;

$script = eZScript::instance();

$script->startup();

$options = $script->getOptions();
$script->initialize();
$script->setUseDebugAccumulators(true);

$rootRemoteNodeId = 23830;
$remoteUrl = 'https://upipa.opencontent.it/';

try {

    /** @var eZUser $user */
    $user = eZUser::fetchByName('admin');
    eZUser::setCurrentlyLoggedInUser($user, $user->attribute('contentobject_id'));

    $siteaccess = eZSiteAccess::current();

    $instance = OpenPAInstance::current();

    $avoids = array(
        'prototipo',
        //'vallarsa',
    );

    foreach ($avoids as $avoid) {
        if (stripos($siteaccess['name'], $avoid) !== false) {
            throw new Exception('Script non eseguibile su ' . $avoid);
        }
    }

    if (OpenPAINI::variable('NetworkSettings', 'SyncTrasparenza', 'enabled') != 'enabled') {
        throw new Exception('Script non eseguibile secondo configurazione openpa.ini');
    }

    $classiTrasparenza = array(
        'nota_trasparenza',
        'pagina_trasparenza',
        'trasparenza',
    );

    foreach ($classiTrasparenza as $identifier) {
        OpenPALog::warning('Controllo classe ' . $identifier);
        $tools = new OpenPAClassTools($identifier);
        $tools->compare();
        $result = $tools->getData();
        if ($result->missingAttributes) {
            OpenPALog::warning('Attributi mancanti rispetto al prototipo: ' . count($result->missingAttributes));
        }
        if ($result->extraAttributes) {
            OpenPALog::error('Attributi aggiuntivi rispetto al prototipo: ' . count($result->extraAttributes));
        }
        if ($result->hasDiffAttributes) {
            $identifiers = array_keys($result->diffAttributes);
            $errors = array_intersect(array_keys($result->errors), $identifiers);
            $warnings = array_intersect(array_keys($result->warnings), $identifiers);

            if (count($errors) > 0)
                OpenPALog::error('Attributi che differiscono dal prototipo: ' . count($result->diffAttributes));
            elseif (count($warnings) > 0)
                OpenPALog::warning('Attributi che differiscono dal prototipo: ' . count($result->diffAttributes));
            else
                OpenPALog::notice('Attributi che differiscono dal prototipo: ' . count($result->diffAttributes));
        }

    }

    $sourceClient = new HttpClient($remoteUrl);
    $tool = new CheckTrasparenzaTool(
        $remoteUrl,
        array('trasparenza', 'pagina_trasparenza')
    );

    eZCLI::instance()->warning($remoteUrl);

    $rootContent = $sourceClient->browse($rootRemoteNodeId);
    $remoteId = $rootContent['remoteId'];
    $rootObject = eZContentObject::fetchByRemoteID($remoteId);
    $rootParentNodeId = $rootObject->attribute('main_parent_node_id');

    $tool->run($rootRemoteNodeId, $rootParentNodeId);

    $script->shutdown();
} catch (Exception $e) {
    print_r($e->getTraceAsString());
    $errCode = $e->getCode();
    $errCode = $errCode != 0 ? $errCode : 1; // If an error has occured, script must terminate with a status other than 0
    $script->shutdown($errCode, $e->getMessage());
}