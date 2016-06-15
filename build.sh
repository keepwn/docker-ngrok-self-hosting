#!/bin/sh

if [ "${DOMAIN}" == "**None**"  ]; then
    echo "Please Input DOMAIN"
    exit 1
fi

echo "=> 1. Clone Latest Ngrok ..."
cd /
git clone https://github.com/inconshreveable/ngrok.git

echo "=> 2. Creating Tls ..."
NGROK_DOMAIN=${DOMAIN}
mkdir /ngrok/tls && cd /ngrok/tls
openssl genrsa -out rootCA.key 2048
openssl req -x509 -new -nodes -key rootCA.key -subj "/CN=$NGROK_DOMAIN" -days 5000 -out rootCA.pem
openssl genrsa -out device.key 2048
openssl req -new -key device.key -subj "/CN=$NGROK_DOMAIN" -out device.csr
openssl x509 -req -in device.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out device.crt -days 5000

cp rootCA.pem /ngrok/assets/client/tls/ngrokroot.crt

echo "=> 3. Building Ngrok ..."
cd /ngrok
make release-server release-client
echo "=> Build Successfully"

echo "=> 4. Outputing Bin To /release"
cp /ngrok/bin/* /release/
cp /ngrok/tls/* /release/

echo "=> 5. Generating Config Files ..."
cat > /release/ngrok.conf <<EOF
server_addr: ${DOMAIN}:${TUNNEL_PORT}
trust_host_root_certs: false
EOF

cat > /release/run_server.sh <<EOF
#!/bin/sh
DOMAIN=${DOMAIN}
TUNNEL_PORT=${TUNNEL_PORT}
HTTP_PORT=${HTTP_PORT}
HTTPS_PORT=${HTTPS_PORT}

docker run --name=ngrok-server \
           --restart=always -d \
           --net=host \
           -v \$(pwd):/release \
           alpine \
           ./release/ngrokd -tlsKey=/release/device.key -tlsCrt=/release/device.crt -domain="\$DOMAIN" -httpAddr=":\$HTTP_PORT" -httpsAddr=":\$HTTPS_PORT" -tunnelAddr=":\$TUNNEL_PORT"
EOF

echo "=> Finish."
