<?php
require 'autoload.php';

use Opencontent\Opendata\Rest\Client\HttpClient;

$script = eZScript::instance();

$script->startup();

$options = $script->getOptions();
$script->initialize();
$script->setUseDebugAccumulators(true);

$rootRemoteNodeId = 23830;
$remoteUrl = 'https://vallarsa.upipa.opencontent.it';

OpenPAClassTools::$remoteUrl = 'http://vallarsa.upipa-dev.opencontent.it/openpa/classdefinition/';
eZINI::instance('openpa.ini')->setVariable('NetworkSettings', 'PrototypeUrl', OpenPAClassTools::$remoteUrl);

try {

    /** @var eZUser $user */
    $user = eZUser::fetchByName( 'admin' );
    eZUser::setCurrentlyLoggedInUser( $user , $user->attribute( 'contentobject_id' ) );

    $siteaccess = eZSiteAccess::current();

    $instance = OpenPAInstance::current();

    $avoids = array(
        //'prototipo',
        'vallarsa',
    );

    foreach($avoids as $avoid) {
        if (stripos($siteaccess['name'], $avoid) !== false) {
            throw new Exception('Script non eseguibile su ' . $avoid);
        }
    }

    if (OpenPAINI::variable('NetworkSettings', 'SyncTrasparenza', 'enabled') != 'enabled'){
        throw new Exception( 'Script non eseguibile secondo configurazione openpa.ini' );
    }

    $classiTrasparenza = array(
        'nota_trasparenza',
        'pagina_trasparenza',
        'trasparenza',
    );

	foreach( $classiTrasparenza as $identifier )
	{
	    OpenPALog::warning( 'Sincronizzo classe ' . $identifier );
	    $tools = new OpenPAClassTools( $identifier, true ); // creo se non esiste
	    $tools->sync( true, true ); // forzo e rimuovo attributi in più
	}

    $sourceClient = new HttpClient($remoteUrl);
    $tool = new SyncTrasparenzaTool(
        $remoteUrl,
        array('trasparenza', 'pagina_trasparenza')
    );

    eZCLI::instance()->warning($remoteUrl);

    $rootContent = $sourceClient->browse($rootRemoteNodeId);
    $remoteId = $rootContent['remoteId'];
    $rootObject = eZContentObject::fetchByRemoteID($remoteId);
    $rootParentNodeId = $rootObject->attribute('main_parent_node_id');

	$tool->run($rootRemoteNodeId, $rootParentNodeId);

    OpenPAMenuTool::refreshMenu(null, false);
    eZContentCacheManager::clearAllContentCache();

    $script->shutdown();
} catch (Exception $e) {
    print_r($e->getTraceAsString());
    $errCode = $e->getCode();
    $errCode = $errCode != 0 ? $errCode : 1; // If an error has occured, script must terminate with a status other than 0
    $script->shutdown($errCode, $e->getMessage());
}