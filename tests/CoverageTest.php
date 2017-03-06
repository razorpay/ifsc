<?php
namespace Razorpay\IFSC\Tests;

use Razorpay\IFSC\IFSC;
use Razorpay\IFSC\Bank;
use PHPUnit\Framework\TestCase;

/**
 * Checks coverage of all Bank Codes and Names
 */
class CoverageTest extends TestCase
{
    public function setUp()
    {
        $contents = file_get_contents(__DIR__ . '/../scripts/data/IFSC-list.json');
        $this->bankCodes = array_values(array_unique(array_map(function($ifsc) {
            return substr($ifsc, 0, 4);
        }, json_decode($contents, true))));
    }

    public function testNames()
    {
        foreach ($this->bankCodes as $code)
        {
            $this->assertNotNull(IFSC::getBankName($code));
        }
    }

    public function testConstants()
    {
        foreach ($this->bankCodes as $code)
        {
            $this->assertEquals($code, constant("Razorpay\IFSC\Bank::$code"));
        }
    }
}
