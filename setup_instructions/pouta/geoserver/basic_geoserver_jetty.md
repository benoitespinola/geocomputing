15.0# Basic GeoServer installation
The following instructions describe the steps to install a GeoServer server (with in-built Jetty container) in an Ubuntu 16.04 virtual machine. These instructions are meant to run in CSC's cPouta environment but can be used for other platforms.

These installation instructions are based on the official [**Linux binary** installation instructions](
http://docs.geoserver.org/maintain/en/user/installation/linux.html). You can read those for reference but it is not necessary.

## Prerequisites
You need to have a basic virtual machine (VM) with a ready Ubuntu OS. These instructions have been tested in a CSC's cPouta environment and with a Ubuntu 16.04 OS.

Hardware requirements:
- a machine with 1 core and 4 Gb of RAM is enough for testing and not demanding purposes, see available options from [cPouta flavours](https://docs.csc.fi/cloud/pouta/vm-flavors-and-billing/).

Security recommendations:
- Define the VM's security settings carefully (for cPouta, see [Security Guidelines for cPouta](https://docs.csc.fi/cloud/pouta/security/)):
  - VM ssh access is secured with a keypair.
  - security groups for firewall rules for ports 22 and 8080.
  - restrict the access to limited ip addresses to avoid risks.

For more details on using cPouta, see [Pouta User Guide](https://docs.csc.fi/cloud/pouta/).

## Basic platform-independent GeoServer installation
These installation steps differ from the official basic installation in the following:
- Ubuntu machine set to Europe/Helsinki timezone for the logs to be in local time.
- GeoServer is added as a service to Ubuntu for automatic startup on reboot.

The installation of the platform-independent binary include a self contained
Jetty server with the GeoServer application already installed.

To run these instructions you neet:
- a cPouta VM with Ubuntu OS running
- a public IP assigned to your VM

### Install Java and set server's time
Connect to your Vm and run the following commands:

````bash
# Update VM
sudo apt-get update
sudo apt-get -y upgrade
# Change server's time zone to Helsinki
sudo timedatectl set-timezone Europe/Helsinki

### Install Java
sudo apt-get -y install default-jre


sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get update
# Manually accept licenses for oracle java
sudo apt-get install -y oracle-java8-installer
````

### Ensure VM's restarts
Add automated daily reboots to ensure that the virtual machine's is updated with kernel updates.

Add the following lines at the end of the file `/etc/crontab`:
```
# Reboot at 3 am
0 3     * * *   root    /sbin/reboot
```

### Get installation package and unzip

Downloand and unpack the GeoServer [**Platform Independent Binary** installation package](http://geoserver.org/release/maintain/) to the VM.

To download GeoServer version 2.15.0:
```shell
wget https://downloads.sourceforge.net/project/geoserver/GeoServer/2.15.0/geoserver-2.15.0-bin.zip
```

Connect to your VM and run the following commands. Remember to edit the zip file name to match the one you actually downloaded:

```bash
# Downloand and unpack GeoServer following http://docs.geoserver.org/stable/en/user/installation/linux.html
sudo apt install unzip
sudo unzip geoserver-2.15.0-bin.zip -d /usr/share/

# change owner of geoserver folder to "cloud-user"
sudo chown -R cloud-user /usr/share/geoserver-2.15.0/
```

**Note**:  if you have problems getting GeoServer to start, check that you actually changed the rights to the */usr/share/geoserver-2.15.0/* folder.

###  Create a symlinks to GeoServer installation
This will make easier to update GeoServer versions since you will need to only update these symlinks.
```
# Create symlink for installation folder
sudo ln -s /usr/share/geoserver-2.15.0/ /usr/share/geoserver
# Create symlink for data folder
ln -s /usr/share/geoserver-2.15.0/data_dir /usr/share/geoserver_data
```

Once you have set these symlinks you can use them through out your configuration settings.

### Add GeoServer to start automatically at VM boot
GeoServer is now installed but it is not running yet. To automatically start
GeoSever whenever the VM restarts, it is best to add it as a service.

To add GeoServer as a service to your server, you need two pieces of information:

- the symlink folder from previous step as the folder where your GeoServer is installed: `/usr/share/geoserver/`

- and the path to the java installation. You can get it by running:
```
# Check path to Java
sudo update-alternatives --config java
# Ouput should include something like:
 > /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java
```
The bit that you need is the path indicated in the output but withouth the "/jre/bin/java" part, for ex **/usr/lib/jvm/java-8-openjdk-amd64**

Connect to your VM and use vim (or any other text editor) to create a service file and edit its content with your GeoServer installation folder and your
Java path:

````bash
# Add GeoServer as service so it starts with VM starts
sudo vim /etc/systemd/system/geoserver.service

# --- start of geoserver.service file ---
# Manually add these lines to the file
# Edit the parts with the Java and GeoServer paths to match your system
[Unit]
Description=GeoServer Jetty container starter (metadata service crawler)
After=network.target

[Service]
User=cloud-user
Environment=JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
Environment=GEOSERVER_HOME=/usr/share/geoserver
ExecStart=/usr/share/geoserver/bin/startup.sh
ExecStop=/usr/share/geoserver/bin/shutdown.sh

# Output needs to appear in instance console output
StandardOutput=journal+console

[Install]
WantedBy=multi-user.target
# --- end of geoserver.service file ---
````

To finish the installation enable the service you just created and restart the VM.

````
# Add the service
sudo systemctl daemon-reload
sudo systemctl enable geoserver.service
sudo shutdown -r now
````

### Test that GeoServer is running

After your VM restars, test that your GeoServer is up and running via the web GUI:

**http://<vm-public-ip>:8080/geoserver/web/** (edit the vm-public-ip with your VM public ip).

You can also check that the server is running via the terminal for example with:
```bash
ps aux | grep GEOSERVER
journalctl -b | less | grep GEOSERVER
```

## Post installation settings

### Set the `admin` and `master` passwords

After GeoServer has been installed, the first thing you **must do** is to change the passwords for admin and master users and add new user for students.

Use the links in the home page of GeoServer web interface and:
- Change the `admin` password the first time you login (default password is `geoserver`).
- Set the `master` account password (see [Root account](http://docs.geoserver.org/stable/en/user/security/root.html) from GeoServer documentation).

## Optional settings to GeoServer
The following are some possibly interesting customization of GeoServer. Review the intention the customiataions and implement them if needed.

### Enabling CORS to allow JavaScript applications
If students want to use GeoServer services for example from a OpenLayers application, which code they write on the local machine, CORS must be allowed on GeoServer.
- Edit manually the GeoServer configuration following these [instruction](http://docs.geoserver.org/latest/en/user/production/container.html#enable-cors).
