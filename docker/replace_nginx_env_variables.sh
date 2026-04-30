#!/bin/sh
envsubst '$PASSENGER_MIN_INSTANCES $PASSENGER_MAX_POOL_SIZE' < /etc/nginx/sites-enabled/decidim-diba.conf > /etc/nginx/sites-enabled/decidim-diba-overriden.conf
mv /etc/nginx/sites-enabled/decidim-diba-overriden.conf /etc/nginx/sites-enabled/decidim-diba.conf
