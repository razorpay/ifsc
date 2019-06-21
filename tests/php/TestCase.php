<?php

namespace Razorpay\IFSC\Tests;

use PHPUnit\Framework\TestCase as BaseTestCase;

abstract class TestCase extends BaseTestCase
{
    public function setUp(): void
    {
        $this->root = realpath(__DIR__ . '/../../');
    }
}
