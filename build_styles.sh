#!/bin/bash

if which sassc &> /dev/null; then
	sassc public/css/styles.scss > public/css/styles.css
else
	echo "No sassc"
	exit 1
fi
