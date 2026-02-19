#!/bin/env bash

read -r -p "Enter project identifier (used in attendance_tracker_{input}): " INPUT 
[[ -n "${INPUT// }" ]]