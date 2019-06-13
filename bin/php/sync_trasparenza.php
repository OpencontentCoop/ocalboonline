<?php
require 'autoload.php';

use Opencontent\Opendata\Rest\Client\HttpClient;

$script = eZScript::instance();

$script->startup();

$options = $script->getOptions('[remote:][root_node:][sync_classes]',
    '',
    array(
        'remote' => "Remote url",
        'root_node' => "Remote root node",
        'sync_classes' => "Sincronizza le classi",
    )
);
$script->initialize();
$script->setUseDebugAccumulators(true);

$rootRemoteNodeId = $options['root_node'];
$remoteUrl = $options['remote'];

$syncClasses = $options['sync_classes'];

OCOpenDataClassRepositoryCache::clearCache();

$cli = eZCLI::instance();

try {

    if (!$options['remote'] || $options['root_node']){
        throw new Exception("Missing arguments");
    }

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

    if ($syncClasses){
        $classiTrasparenza = array(
            'nota_trasparenza',
            'pagina_trasparenza',
            'trasparenza',
        );

    	foreach( $classiTrasparenza as $identifier )
    	{
    	    $cli->warning( 'Sincronizzo classe ' . $identifier );
            $remoteClassUrl = rtrim($remoteUrl, '/') . '/classtools/definition/';
            $tools = new OCClassTools($identifier, true, array(), $remoteClassUrl);
    	    $tools->sync( true, true ); // forzo e rimuovo attributi in più
    	}
    }

    $sourceClient = new HttpClient($remoteUrl);
    $tool = new SyncTrasparenzaTool(
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

    OpenPAMenuTool::refreshMenu(null, false);
    eZContentCacheManager::clearAllContentCache();

    $script->shutdown();
} catch (Exception $e) {
    print_r($e->getTraceAsString());
    $errCode = $e->getCode();
    $errCode = $errCode != 0 ? $errCode : 1; 
    $script->shutdown($errCode, $e->getMessage());
}