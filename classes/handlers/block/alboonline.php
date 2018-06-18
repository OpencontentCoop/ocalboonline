<?php

use Opencontent\Opendata\Api\ClassRepository;
use Opencontent\Opendata\Api\Values\ContentClass;
use Opencontent\Opendata\Api\ContentSearch;

class BlockHandlerAlboOnLine extends OpenPABlockHandler
{
    /**
     * @var eZContentObjectTreeNode
     */
    protected $currentSubTreeNode;

    protected $parameters = array();

    private $queryParts = array();

    protected function run()
    {
        try{
            $this->parseParameters();
        }catch(Exception $e){
            $this->data['error'] = $e->getMessage();
        }
        $this->data['root_node'] = $this->currentSubTreeNode;
        $this->data['has_content'] = false;
        $this->data['content'] = array();
        $this->data['parameters'] = $this->parameters;
    }

    private function validateParameters()
    {
        $requiredList = array(
            'node_id',
            'class',
            'fields',
        );
        $settings = eZINI::instance('block.ini')->group('AlboOnLine');
        foreach ($requiredList as $required) {
            if (!isset( $this->currentCustomAttributes[$required] )) {
                $message = 'Occorre specificare il parametro ' . $settings['CustomAttributeNames'][$required];
                eZDebug::writeError($message, __METHOD__);
                throw new Exception($message, 1);
            }
        }
    }

    private function parseParameters()
    {
        $this->validateParameters();

        $language = 'ita-IT'; //eZLocale::currentLocaleCode();
        $repo = new ClassRepository();
        $ignoreLimitations = (int)$this->currentCustomAttributes['ignore_limitations'] == 1;

        $this->queryParts = array();

        $this->currentSubTreeNode = OpenPABase::fetchNode($this->currentCustomAttributes['node_id']);
        if (!$this->currentSubTreeNode instanceof eZContentObjectTreeNode){            
            $message = "Sorgente non trovata: " . $this->currentCustomAttributes['node_id'];
            eZDebug::writeError($message, __METHOD__);
            throw new Exception($message, 1);
        }
        $this->queryParts[] = "subtree [" . $this->currentSubTreeNode->attribute('node_id') . "]";

        $class = $repo->load(trim($this->currentCustomAttributes['class']));
        if (!$class instanceof ContentClass){            
            $message = "Classe non trovata: " . $this->currentCustomAttributes['class'];
            eZDebug::writeError($message, __METHOD__);
            throw new Exception($message, 1);
        }
        $this->queryParts[] = "classes [" . $class->identifier . "]";

        if (isset($this->currentCustomAttributes['depth']) && is_numeric($this->currentCustomAttributes['depth'])){
            $this->queryParts[] = 'raw[meta_depth_si] range ['
                . $this->currentSubTreeNode->attribute('depth') . "," . ($this->currentSubTreeNode->attribute('depth')+$this->currentCustomAttributes['depth'])
                . ']';
        }

        $fields = array();
        $fieldIdentifiers = explode(',', $this->currentCustomAttributes['fields']);
        foreach ($fieldIdentifiers as $fieldIdentifier) {
            $fieldIdentifierParts = explode('.', $fieldIdentifier);
            foreach ($class->fields as $classField) {
                if ($fieldIdentifierParts[0] == $classField['identifier']){
                    $field = $classField;
                    if (isset($fieldIdentifierParts[1]) && $classField['dataType'] == 'ezmatrix'){
                        $field['matrix_column'] = $fieldIdentifierParts[1];
                    }
                    $fields[] = $field;
                }
            }
        }

        $columns = array();
        foreach ($fields as $field) {
            $title = $field['name'][$language];
            if (isset($field['matrix_column'])){
                foreach ($field['template']['format'][0][0] as $columnIdentifier => $columnName) {
                    if ($columnIdentifier == $field['matrix_column']){
                        $title .= ' ' . str_replace('string (', '', str_replace(')', '', $columnName));
                        break;
                    }
                }
            }
            $columns[] = array(
                'data' => "data.{$language}." . $field['identifier'],
                'name' => $field['identifier'],
                'title' => $title,
                'searchable' => $field['isSearchable'] && $field['dataType'] != 'ezmatrix',
                'orderable' => $field['isSearchable'] && $field['dataType'] != 'ezmatrix',
            );
        }

        $facetQueryParts = array();
        $groupFacets = array();
        if (!empty($this->currentCustomAttributes['group'])){
            $groupBy = $this->currentCustomAttributes['group'];
            $facetQueryParts[] = 'limit 1';
            $facetQueryParts[] = 'facets [' . $groupBy . '|alpha|100]';
            $facetQuery = implode(' and ', array_merge($this->queryParts, $facetQueryParts));
            $groupFacets = $this->getGroupFacets($groupBy, $facetQuery);
        }

        $stateFacets = array();
        if (!empty($this->currentCustomAttributes['states_enabled'])){
            /** @var eZContentObjectState[] $alboStates */
            $alboStates = OcAlboOnLineStates::getStates();
            $states = explode(',', $this->currentCustomAttributes['states_enabled']);
            $states = array_map('trim', $states);
            foreach ($states as $state) {
                if ($state[0] == '*' && eZUser::currentUser()->attribute('is_logged_in')){
                    $state = str_replace('*', '', $state);
                }
                foreach ($alboStates as $alboState) {
                    if ($alboState->attribute('identifier') == $state){
                        $stateFacets[] = array(
                            'field' => 'state',
                            'operator' => 'in',
                            'value' => '["' . $alboState->attribute('id') . '"]',
                            'name' => $alboState->attribute('current_translation')->attribute('name')
                        );
                        break;
                    }
                }
            }
        }

        $initialGroupFacets = array();
        if (count($stateFacets) == 1 && !empty($this->currentCustomAttributes['group'])){
            $initialGroupFacetsQueryParts = $facetQueryParts;
            $initialGroupFacetsQueryParts[] = $stateFacets[0]['field'] . ' ' . $stateFacets[0]['operator'] . ' ' . str_replace('"', "'", $stateFacets[0]['value']); 
            $initialGroupFacetsQuery = implode(' and ', array_merge($this->queryParts, $initialGroupFacetsQueryParts));
            $initialGroupFacets = $this->getGroupFacets($groupBy, $initialGroupFacetsQuery);
        }

        $this->parameters['query'] = implode(' and ', $this->queryParts);
        $this->parameters['group_facet_query_part'] = implode(' and ', $facetQueryParts);
        $this->parameters['group_facets'] = $groupFacets;
        $this->parameters['initial_group_facets'] = $initialGroupFacets;
        $this->parameters['state_facets'] = $stateFacets;
        $this->parameters['searching'] = !empty($this->currentCustomAttributes['show_search']);
        $limit = (int)$this->currentCustomAttributes['limit'];
        if ($limit == 0){
            $limit = 10;
        }
        $this->parameters['length'] = $limit;
        $this->parameters['fields'] = $fields;
        $this->parameters['columns'] = $columns;
        $this->parameters['ignore_limitations'] = $ignoreLimitations;
    }

