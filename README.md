# Zoneminder

Dockerfile using this source https://github.com/ZoneMinder/zmdockerfiles/tree/master/release/ubuntu18.04 and subsequently adding zmeventnotification (ES)
without hooks, from project repository https://github.com/pliablepixels/zmeventnotification .
Essentially using zmeventnotification to push motion triggers via mqtt.

```
  zoneminder:
    container_name: zoneminder
    image: juan11perez/zoneminder:latest
    restart: unless-stopped
    hostname: UNRAID
    network_mode: bridge
    privileged: true
    shm_size: 3G #512mb/cam
    volumes:
    - /mnt/user/media/appdata/zoneminder/events:/var/cache/zoneminder/events
    - /mnt/user/media/appdata/zoneminder/images:/var/cache/zoneminder/images
    - /mnt/cache/appdata/zoneminder/mysql:/var/lib/mysql
    - /mnt/cache/appdata/zoneminder/logs:/var/log/zm  
    - /mnt/cache/appdata/zoneminder/conf:/config
    ports:
    - 9000:9000/tcp
    - 8089:80/tcp #http view
    environment:
    - PGID=100
    - PUID=99
    - TZ=Asia/Dubai   
```


Note: upgrading from 1.34.19 to 1.34.20 requires database upgrade
to upgrade database
docker exec -it zoneminder zmupdate.pl
