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

$user = eZUser::fetchByName('admin');
eZUser::setCurrentlyLoggedInUser( $user, $user->attribute( 'contentobject_id' ) );

$classes = ['determinazione', 'deliberazione', 'decreto'];

$nodes = eZContentObjectTreeNode::subTreeByNodeID([
	'ClassFilterType' => 'include',
	'ClassFilterArray' => $classes,
	'Limitation' => array(),
], 1);

$states = array();

function getState( $identifier )
{
    global $states;

    if (isset($states[$identifier])){
    	return $states[$identifier];
    }

    @list( $groupIdentifier, $stateIdentifier ) = explode( '/', $identifier );

    $stateObject = null;
    $stateGroup = eZContentObjectStateGroup::fetchByIdentifier( $groupIdentifier );
    if ( $stateGroup instanceof eZContentObjectStateGroup )
    {
        $stateObject = $stateGroup->stateByIdentifier( $stateIdentifier );
    }

    if ( !$stateObject instanceof eZContentObjectState ){
        throw new Exception( "State $identifier not found" );
    }

    $states[$identifier] = $stateObject;

    return $stateObject;
}

$old = 'albo_on_line/archiviato';
$new = 'albo_on_line/riservato';

$newstate = getState($new);

foreach ($nodes as $node) {
	$object = $node->object();
	if (in_array($old, $object->attribute('state_identifier_array'))){
		$cli->output($object->attribute('name'));
		eZContentOperationCollection::updateObjectState($object->attribute('id'), [$newstate->attribute('id')]);
	}
}

$script->shutdown();