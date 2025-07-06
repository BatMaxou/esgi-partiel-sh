#!/bin/bash

bash scripts/basic.sh partiel partiel

bash scripts/glpi.sh

bash scripts/init-ca.sh

bash scripts/ssl.sh glpi

bash scripts/client-cert.sh bob
