# aura-m
Aura Monitoring Service
![alt text](https://raw.githubusercontent.com/kokleong98/aura-m/master/docs/panel-design.png)

Installation command
```
curl -O https://raw.githubusercontent.com/kokleong98/aura-m/master/install-auram.sh
chmod +x install-auram.sh
sudo ./install-auram.sh
```

Youtube clean installation guide:
https://youtu.be/8mIMr0uAn5I
[![](http://img.youtube.com/vi/8mIMr0uAn5I/0.jpg)](http://www.youtube.com/watch?v=8mIMr0uAn5I "AURA-M")

# How to use
1. Upon installation and aura sync completion login using the created aura service account.
Run the following command to start auram monitoring.
```
auram start
```
2. Browse your web dasbboard url and login with pre-generated username and password during installation.
http://your_server_ip/aura/

3. You may change the password or add new username using auram pass command.

# Common commands
Add / Change dashboard password
```
auram pass <username> <password>
# eg. auram pass auram newpass
```
Check auram service logs
```
auram logs
```
