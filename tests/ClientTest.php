<?php

namespace Razorpay\IFSC\Tests;

use Razorpay\IFSC\Client;
use PHPUnit_Framework_TestCase;
use Http\Mock\Client as MockClient;
use Http\Discovery\HttpClientDiscovery;
use Http\Discovery\Strategy\MockClientStrategy;

class ClientTest extends PHPUnit_Framework_TestCase
{

    public function setUp()
    {
        HttpClientDiscovery::prependStrategy(MockClientStrategy::class);

        $this->client = new Client();
    }

    public function testInit()
    {


        $this->assert(is_a($client), Razorpay\IFSC\Client::class);
    }
}
