<?php

namespace Razorpay\IFSC;

use Http\Client\HttpClient;
use Http\Message\RequestFactory;
use Http\Discovery\HttpClientDiscovery;
use Psr\Http\Message\ResponseInterface;
use Http\Discovery\MessageFactoryDiscovery;

class Client
{
    const API_BASE = 'https://ifsc.razorpay.com';

    const GET = 'GET';

    protected $httpClient = null;

    /**
     * Creates a IFSC Client instance
     * @param Http\Client\HttpClient $httpClient A valid HTTPClient
     */
    public function __construct($httpClient = null, RequestFactory $requestFactory = null)
    {
        $this->httpClient = $httpClient ?? HttpClientDiscovery::find();
        $this->requestFactory = $requestFactory ?: MessageFactoryDiscovery::find();
    }

    public function getHttpClient(): HttpClient
    {
        return $this->httpClient;
    }

    public function lookupIFSC(string $ifsc): Entity
    {
        if (IFSC::validate($ifsc))
        {
            $url = $this->makeUrl("/$ifsc");
            $request  = $this->requestFactory->createRequest(
                self::GET,
                $url
            );

            $response = $this->httpClient->sendRequest($request);

            return $this->parseResponse($response, $ifsc);
        }
        else
        {
            $this->throwInvalidCode($ifsc);
        }
    }

    /**
     * Parses a response into a IFSC\Entity instance
     * @param  ResponseInterface $response Response from the API
     * @param  string            $ifsc
     * @throws Exception\ServerError
     * @throws Exception\InvalidCode
     * @return Entity
     */
    protected function parseResponse(ResponseInterface $response, string $ifsc): Entity
    {
        switch ($response->getStatusCode())
        {
            case 200:
                return new Entity($response);
                break;

            case 404:
                $this->throwInvalidCode($ifsc);
                break;

            default:
                throw new Exception\ServerError('IFSC API returned invalid response: ' .  $ifsc);
                break;
        }
    }

    /**
     * @throws Exception\InvalidCode
     * @param  string $ifsc IFSC Code
     */
    protected function throwInvalidCode(string $ifsc)
    {
        throw new Exception\InvalidCode('Invalid IFSC: ' . $ifsc);
    }

    protected function makeUrl(string $path): string
    {
        return self::API_BASE . $path;
    }
}
