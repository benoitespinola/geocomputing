# Manual installation of Geonode in Ubuntu16.04
**Note:** Use the Quick Installation if possible. Manually installing GeoNode requires a lot of manual settings. 

Start with a clean Ubuntu16.04 virtual machine. It can be a GUI machine or a server machine and it can be running locally in for ex. VirtualBox or in the cloud for ex in CSC's cPouta.

Some differences may arise depending on the starting machine and what is installed in it by default. For example the tests with a default Ubuntu 16.04 server machine have commonly needed the installation of some packages that were not needed when using a default Ubuntu 16.04 GUI machine. The differences are marked with **Note-server-vm: ...** .

The following instructions are based on the official documentation but include some modifications. The full set of minimum installation commands and settings is found here so you only need to follow these instructions.

For reference, the official documentation can be found at:
http://docs.geonode.org/en/master/tutorials/install_and_admin/geonode_install/

The instructions below have been tested in VirtualBox Ubuntu16.04 GUI machine and in CSC's cPouta cloud using a default Ubuntu16.04 server machine.

The following instructions illustrate the case using a **cPouta default Ubuntu 16.04 server machine** but could be probably apply in another cloud service.

## Create a cPouta Ubuntu16.04 virtual machine

In cPouta create a virtual machine configuration (flavor) with at least 8Gb of memory. For example **Standard.Large** flavor.

Make sure that you have SSH access to the VM (in cPouta this means having properly configured security groups, public IP, ssh keys...).

The instructions below assume that you are loged in as the "geo" user. It will be easier to follow the installation instructions if you create a "geo" user.

cPouta VM images come with a single user named "cloud-user". Log in to the machine as "cloud-user" and create a "geo" user. Then add this new user to the sudo group.

**Note**: you can use any user account to follow these installation instructions but it needs to have sudo capabilities. If you are using a different user change the commands as necessary.

## Installation
The installation steps in summary:
- Packages installation
- GeoNode Virtual Environment Setup
- Install GeoNode to the Virtual Environment
- Databases and Permissions
- Finalize GeoNode Setup
- Set the environment
- Accessing and testing GeoNode
- Troubleshooting


## Packages Installation
This part follows the http://docs.geonode.org/en/master/tutorials/install_and_admin/geonode_install/install_geonode_application.html#packages-installation instructions.

This part goes quite well by simply following the oficial documentation. Run these commands manually one by one, see comments along with the commands for more details.

```
sudo apt-get update
sudo apt-get install python-virtualenv python-dev libxml2 libxml2-dev libxslt1-dev zlib1g-dev libjpeg-dev libpq-dev git default-jdk
sudo apt-get install build-essential openssh-server gettext nano vim unzip zip patch git-core postfix
# You will be asked for a method to set up email... Choose for ex Internet site... and accept the offer default for the mail name 'geonode-2.8.novalocal'.

sudo apt-add-repository ppa:webupd8team/java
sudo apt-get update
sudo apt-get install oracle-java8-installer
# Requires Java installation manual interaction to accept java's license terms

sudo apt-add-repository ppa:ubuntugis && sudo apt-get update && sudo apt-get upgrade
sudo apt-add-repository ppa:ubuntugis/ppa && sudo apt-get update && sudo apt-get upgrade
sudo apt-get install gcc apache2 libapache2-mod-wsgi libgeos-dev libjpeg-dev libpng-dev libpq-dev libproj-dev libxml2-dev libxslt-dev
sudo apt-add-repository ppa:ubuntugis/ubuntugis-testing && sudo apt-get update && sudo apt-get upgrade
sudo apt-get install gdal-bin libgdal20 libgdal-dev
sudo apt-get install python-gdal python-pycurl python-imaging python-pastescript python-psycopg2 python-urlgrabber
sudo apt-get install postgresql postgis postgresql-9.5-postgis-scripts postgresql-contrib
sudo apt-get install tomcat8
sudo apt-get update && sudo apt-get upgrade && sudo apt-get autoremove && sudo apt-get autoclean && sudo apt-get purge && sudo apt-get clean

# It will take some time but installation should have gone without problems

```

