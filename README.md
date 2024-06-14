# Cloud Run VPC Dirrect Connect issue reproducer

This creates a minimal environment that demonstrates unexpected / undesirable
behavior of network timeouts under the following conditions:
1. VPC direct connect is enabled
2. All traffic is routed through the VPC
3. The services makes a request to a public internet resource on startup

Creates the following:
- network project that shares a VPC with one subnet, and has a NAT gateway
- cloud run project that uses the shared VPC and hosts cloud run services
- two dummy cloud run services that use VPC direct connect, one routing
  all traffic through the VPC, the other routing internal traffic only

The cloud run services just launch a container that executes a `time curl ...`
request on startup. When all traffic is routed through the VPC, timeouts
(demonstrated by ~5s "real" time and exit code 28 in the logs) can be seen;
when only internal traffic is routed through the VPC, normal behavior
(demonstrated by exit(0) from curl and <1s "real" time in the logs) can be seen.

