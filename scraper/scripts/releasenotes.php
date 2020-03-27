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

sort($plus);sort($minus);

$diffSize = count($plus)+count($minus);

// Reduce one for the final newline
$ifscCount = (((int) `wc -l data/IFSC.csv`) - 1);
?>**IFSC Count**: <?=$ifscCount;?>

**Diff Size**: <?=$diffSize?> (This only counts new or deleted IFSCs from previous release)

- Only metadata changes in this release.
- TODO

<details><summary><strong>Aggregate Breakdown</strong>
</summary>

```
<?=file_get_contents('ifsc-api/diffsummary.txt');?>
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
