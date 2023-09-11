# Cloak + WireGuard + Docker  + LAN gateway (client-side)

## Client-side setup for internet access through a separate gateway in the local network. Server-side here <https://github.com/n-r-w/shadow-server>

### The first step is to install the server-side component because during its installation, encryption keys are generated, which will be needed here.

Data flows through the following chain:

- Computer (LAN) with the client part of this configuration specified as the gateway
- Gateway (LAN)
- WireGuard client (LAN)
- Cloak client (LAN)
- Censored Internet
- Cloak server (remote)
- WireGuard server (remote)
- Free Internet

For simplicity, all operations are performed as root, using Ubuntu 22.04 as an example. All settings are for IPv4 only.

## Go to the home folder

```bash
cd /root
```

## docker setup

### Install docker Manually

Install docker manually using manual at <https://docs.docker.com/engine/install/ubuntu/> + install docker-compose:

```bash
apt update && apt install -y ca-certificates curl gnupg && \
install -m 0755 -d /etc/apt/keyrings && \
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes && \
chmod a+r /etc/apt/keyrings/docker.gpg && \
if [ ! -e /etc/apt/sources.list.d/docker.list ]; then
echo \
"deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
"$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
fi && \
apt update && \
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && \
wget https://github.com/docker/compose/releases/download/v2.21.0/docker-compose-linux-x86_64 && \
mv docker-compose-linux-x86_64 /usr/local/bin/docker-compose && \
chmod +x /usr/local/bin/docker-compose
```

### Alternatively, install docker via snap (in Ubuntu 22.04, it is not working at the moment)

```bash
apt install -y snapd && snap install docker
```

## Setup

### Download this repository

```bash
git clone https://github.com/n-r-w/shadow-client.git && cd shadow-client
```

### Set up environment variables for docker

In the doc directory there is an example file with environment variables ```env.txt```. Copy it to the ```.env``` file, which contains environment variables for ```docker-compose```

```bash
apt install -y nano && \
cp ./doc/env.txt ./.env && \
nano ./.env
```

Setting the values ​​of the variables

- ```REMOTE_IP``` ip address of <https://github.com/n-r-w/shadow-server>
- ```PARENT_INTERFACE``` default interface on host
- ```SUBNET``` LAN subnet
- ```LAN_GATEWAY``` LAN gateway
- ```VPN_GATEWAY``` gateway for lan clients to access vpn. must be in LAN subnet and not used by any other LAN device. It's ip of wireguard server
- ```CK_IP``` ip address of cloak server. must be in LAN subnet and not used by any other LAN device

Encryption keys that were generated earlier during the server installation process:

- ```WG_CLIENT_PRIVATE_KEY``` wireguard client private key
- ```WG_SERVER_PUBLIC_KEY``` wireguard server public key
- ```CK_UID```cloak client UID
- ```CK_PUBLIC_KEY``` cloak server public key

## Test run

We check that everything starts (the first launch is long)

```bash
docker-compose up
```

Press CTRL+C and then

```bash
docker-compose down
```

## Create systemd service to automatically launch a container

If installed via ```snap```:

```bash
cp ./doc/shadow-client-snap.service /etc/systemd/system/shadow-client-snap.service && \
systemctl daemon-reload && \
systemctl enable shadow-client-snap && \
systemctl start shadow-client-snap
```

If you installed it according to the instructions from the ubuntu website:

```bash
cp ./doc/shadow-client.service /etc/systemd/system/shadow-client.service && \
systemctl daemon-reload && \
systemctl enable shadow-client && \
systemctl start shadow-client
```

## Configuring devices in the local network to connect to the VPN

- Set the IP address specified in the VPN_GATEWAY variable as the gateway
- In the network interface settings, set the MTU to 1420. This is necessary because the traffic is routed through WireGuard, which reduces the packet size.
