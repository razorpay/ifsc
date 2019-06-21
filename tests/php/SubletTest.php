<?php
namespace Razorpay\IFSC\Tests;

use Razorpay\IFSC\IFSC;
use Razorpay\IFSC\Bank;

/**
 * Checks Bank names for sublet branches
 */
class SubletTest extends TestCase
{
    public function setUp(): void
    {
        parent::setUp();
        $this->sublets = json_decode(file_get_contents($this->root . '/src/sublet.json'), true);
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
        // This test is currently marked as skipped
        // Since some of the Banks in the NPCI ACH list have sublets
        // Belonging to themselves. Skipped till we figure out a better way
        // Reported to RBI, no response yet
        $this->markTestSkipped();
        foreach ($this->sublets as $ifsc => $bankCode)
        {
            // This would be the naive owner
            $ownerBankCode = substr($ifsc, 0, 4);

            $match = (IFSC::getBankName($ifsc) === IFSC::getBankName($ownerBankCode));

            $expected = $this->sublets[$ifsc];

            $this->assertTrue(!$match, "Bank Name for $ifsc matches $ownerBankCode (expected $expected)");
        }
    }

    public function testCustomSublet()
    {
        $data = [
            // Test a complete 11 character prefix
            "VIJB0SSB001" => "Shimsha Sahakara Bank Niyamitha",
            // A 8 character prefix pointing to a bank code
            "KSCB0006001" => "Tumkur District Central Bank",
            // A 9 character prefix pointing to a static name
            "WBSC0KPCB01" => "Kolkata Police Co-operative Bank",
            "YESB0ADB002" => "Amravati District Central Co-operative Bank"
        ];

        foreach ($data as $code => $expected) {
            $this->assertEquals($expected, IFSC::getBankName($code));
        }
    }
}
