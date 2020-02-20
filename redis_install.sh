#!/bin/bash
echo "====安裝需要套件===="
yum install -y wget gcc

echo "====下載redis-5.0.7，並解壓縮後編譯===="
wget http://download.redis.io/releases/redis-5.0.7.tar.gz
tar zxf redis-5.0.7.tar.gz

echo "====開始編譯===="
cd redis-5.0.7 && make

echo "====取代舊版redis軟體===="
/bin/cp ~/redis-5.0.7/src/redis-benchmark /usr/local/bin/
/bin/cp ~/redis-5.0.7/src/redis-check-aof /usr/local/bin/
/bin/cp ~/redis-5.0.7/src/redis-check-rdb /usr/local/bin/
/bin/cp ~/redis-5.0.7/src/redis-cli /usr/local/bin/
/bin/cp ~/redis-5.0.7/src/redis-server /usr/local/bin/
/bin/cp ~/redis-5.0.7/src/redis-sentinel /usr/local/bin/

echo "====複製設定檔===="
/bin/cp ~/redis-5.0.7/redis.conf /etc/redis.conf

echo "====修改設定檔===="
sed -i 's/^bind 127.0.0.1$/#bind 127.0.0.1/g' /etc/redis.conf
sed -i 's/^protected-mode yes/protected-mode no/g' /etc/redis.conf
sed -i 's/^logfile \"\"/logfile \/var\/log\/redis\/redis.log/g' /etc/redis.conf
sed -i 's/^save 900 1/#save 900 1/g' /etc/redis.conf
sed -i 's/^dynamic-hz yes/dynamic-hz no/g' /etc/redis.conf
sed -i 's/^save 300 10/#save 300 10/g' /etc/redis.conf
sed -i 's/^save 60 10000/#save 60 10000/g' /etc/redis.conf
sed -i 's/^tcp-keepalive 300/tcp-keepalive 0/g' /etc/redis.conf
sed -i 's/^dir \.\//dir \/var\/lib\/redis\//g' /etc/redis.conf
sed -i 's/^aof-use-rdb-preamble yes/aof-use-rdb-preamble no/g' /etc/redis.conf

echo "=====新增systemd檔案redis.service===="
cat << EOF > /lib/systemd/system/redis.service
[Unit]
Description=Redis
After=network.target

[Service]
ExecStart=/usr/local/bin/redis-server /etc/redis.conf  --daemonize no
ExecStop=/usr/local/bin/redis-cli -h 127.0.0.1 -p 6379 shutdown

[Install]
WantedBy=multi-user.target
EOF

echo "====開啟redis===="
systemctl start redis

echo "====查看redis服務狀態===="
systemctl status redis
