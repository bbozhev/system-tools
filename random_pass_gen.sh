#!/bin/sh
function adminpass
{
echo `</dev/urandom tr -dc A-Za-z0-9 | head -c12`
}

echo `adminpass`;
