<?php

/** @var eZModule $Module */
$Module = $Params['Module'];
$tpl = eZTemplate::factory();

$Result = array();
$Result['persistent_variable'] = $tpl->variable( 'persistent_variable' );
$Result['content'] = $tpl->fetch( 'design:alboonline/dashboard.tpl' );
$Result['node_id'] = 0;

$contentInfoArray = array( 'url_alias' => 'alboonline/dashboard' );
$contentInfoArray['persistent_variable'] = false;
if ( $tpl->variable( 'persistent_variable' ) !== false ){
    $contentInfoArray['persistent_variable'] = $tpl->variable( 'persistent_variable' );
}
$Result['content_info'] = $contentInfoArray;
$Result['path'] = array( 
	array( 'text' => 'Pannello strumenti' , 'url' => '/content/dashboard' ),
	array( 'text' => 'Cruscotto Albo On Line' , 'url' => false ) 
);