## GeoNode Virtual Environment Setup
Follows the official documentation: http://docs.geonode.org/en/master/tutorials/install_and_admin/geonode_install/install_geonode_application.html#geonode-setup

This part already has some things that needed to be changed from the official documentation. Follow these instructions and visit the oficial documentation for some extra info and to compare with the commands below.

```
# There were problems upgrading pip with the suggested commands. Use instead:
sudo easy_install pip
pip --version
# You should have something like: pip 10.0.1 (tested in June 2018)


pip install --user virtualenv
pip install --user virtualenvwrapper

export WORKON_HOME=~/Envs
mkdir -p $WORKON_HOME
source $HOME/.local/bin/virtualenvwrapper.sh
printf '\n%s\n%s\n%s' '# virtualenv' 'export WORKON_HOME=~/Envs' 'source $HOME/.local/bin/virtualenvwrapper.sh' >> ~/.bashrc
source ~/.bashrc

mkvirtualenv --no-site-packages geonode
```
**Note-server-machine**: when installing `virtualenv` in a server machine you may get an error about path not found, for ex *'ERROR: virtualenvwrapper could not find virtualenv in your path'*.

If you are installing in a server machine run this commands:
```
sudo apt install virtualenv
sudo apt install virtualenvwrapper
```

- TODO: why these problems with the pip installation?

The following commands create a "geonode" user and add the user "geo" to the "geonode" group.

```
sudo useradd -m geonode
sudo usermod -a -G geonode
sudo chmod -Rf 775 /home/geonode/
sudo su - geo
```

## Install GeoNode to the Virtual Environment
Activate the virtualenv and install the GeoNode Django project:
```
workon geonode
cd /home/geonode
# note that you are working from now on in the geonode virtualenv so your prompt looks like:
# (geonode) geo@geonode-virtualmachine:/home/geonode$

pip install Django==1.8.18

django-admin.py startproject --template=https://github.com/GeoNode/geonode-project/archive/2.8.0.zip -e py,rst,json,yml my_geonode

# If you get an error like: CommandError: [Errno 13] Permission denied: '/home/geonode/my_geonode'...
# log out and log in for permissions of your "geo" user to be active
```

Install GeoNode with the commands below.

Here you will need to make several changes to the installation settings you get from the git repository and some extra commands not mentioned in the official documentation.

First go to the GeoNode project folder and check for the gdal version installed in your system and what pygdal versions are available.
```
cd my_geonode
# Find the closest pygdal version.
# Example: 2.2.1 ...  2.2.1.3, ...
# Your installed gdal version:
gdal-config --version
# The available python packages:
pip install pygdal==
```

Edit the requirements.txt with the pygdal version you found plus the following versions and add and remove as indicated in the `requirements.txt` file:
```
vim requirements.txt
```

Edit the file as follwos:
```
# Edit existing lines with:
pygdal==2.2.1.3
pyproj==1.9.5
Shapely==1.5.13

# Add the following packages:
kombu==4.1.0
pytz==2018.3
amqp==2.2.2

# Remove the following packages:
celery==4.1.0

# Add the following line to add the geonode repository:
-e git://github.com/GeoNode/geonode.git@2.8.0#egg=geonode

# leave the rest of the lines as they were in the original file
# ...
```

This is an example of the requirements.txt file after the above mentioned edits:
```
TODO
```

Now for the installation:
```
pip install celery==4.1.0
pip install -r requirements.txt --upgrade
pip install -e . --upgrade --no-cache
```

You may notice that you get the errors below, but those seem an unsolvable conflict between geonode and pycsw requirements (TODO: find out more about how to fix this issue):
```
pycsw 2.0.3 has requirement OWSLib==0.10.3, but you'll have owslib 0.15.0 which is incompatible.
pycsw 2.0.3 has requirement pyproj==1.9.3, but you'll have pyproj 1.9.5.1 which is incompatible.
pycsw 2.0.3 has requirement Shapely==1.3.1, but you'll have shapely 1.5.13 which is incompatible.
```

This phase should be OK now.


## Databases and Permissions
The original official instructions:
http://docs.geonode.org/en/master/tutorials/install_and_admin/geonode_install/create_geonode_db.html#databases-and-permissions

