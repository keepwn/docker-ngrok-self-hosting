# docker-ngrok-self-hosting

## Build Image
```
docker build -t my/ngrok-self-hosting .
```

## Generate Ngrok-Self
```
cd ~
mkdir ngrok-bin
docker run --rm -e DOMAIN="tunnel.mydomain.com" -v ~/ngrok-bin:/release my/ngrok-self-hosting
```
Ngrok server and client binaries will be available in `~/ngrok-bin` on the host.

## Environment Variables
| variables   |  default   | meaning                                  |
| ----------- | :--------: | ---------------------------------------- |
| DOMAIN      | *required* | domain name that ngrok running on        |
| TUNNEL_PORT |   `4443`   | port that ngrok server's control channel listens |
| HTTP_PORT   |    `80`    | port that ngrok server's http tunnel listents |
| HTTPS_PORT  |   `443`    | port that ngrok server's https tunnel listents |

## Run Server
You need copy `ngrok-bin` to server, and `docker` must be installed in server.
```
cd ngrok-bin
./run_server.sh
```
