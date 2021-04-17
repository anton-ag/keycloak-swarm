# Docker Swarm Native Keycloak Cluster
This is an attempt at tackling a problem of implementing docker swarm native clustering for Keycloak. I have seen several examples online, but none of them have quite satisfied me. 

I hope this will prove useful for those of you who want to implement some sort of high availability setup.

## A Problem
The main goal was to set up a working Keycloak cluster while avoiding a typical Docker Swarm anti-pattern, namely, defining several docker services different in name only (like "keycloak1", "keycloak2", etc.). A setup like like this would require an additional configuration of load balancer or solving the problem of having several endpoints programmatically. There is no need to add an extra instance of haproxy when you can simply delegate the task of load balancing to Docker.

## A Solution
But here's the thing: to make sure that Keycloak containers know whom to call to request clustering, one would have to provide perspective peers' ip-addresses, or other alternatives, on startup. For that reason, I decided to teach Keycloak containers how to discover peers dynamically. And to do that they just have to ask Docker about it using the `host` utility. An example of that is provided in my version of `jgroups.sh` script (the part that's added to the original image's script is marked).

This setup works like a charm. In fact, scaling Keycloak service defined this way is as easy as using `docker service scale`, both up and down.

As an example, I have added a postgres service which is what we use for our project.
## Howto
To deploy Keycloak cluster you are going to need a proper image described in `Dockerfile`. It features a customised version of `jgroups.sh` and a discovery settings file `TCPPING.cli` (which I have not written myself. It is a version I found somewhere on Keycloak Blog or Forum).
### Image
Here's how you build this image with a name and a tag of your choosing:
```
docker build . -t name_of_your_choice:any_tag
```
Alternatively, there is a pre-built image uploaded to DockerHub, `antonaag/keycloak:12.0.4`. It is referenced in `keycloak-stack.yaml`. 
### Docker Swarm
To learn in detail about Docker Swarm, visit the official Docker website. In short, it is a manager for a cluster of Docker Engines, referred to as a "swarm". To test this setup, you should have a cluster of at least 2 Docker hosts.

[ I guess adding a short manual on how to create a swarm would be great. I'll either do it later or will be happy to get a pull request. ]
### Deploying Stack
To deploy a stack, run the following command on a manager node of your swarm cluster:
```
docker stack deploy -c keycloak-stack.yaml stack
```
This command will deploy two services to your swarm: `stack_postgres` and `stack_keycloak`. After you make sure that Keycloak is functional (for example by visiting its Web Interface or sending a request to its API), you can scale Keycloak by running the following:
```
docker service scale stack_keycloak=2
```
Obviously, you can scale it to more than 2 replicas. In terms of high-availability, it makes sense to set `max_replicas_per_node` equal to 1 (as it is done in `keycloak-stack.yaml`). In this case, you are limited by a number of nodes in your swarm.