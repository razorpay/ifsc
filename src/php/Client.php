<?php

namespace Razorpay\IFSC;

use Http\Client\HttpClient;
use Http\Message\RequestFactory;
use Http\Discovery\HttpClientDiscovery;
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

    public function getHttpClient()
    {
        return $this->httpClient;
    }

    public function lookupIFSC(string $ifsc)
    {
        if (IFSC::validate($ifsc))
        {
            $url = $this->makeUrl("/$ifsc");
            $request  = $this->requestFactory->createRequest(
                self::GET,
                $url
            );

            $response = $this->httpClient->sendRequest($request);

            return $response;
        }
        else
        {
            return false;
        }
    }

    protected function makeUrl($path)
    {
        return self::API_BASE . $path;
    }
}
