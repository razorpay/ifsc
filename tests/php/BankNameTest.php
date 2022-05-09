<?php
namespace Razorpay\IFSC\Tests;

use Razorpay\IFSC\Bank;
use PHPUnit\Framework\TestCase;

class Name extends TestCase
{
    public function testDefined() {
        $this->assertEquals('PUNB', constant('Razorpay\IFSC\Bank::PUNB'));
        $this->assertEquals('BDBL', constant('Razorpay\IFSC\Bank::BDBL'));

        $this->assertEquals('BDBL', Bank::BDBL);
    }

    public function testBankDetails() {
        $this->assertEqualsCanonicalizing([
            'code' => 'PUNB',
            'ifsc' => 'PUNB0244200',
            'micr' => '110024001',
            'iin' => '508568',
            'ach_credit' => true,
            'ach_debit' => true,
            'apbs' => true,
            'nach_debit' => true,
            'type' => 'PSB',
            'upi' => true,
            'name' => 'Punjab National Bank',
            'bank_code' => '024',
        ], Bank::getDetails('PUNB'));

        $this->assertEqualsCanonicalizing([
            'code' => 'FINO',
            'ifsc' => 'FINO0000001',
            'micr' => '990099909',
            'iin' => '608001',
            'ach_credit' => true,
            'ach_debit' => false,
            'nach_debit' => false,
            'apbs' => true,
            'type' => 'PB',
            'upi' => true,
            'name' => 'Fino Payments Bank',
            'bank_code' => '099'
        ], Bank::getDetails('FINO'));
    }
}
