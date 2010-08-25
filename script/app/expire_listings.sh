#!/bin/bash

if [ ! -f /home/vns/vns/shared/system/maintenance.html ]
then
  /usr/bin/ruby /home/vns/vns/current/script/runner -e production 'Listing.expire_listings'
fi