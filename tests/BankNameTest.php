<?php
namespace Razorpay\IFSC\Tests;

use Razorpay\IFSC\Bank;
use PHPUnit\Framework\TestCase;

class Name extends TestCase
{
    public function testDefined()
    {
        $this->assertEquals('PUNB', constant('Razorpay\IFSC\Bank::PUNB'));
        $this->assertEquals('BDBL', constant('Razorpay\IFSC\Bank::BDBL'));

        $this->assertEquals('BDBL', Bank::BDBL);
    }
}
