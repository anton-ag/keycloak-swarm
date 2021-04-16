# Docker Swarm Native Keycloak Cluster
This is an attempt at tackling a problem of implementing docker swarm native clustering for Keycloak. I have seen several examples online, but none of them have quite satisfied me. 

I hope this will prove useful for those of you who want to implement some sort of high availability setup.

## A Problem
The main goal was to set up a working Keycloak cluster while avoiding a typical Docker Swarm anti-pattern, namely, defining several docker services different in name only (like "keycloak1", "keycloak2", etc.). A setup like like this would require an additional configuration of load balancer or solving the problem of having several endpoints programmatically. There is no need to add an extra instance of haproxy when you can simply delegate the task of load balancing to Docker.

## A Solution
But here's the thing: to make sure that Keycloak containers know whom to call to request clustering, one would have to provide perspective peers' ip-addresses, or other alternatives, on startup. For that reason, I decided to teach Keycloak containers how to discover peers dynamically. And to do that they just have to ask Docker about it using the `host` utility. An example of that is provided in my version of `jgroups.sh` script (the part that's added to the original image's script is marked).

This setup works like a charm. In fact, scaling Keycloak service defined this way is as easy as using `docker service scale`, both up and down.

As an example, I have added a postgres service which is what we use for our project.
