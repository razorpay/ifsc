<?php
namespace Razorpay\IFSC\Tests;

use PharData;
use Razorpay\IFSC\IFSC;

/**
 * This class is for testing anything inside
 * the scraper/scripts/data directory. Since the directory
 * is empty during usual development, most of these will be skipped unless
 * we are in CI.
 */
class DatasetTest extends TestCase
{
    const KNOWN_FIELDS = [
        'BANK',
        'IFSC',
        'BRANCH',
        'CENTRE',
        'DISTRICT',
        'STATE',
        'ADDRESS',
        'CONTACT',
        'IMPS',
        'RTGS',
        'CITY',
        'NEFT',
        'MICR',
        'UPI'
    ];

    public function testIFSCDotCsv() {
        $file = __DIR__ . "../../scraper/scripts/data/IFSC.csv";
        if(file_exists($file)) {
            $line = fgets(fopen($file, 'r'));
            $row = str_getcsv($line);
            foreach (self::KNOWN_FIELDS as $field) {
                $this->assertContains($field, $row, "$row missing in IFSC.csv");
            }
        }
        else {
            $this->markTestSkipped("IFSC.csv missing. This should not be skipped in CI");
        }
    }

    /**
     * We extract the by-banks.tar.gz again because
     * compression helps keep the download file size for releases low.
     */
    public function testBankFiles() {
        $gzFile = __DIR__ . "/../../scraper/scripts/data/by-bank.tar.gz";
        $tarFile = __DIR__ . "/../../scraper/scripts/data/by-bank.tar";

        $dir = tempnam(sys_get_temp_dir(), '') . '.dir';

        @unlink($tarFile);
        mkdir($dir);

        $p = new PharData($gzFile);
        $p->decompress();

        // unarchive from the tar
        $phar = new PharData($tarFile);
        print_r($phar->extractTo($dir));

        foreach(glob("$dir/by-bank/*.json") as $json) {
            $data = json_decode(file_get_contents($json), true);
            foreach ($data as $row) {
                $ifsc = $row['IFSC'];
                $fields = array_keys($row);
                foreach (self::KNOWN_FIELDS as $field) {
                    $this->assertContains($field, $fields, "$ifsc missing $field in $json");
                }
            }
        }
    }
}
