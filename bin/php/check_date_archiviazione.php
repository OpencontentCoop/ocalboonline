<?php
require 'autoload.php';

$script = eZScript::instance([
    'description' => ("Controlla date archiviazione"),
    'use-session' => false,
    'use-modules' => true,
    'use-extensions' => true
]);

$script->startup();

$options = $script->getOptions();
$script->initialize();
$script->setUseDebugAccumulators(true);

$cli = eZCLI::instance();

$classes = ['determinazione', 'deliberazione', 'decreto', 'concorso', 'bando', 'avviso'];

$nodes = eZContentObjectTreeNode::subTreeByNodeID([
	'ClassFilterType' => 'include',
	'ClassFilterArray' => $classes,
	'Limitation' => array(),
], 1);

foreach ($nodes as $node) {
	$dataMap = $node->attribute('data_map');
	if (isset($dataMap['data_archiviazione']) && $dataMap['data_archiviazione']->hasContent() && isset($dataMap['data_finepubblicazione']) && $dataMap['data_finepubblicazione']->hasContent()){
		$cli->error(" - " . $node->attribute('name') . ' data_archiviazione:' . $dataMap['data_archiviazione']->toString() . ' data_finepubblicazione:' . $dataMap['data_finepubblicazione']->toString());
		$cli->error('  -> https://' . eZINI::instance()->variable('SiteSettings', 'SiteURL') . '/content/view/full/' . $node->attribute('node_id') );
	}else{
		$cli->output(" - " . $node->attribute('name') . ' data_archiviazione:' . $dataMap['data_archiviazione']->toString() . ' data_finepubblicazione:' . $dataMap['data_finepubblicazione']->toString());
	}
}

$script->shutdown();