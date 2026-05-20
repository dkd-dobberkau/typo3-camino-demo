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
        $remoteAddr = $serverParams['REMOTE_ADDR'] ?? null;

        $forwardedFor = $request->getHeaderLine('X-Forwarded-For');
        $clientIp = $forwardedFor !== ''
            ? trim(explode(',', $forwardedFor)[0])
            : $remoteAddr;

        $this->logger->warning('Firewall blocked request', [
            'rule' => $event->rule,
            'method' => $request->getMethod(),
            'uri' => (string)$request->getUri(),
            'client_ip' => $clientIp,
            'remote_addr' => $remoteAddr,
            'user_agent' => $request->getHeaderLine('User-Agent'),
            'referer' => $request->getHeaderLine('Referer') ?: null,
        ]);
    }
}
