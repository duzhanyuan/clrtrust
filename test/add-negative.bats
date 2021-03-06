#!/usr/bin/env bats
# Copyright 2017 Intel Corporation

load test_lib

setup() {
    find_clrtrust
    setup_fs
}

@test "generate empty store, fail to add certificates" {
    $CLRTRUST generate
    cnt=$(ls $STORE/anchors | wc -l)
    ls $STORE/anchors
    [ $cnt -eq 1 ]
    run $CLRTRUST list
    [ $status -eq 0 ]
    [ -z "$output" ]
    # try adding intermediate CA
    run $CLRTRUST add $CERTS/bad/intermediate.pem
    [ $status -eq 255 ]
    run $CLRTRUST list
    [ $status -eq 0 ]
    [ -z "$output" ]
    # try adding leaf certificate
    run $CLRTRUST add $CERTS/bad/leaf.pem
    [ $status -eq 255 ]
    run $CLRTRUST list
    [ $status -eq 0 ]
    [ -z "$output" ]
    # try adding non-certificate
    run $CLRTRUST add $CERTS/bad/non-cert.txt
    [ $status -eq 255 ]
    run $CLRTRUST list
    [ $status -eq 0 ]
    [ -z "$output" ]
    # add acceptable CA
    run $CLRTRUST add $CERTS/c1.pem
    [ $status -eq 0 ]
    run $CLRTRUST list
    [ $status -eq 0 ]
    cnt=$(echo "$output" | grep ^id | wc -l)
    [ $cnt -eq 1 ]
    # try removing non-certificate
    run $CLRTRUST remove $CERTS/bad/non-cert.txt
    [ $status -eq 255 ]
    run $CLRTRUST list
    cnt=$(echo "$output" | grep ^id | wc -l)
    [ $cnt -eq 1 ]
    # leaf can be forced
    $CLRTRUST add --force $CERTS/bad/leaf.pem
    run $CLRTRUST list
    [ $status -eq 0 ]
    cnt=$(echo "$output" | grep ^id | wc -l)
    [ $cnt -eq 2 ]
    # intermediate can be forced
    $CLRTRUST add -f $CERTS/bad/intermediate.pem
    run $CLRTRUST list
    [ $status -eq 0 ]
    cnt=$(echo "$output" | grep ^id | wc -l)
    [ $cnt -eq 3 ]
}

teardown() {
    remove_fs
}

# vim: ft=sh:sw=4:ts=4:et:tw=80:si:noai:nocin
