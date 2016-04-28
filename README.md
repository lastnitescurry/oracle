# Oracle XE Server and Client

Configure Oracle XE for development or test Documentum Content Server

##### Configure 2G Swap 

if required, configure at least 2G of swap 

    dd if=/dev/zero of=/swapfile bs=1024 count=2048k
    mkswap /swapfile
    swapon /swapfile
    swapon -s

1. [how-to-add-swap-on-centos-6](https://www.digitalocean.com/community/tutorials/how-to-add-swap-on-centos-6)
2. [Centos Adding swap](https://www.centos.org/docs/5/html/Deployment_Guide-en-US/s1-swap-adding.html)
3. [XE install](http://docs.oracle.com/cd/E17781_01/install.112/e18802/toc.htm#XEINL110)

      