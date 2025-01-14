<?php

use Opencontent\Opendata\Rest\Client\PayloadBuilder;

class SyncTrasparenzaTool extends BaseTrasparenzaTool
{
    protected function onLocalFound(
        $remoteBroseItem,
        $remoteContent,
        $localCurrentParentNodeId,
        $localContent
    )
    {
        try {

            if ($this->needSyncContent($remoteContent, $localContent)){
                $this->syncContent($remoteContent, $localCurrentParentNodeId);
            }
            
            $mainNode = eZContentObjectTreeNode::fetch($localContent['metadata']['mainNodeId']);
            if (!$mainNode instanceof eZContentObjectTreeNode) {
                throw new Exception("Main node " . $localContent['metadata']['mainNodeId'] . " of content with remote " . $localContent['metadata']['remoteId'] . " not found");
            }
                        
            $this->syncPriority($mainNode, $localCurrentParentNodeId, $remoteBroseItem);            
            $this->syncLocation($mainNode, $remoteBroseItem);
      
        } catch (Exception $e) {
            $this->currentLog->appendError($e->getMessage());
        }
        
    }

    protected function onLocalNotFound(
        $remoteBroseItem,
        $remoteContent,
        $localCurrentParentNodeId
    )
    {
        try {
            $localContent = $this->syncContent($remoteContent, $localCurrentParentNodeId);
            
            $mainNode = eZContentObjectTreeNode::fetch($localContent['metadata']['mainNodeId']);
            if (!$mainNode instanceof eZContentObjectTreeNode) {
                throw new Exception("Main node " . $localContent['metadata']['mainNodeId'] . " of content with remote " . $localContent['metadata']['remoteId'] . " not found");
            }
            
            $this->syncLocation($mainNode, $remoteBroseItem);
            $this->syncPriority($mainNode, $localCurrentParentNodeId, $remoteBroseItem);
            
            $this->currentLog->write();

            $this->walkTreeChildren($remoteBroseItem, $mainNode->attribute('node_id'));

        } catch (Exception $e) {
            $this->currentLog->appendError($e->getMessage())->write();
        }
    }

    private function syncLocation(eZContentObjectTreeNode $mainNode, $remoteBroseItem)
    {
        if ($mainNode->attribute('class_identifier') == 'pagina_trasparenza') {
            $localParentNode = $mainNode->attribute('parent');
            $localParentObjectRemoteId = $localParentNode->attribute('object')->attribute('remote_id');
            $remoteParentNodeId = $remoteBroseItem['parentNodeId'];

            $remoteBrowseItem = $this->browse($remoteParentNodeId);
            if ($localParentObjectRemoteId != $remoteBrowseItem['remoteId']) {
                $newLocationObject = eZContentObject::fetchByRemoteID($remoteBrowseItem['remoteId']);
                if ($newLocationObject instanceof eZContentObject){
                    $this->currentLog->appendWarning("Sync-location"); // . $localParentNode->attribute('node_id') . ' -> ' . $newLocationObject->attribute('main_node_id'));   
                    eZContentObjectTreeNodeOperations::move($mainNode->attribute('node_id'), $newLocationObject->attribute('main_node_id'));
                }else{
                    $this->currentLog->appendError("Error fetching object " . $remoteBrowseItem['remoteId']);
                }                
            }
        }
    }

    private function syncPriority(eZContentObjectTreeNode $mainNode, $localCurrentParentNodeId, $remoteBroseItem)
    {
        try {
            
            $mainNode->setAttribute('sort_field', $remoteBroseItem['sortField']);
            $mainNode->setAttribute('sort_order', $remoteBroseItem['sortOrder']);
            $mainNode->store();

            if ($mainNode->attribute('priority') != $remoteBroseItem['priority']) {
                $priority = $remoteBroseItem['priority'];
                $nodeID = $mainNode->attribute('node_id');
                
                $db = eZDB::instance();
                $db->begin();                

                $db->query("UPDATE ezcontentobject_tree SET priority={$priority} WHERE node_id={$nodeID} AND parent_node_id={$localCurrentParentNodeId}");
                $db->commit();

                $this->currentLog->appendWarning("Sync-priority from " . $mainNode->attribute('priority') . " to $priority");

            }

        } catch (Exception $e) {
            $this->currentLog->appendError($e->getMessage());
        }

    }

    /**
     * @param array $remoteContent
     * @param int $localCurrentParentNodeId
     * @return array
     * @throws Exception
     */
    private function syncContent($remoteContent, $localCurrentParentNodeId)
    {
        $remoteUrl = $this->remoteUrl;

        $payload = $this->sourceClient->getPayload($remoteContent);

        $payload->setParentNodes(
            array($localCurrentParentNodeId)
        );

        foreach ($payload->getMetadaData('languages') as $locale) {
            if ($payload->hasData('image', $locale)) {
                $imageUrl = $payload->getData('image', $locale);
                $payload->setData($locale, 'image', [
                    'url' => rtrim($remoteUrl, '/') . '/' . ltrim($imageUrl['url'], '/'),
                    'filename' => $imageUrl['filename'],
                ]);
            }

            if ($payload->hasData('decorrenza_di_pubblicazione', $locale)) {
                $data = $payload->getData('decorrenza_di_pubblicazione', $locale);
                $data = array_filter($data);
                if (SyncTrasparenzaTool::isEmpty($data)) {
                    $payload->setData($locale, 'decorrenza_di_pubblicazione', []);
                }
            }

            if ($payload->hasData('aggiornamento', $locale)) {
                $data = $payload->getData('aggiornamento', $locale);
                if (SyncTrasparenzaTool::isEmpty($data)) {
                    $payload->setData($locale, 'aggiornamento', []);
                }
            }

            if ($payload->hasData('licenza', $locale)) {
                $data = $payload->getData('licenza', $locale);
                if (SyncTrasparenzaTool::isEmpty($data)) {
                    $payload->setData($locale, 'licenza', []);
                }
            }

            if ($payload->hasData('referente', $locale)) {
                $payload->unSetData('referente', $locale);
            }

            if ($payload->hasData('termine_pubblicazione', $locale)) {
                $data = $payload->getData('termine_pubblicazione', $locale);
                if (SyncTrasparenzaTool::isEmpty($data)) {
                    $payload->setData($locale, 'termine_pubblicazione', []);
                }
            }
        }

        $response = $this->repository->createUpdate($payload->getArrayCopy());

        if ($response['message'] == 'success') {
            $this->currentLog->appendWarning($response['method']);            
        } else {
            throw new Exception("Invalid response " . var_export($response, 1));
        }

        return $response['content'];
    }
}