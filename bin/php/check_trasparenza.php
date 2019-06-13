<?php
require 'autoload.php';

use Opencontent\Opendata\Rest\Client\HttpClient;

$script = eZScript::instance();

$script->startup();

$options = $script->getOptions('[remote:][root_node:][force]',
    '',
    array(
        'remote' => "Remote url",
        'root_node' => "Remote root node",
    )
);
$script->initialize();
$script->setUseDebugAccumulators(true);

$rootRemoteNodeId = $options['root_node'];
$remoteUrl = $options['remote'];

$cli = eZCLI::instance();

try {

    if (!$options['remote'] || !$options['root_node']){
        throw new Exception("Missing arguments");
    }

    /** @var eZUser $user */
    $user = eZUser::fetchByName('admin');
    eZUser::setCurrentlyLoggedInUser($user, $user->attribute('contentobject_id'));

    $siteaccess = eZSiteAccess::current();

    $instance = OpenPAInstance::current();

    $avoids = $options['force'] ? array() : array(
        'prototipo',
    );

    foreach ($avoids as $avoid) {
        if (stripos($siteaccess['name'], $avoid) !== false) {
            throw new Exception('Script non eseguibile su ' . $avoid);
        }
    }

    if (!$options['force'] && OpenPAINI::variable('NetworkSettings', 'SyncTrasparenza', 'enabled') != 'enabled') {
        throw new Exception('Script non eseguibile secondo configurazione openpa.ini');
    }

    $classiTrasparenza = array(
        'nota_trasparenza',
        'pagina_trasparenza',
        'trasparenza',
    );

    foreach ($classiTrasparenza as $identifier) {
        $cli->warning('Controllo classe ' . $identifier);
        $remoteClassUrl = rtrim($remoteUrl, '/') . '/classtools/definition/';
        $tools = new OCClassTools($identifier, false, array(), $remoteClassUrl);
        $tools->compare();
        $result = $tools->getData();
        if ($result->missingAttributes) {
            $cli->warning('Attributi mancanti rispetto al prototipo: ' . count($result->missingAttributes));
        }
        if ($result->extraAttributes) {
            $cli->error('Attributi aggiuntivi rispetto al prototipo: ' . count($result->extraAttributes));
        }
        if ($result->hasDiffAttributes) {
            $identifiers = array_keys($result->diffAttributes);
            $errors = array_intersect(array_keys($result->errors), $identifiers);
            $warnings = array_intersect(array_keys($result->warnings), $identifiers);

            if (count($errors) > 0)
                $cli->error('Attributi che differiscono dal prototipo: ' . count($result->diffAttributes));
            elseif (count($warnings) > 0)
                $cli->warning('Attributi che differiscono dal prototipo: ' . count($result->diffAttributes));
            else
                $cli->notice('Attributi che differiscono dal prototipo: ' . count($result->diffAttributes));
        }

    }

    $sourceClient = new HttpClient($remoteUrl);
    $tool = new CheckTrasparenzaTool(
        $remoteUrl,
        array('trasparenza', 'pagina_trasparenza')
    );

    $cli->warning($remoteUrl);

    $rootContent = $sourceClient->browse($rootRemoteNodeId);
    $remoteId = $rootContent['remoteId'];
    $rootObject = eZContentObject::fetchByRemoteID($remoteId);
    $cli->warning($rootObject->attribute('name'));
    $rootParentNodeId = $rootObject->attribute('main_parent_node_id');

    $tool->run($rootRemoteNodeId, $rootParentNodeId);

    $script->shutdown();
} catch (Exception $e) {
    print_r($e->getTraceAsString());
    $errCode = $e->getCode();
    $errCode = $errCode != 0 ? $errCode : 1; // If an error has occured, script must terminate with a status other than 0
    $script->shutdown($errCode, $e->getMessage());
}