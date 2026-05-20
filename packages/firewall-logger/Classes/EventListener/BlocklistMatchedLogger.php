<?php

declare(strict_types=1);

namespace Dkd\FirewallLogger\EventListener;

use Flowd\Phirewall\Events\BlocklistMatched;
use Psr\Log\LoggerInterface;
use TYPO3\CMS\Core\Attribute\AsEventListener;

final readonly class BlocklistMatchedLogger
{
    public function __construct(
        private LoggerInterface $logger,
    ) {
    }

    #[AsEventListener]
    public function __invoke(BlocklistMatched $event): void
    {
        $request = $event->serverRequest;
        $serverParams = $request->getServerParams();

        $this->logger->notice('Firewall blocked request', [
            'rule' => $event->rule,
            'method' => $request->getMethod(),
            'uri' => (string)$request->getUri(),
            'remote_addr' => $serverParams['REMOTE_ADDR'] ?? null,
            'user_agent' => $request->getHeaderLine('User-Agent'),
            'referer' => $request->getHeaderLine('Referer') ?: null,
        ]);
    }
}
