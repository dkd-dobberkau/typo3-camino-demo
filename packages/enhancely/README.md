# Enhancely JSON-LD for TYPO3

AI-generated JSON-LD structured data for improved SEO and LLM visibility.

## Installation

### Via Composer (recommended)

```bash
composer require enhancely/enhancely
```

### Manual Installation

1. Download the extension
2. Upload to `typo3conf/ext/enhancely`
3. Activate in Extension Manager

## Configuration

1. Go to **Admin Tools > Settings > Extension Configuration**
2. Select **enhancely**
3. Configure the following settings:

| Setting | Description |
|---------|-------------|
| API Key | Your Enhancely API key (get it from [enhancely.ai](https://enhancely.ai)) |
| Enabled | Enable or disable JSON-LD generation |
| Excluded Page Types | Comma-separated list of page types to exclude |
| Cache Lifetime | Cache lifetime in seconds (default: 86400 = 24 hours) |

## How It Works

1. The extension registers a PSR-15 middleware that runs after page rendering
2. For each frontend request, it calls the Enhancely API with the page URL
3. The API returns AI-generated JSON-LD structured data
4. The JSON-LD is injected into the `<head>` section of the page
5. ETags are cached to minimize API calls for unchanged content

## Features

- **Automatic JSON-LD Generation**: No manual schema markup required
- **ETag Caching**: Efficient API usage through conditional requests
- **TYPO3 Cache Integration**: Uses TYPO3's native caching framework
- **Page Type Exclusion**: Skip specific page types (e.g., 404 pages)
- **Error Handling**: Graceful degradation if API is unavailable

## Requirements

- TYPO3 12.4+ or 13.x
- PHP 8.2+
- Valid Enhancely API key

## Support

- Website: [enhancely.ai](https://enhancely.ai)
- Documentation: [docs.enhancely.ai](https://docs.enhancely.ai)
