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
        'UPI',
        'ISO3166'
    ];

    public function testIFSCDotCsv() {
        $fileName = __DIR__ . "/../../scraper/scripts/data/IFSC.csv";
        if(file_exists($fileName) or getenv('RUN_DATASET_TESTS')) {
            $file = fopen($fileName, 'r');
            $line = fgets($file);
            $row = str_getcsv($line);
            foreach (self::KNOWN_FIELDS as $field) {
                $this->assertContains($field, $row, "$field missing in IFSC.csv");
            }

            $expectedCount = count($row);

            $bankNameIndex = array_search('BANK', $row);
            $iso3166Index = array_search('ISO3166', $row);
            $micrIndex = array_search('MICR', $row);

            $lineno = 2;

            while($line = fgets($file)) {
                $row = str_getcsv($line);
                $this->assertCount($expectedCount, $row, "IFSC.csv L$lineno missing fields: $line");
                $this->assertNotEmpty($row[$bankNameIndex], "IFSC.csv L$lineno has empty bankname $line");
                $this->assertNotEmpty($row[$iso3166Index], "IFSC.csv L$lineno has empty ISO3166 code");
                $this->assertNotEquals('NA', $row[$micrIndex], "IFSC.csv L$lineno has MICR set to NA $line");
                $lineno++;
            }
        }
        else {
            $this->markTestSkipped("IFSC.csv missing");
        }
    }

    /**
     * We extract the by-banks.tar.gz again because
     * compression helps keep the download file size for releases low.
     */
    public function testBankFiles() {
        $tarFile = __DIR__ . "/../../scraper/scripts/data/by-bank.tar";

        if (file_exists($tarFile) or getenv('RUN_DATASET_TESTS')) {
            $dir = tempnam(sys_get_temp_dir(), '') . '.dir';

            // unarchive from the tar
            $phar = new PharData($tarFile);
            $phar->extractTo($dir, null, true);

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
        } else {
            $this->markTestSkipped("by-bank.tar missing");
        }
    }
}
