<?php

use Opencontent\Opendata\Api\Values\Content;

class AlboOnLineEnvironmentSettings extends DatatableEnvironmentSettings
{
    public function filterSearchResult(
        \Opencontent\Opendata\Api\Values\SearchResults $searchResults,
        \ArrayObject $query,
        \Opencontent\QueryLanguage\QueryBuilder $builder
    ) {

        $parameters = $this->request->get;
        $columns = $parameters['columns'];
        $requestNames = array();
        foreach( $columns as $index => $column ){
            $requestNames[] = $column['name'];
        }

        foreach($searchResults->searchHits as &$content){
            $fixData = array();
            foreach($content['data'] as $language => $data){
                $diff = array_diff($requestNames, array_keys($data));
                $missing = array_intersect($builder->fields, $diff);
                if (!empty($missing)){
                    $data = array_merge($data, array_fill_keys($missing, null));
                }
                $fixData[$language] = $data;
                $content['data'] = $fixData;
            }
        }

        return array(
            'draw' => (int)( ++$this->request->get['draw']),
            'recordsTotal' => (int)$searchResults->totalCount,
            'recordsFiltered' => (int)$searchResults->totalCount,
            'data' => $searchResults->searchHits,
            'facets' => $searchResults->facets,
            'query' => $query
        );
    }
    
    protected function filterMetaData(Content $content)
    {
        return $content;
    }  

    public function filterContent(Content $content)
    {
        $language = \eZLocale::currentLocaleCode();     
        $object = $content->getContentObject($language);        
        $content = parent::filterContent($content);
        $content['metadata']['can_read'] = $object->canRead();
        
        return $content;
    }  
        
}
