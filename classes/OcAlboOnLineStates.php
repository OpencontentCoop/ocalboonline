<?php

class OcAlboOnLineStates
{
    const GROUP = 'albo_on_line';

    const STATE_IN_PUBBLICAZIONE = 'in_pubblicazione';

    const STATE_ARCHIVIATO = 'archiviato';

    const STATE_RISERVATO = 'riservato';

    const STATE_NON_VISIBILE = 'non_visibile';

    const STATE_ANNULLATO = 'annullato';

    private static $states;

    /**
     * Conversione degli stati dall'Albo telematico trentino
     *
     * @see AlbotelematicoHelperBase
     */
    public static function convertFromAlbotelematico()
    {
        $map = array(
            'visibile' => self::STATE_IN_PUBBLICAZIONE,
            'archivioricercabile' => self::STATE_ARCHIVIATO,
            'archiviononricercabile' => self::STATE_RISERVATO,
            'nonvisibile' => self::STATE_NON_VISIBILE,
            'annullato' => self::STATE_ANNULLATO
        );

        $stateGroup = eZContentObjectStateGroup::fetchByIdentifier('albotelematico');
        if ($stateGroup instanceof eZContentObjectStateGroup) {
            /** @var eZContentObjectState $state */
            foreach ($stateGroup->states() as $state) {
                $identifier = $state->attribute('identifier');
                foreach ($map as $old => $new) {
                    $name = ucfirst(str_replace('_', ' ', $new));

                    if ($old == $identifier) {
                        $state->setAttribute('identifier', $new);
                        $state->store();

                        /** @var eZContentObjectStateLanguage[] $translations */
                        $translations = eZContentObjectStateLanguage::fetchByState($state->attribute('id'));
                        foreach ($translations as $translation){
                            $translation->setAttribute('name', $name);
                            $translation->store();
                        }
                    }
                }
            }
            $stateGroup->setAttribute('identifier', self::GROUP);
            $stateGroup->store();

            return true;
        }

        return false;
    }

    /**
     * @return eZContentObjectState[]
     */
    public static function getStates()
    {
        if (self::$states === null) {
            self::$states = array();
            $stateGroup = eZContentObjectStateGroup::fetchByIdentifier(self::GROUP);
            if ($stateGroup instanceof eZContentObjectStateGroup) {
                self::$states = $stateGroup->states();
            }
        }

        return self::$states;
    }

}
