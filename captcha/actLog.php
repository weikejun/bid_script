<?php

$logDir = dirname(dirname(__FILE__))."/log";

$logFile = date("Ymd");

$lines = array_reverse(file("$logDir/$logFile"));

echo '<pre>';
foreach($lines as $line) {
	echo $line;
}
echo '</pre>';
