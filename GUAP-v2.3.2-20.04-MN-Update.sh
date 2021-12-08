#!/bin/bash

#stop_daemon function
function stop_daemon {
    if pgrep -x 'guapcoind' > /dev/null; then
        echo -e "${YELLOW}Attempting to stop guapcoind${NC}"
        guapcoin-cli stop
        sleep 30
        if pgrep -x 'guapcoind' > /dev/null; then
            echo -e "${RED}guapcoind daemon is still running!${NC} \a"
            echo -e "${RED}Attempting to kill...${NC}"
            sudo pkill -9 guapcoind
            sleep 30
            if pgrep -x 'guapcoind' > /dev/null; then
                echo -e "${RED}Can't stop guapcoind! Reboot and try again...${NC} \a"
                exit 2
            fi
        fi
    fi
}


echo "Your GuapCoin Masternode Will be Updated To The Latest Version v2.3.2 Now" 
sudo apt-get -y install unzip

#remove crontab entry to prevent daemon from starting
crontab -l | grep -v 'guapauto.sh' | crontab -

#Stop guapcoind by calling the stop_daemon function
stop_daemon

rm -rf /usr/local/bin/guapcoin*
mkdir GUAP_2.3.2
cd GUAP_2.3.2
wget https://github.com/guapcrypto/Guap-v2.3.2-MN/releases/download/v2.3.2/Guapcoin-2.3.2-Ubuntu20.04-daemon.tar.gz
tar -xzvf Guapcoin-2.3.2-Ubuntu20.04-daemon.tar.gz
mv guapcoind /usr/local/bin/guapcoind
mv guapcoin-cli /usr/local/bin/guapcoin-cli
chmod +x /usr/local/bin/guapcoin*
rm -rf ~/.guapcoin/blocks
rm -rf ~/.guapcoin/chainstate
rm -rf ~/.guapcoin/sporks
rm -rf ~/.guapcoin/peers.dat
cd ~/.guapcoin/
wget https://github.com/guapcrypto/Guap-v2.3.2-MN/releases/download/v2.3.2/bootstrap.zip
unzip bootstrap.zip

cd ..
rm -rf ~/.guapcoin/bootstrap.zip ~/GUAP_2.3.2

# add new nodes to config file
sed -i '/addnode/d' ~/.guapcoin/guapcoin.conf

echo "addnode=159.65.221.180
addnode=45.76.61.148
addnode=209.250.250.121
addnode=136.244.112.117
addnode=199.247.20.128
addnode=78.141.203.208
addnode=155.138.140.38
addnode=45.76.199.11
addnode=45.63.25.141" >> ~/.guapcoin/guapcoin.conf

#start guapcoind
guapcoind -daemon

printf '#!/bin/bash\nif [ ! -f "~/.guapcoincoin/guapcoin.pid" ]; then /usr/local/bin/guapcoind -daemon ; fi' > /root/guapauto.sh
chmod -R 755 /root/guapauto.sh
#Setting auto start cron job for GuapCoin
if ! crontab -l | grep "guapauto.sh"; then
    (crontab -l ; echo "*/5 * * * * /root/guapauto.sh")| crontab -
fi

echo "Masternode Updated!"
echo "Please wait a few minutes and start your Masternode again on your Local Wallet"