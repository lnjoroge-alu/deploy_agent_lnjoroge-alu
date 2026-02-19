#!/bin/env bash

# Helper functions for error handling 
die()  { echo "Error: $*" >&2; exit 1; }


read -r -p "Enter project identifier (used in attendance_tracker_{input}): " INPUT 
[[ -n "${INPUT// }" ]] 