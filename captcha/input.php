<!DOCTYPE html>
<html>
<head lang="en">
  <meta charset="UTF-8">
  <title>Captcha Input Page</title>
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
    <h3>验证码输入(计时：<span id="countdown">0</span> 秒)</h3>
    <hr>
    <form method="post" class="am-form" action="submit.php">
<?php
$dir = dirname(__FILE__);
$files = scandir($dir);
foreach($files as $f) {
	$finfo = pathinfo($f);
	if($finfo['extension'] == 'gif') {
		$flmtm = filemtime($f);
		if(date('Ymd', $flmtm) == date('Ymd')) {
?>
      <label for="captcha[<?php echo $finfo['filename']; ?>]"><img src="<?php echo $f;?>"></label>
      <input type="text" name="captcha[<?php echo $finfo['filename']; ?>]" id="captcha[<?php echo $finfo['filename']; ?>]" value="">
      <br>
<?php }}} ?>
      <div class="am-cf">
        <input type="submit" name="" value="提 交" class="am-btn am-btn-primary am-btn-sm am-fl">
      </div>
    </form>
    <hr>
    <p>© 2016 Jimwei </p>
  </div>
</div>
<script>
var countTime = 0;
var timer = setInterval(function() {
		document.getElementById('countdown').innerHTML = ++countTime;
		}, 1000);
</script>
</body>
</html>