    private function getGroupFacets($groupBy, $facetQuery)
    {
        $contentSearch = new ContentSearch();
        $contentSearch->setEnvironment(new FullEnvironmentSettings());
        $ignoreLimitations = (int)$this->currentCustomAttributes['ignore_limitations'] == 1;
        $limitations = $ignoreLimitations ? array() : null;

        $groupFacets = array();
        $facets = array();
        try{
            eZDebug::writeDebug($facetQuery, __METHOD__);
            $facetSearchResults = (array)$contentSearch->search($facetQuery, $limitations);
        }catch(Exception $e){
            eZDebug::writeError($e->getMessage(), __METHOD__);
            throw new Exception("Errore processando il raggruppemento in $facetQuery: " . $e->getMessage(), 1);

        }
        if (isset($facetSearchResults['facets'][0]['data'])){
            foreach ($facetSearchResults['facets'][0]['data'] as $key => $value) {
                if (strpos($groupBy, 'year____dt') !== false){
                    $key = str_replace('-01-01T00:00:00Z', '', $key);
                }
                if ($value > 0){
                    $facets[] = $key;
                }
            }
        }
        if ($groupBy == 'anno' || strpos($groupBy, 'dt') !== false){
            $facets = array_reverse($facets);
        }

        if (!empty($facets)){
            foreach ($facets as $facet) {
                $groupFacets[] = array(
                    'field' => $groupBy,
                    'operator' => (strpos($groupBy, 'year____dt') !== false) ? 'range' : 'in',
                    'value' => (strpos($groupBy, 'year____dt') !== false) ? "[\"{$facet}-01-01T00:00:00Z\",\"{$facet}-12-31T23:59:00Z\"]" : "[\"{$facet}\"]",
                    'name' => $facet
                );
            }
        }

        return $groupFacets;
    }

}