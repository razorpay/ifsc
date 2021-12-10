**Release Date**: `TODO`
**RBI Update Date**: `TODO`
<?php
// Do some pre-processing
$plus = $minus = [];
foreach(file('ifsc-api/diff.txt') as $row) {
    $ifsc = substr($row, 1, -1);
    if (substr($row,0,1) === '+') {
        $plus[] = $ifsc;
    }
    elseif (substr($row, 0, 1) === '-') {
        $minus[] = $ifsc;
    }
}

$common = array_intersect($plus, $minus);
$plus = array_diff($plus, $common);
$minus = array_diff($minus, $common);

$summary = [];

foreach ($plus as $ifsc){
    $bank = substr($ifsc, 0, 4);
    if(!isset($summary[$bank])) {
        $summary[$bank] = 0;
    }
    $summary[$bank] +=1;
}
foreach ($minus as $ifsc) {
    $bank = substr($ifsc, 0, 4);
    if(!isset($summary[$bank])) {
        $summary[$bank] = 0;
    }
    $summary[$bank] -=1;
}
asort($summary);

sort($plus);sort($minus);

$diffSize = count($plus) + count($minus);

// Reduce one for the final newline
$ifscCount = (((int) `wc -l data/IFSC.csv`) - 1);  // nosemgrep : php.lang.security.backticks-use.backticks-use
?>**IFSC Count**: <?=$ifscCount;?>

**Diff Size**: <?=$diffSize?> (This only counts new or deleted IFSCs from previous release)

- Only metadata changes in this release.
- TODO

<details><summary><strong>Aggregate Breakdown</strong>
</summary>

```
<?php
foreach ($summary as $bank => $count) {
    echo str_pad(sprintf("%+d",$count), 4) . "\t" . $bank . "\n";
}
?>
```
</details>

<details><summary><strong>Exact IFSC Diff</strong></summary>

```diff
<?php
foreach ($plus as $ifsc) {
    echo "+$ifsc\n";
}
foreach ($minus as $ifsc) {
    echo "-$ifsc\n";
}
?>
```
</details>


Here is a cute TODO:
