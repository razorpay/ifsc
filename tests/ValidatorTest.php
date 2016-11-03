<?php
namespace Razorpay\IFSC\Tests;

use Razorpay\IFSC\IFSC;
use PHPUnit_Framework_TestCase;

class ValidatorTest extends PHPUnit_Framework_TestCase
{

    protected static $allTests = [];

    public function setUp()
    {
        $contents = file_get_contents(__DIR__ . '/validator_asserts.json');
        $this->groups = json_decode($contents, true);
    }

    public function testValidator()
    {
        foreach ($this->groups as $message => $tests)
        {
            $this->singleTest($message, $tests);
        }
    }

    protected function singleTest($message, $tests)
    {
        foreach ($tests as $code => $expectedValue)
        {
            $this->assertEquals($expectedValue, IFSC::validate($code), $message);
        }
    }
}
