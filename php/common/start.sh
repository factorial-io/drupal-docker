#!/bin/bash
# Save env-vars
env  | grep -v "affinity:container" | grep '[a-zA-Z_][a-zA-Z0-9_]*=' > /etc/profile.d/docker-env-vars.sh
sed -i 's/ /\\ /g' /etc/profile.d/docker-env-vars.sh
sed -i 's/^/export /' /etc/profile.d/docker-env-vars.sh
sed -i -r 's/export\s([^=]*)=(.*)/export "\1"="\2" /' /etc/profile.d/docker-env-vars.sh
supervisord -n
