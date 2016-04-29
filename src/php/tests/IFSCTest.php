<?php
namespace Razorpay\IFSC\Tests;

use Razorpay\IFSC\IFSC;
use PHPUnit_Framework_TestCase;

class IFSCTest extends PHPUnit_Framework_TestCase
{
    public function testValidator()
    {
        $this->assertTrue(IFSC::validate('KKBK0000261'));
        $this->assertTrue(IFSC::validate('HDFC0002854'));
        $this->assertTrue(IFSC::validate('KARB0000001'));
    }

    public function testValidateInsideRange()
    {
        $this->assertTrue(IFSC::validate('DLXB0000097'));
    }

    public function testValidateStringLookup()
    {
        $this->assertTrue(IFSC::validate('BOTM0NEEMRA'));
        $this->assertTrue(IFSC::validate('BARB0ZOOTIN'));
    }

    public function testValidateInvalidCode()
    {
        $this->assertFalse(IFSC::validate('BOTM0XEEMRA'));
        $this->assertFalse(IFSC::validate('BOTX0XEEMRA'));
        $this->assertFalse(IFSC::validate('BOTX0000000'));
        $this->assertFalse(IFSC::validate('BOTX0000500'));
        $this->assertFalse(IFSC::validate('BOTM0000500'));
        $this->assertFalse(IFSC::validate('DLXB0000500'));
    }
}
