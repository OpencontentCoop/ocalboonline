<?php

use Opencontent\Opendata\Rest\Client\HttpClient;
use Opencontent\Opendata\Api\ContentRepository;

/** @var eZModule $Module */
$Module = $Params['Module'];
$tpl = eZTemplate::factory();
$http = eZHTTPTool::instance();

if ($http->hasGetVariable('remote-browse')){
	$remoteUrl = $http->getVariable('remote');
	$nodeId = $http->getVariable('node');
	$limit = $http->getVariable('limit');
	$offset = $http->getVariable('offset');
	$sourceClient = new HttpClient($remoteUrl);
	try{
		$data = $sourceClient->browse($nodeId, 100);
	}catch(Exception $e){
		$data = ['error' => $e->getMessage()];
	}

	if ($http->hasGetVariable('debug')){
		echo '<pre>';
		print_r($data);
		eZDisplayDebug();
	}else{
		header('Content-Type: application/json');
		echo json_encode( $data );	
	}
	eZExecution::cleanExit();
}

if ($http->hasGetVariable('remote-read')){
	$remoteUrl = $http->getVariable('remote');
	$id = $http->getVariable('id');
	$sourceClient = new HttpClient($remoteUrl);
	try{
		$data = $sourceClient->read($id);
	}catch(Exception $e){
		$data = ['error' => $e->getMessage()];
	}

	if ($http->hasGetVariable('debug')){
		echo '<pre>';
		print_r($data);
		eZDisplayDebug();
	}else{
		header('Content-Type: application/json');
		echo json_encode( $data );	
	}
	eZExecution::cleanExit();
}

if ($http->hasGetVariable('local-read')){
	$repository = new ContentRepository();
    $repository->setCurrentEnvironmentSettings(new DefaultEnvironmentSettings());
	$id = $http->getVariable('id');
	try{
		$data = $repository->read($id);
	}catch(Exception $e){
		$data = ['error' => $e->getMessage()];
	}

	if ($http->hasGetVariable('debug')){
		echo '<pre>';
		print_r($data);
		eZDisplayDebug();
	}else{
		header('Content-Type: application/json');
		echo json_encode( $data );	
	}
	eZExecution::cleanExit();
}


$Result = array();
$Result['persistent_variable'] = $tpl->variable( 'persistent_variable' );
$Result['content'] = $tpl->fetch( 'design:alboonline/bussola.tpl' );
$Result['node_id'] = 0;

$contentInfoArray = array( 'url_alias' => 'alboonline/bussola' );
$contentInfoArray['persistent_variable'] = false;
if ( $tpl->variable( 'persistent_variable' ) !== false ){
    $contentInfoArray['persistent_variable'] = $tpl->variable( 'persistent_variable' );
}
$Result['content_info'] = $contentInfoArray;
$Result['path'] = array( 
	array( 'text' => 'Pannello strumenti' , 'url' => '/content/dashboard' ),
	array( 'text' => 'Controlla alberatura trasapenza' , 'url' => false ) 
);
