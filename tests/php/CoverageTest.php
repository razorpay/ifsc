<?php
namespace Razorpay\IFSC\Tests;

use Razorpay\IFSC\IFSC;
use Razorpay\IFSC\Bank;
use Symfony\Component\Yaml\Yaml;
use Razorpay\IFSC\Client;

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

        $file = $this->root . '/scraper/scripts/data/IFSC-list.json';
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
        $exceptions = ['IFSC', 'KPKH'];
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
        // TODO: Skip the check while this is fixed.
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

            $innerCode = substr($code, 0, 4);

            $this->assertEquals($code, constant("Razorpay\IFSC\Bank::$innerCode"));

            $this->assertNotNull(IFSC::getBankName($innerCode), "Name missing for $innerCode");
        }
    }

    public function testAllBanksHaveValidType()
    {
        $validBankTypes = [
            'DCCB',
            'Foreign',
            'LAB',
            'O-UCB',
            'PB',
            'Private',
            'PSB',
            'RRB',
            'SCB',
            'SFB',
            'S-UCB',
        ];

        $invalidBanks = [];

        foreach ($this->bankList as $code => $details)
        {
            if(!isset($details['type']) || !in_array($details['type'], $validBankTypes))
            {
                $invalidBanks []= $code;
            }
        }

        $this->assertSame($invalidBanks, [], "Invalid `type` in src/banks.json for these banks. Please add these in the corresponding src/patches/type*.yml files");
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

    /**
     * Takes all the IFSC
     * @return [type] [description]
     */
    public function testPatches()
    {
        $failures = [];

        foreach (glob("src/patches/*.yml") as $file)
        {
            $yaml = Yaml::parseFile($file);

            foreach ($yaml['ifsc'] as $code)
            {
                if (IFSC::validate($code) !== true and $yaml['action'] != 'delete')
                {
                    $failures[] = $code;
                }
            }
        }

        // BANKOFBAROD is an invalid code, so it is marked as an exception
        $this->assertEquals([], $failures, "IFSC codes present in patches, but fails validation");
    }

    public function testXNSE()
    {
        $failures = [];

        IFSC::validate('XNSE0000001');
        IFSC::validateBankCode('XNSE');
        IFSC::getBankName('XNSE');
        IFSC::getBankName(Bank::XNSE);
        Bank::getDetails(Bank::XNSE);
        Bank::getDetails('XNSE');

        $client = new Client();
        $res = $client->lookupIFSC('XNSE0000001');

        echo $res->bank;
        echo $res->branch;
        echo $res->address;
        echo $res->contact;
        echo $res->city;
        echo $res->district;
        echo $res->state;
        echo $res->centre;
        echo $res->getBankCode();
        echo $res->getBankName();
        echo $res->micr;

        $this->assertEquals([], $failures, "IFSC codes present in fails validation");
// Boolean fields: $res->upi, $res->rtgs, $res->neft, res->imps

// You will get a SWIFT code where possible:

        //echo $client->lookupIFSC('https://ifsc.razorpay.com/ICLL0000001')->swift;

// lookupIFSC may throw `Razorpay\IFSC\Exception\ServerError`
// in case of server not responding in time
// or Razorpay\IFSC\Exception\InvalidCode in case
// the IFSC code is invalid
    }
}
