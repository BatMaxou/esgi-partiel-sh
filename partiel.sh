#!/bin/bash

bash scripts/init.sh

bash scripts/basic.sh partiel partiel

bash scripts/glpi.sh

bash scripts/dolibarr.sh

bash scripts/init-ca.sh

bash scripts/ssl.sh glpi

bash scripts/ssl.sh dolibarr

bash scripts/client-cert.sh bob
