<?php

$dir = dirname(__FILE__);
echo '<pre>';
if(isset($_POST['captcha'])) {
	foreach($_POST['captcha'] as $fname => $capVal) {
		if(!trim($capVal)) continue;
		file_put_contents($fname.'.res', $capVal);
		echo date('Ymd H:i:s').' Create '.$fname.".res\n";
	}
}
echo '</pre><a href="actLog.php">see logs</a>';
