<?php
$Module = array('name' => 'Albo on-line');

$ViewList = array();
$ViewList['dashboard'] = array(
    'script' => 'dashboard.php',
    'functions' => array('use')
);
$ViewList['bussola'] = array(
    'script' => 'bussola.php',
    'functions' => array('use')
);

$FunctionList = array();
$FunctionList['use'] = array();