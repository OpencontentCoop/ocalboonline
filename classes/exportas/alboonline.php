<?php

use Opencontent\Opendata\Api\ContentSearch;
use Opencontent\Opendata\Api\ClassRepository;
use Opencontent\Opendata\Api\AttributeConverterLoader;

class AlboOnLineCSVExporter extends SearchQueryCSVExporter
{
    private $blockParameters;

    public function __construct($parentNodeId, $blockId)
    {
        $http = eZHTTPTool::instance();
        $this->functionName = 'csv';

        $this->block = eZPageBlock::fetch($blockId);
        if ( $this->block instanceof eZPageBlock) {
            $handler = new BlockHandlerAlboOnLine($this->block);
            $this->blockParameters = $handler->attribute('parameters');
            if (isset($this->blockParameters['query'])) {
                $this->queryString = $this->blockParameters['query'];
            }
        }

        $this->ini = eZINI::instance('exportas.ini');
        $this->setOptions($this->ini->group('Settings'));

        $currentEnvironment = new CsvEnvironmentSettings;
        $currentEnvironment->__set('identifier', 'csv');
        $currentEnvironment->__set('debug', false);
        $this->maxSearchLimit = $currentEnvironment->getMaxSearchLimit();
        $this->contentSearch = new ContentSearch();
        $this->contentSearch->setEnvironment($currentEnvironment);

        $this->filename = uniqid('export_');

        $this->classRepository = new ClassRepository();

        $this->language = eZLocale::currentLocaleCode();

        if ($http->hasGetVariable('download_id')){
            $this->downloadId = $http->getVariable('download_id');
            $this->filename = $this->downloadId;
            $this->iteration = intval( $http->getVariable('iteration') );
            if ($http->hasGetVariable('download')){
                $this->download = true;
            }
        }
    }

    public function fetch()
    {
        if ($this->queryString === null){
            throw new InvalidArgumentException("Query string not found");
        }
        $limitation = $this->blockParameters['ignore_limitations'] ? array() : null;
        return $this->contentSearch->search($this->queryString, $limitation);
    }

    public function fetchCount()
    {
        if ($this->queryString === null){
            throw new InvalidArgumentException("Query string not found");
        }

        if ($this->count === null) {
            $limitation = $this->blockParameters['ignore_limitations'] ? array() : null;
            $result = $this->contentSearch->search($this->queryString, $limitation);

            $this->count = $result->totalCount;
        }
        return $this->count;
    }

    protected function csvHeaders($item)
    {
        $this->CSVheaders = array();
        foreach ($this->blockParameters['columns'] as $column){
            $this->CSVheaders[] = $column['title'];
        }

        return $this->CSVheaders;
    }

    function transformItem($item)
    {
        $data = $item['data'][$this->language];

        $stringData = array();

        foreach ($this->blockParameters['columns'] as $column){
            $string = '';
            if (isset($column['name'])) {
                $field = $data[$column['name']];
                list($classIdentifier, $identifier) = explode('/', $field['identifier']);
                $converter = AttributeConverterLoader::load(
                    $classIdentifier,
                    $identifier,
                    $field['datatype']
                );
                $string = $converter->toCSVString($field['content']);
            }
            $stringData[$column['title']] = $string;
        }

        return $stringData;
    }
}