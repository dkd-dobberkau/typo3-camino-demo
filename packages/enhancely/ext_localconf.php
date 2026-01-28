<?php

declare(strict_types=1);

use TYPO3\CMS\Core\Cache\Backend\Typo3DatabaseBackend;

defined('TYPO3') or die();

// Register cache for ETags
$GLOBALS['TYPO3_CONF_VARS']['SYS']['caching']['cacheConfigurations']['enhancely_etag'] ??= [
    'frontend' => \TYPO3\CMS\Core\Cache\Frontend\VariableFrontend::class,
    'backend' => Typo3DatabaseBackend::class,
    'options' => [
        'defaultLifetime' => 86400, // 24 hours
    ],
    'groups' => ['pages'],
];
