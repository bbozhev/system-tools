<?php

if ($handle = opendir('/cache')) 
{
    echo "Directory handle: $handle\n";
    echo "Files:\n";

    while (false !== ($file = readdir($handle))) 
    {
        if( is_file($file) )
        {
            unlink($file);
        }
    }

    closedir($handle);
}
?>
