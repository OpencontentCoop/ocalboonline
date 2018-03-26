<?php

class ObjectHandlerServiceAlboOnLine extends ObjectHandlerServiceBase
{
    function run()
    {
        $this->fnData['allowed_state_identifiers'] = 'getAllowedStateIdentifiers';
        $this->fnData['anonymous_allowed_state_identifiers'] = 'getAnonymousAllowedStateIdentifiers';
        $this->fnData['allowed_states'] = 'getAllowedStates';
    }

    protected function getAllowedStateIdentifiers()
    {
        return array("in_pubblicazione", "archiviato", "riservato");
    }

    protected function getAnonymousAllowedStateIdentifiers()
    {
        return array("in_pubblicazione", "archiviato");
    }

    protected function getAllowedStates()
    {
        $result = array();
        $states = OcAlboOnLineStates::getStates();
        foreach ($states as $state){
            if (in_array($state->attribute('identifier'), $this->getAllowedStateIdentifiers())){
                $result[] = $state;
            }
        }

        return $result;
    }

}
