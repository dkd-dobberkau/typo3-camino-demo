<?php

declare(strict_types=1);

use Enhancely\Enhancely\Middleware\JsonLdMiddleware;

return [
    'frontend' => [
        'enhancely/jsonld' => [
            'target' => JsonLdMiddleware::class,
            'after' => [
                'typo3/cms-frontend/content-length-headers',
            ],
            'before' => [
                'typo3/cms-frontend/output-compression',
            ],
        ],
    ],
];