Set up a new PostgreSQL user and databases:
```
sudo -u postgres createuser -P geonode
# give a password for the new database user
sudo -u postgres createdb -O geonode geonode

# And database geonode_data with owner geonode
sudo -u postgres createdb -O geonode geonode_data
# Switch to user postgres and create PostGIS extension
sudo -u postgres psql -d geonode_data -c 'CREATE EXTENSION postgis;'
```
**Note-server-machine**: postgis-scripts did not install properly, creating extension fails.
	- Fix: sudo apt install -y postgresql-9.5-postgis-2.3 postgresql-9.5-postgis-2.3-scripts
	- TODO: review why this is happening (for ex. install differently at the beginning?)

Then adjust permissions:
```
sudo -u postgres psql -d geonode_data -c 'GRANT ALL ON geometry_columns TO PUBLIC;'
sudo -u postgres psql -d geonode_data -c 'GRANT ALL ON spatial_ref_sys TO PUBLIC;'
sudo -u postgres psql -d geonode_data -c 'GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO geonode;'
```

Now change user access policy for local connections in file `pg_hba.conf`:
```
sudo vim /etc/postgresql/9.5/main/pg_hba.conf
```

Change the following:
```
Scroll down to the bottom of the document. We only need to edit one line. Change
 "local" is for Unix domain socket connections only
local   all             all                                     peer
Into
 "local" is for Unix domain socket connections only
local   all             all                                     trust
```

**Note**: make sure setting this to trust is safe enough. (Trust: Allow the connection unconditionally. This method allows anyone that can connect to the PostgreSQL database server to login as any PostgreSQL user they wish, without the need for a password or any other authentication.)

Restart PostgreSQL:
```
sudo service postgresql restart
# check that it is working
psql -U geonode geonode
# Use \q to quit
```

## Finalize GeoNode Setup
The original official instructions:
http://docs.geonode.org/en/master/tutorials/install_and_admin/geonode_install/create_geonode_db.html#finalize-geonode-setup

Final settings for a basic GeoNode installation to run. The following instructions differ substantially from the official documentation but have been tested and work.
```
# If not already active, activate the `geonode` Python Virtual Environment:
workon geonode
cd /home/geonode/my_geonode
# your promt looks like:
# (geonode) geo@geonode-virtualmachine:/home/geonode/my_geonode$
```

Edit the */home/geonode/my_geonode/my_geonode/settings.py* file:
```
vim my_geonode/settings.py
# Find the line where the time zone is defined and change it to:
'Europe/Helsinki'
```

Create a copy of the */home/geonode/my_geonode/my_geonode/local_settings.py.sample* file, no need to edit it:
```
cp my_geonode/local_settings.py.sample my_geonode/local_settings.py
```

TODO: revisit this documentation link and review what changes would be necessary, so far with the default values all seems to work OK.


## Set the environment
http://docs.geonode.org/en/master/tutorials/install_and_admin/geonode_install/create_geonode_db.html

First, install paver and pyyaml (in case it is not installed yet) stop all the services and reset the GeoNode installation.
```
sudo apt install python-paver

sudo service apache2 stop
sudo service tomcat8 stop
# Being sure other services are stopped

# Hard Reset
# Warning: This will delete all data you created until now.
paver reset_hard
sudo pip install pyyaml

# Cleanup folders and old DB Tables
# Hard Reset
# Warning: This will restore only GeoServer.
rm -Rf geoserver
rm -Rf downloaded/*.*
```

Revert to default GeoNode site settings:
```
# TODO: find out why these lines need to be commented
# You need to revert some customizations of the my_geonode local_settings. In order to do that, edit the my_geonode/local_settings.py file:

vim my_geonode/local_settings.py

# Comment the following pieces

...
# SITEURL = 'http://localhost'
...
#GEOSERVER_LOCATION = os.getenv(
#    'GEOSERVER_LOCATION', '{}/geoserver/'.format(SITEURL)
#)

#GEOSERVER_PUBLIC_LOCATION = os.getenv(
#    'GEOSERVER_PUBLIC_LOCATION', '{}/geoserver/'.format(SITEURL)
#)
...
```

