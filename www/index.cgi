#!/usr/bin/env bash

# Include the www.sh library
source ../code/www.sh

# Setup all the routes
route / index
route /source/ view-source
route /about/ view-about
route /contact/ view-contact
route /contact/send send-contact

# Tell www.sh that we're ready
http_serve