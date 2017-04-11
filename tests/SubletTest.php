<?php
namespace Razorpay\IFSC\Tests;

use Razorpay\IFSC\IFSC;
use Razorpay\IFSC\Bank;
use PHPUnit\Framework\TestCase;

/**
 * Checks Bank names for sublet branches
 */
class SubletTest extends TestCase
{
    public function setUp()
    {
        $this->sublets = json_decode(file_get_contents(__DIR__ . '/../src/sublet.json'), true);
    }

    public function testBasicNames()
    {
        $name = IFSC::getBankName('ALLA0AU1002');

        $this->assertEquals("Allahabad Up Gramin Bank", $name);
    }

    /**
     * Ensure that the sublet list only
     * includes genuine subleases
     */
    public function testNamesDiffer()
    {
        foreach ($this->sublets as $ifsc => $bankCode)
        {
            // This would be the naive owner
            $ownerBankCode = substr($ifsc, 0, 4);

            $match = (IFSC::getBankName($ifsc) === IFSC::getBankName($ownerBankCode));

            $expected = $this->sublets[$ifsc];

            $this->assertTrue(!$match, "Bank Name for $ifsc matches $ownerBankCode (expected $expected)");
        }
    }
}