Being sure folders permissions are correctly set
```
sudo chown -Rf geonode: my_geonode/uploaded/
sudo chown -Rf geonode: my_geonode/static*
```

Before you continue you need to do some modifications to the GeoNode's own firewall settings.
```
vim /home/geo/Envs/geonode/local/lib/python2.7/site-packages/django/http/request.py

# ---> Change lines
...
# Allow variants of localhost if ALLOWED_HOSTS is empty and DEBUG=True.
			 allowed_hosts = settings.ALLOWED_HOSTS
			 if settings.DEBUG and not allowed_hosts:
					 allowed_hosts = ['localhost', '127.0.0.1', '[::1]']

# ---> To: (where <your-public-ip> is the public ip of the VM where the GeoNode server is accessed)
# Allow variants of localhost if ALLOWED_HOSTS is empty and DEBUG=True.
			 allowed_hosts = ['<your-public-ip>', 'localhost', '127.0.0.1', '[::1]']
			 # if settings.DEBUG and not allowed_hosts:
			 #	 allowed_hosts = ['localhost', '127.0.0.1', '[::1]']

```
TODO: find out why setting the firewall rules in the my_geonode/settings.py file does not casdade to the reques.py file edited above, which would be the logical way to set this.


## Final settings

### Install GeoServer pringing plugin

Go to the download page for the GeoServer version you have in your installation, and download to the GeoServer libraries folder (/home/geonode/my_geonode/geoserver/geoserver/WEB-INF/lib)

For example if your GeoServer version is 2.12.2:

wget https://downloads.sourceforge.net/project/geoserver/GeoServer/2.12.2/extensions/geoserver-2.12.2-printing-plugin.zip

The plugin will be installed next time you restart the GeoSever service.

### Set Apache LogLevel

Change the level of information to log by Apache:

```
sudo vim /etc/apache2/apache2.conf

Edit to:

# LogLevel: Control the severity of messages logged to the error_log.
# Available values: trace8, ..., trace1, debug, info, notice, warn,
# error, crit, alert, emerg.
# It is also possible to configure the log level for particular modules, e.g.
# "LogLevel info ssl:warn"
#
LogLevel info
```

## Start GeoNode

Setup and start the system in DEV mode:

```
paver setup
# This command downloads and extract the correct GeoServer version

paver sync
# This command prepares the DB tables and loads initial data

paver start
# This command allows you to start GeoNode in development mode
```

## Accessing and testing GeoNode

### Accessing GeoNode

After starting GeoNode with *paver start* Your terminal keeps on giving you the logs of the server. You can exit this view with ctrl+C, the server remains up and running.

Geonode should be available at port 8000 in the public ip address of your VM (http://<your-public-ip>:8000).

Also Geoserver at http://<your-public-ip>:8080/geoserver

**Make sure that your virtual machine has the firewall rules properly set (security groups in cPouta). Open the ports 8000 and 8080 as necessary.**

### Logs and data directory
To see the logs once server is running:
- http://docs.geonode.org/en/master/tutorials/admin/debug_geonode/
- tail /var/log/apache2/error.log
- tail /var/log/postgresql/postgresql-9.5-main.log
- tail /home/geonode/my_geonode/geoserver/data/logs/geoserver.log

GeoServer data directory:
Data directory 	/home/geonode/my_geonode/geoserver/data

GeoSever extensions directory:
/home/geonode/my_geonode/geoserver/geoserver/WEB-INF/lib


Apache2 running in port 80


### Restarting GeoNode after machine reboot
```
workon geonode
cd /home/geonode/my_geonode

sudo service apache2 stop
sudo service tomcat8 stop
paver stop
paver sync
paver start

# if Port 8080 is already in use... repeat until it works
```

## Troubleshooting
### Reseting installation
If you run into some errors during the paver phase or need to change some settings, use the following commands to reset the installation (Warning: THIS WILL DELETE THE WHOLE INSTALLATION INC DATA LAYERS):
```
workon geonode
cd /home/geonode/my_geonode

sudo service apache2 stop
sudo service tomcat8 stop
paver reset_hard
paver sync
paver start
```
