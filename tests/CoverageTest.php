<?php
namespace Razorpay\IFSC\Tests;

use Razorpay\IFSC\IFSC;
use Razorpay\IFSC\Bank;
use PHPUnit\Framework\TestCase;

/**
 * Checks coverage of all Bank Codes and Names and other lists
 *
 * There are more efficient ways of doing this (diffing etc)
 * But they won't easily point you to the exact error, especially
 * when you have multiple sources to check against
 */
class CoverageTest extends TestCase
{
    public function setUp()
    {
        $contents = file_get_contents(__DIR__ . '/../scripts/data/IFSC-list.json');
        $this->bankCodes = array_values(array_unique(array_map(function($ifsc) {
            return substr($ifsc, 0, 4);
        }, json_decode($contents, true))));

        $this->bankNamesList = json_decode(file_get_contents(__DIR__ . '/../src/banknames.json'), true);

        $this->sublets = json_decode(file_get_contents(__DIR__ . '/../src/sublet.json'), true);
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

    public function testCoverageAgainstBankNames()
    {
        foreach ($this->bankNamesList as $code => $name)
        {
            $this->assertEquals($code, constant("Razorpay\IFSC\Bank::$code"));
        }
    }

    public function testConstantsAgainstNames()
    {
        $constants = (new \ReflectionClass(Bank::class))->getConstants();

        foreach ($constants as $code => $code2)
        {
            $this->assertEquals($code2, $code, "Constant $code should equal its value: $code2");

            $this->assertNotNull(IFSC::getBankName($code), "Name missing for $code");
        }
    }

    /**
     * Ensures that all 4 character codes are well-defined and known
     */
    public function testSubletCoverage()
    {
        $subletCodes = array_values($this->sublets);

        foreach ($subletCodes as $code)
        {
            $this->assertEquals($code, constant("Razorpay\IFSC\Bank::$code"));

            $this->assertNotNull(IFSC::getBankName($code), "Name missing for $code");
        }
    }

}
