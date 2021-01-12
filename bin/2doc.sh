#!/bin/bash

Script=$(basename $0)

if [[ $# == 0 ]]; then
    cat << eof
    Script Location: 
        $0
    Purpose:
        Copy a file to $DOC_ROOT
    DOC_ROOT:
        $DOC_ROOT
    Usage:
        $Script SOURCE DESTINATION
eof
    exit 
fi

if [[ $DOC_ROOT ]]; then
    mv $1 $DOC_ROOT/$2
fi

