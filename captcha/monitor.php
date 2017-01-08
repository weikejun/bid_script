<!DOCTYPE html>
<html>
<head lang="en">
  <meta charset="UTF-8">
  <title>Config Page</title>
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
    <h3>配置监控</h3>
    <hr>
<?php
$dir = dirname(dirname(__FILE__));

echo '<pre>';
echo '<b>[Car List]</b>'."\n";
if(file_exists("$dir/car.list")) {
	$lines = file("$dir/car.list");
	foreach($lines as $line) {
		echo $line;
	}
}
echo "\n";
echo '<b>[User List]</b>'."\n";
if(file_exists("$dir/user.list")) {
	$lines = file("$dir/user.list");
	foreach($lines as $line) {
		$user=explode("|", $line);
		echo $user[0];
	}
}
echo '</pre>';
?>
    <hr>
    <p>© 2016 Jimwei </p>
  </div>
</div>
</body>
</html>

