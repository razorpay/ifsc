<?php
namespace Razorpay\IFSC\Tests;

use Razorpay\IFSC\IFSC;
use Razorpay\IFSC\Bank;

/**
 * Checks coverage of all Bank Codes and Names and other lists
 *
 * There are more efficient ways of doing this (diffing etc)
 * But they won't easily point you to the exact error, especially
 * when you have multiple sources to check against
 */
class CoverageTest extends TestCase
{
    public function setUp(): void
    {
        parent::setUp();
        $contents = "[]";
        $file = $this->root . '/src/IFSC-list.json';
        if (file_exists($file)) {
            $contents = file_get_contents($file);
        }
        $this->bankCodes = array_values(array_unique(array_map(function($ifsc) {
            return substr($ifsc, 0, 4);
        }, json_decode($contents, true))));

        $this->bankNamesList = json_decode(file_get_contents($this->root . '/src/banknames.json'), true);

        $this->sublets = json_decode(file_get_contents($this->root . '/src/sublet.json'), true);

        $this->bankList = json_decode(file_get_contents($this->root . '/src/banks.json'), true);
    }

    public function testNames()
    {
        // For some reason the CSV header is picked up as a IFSC code
        // Skip the check while this is fixed.
        $exceptions = ['IFSC'];
        foreach ($this->bankCodes as $code)
        {
            if (!in_array($code, $exceptions))
            {
                $this->assertNotNull(IFSC::getBankName($code), "Could not get name for $code");
            }
        }
    }

    public function testConstants()
    {
        $failures = [];
        // For some reason the CSV header is picked up as a IFSC code
        // Skip the check while this is fixed.
        $exceptions = ['IFSC'];

        foreach ($this->bankCodes as $code)
        {
            if (!defined("Razorpay\IFSC\Bank::$code") and !in_array($code, $exceptions))
            {
                $failures[] = [$code];
            }
        }

        $this->assertSame([], $failures);
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

    public function testSubletsAgainstConstants()
    {
        foreach ($this->sublets as $ifsc => $bankCode) {
            $this->assertEquals($bankCode, constant("Razorpay\IFSC\Bank::$bankCode"));
        }
    }

    public function testConstantsAgainstCompleteBanksList()
    {
        foreach ($this->bankList as $code => $details)
        {
            $this->assertEquals($code, constant("Razorpay\IFSC\Bank::$code"));

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

    public function testValidateJsonFormat()
    {
        // Move this to setUp if another tests uses this
        $lists = json_decode(file_get_contents($this->root . '/src/IFSC.json'), true);

        $failures = [];

        foreach ($lists as $bankCode => $list) {
            foreach ($list as $partialCode) {
                if (is_string($partialCode) and (strlen(trim($partialCode)) !== 6))
                {
                    $failures[] = [$bankCode, $partialCode];
                }
            }
        }

        if(count($failures) > 0)
        {
            foreach ($failures as $failure) {
                echo "{$failure[0]}: {$failure[1]}\n";
            }
        }
        $this->assertCount(0, $failures);
    }

    /**
     * This checks the `banks.json` file (generated from NPCI Data) against our validation
     * which is based on RBI data.
     */
    public function testNpciListAgainstRbi()
    {
        $failures = [];
        foreach ($this->bankList as $code => $data) {
            $ifsc = $data['ifsc'];
            if (strlen($ifsc) === 11 and IFSC::validate($ifsc) !== true)
            {
                $failures[] = $ifsc;
            }
        }

        $this->assertEquals([], $failures, "IFSC codes present in NPCI, but missing in RBI lists");
    }
}
