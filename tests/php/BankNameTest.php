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
        $this->assertSame([
            'code' => 'PUNB',
            'type' => 'PSB',
            'ifsc' => 'PUNB0244200',
            'micr' => '110024001',
            'iin' => '508568',
            'apbs' => true,
            'ach_credit' => true,
            'ach_debit' => true,
            'nach_debit' => true,
            'name' => 'Punjab National Bank',
            'bank_code' => '024',
        ], Bank::getDetails('PUNB'));

        $this->assertSame([
            'code' => 'FINO',
            'type' => 'PB',
            'ifsc' => 'FINO0000001',
            'micr' => null,
            'iin' => '608001',
            'apbs' => true,
            'ach_credit' => true,
            'ach_debit' => false,
            'nach_debit' => false,
            'name' => 'Fino Payments Bank',
            'bank_code' => null
        ], Bank::getDetails('FINO'));
    }
}
