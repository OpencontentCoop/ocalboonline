<?php

use Opencontent\Opendata\Rest\Client\HttpClient;
use Opencontent\Opendata\Api\ContentRepository;
use Opencontent\Opendata\Api\ContentSearch;
use Opencontent\Opendata\Api\Exception\NotFoundException;

abstract class BaseTrasparenzaTool
{
    protected $remoteUrl;

    /**
     * @var HttpClient
     */
    protected $sourceClient;

    protected $classIdentifiers = array('trasparenza', 'pagina_trasparenza');

    /**
     * @var ContentRepository
     */
    protected $repository;

    /**
     * @var ContentSearch
     */
    protected $search;

    /**
     * @var LogLine
     */
    protected $currentLog;

    protected static $level = 0;

    protected static $browseItems = array();

    protected static $readItems = array();

    public function __construct(
        $remoteUrl,
        $classIdentifiers = null
    ) {
        $this->remoteUrl = $remoteUrl;
        $this->sourceClient = new HttpClient($remoteUrl);

        if ($classIdentifiers)
            $this->classIdentifiers = $classIdentifiers;

        $this->repository = new ContentRepository();
        $this->repository->setCurrentEnvironmentSettings(new DefaultEnvironmentSettings());

        $this->search = new ContentSearch();
        $this->search->setCurrentEnvironmentSettings(new DefaultEnvironmentSettings());

        eZDB::setErrorHandling( eZDB::ERROR_HANDLING_EXCEPTIONS );
    }

    public function run($remoteRootNodeId, $localCurrentParentNodeId)
    {
        $this->walkTree($remoteRootNodeId, $localCurrentParentNodeId);
    }

    protected function walkTreeChildren($remoteBroseItem, $localCurrentParentNodeId)
    {
        self::$level++;
        if ($remoteBroseItem['childrenCount'] > 0) {            
            foreach ($remoteBroseItem['children'] as $index => $item) {
                if (($this->classIdentifiers && in_array($item['classIdentifier'], $this->classIdentifiers)) || !$this->classIdentifiers) {
                    $this->walkTree($item['mainNodeId'], $localCurrentParentNodeId, $index);
                }
            }
        }
        self::$level--;
    }

    protected function browse($remoteNodeId)
    {
        if (!isset(self::$browseItems[$remoteNodeId])){
            self::$browseItems[$remoteNodeId] = $this->sourceClient->browse($remoteNodeId, 100);
        }

        return self::$browseItems[$remoteNodeId];
    }

    protected function read($remoteId)
    {
        if (!isset(self::$readItems[$remoteId])){
            self::$readItems[$remoteId] = $this->sourceClient->read($remoteId);
        }

        return self::$readItems[$remoteId];
    }

    protected function walkTree($remoteRootNodeId, $localCurrentParentNodeId)
    {
        $this->currentLog = new LogLine(self::$level);
        $remoteBroseItem = $this->browse($remoteRootNodeId);
        $remoteContent = $this->read($remoteBroseItem['id']);

        $this->currentLog->appendNotice($remoteContent['metadata']['name']['ita-IT']);

        try {
            $localContent = $this->repository->read($remoteContent['metadata']['remoteId']);            
            $this->onLocalFound(
                $remoteBroseItem,
                $remoteContent,
                $localCurrentParentNodeId,
                $localContent
            );

            $this->currentLog->write();
            
            $this->walkTreeChildren($remoteBroseItem, $localContent['metadata']['mainNodeId']);

        } catch (Exception $e) {

            if ($e instanceof NotFoundException) {
                $this->onLocalNotFound(
                    $remoteBroseItem,
                    $remoteContent,
                    $localCurrentParentNodeId
                );
            }else{
                $this->currentLog->appendError($e->getMessage())->write();
            }
        }
    }

    abstract protected function onLocalFound(
        $remoteBroseItem,
        $remoteContent,
        $localCurrentParentNodeId,
        $localContent
    );

    abstract protected function onLocalNotFound(
        $remoteBroseItem,
        $remoteContent,
        $localCurrentParentNodeId
    );

    protected static function moveChildren(eZContentObject $object, $parentFrom, $parentTo)
    {
        eZCLI::instance()->error("Move content from $parentFrom to $parentTo", false);
        $fromNode = $toNode = null;
        $assignedNodes = $object->assignedNodes();
        foreach($assignedNodes as $assignedNode){
            if ($assignedNode->attribute('parent_node_id') == $parentFrom){
                $fromNode = $assignedNode;
            }
            if ($assignedNode->attribute('parent_node_id') == $parentTo){
                $toNode = $assignedNode;
            }
        }

        if ($fromNode instanceof eZContentObjectTreeNode && $toNode instanceof eZContentObjectTreeNode ){
            /** @var eZContentObjectTreeNode[] $children */
            $children = $fromNode->children();
            foreach($children as $child){
                eZContentObjectTreeNodeOperations::move(
                    $child->attribute('node_id'),
                    $toNode->attribute('node_id')
                );
            }

            if ($fromNode->childrenCount() == 0){
                eZContentOperationCollection::removeNodes(array($fromNode->attribute('node_id')));
            }
        }

    }

    protected static function isEmpty($data)
    {
        if (empty( $data )) {
            return true;
        }

        $isEmpty = false;
        if (is_array($data)) {
            foreach ($data as $item) {
                if (!$isEmpty) {
                    $isEmpty = self::isEmpty($item);
                }
            }
        }

        return $isEmpty;
    }

    protected function needSyncContent($remoteContent, $localContent)
    {
        $remoteData = $remoteContent['data']['ita-IT'];
        $localData = $localContent['data']['ita-IT'];

        foreach ($remoteData as $key => $remoteValue) {
            if ($key == 'referente'){
                continue;
            }
            $localValue = $localData[$key];
            if ($this->hasDiff($remoteValue, $localValue)){
                $this->currentLog->appendWarning("Diff in $key");
                return true;
            }
        }

        return false;
    }

    protected function hasDiff($remoteValue, $localValue)
    {
        if (is_string($remoteValue)){            
            return $this->cleanForDiff($remoteValue) != $this->cleanForDiff($localValue);
        }else{            
            foreach ($remoteValue as $key => $value) {
                if ($this->hasDiff($value, $localValue[$key])){
                    return true;
                }
            }
        }
        return false;
    }

    protected function cleanForDiff($value)
    {
        $value = strip_tags($value);
        $value = preg_replace('/\s/', '', $value);
        $value = trim($value);

        return $value;
    }

}