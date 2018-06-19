<?php

use Opencontent\Opendata\Api\Exception\NotFoundException;

class CheckTrasparenzaTool extends BaseTrasparenzaTool
{

    protected function onLocalFound(
        $remoteBroseItem,
        $remoteContent,
        $localCurrentParentNodeId,
        $localContent
    )
    {
        try{
            $currentObject = eZContentObject::fetchByRemoteID($localContent['metadata']['remoteId']);
            if (!$currentObject instanceof eZContentObject) {
                throw new Exception("Content with remote " . $remoteContent['metadata']['remoteId'] . " not found");
            }
            $mainNode = $currentObject->mainNode();
            if (!$mainNode instanceof eZContentObjectTreeNode){
                throw new Exception("Main node of content with remote " . $currentObject->attribute('remote_id') . " not found");
            }            

            $this->checkPriority($mainNode, $remoteBroseItem['priority']);
            $this->checkLocation($mainNode, $remoteBroseItem);

        } catch (Exception $e) {
            $this->currentLog->appendError($e->getMessage());
        }
    }

    protected function onLocalNotFound(
        $remoteBroseItem,
        $remoteContent,
        $localCurrentParentNodeId
    ){
        $this->currentLog->appendError('Non-trovato')->write();
        $this->findContentAndTellUser($remoteContent['metadata']['name']['ita-IT'], $remoteContent['metadata']['remoteId']);

        $this->walkTreeChildren($remoteBroseItem, -1);
    }

    private function checkPriority(eZContentObjectTreeNode $mainNode, $priority)
    {
        try {
            if ($mainNode->attribute('priority') != $priority) {
                $this->currentLog->appendWarning("$priority/" . $mainNode->attribute('priority'));
            }

        } catch (Exception $e) {
            $this->currentLog->appendError($e->getMessage());
        }

    }

    private function checkLocation(eZContentObjectTreeNode $mainNode, $remoteBroseItem)
    {
        if($mainNode->attribute('class_identifier') == 'pagina_trasparenza'){
            $localParentNode = $mainNode->attribute('parent');
            $localParentObjectRemoteId = $localParentNode->attribute('object')->attribute('remote_id');
            $remoteParentNodeId = $remoteBroseItem['parentNodeId'];

            $remoteBrowseItem = $this->browse($remoteParentNodeId);
            if ($localParentObjectRemoteId != $remoteBrowseItem['remoteId']){
                $this->currentLog->appendError("Collocazione-errata"); //: $localParentObjectRemoteId " . $remoteBrowseItem['remoteId']);
            }
        }
    }

    private function hasWrongName($name)
    {
        $data = array(
            "Oneri informativi per i cittadini e le imprese" => "Oneri informativi per cittadini e imprese",
            "Titolari di incarichi di amministrazione, di direzione o di governo" => "Titolari di incarichi politici, di amministrazione, di direzione o di governo",
            "Titolari di incarichi di consulenza e di collaborazione" => "Titolari di incarichi di collaborazione o consulenza",
            "Titolari di incarichi di consulenza e collaborazione" => "Titolari di incarichi di consulenza e di collaborazione",
            "Titolari di incarichi amministrativi di vertice" => "Titolari di incarichi dirigenziali amministrativi di vertice",
            "Titolari di incarichi dirigenziali" => "Titolari di incarichi dirigenziali (dirigenti non generali)",
            "Incarichi conferiti e autorizzati ai dipendenti" => "Incarichi conferiti e autorizzati ai dipendenti (dirigenti e non dirigenti)",
            "Piano della performance / Piano esecutivo di gestione" => "Piano della performance",
            "Provvedimenti degli organi di indirizzo politico" => "Provvedimenti organi indirizzo politico",
            "Provvedimenti dei dirigenti amministrativi" => "Provvedimenti dirigenti amministrativi",
        );

        foreach ($data as $key => $value) {
            if ($value == $name) {
                return $key;
            }
        }

        return null;
    }

    private function findContentAndTellUser($remoteName, $remoteRemoteId)
    {        
        $query = "titolo = '" . addcslashes($remoteName, "'") . "' and classes [pagina_trasparenza] and subtree [1]";
        eZCLI::instance()->error("Cerco per \"$query\"", false);
        $results = $this->search->search($query);
        if (count($results->searchHits) > 0) {

            foreach ($results->searchHits as $hit) {
                if (!empty($hit['metadata']['name']['ita-IT'])) {
                    $object = eZContentObject::fetchByRemoteID($hit['metadata']['remoteId']);
                    if (!$object instanceof eZContentObject){
                        var_dump($hit['metadata']);die();
                    }
                    $options[] = $hit['metadata']['name']['ita-IT'] . "\n" . '     remoteId: ' . $hit['metadata']['remoteId'] . "\n" . '     path: ' . $object->attribute('main_node')->attribute('path_identification_string');
                }
            }

            if (!empty($options)) {

                eZCLI::instance()->error();
                eZCLI::instance()->error();

                array_unshift($options, 'No grazie');
                $output = new ezcConsoleOutput();
                $menu = new ezcConsoleMenuDialog($output);
                $menu->options = new ezcConsoleMenuDialogOptions();
                $menu->options->text = "Forse devi sostituire il remote_id di uno di questi oggetti?\n";
                $menu->options->validator = new ezcConsoleMenuDialogDefaultValidator(
                    $options,
                    "0"
                );

                $choice = ezcConsoleDialogViewer::displayDialog($menu);
                if ($choice > 0) {
                    $choiceParts = explode("\n", $options[$choice]);
                    $remoteIdParts = explode(':', $choiceParts[1]);
                    $remoteId = trim($remoteIdParts[1]);
                    $object = eZContentObject::fetchByRemoteID($remoteId);                    
                    eZCLI::instance()->warning("Cambio remoteId da $remoteId a " . $remoteRemoteId . ' al nodo ' . $object->attribute('main_node_id'));
                    $object->setAttribute('remote_id', $remoteRemoteId);
                    $object->store();
                    eZSearch::addObject($object);
                }

                eZCLI::instance()->error();
                eZCLI::instance()->error();
            }else{
                eZCLI::instance()->error(" ... nulla");
            }
        } elseif ($wrongName = $this->hasWrongName($remoteName)) {            
            eZCLI::instance()->warning(" ...controllo per \"$wrongName\"");
            $this->findContentAndTellUser($wrongName, $remoteRemoteId);
        } else{
            eZCLI::instance()->error(" ...nulla");
        }
    }
}