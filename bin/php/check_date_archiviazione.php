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
	if (isset($dataMap['data_archiviazione']) && isset($dataMap['data_finepubblicazione'])){
		
		$archiviazione = $dataMap['data_archiviazione']->hasContent() ? date('d/m/Y', $dataMap['data_archiviazione']->toString()) : '';
		$finepubblicazione = $dataMap['data_finepubblicazione']->hasContent() ? date('d/m/Y', $dataMap['data_finepubblicazione']->toString()) : '';
		$now = time();

		if ($dataMap['data_archiviazione']->hasContent() &&  $dataMap['data_finepubblicazione']->hasContent()){
			if ($dataMap['data_archiviazione']->toString() > $now || $dataMap['data_finepubblicazione']->toString() > $now){
				$cli->error(" - " . $node->attribute('name') . ' data_archiviazione:' . $archiviazione . ' data_finepubblicazione:' . $finepubblicazione);
				$cli->error('  -> https://' . eZINI::instance()->variable('SiteSettings', 'SiteURL') . '/content/view/full/' . $node->attribute('node_id') );
			}else{
				$cli->warning(" - " . $node->attribute('name') . ' data_archiviazione:' . $archiviazione . ' data_finepubblicazione:' . $finepubblicazione);
				$cli->warning('  -> https://' . eZINI::instance()->variable('SiteSettings', 'SiteURL') . '/content/view/full/' . $node->attribute('node_id') );
			}
		}else{
			//$cli->output(" - " . $node->attribute('name') . ' data_archiviazione:' . $archiviazione . ' data_finepubblicazione:' . $finepubblicazione);
		}
	}
}

$script->shutdown();