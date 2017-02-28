<?php

namespace Razorpay\IFSC\Tests;

use Razorpay\IFSC\Client;
use PHPUnit_Framework_TestCase;
use Http\Mock\Client as MockClient;
use Psr\Http\Message\RequestInterface;
use Http\Discovery\HttpClientDiscovery;
use Http\Discovery\Strategy\MockClientStrategy;

class ClientTest extends PHPUnit_Framework_TestCase
{
    const FAKE_IFSC = 'RAZR0000001';
    const REAL_IFSC = 'AIRP0000001';

    public function setUp()
    {
        HttpClientDiscovery::prependStrategy(MockClientStrategy::class);

        $this->client = new Client();
    }

    public function testInit()
    {
        $this->assertTrue(is_a($this->client, Client::class));
    }

    public function testLookupRequest()
    {
        $res = $this->client->lookupIFSC(self::REAL_IFSC);

        $requests = $this->client->getHttpClient()->getRequests();

        $this->assertCount(1, $requests);

        $req = $requests[0];

        $this->assertInstanceOf(RequestInterface::class, $req);

        $this->assertSame('GET', $req->getMethod());

        $uri = $req->getUri();

        $this->assertSame('https', $uri->getScheme());
        $this->assertSame('ifsc.razorpay.com', $uri->getAuthority());
        $this->assertSame('ifsc.razorpay.com', $uri->getHost());
        $this->assertSame('/' . self::REAL_IFSC, $uri->getPath());
    }

}
