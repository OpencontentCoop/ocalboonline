<?php

class OcAlboOnLineType extends eZWorkflowEventType
{
    const WORKFLOW_TYPE_STRING = 'ocalboonline';
    
    function __construct()
    {
        $this->eZWorkflowEventType( self::WORKFLOW_TYPE_STRING,  ezpI18n::tr( 'ocalboonline/event', "Workflow Alboonline" ) );
        $this->setTriggerTypes( array( 'content' => array( 'publish' => array( 'before', 'after' ) ) ) );
    }


    function execute( $process, $event )
    {
        $parameters = $process->attribute( 'parameter_list' );
        $object = eZContentObject::fetch( $parameters['object_id'] );
        if ($object->attribute('current_version') == 1){
            $dataMap = $object->dataMap();
            if (isset($dataMap['data_iniziopubblicazione'])){
                $dataMap['data_iniziopubblicazione']->fromString(time());
                $dataMap['data_iniziopubblicazione']->store();
            }
        }
        return eZWorkflowType::STATUS_ACCEPTED;
    }

}

eZWorkflowEventType::registerEventType( OcAlboOnLineType::WORKFLOW_TYPE_STRING, "OcAlboOnLineType" );

