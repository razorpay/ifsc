<?php
namespace Razorpay\IFSC\Tests;

use Razorpay\IFSC\IFSC;

class ValidatorTest extends TestCase
{
    protected static $allTests = [];

    public function setUp(): void
    {
        parent::setUp();
        $contents = file_get_contents($this->root . '/tests/validator_asserts.json');
        $this->groups = json_decode($contents, true);
    }

    public function testValidator()
    {
        foreach ($this->groups as $message => $tests)
        {
            $this->singleTest($message, $tests);
        }
    }

    public function testBankCodeValidator()
    {
        $this->assertTrue(IFSC::validateBankCode('PUNB'));
        $this->assertFalse(IFSC::validateBankCode('ABCD'));
    }

    public function testBankNames()
    {
        $this->assertEquals('Punjab National Bank', IFSC::getBankName('PUNB'));
        $this->assertEquals('Shri Chhatrapati Rajashri Shahu Urban Co-operative Bank', IFSC::getBankName('CRUB'));
        $this->assertEquals(null, IFSC::getBankName('ABCD'));
    }

    public function testSubletBankName()
    {
        $this->assertEquals('Vaish Co-operative New Bank', IFSC::getBankName('YESB0VNB001'));
    }

    protected function singleTest($message, $tests)
    {
        $failures = [];
        foreach ($tests as $code => $expectedValue)
        {
            if (IFSC::validate($code) !== $expectedValue)
            {
                $failures[] = $code;
            }
        }

        $this->assertEquals([], $failures, $message);
    }
}
