<?php

namespace Razorpay\IFSC;

class IFSC
{
    protected static $data = null;
    protected static $bankNames = null;
    protected static $sublet = null;

    public static function init()
    {
        if (!self::$data)
        {
            $contents = file_get_contents(__DIR__ . '/../IFSC.json');
            self::$data = json_decode($contents, true);
        }

        if (!self::$bankNames)
        {
            self::$bankNames = json_decode(file_get_contents(__DIR__ . '/../banknames.json'), true);
        }

        if (!self::$sublet)
        {
            self::$sublet = json_decode(file_get_contents(__DIR__ . '/../sublet.json'), true);
        }
    }

    public static function validate($code)
    {
        self::init();

        if (strlen($code) !== 11) {
            return false;
        }

        if ($code[4] !== '0') {
            return false;
        }

        $bankCode   = strtoupper(substr($code, 0, 4));
        $branchCode = strtoupper(substr($code, 5));

        if (! array_key_exists($bankCode, self::$data)) {
            return false;
        }

        $list = self::$data[$bankCode];

        if (ctype_digit($branchCode)) {
            return static::lookupNumeric($list, $branchCode);
        } else {
            return static::lookupString($list, $branchCode);
        }
    }

    /**
     * Validates a given bank code
     * @param  string $bankCode 4 character bank code
     * @return boolean
     */
    public static function validateBankCode($bankCode)
    {
        return defined("Razorpay\IFSC\Bank::$bankCode");
    }

    /**
     * Returns a valid display-friendly bank name
     * @param  string $code
     * @return string or null
     */
    public static function getBankName(string $code)
    {
        self::init();

        if (self::validateBankCode($code))
        {
            return self::$bankNames[$code];
        }
        else if (self::validate($code))
        {
            // Check if the IFSC is sublet, if not use first 4
            $bankCode = self::$sublet[$code] ?? substr($code, 0, 4);

            return self::$bankNames[$bankCode];
        }
    }

    protected static function lookupNumeric(array $list, $branchCode)
    {
        $branchCode = intval($branchCode);

        if (in_array($branchCode, $list)) {
            return true;
        }

        return false;
    }

    protected static function lookupString(array $list, $branchCode)
    {
        return in_array($branchCode, $list);
    }
}
