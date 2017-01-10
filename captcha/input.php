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
    <h3>验证码输入(时间:<span id="now_time">--:--:--</span>&nbsp;&nbsp;提交倒计时:<span id="countdown">--</span>)</h3>
    <hr>
    <form id="sub_form" method="post" class="am-form" action="submit.php">
<?php
$dir = dirname(__FILE__);
$files = scandir($dir);
$show = 0;
foreach($files as $f) {
	$finfo = pathinfo($f);
	if($finfo['extension'] == 'gif') {
		$flmtm = filemtime($f);
		if(date('Ymd', $flmtm) == date('Ymd')) {
			$show++;
?>
      <label for="captcha[<?php echo $finfo['filename']; ?>]"><img src="<?php echo $f;?>"></label>
      <input autocomplete="off" type="text" name="captcha[<?php echo $finfo['filename']; ?>]" id="captcha[<?php echo $finfo['filename']; ?>]" value="">
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
var show = <?php echo $show; ?>;
setInterval(function() {
	var dt = new Date();
	document.getElementById('now_time').innerHTML = dt.getHours()+":"+dt.getMinutes()+":"+dt.getSeconds();
}, 1000);
var countTime = 10 - (new Date().getSeconds());
if(countTime > 3 && show > 0) {
	var timer = setInterval(function() {
		document.getElementById('countdown').innerHTML = --countTime;
		if(countTime == 0) {
			clearInterval(timer);
			timer = null;
			document.getElementById('sub_form').submit();
		}
	}, 1000);
} else {
	var refreshTimer = setInterval(function() {
		var dt = new Date();
		if(dt.getSeconds() >= 0 && dt.getSeconds() <= 3) {
			clearInterval(refreshTimer);
			refreshTimer = null;
			setTimeout(function() {
				location.reload();
			}, 500);
		}
	}, 10);
}
</script>
</body>
</html>
