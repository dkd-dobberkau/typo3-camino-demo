<?php

declare(strict_types=1);

namespace Enhancely\Enhancely\Middleware;

use Enhancely\Client;
use Enhancely\Enhancely\Configuration\ExtensionConfiguration;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\MiddlewareInterface;
use Psr\Http\Server\RequestHandlerInterface;
use Psr\Log\LoggerInterface;
use TYPO3\CMS\Core\Cache\Frontend\FrontendInterface;
use TYPO3\CMS\Core\Http\StreamFactory;
use TYPO3\CMS\Frontend\Controller\TypoScriptFrontendController;

final class JsonLdMiddleware implements MiddlewareInterface
{
    public function __construct(
        private readonly ExtensionConfiguration $configuration,
        private readonly FrontendInterface $cache,
        private readonly LoggerInterface $logger,
        private readonly StreamFactory $streamFactory,
    ) {}

    public function process(ServerRequestInterface $request, RequestHandlerInterface $handler): ResponseInterface
    {
        $response = $handler->handle($request);

        if (!$this->shouldProcess($request, $response)) {
            return $response;
        }

        return $this->injectJsonLd($request, $response);
    }

    private function shouldProcess(ServerRequestInterface $request, ResponseInterface $response): bool
    {
        // Check if extension is enabled
        if (!$this->configuration->isEnabled()) {
            return false;
        }

        // Check if API key is configured
        if ($this->configuration->getApiKey() === '') {
            return false;
        }

        // Only process HTML responses
        $contentType = $response->getHeaderLine('Content-Type');
        if (!str_contains($contentType, 'text/html')) {
            return false;
        }

        // Only process successful responses
        if ($response->getStatusCode() !== 200) {
            return false;
        }

        // Check excluded page types
        $tsfe = $request->getAttribute('frontend.controller');
        if ($tsfe instanceof TypoScriptFrontendController) {
            $pageType = (int)$tsfe->page['doktype'];
            if (in_array($pageType, $this->configuration->getExcludedPageTypes(), true)) {
                return false;
            }
        }

        return true;
    }

    private function injectJsonLd(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $url = (string)$request->getUri();
        $cacheIdentifier = $this->getCacheIdentifier($url);

        // Get cached ETag
        $cachedData = $this->cache->get($cacheIdentifier);
        $cachedEtag = $cachedData['etag'] ?? null;
        $cachedJsonLd = $cachedData['jsonld'] ?? null;

        try {
            // Set API key
            Client::setApiKey($this->configuration->getApiKey());

            // Request JSON-LD from Enhancely
            $enhancelyResponse = Client::jsonld(
                url: $url,
                etag: $cachedEtag
            );

            if ($enhancelyResponse->notModified() && $cachedJsonLd !== null) {
                // Content unchanged, use cached JSON-LD
                $jsonLdScript = $cachedJsonLd;
            } elseif ($enhancelyResponse->ready()) {
                // New content available
                $jsonLdScript = (string)$enhancelyResponse;

                // Cache the new data
                $this->cache->set(
                    $cacheIdentifier,
                    [
                        'etag' => $enhancelyResponse->etag(),
                        'jsonld' => $jsonLdScript,
                    ],
                    ['pages'],
                    $this->configuration->getCacheLifetime()
                );
            } else {
                // Not ready yet or error, skip injection
                if ($enhancelyResponse->error()) {
                    $this->logger->warning('Enhancely API error', [
                        'url' => $url,
                        'error' => $enhancelyResponse->error(),
                    ]);
                }
                return $response;
            }

            // Inject JSON-LD before </head>
            $body = (string)$response->getBody();
            $modifiedBody = $this->insertBeforeHeadClose($body, $jsonLdScript);

            return $response->withBody(
                $this->streamFactory->createStream($modifiedBody)
            );
        } catch (\Throwable $e) {
            $this->logger->error('Enhancely JSON-LD injection failed', [
                'url' => $url,
                'exception' => $e->getMessage(),
            ]);
            return $response;
        }
    }

    private function getCacheIdentifier(string $url): string
    {
        return 'enhancely_' . md5($url);
    }

    private function insertBeforeHeadClose(string $html, string $jsonLd): string
    {
        $position = stripos($html, '</head>');
        if ($position === false) {
            return $html;
        }

        return substr($html, 0, $position) . "\n" . $jsonLd . "\n" . substr($html, $position);
    }
}
