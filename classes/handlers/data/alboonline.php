<?php

use Opencontent\Opendata\Api\ContentSearch;
use Opencontent\Opendata\Api\EnvironmentLoader;

class DataHandlerAlboOnLine implements OpenPADataHandlerInterface
{
    protected $block;
    protected $contentSearch;    
    
    public function __construct( array $Params )
    {
        $blockId = isset($Params['Parameters'][1]) ? $Params['Parameters'][1] : 0;
        $this->block = eZPageBlock::fetch($blockId);
        
        $this->contentSearch = new ContentSearch();     
        $currentEnvironment = new AlboOnLineEnvironmentSettings();
        $parser = new ezpRestHttpRequestParser();
        $request = $parser->createRequest();
        $currentEnvironment->__set('request', $request);

        $this->contentSearch->setEnvironment($currentEnvironment);
    }

    public function getData()
    {
        $data = array();
        if ( $this->block instanceof eZPageBlock){
            $handler = new BlockHandlerAlboOnLine($this->block);
            $parameters = $handler->attribute('parameters');
            if (isset($parameters['query'])){                
                $query = urldecode(eZHTTPTool::instance()->getVariable('q', '')) . ' ' . $parameters['query'];
                try{
                    $limitation = $parameters['ignore_limitations'] ? array() : null;
                    $data = (array)$this->contentSearch->search($query, $limitation);
                }catch(Exception $e){
                    $data['error'] = $e->getMessage();
                }
            }
        }
        return $data;
    }
}
