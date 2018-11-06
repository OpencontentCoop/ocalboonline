<?php

use Opencontent\Opendata\Api\ContentSearch;
use Opencontent\Opendata\Api\EnvironmentLoader;

class DataHandlerAlboOnLine implements OpenPADataHandlerInterface
{
    protected $block;
    protected $datatableSearch;
    protected $contentSearch;
    
    public function __construct( array $Params )
    {
        $blockId = isset($Params['Parameters'][1]) ? $Params['Parameters'][1] : 0;
        $this->block = eZPageBlock::fetch($blockId);
        
        $this->datatableSearch = new ContentSearch();     
        $currentEnvironment = new AlboOnLineEnvironmentSettings();
        $parser = new ezpRestHttpRequestParser();
        $request = $parser->createRequest();
        $currentEnvironment->__set('request', $request);
        $this->datatableSearch->setEnvironment($currentEnvironment);

        $this->contentSearch = new ContentSearch();     
        $defaultEnvironment = new DefaultEnvironmentSettings();
        $parser = new ezpRestHttpRequestParser();
        $request = $parser->createRequest();
        $defaultEnvironment->__set('request', $request);
        $this->contentSearch->setEnvironment($defaultEnvironment);
    }

    public function getData()
    {
        $data = array();
        if ( $this->block instanceof eZPageBlock){
            $handler = new BlockHandlerAlboOnLine($this->block);
            $parameters = $handler->attribute('parameters');
            if (isset($parameters['query'])){                
                if(isset($_GET['search_facets'])){
                    $query = $parameters['query'] . ' and ' . $_GET['search_facets'];
                    try{
                        $limitation = $parameters['ignore_limitations'] ? array() : null;
                        $data = (array)$this->contentSearch->search($query, $limitation);
                        $data['searchHits'] = array();
                    }catch(Exception $e){
                        $data['error'] = $e->getMessage();
                    }
                }else{
                    $query = urldecode(eZHTTPTool::instance()->getVariable('q', '')) . ' ' . $parameters['query'];
                    try{
                        $limitation = $parameters['ignore_limitations'] ? array() : null;
                        $data = (array)$this->datatableSearch->search($query, $limitation);
                    }catch(Exception $e){
                        $data['error'] = $e->getMessage();
                    }
                }
            }
        }
        return $data;
    }
}
