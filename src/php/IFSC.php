<?php

namespace Razorpay\IFSC;

class IFSC
{
    protected static $data = null;
    protected static $bankNames = null;

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
        return array_key_exists($bankCode, self::$data);
    }

    /**
     * Returns a valid display-friendly bank name
     * @param  string $bankCode valid 4 character bank code
     * @return string or null
     */
    public static function getBankName($bankCode)
    {
        if (self::validateBankCode($bankCode))
        {
            return self::$bankNames[$bankCode];
        }
    }

    protected static function lookupNumeric(array $list, $branchCode)
    {
        $branchCode = intval($branchCode);

        if (in_array($branchCode, $list)) {
            return true;
        }

        return static::lookupRanges($list, $branchCode);
    }

    protected static function lookupRanges(array $list, $branchCode)
    {
        foreach ($list as $item) {
            if (!is_array($item)) {
                continue;
            }

            assert(count($item) === 2);

            if ($branchCode  >= $item[0] and $branchCode <= $item[1]) {
                return true;
            }
        }

        return false;
    }

    protected static function lookupString(array $list, $branchCode)
    {
        return in_array($branchCode, $list);
    }
}
