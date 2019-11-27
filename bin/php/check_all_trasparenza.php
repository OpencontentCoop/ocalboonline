<?php
require 'autoload.php';

$script = eZScript::instance(array('description' => (""),
    'use-session' => false,
    'use-modules' => true,
    'use-extensions' => false));

$script->startup();

$options = $script->getOptions('[remote:][root_node:][sync_classes][force]',
    '',
    array(
        'remote' => "Remote url",
        'root_node' => "Remote root node",
        'sync_classes' => "Sincronizza le classi",
    )
);
$script->initialize();
$script->setUseDebugAccumulators(true);
$output = new ezcConsoleOutput();
$cli = eZCLI::instance();

$siteaccess = OpenPABase::getInstances();

$optionsArgs = '';
if ($options['remote']){
	$optionsArgs .= ' --remote="' . $options['remote'] . '"';
}
if ($options['root_node']){
	$optionsArgs .= ' --root_node=' . $options['root_node'];
}
if ($options['sync_classes']){
	$optionsArgs .= ' --sync_classes';
}

foreach( $siteaccess as $sa )
{
    $command = "php extension/ocalboonline/bin/php/check_trasparenza.php -s{$sa} $optionsArgs";
    $cli->error("Eseguo: $command");
    $cli->output();
    system( $command );
    $cli->output();
}

$script->shutdown();