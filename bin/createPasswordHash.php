<?php

echo("\n");

if (count($argv) !== 3) {
    echo "Usage : php external/ezp-toolkit/bin/createPasswordHash.php [username] [password]\n";
    exit(1);
}

$username = $argv[1];
$password = $argv[2];
$hash = password_hash($password,PASSWORD_DEFAULT);

echo ("Hash : $hash\n");
echo ("SQL :\nupdate ezuser set password_hash='$hash', password_hash_type=7 where login='$username';\n\n\n");

