<?php

declare(strict_types=1);

namespace Enhancely\Enhancely\Configuration;

use TYPO3\CMS\Core\Configuration\ExtensionConfiguration as Typo3ExtensionConfiguration;
use TYPO3\CMS\Core\SingletonInterface;

final class ExtensionConfiguration implements SingletonInterface
{
    private array $configuration;

    public function __construct(
        private readonly Typo3ExtensionConfiguration $extensionConfiguration
    ) {
        $this->configuration = $this->extensionConfiguration->get('enhancely');
    }

    public function getApiKey(): string
    {
        return trim((string)($this->configuration['apiKey'] ?? ''));
    }

    public function isEnabled(): bool
    {
        return (bool)($this->configuration['enabled'] ?? true);
    }

    public function getExcludedPageTypes(): array
    {
        $types = trim((string)($this->configuration['excludedPageTypes'] ?? ''));
        if ($types === '') {
            return [];
        }
        return array_map('intval', explode(',', $types));
    }

    public function getCacheLifetime(): int
    {
        return (int)($this->configuration['cacheLifetime'] ?? 86400);
    }
}
