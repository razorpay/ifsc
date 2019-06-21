<?php

namespace Razorpay\IFSC\Tests;

use Razorpay\IFSC;
use PHPUnit\Framework\TestCase;
use Http\Mock\Client as MockClient;
use Psr\Http\Message\RequestInterface;
use Http\Discovery\HttpClientDiscovery;
use Http\Discovery\Strategy\MockClientStrategy;

class ClientTest extends TestCase
{
    const FAKE_IFSC = 'RAZR0000001';
    const REAL_IFSC = 'AIRP0000001';

    const AIRP = 'AIRP';

    public function setUp(): void
    {
        HttpClientDiscovery::prependStrategy(MockClientStrategy::class);

        $this->client = new IFSC\Client();
    }

    public function testInit()
    {
        $this->assertTrue(is_a($this->client, IFSC\Client::class));
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

    protected function getExpectedResponse(string $ifsc)
    {
        $response = $this->getDefaultResponse();

        $body = json_encode($this->getMockData($ifsc));

        $response->method('getBody')->willReturn($body);

        return $response;
    }

    protected function getDefaultResponse($status = 200)
    {
        $response = $this->createMock('Psr\Http\Message\ResponseInterface');

        $response->method('getStatusCode')->willReturn($status);

        return $response;
    }

    protected function getMockData(string $ifsc)
    {
        return [
            "BANK" => "AIRTEL PAYMENTS BANK LIMITED",
            "IFSC" => $ifsc,
            "BRANCH" => "AIRTEL PAYMENTS BRANCH",
            "ADDRESS" => "AIRTEL CENTER, PLAT NO-16, UDYOG VIHAR, PHASE-4, GURGOAN",
            "CONTACT" => "4222222",
            "CITY" => "GURGOAN",
            "DISTRICT" => "GURGOAN",
            "STATE" => "HARYANA"
        ];
    }

    public function testLookupResponse()
    {
        $expectedResponse = $this->getExpectedResponse(self::REAL_IFSC);

        $this->client->getHttpClient()->addResponse($expectedResponse);

        $entity = $this->client->lookupIFSC(self::REAL_IFSC);

        $this->assertInstanceOf(IFSC\Entity::class, $entity);

        $this->assertSame(self::AIRP, $entity->getBankCode());

        $this->assertSame(IFSC\IFSC::getBankName(self::AIRP), $entity->getBankName());

        $mockData = $this->getMockData(self::REAL_IFSC);

        $this->assertSame($mockData['BANK'], $entity->bank);

        $this->assertSame($mockData['BRANCH'], $entity->branch);

        $this->assertSame($mockData['ADDRESS'], $entity->address);

        $this->assertSame($mockData['CONTACT'], $entity->contact);

        $this->assertSame($mockData['CITY'], $entity->city);

        $this->assertSame($mockData['IFSC'], $entity->code);

        $this->assertSame($mockData['DISTRICT'], $entity->district);

        $this->assertSame($mockData['STATE'], $entity->state);
    }

    public function testServerErrorResponse()
    {
        $this->expectException(IFSC\Exception\ServerError::class);

        $expectedResponse = $this->getDefaultResponse(500);

        $this->mockResponse($expectedResponse);

        $entity = $this->client->lookupIFSC(self::REAL_IFSC);
    }

    public function testMissingResponse()
    {
        $this->expectException(IFSC\Exception\InvalidCode::class);

        $expectedResponse = $this->getDefaultResponse(404);

        $this->mockResponse($expectedResponse);

        $entity = $this->client->lookupIFSC(self::REAL_IFSC);
    }

    public function testInvalidCode()
    {
        $this->expectException(IFSC\Exception\InvalidCode::class);

        $expectedResponse = $this->getDefaultResponse(404);

        $this->mockResponse($expectedResponse);

        $entity = $this->client->lookupIFSC(self::FAKE_IFSC);
    }

    protected function mockResponse($response)
    {
        $this->client->getHttpClient()->addResponse($response);
    }

}
