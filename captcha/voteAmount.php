<!DOCTYPE html>
<html>
<head lang="en">
  <meta charset="UTF-8">
  <title>融抢器 - 已投票金额</title>
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="format-detection" content="telephone=no">
  <meta name="renderer" content="webkit">
  <meta http-equiv="Cache-Control" content="no-siteapp" />
  <link rel="alternate icon" type="image/png" href="/i/favicon.png">
  <link rel="stylesheet" href="amazeui.min.css"/>
  <style>
    .header {
      text-align: center;
    }
    .header h1 {
      font-size: 200%;
      color: #333;
      margin-top: 30px;
    }
    .header p {
      font-size: 14px;
    }
  </style>
</head>
<body>
<div class="header">
  
  <hr />
</div>
<div class="am-g">
  <div class="am-u-lg-6 am-u-md-8 am-u-sm-centered">
    <h3>已投票金额</h3>
    <hr>
<?php

$dir = dirname(dirname(__FILE__));
$files = scandir("$dir/http");

echo "<pre>";
$allAmount = 0;
$allCount = 0;
$allOutput = "";
foreach($files as $f) {
	$finfo = pathinfo($f);
	if (strpos($finfo['filename'], 'list_cf') !== false) {
		$detail = json_decode(file_get_contents("$dir/http/$f"), true);
		$fnParam = explode("_", $f);
		$amount = 0;
		$output = "";
		$count = count($detail['tb']);
		for($i = 0; $i < $count; $i++) {
			$item = $detail['tb'][$i];
			$date = explode(" ", $item['CreateDate']);
			$output .= $fnParam[2]."|" 
				.$item['StTitle']."|"
				.$item['EveryOneMoney']."|"
				.$date[0]."\n";
			$amount += $item['EveryOneMoney'];
		}
		$allAmount += $amount;
		$allCount += $count;
		$allOutput .= $output;
	}
}
echo "<b>车辆总计: $allCount 投票金额: $allAmount 预期收益: ".($allAmount*0.03)."</b>\n" . $allOutput;
echo "</pre>";

?>
    <hr>
    <p>© 2016 Jimwei </p>
  </div>
</div>
</body>
</html>

