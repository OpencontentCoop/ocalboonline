<?php

include( 'autoload.php' );

$siteaccess = OpenPABase::getInstances();


foreach( $siteaccess as $sa )
{
    $command = "php extension/ocalboonline/bin/php/sync_trasparenza.php -s{$sa} ";
    print "\nEseguo: $command \n";
    system( $command );
}
