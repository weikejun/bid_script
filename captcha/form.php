<?php

echo '<form action="submit.php" method="POST">';
$dir = dirname(__FILE__);
$files = scandir($dir);
foreach($files as $f) {
	$finfo = pathinfo($f);
	if($finfo['extension'] == 'gif') {
		$flmtm = filemtime($f);
		if(date('Ymd', $flmtm) == date('Ymd')) {
			echo '<img src="'.$f.'"></img><input type="text" name="captcha['.$finfo['filename'].']" />&nbsp;&nbsp;'.$finfo['filename'].'<br />';
		}
	}
}
echo '<br /><input type="submit" value="submit" /></form>';

?>
