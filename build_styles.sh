#!/bin/bash

if which sassc &> /dev/null; then
	sassc public/css/styles.scss > public/css/styles.css
else
	exit 1
fi
