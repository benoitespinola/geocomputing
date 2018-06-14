# Installation of Geonode in Ubuntu16.04
Start with a clean Ubuntu16.04 virtual machine. It can be a GUI machine or a server machine and it can be running in VirtualBox or cPouta.

Some differences may arise depending on the starting machine and what is installed in it by default. For example the tests with a Ubuntu server machine have commonly needed the installation of some software that was not needed for in the GUI tests. The differences are marked with for ex. **Note-server-vm:...**.

The following instructions are based on the official documentation at:
http://docs.geonode.org/en/master/tutorials/install_and_admin/geonode_install/

The commands we needed to run are all copied here from the official documentation, those may not be explained in detail as they already are in the official tutorial. Things that were not up-to-date and/or necessary extra steps and/or important notes are the main contribution to the official documentation.

The instructions below have been tested in VirtualBox GUI Ubuntu16.04 machine and in cPouta server Ubuntu16.04.

## Create a cPouta Ubuntu16.04 virtual machine
Use a configuration (flavor) with at least 8Gb of memory.

If using a cloud service as cPouta, make sure that you have SSH access to the VM (security groups, public IP...).

**Note-gui-machine**: If you are using an Ubuntu16.06 GUI machine, create a user named "geo", so you can easily follow the general installation instructions (which assume such a user).

**Note-server-machine**: if you are using for ex cPouta, you can use the default user ("cloud-user") during the installation. Remember to change the name where corresponds, it is also noted in the instructions below.


### Packages Installation
The part follows the http://docs.geonode.org/en/master/tutorials/install_and_admin/geonode_install/install_geonode_application.html#packages-installation instructions.

This part goes quite well by simply following the oficial documentation. Run these commands manually one by one, see comments below for information.

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

### GeoNode Setup
Following the official documentation: http://docs.geonode.org/en/master/tutorials/install_and_admin/geonode_install/install_geonode_application.html#geonode-setup

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
**Note-server-machine**: when installing in server machine virtualenv you may get an error about path not found, for ex '*ERROR: virtualenvwrapper could not find virtualenv in your path*'.

If installing in server machine run this commands:

```
sudo apt install virtualenv
sudo apt install virtualenvwrapper
```
- TODO: why these problems with the pip installation?

The following commands are creating a "geonode" user and adding the "geo" (or "cloud-user") to the geonode's group.
**Note-server-machine**: for the following commands use "cloud-user" instead geo user.
```
sudo useradd -m geonode
sudo usermod -a -G geonode  #sudo usermod -a -G geonode cloud-user
sudo chmod -Rf 775 /home/geonode/
sudo su - geo # sudo su - cloud-user
```

### Install GeoNode to the geonode virtualenv
Activate the virtualenv and install the GeoNode Django project:

```
workon geonode
cd /home/geonode
# note that you are working from now on in the geonode virtualenv so your prompt looks like:
# (geonode) cloud-user@geonode-virtualmachine:/home/geonode$

pip install Django==1.8.18
django-admin.py startproject --template=https://github.com/GeoNode/geonode-project/archive/2.8.0.zip -e py,rst,json,yml my_geonode

# If you get an error like: CommandError: [Errno 13] Permission denied: '/home/geonode/my_geonode'...
# log out and log in for permissions to be active
```

Install GeoNode with the commands below. Here you will need to make several changes to the installation settings you get from the git repository and some extra commands not mentioned in the documentation.

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

Edit the requirements.txt with the pygdal version you found plus the following versions and add and remove as indicated here:
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
```

This is an example of the requirements.txt file after the above mentioned edits:
```

```

Now for the installation:
```
pip install celery==4.1.0
pip install -r requirements.txt --upgrade
pip install -e . --upgrade --no-cache
```

You may notice that you get these errors, but those seem an unsolvable conflict between geonode and pycsw requirements (TODO: find out more about this):
```
pycsw 2.0.3 has requirement OWSLib==0.10.3, but you'll have owslib 0.15.0 which is incompatible.
pycsw 2.0.3 has requirement pyproj==1.9.3, but you'll have pyproj 1.9.5.1 which is incompatible.
pycsw 2.0.3 has requirement Shapely==1.3.1, but you'll have shapely 1.5.13 which is incompatible.
```

This phase should be OK now.


### Databases and Permissions
http://docs.geonode.org/en/master/tutorials/install_and_admin/geonode_install/create_geonode_db.html#databases-and-permissions

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

Now we are going to change user access policy for local connections in file pg_hba.conf
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

**Note**: make sure setting this to trust is safe enough. (Trust: Allow the connection unconditionally. This method allows anyone that can connect to the PostgreSQL database server to login as any PostgreSQL user they wish, without the need for a password or any other authentication. See Section 19.3.1 for details.)

Restart PostgreSQL:
```
sudo service postgresql restart
# check that it is working
psql -U geonode geonode
# Use \q to quit
```

### Finalize GeoNode Setup
http://docs.geonode.org/en/master/tutorials/install_and_admin/geonode_install/create_geonode_db.html#finalize-geonode-setup

Final settings for a basic GeoNode installation to run. The following instructions differ substantially from the official documentation but have been tested and work.
```
# If not already active let’s activate the new geonode Python Virtual Environment:
workon geonode
cd /home/geonode/my_geonode
# your promt looks like:
# (geonode) cloud-user@geonode-virtualmachine:/home/geonode/my_geonode$
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


###  Set the environment and paver http://docs.geonode.org/en/master/tutorials/install_and_admin/geonode_install/create_geonode_db.html

Firs, stop all the services and reset the GeoNode installation.
```
sudo service apache2 stop
sudo service tomcat8 stop
# Being sure other services are stopped

# Hard Reset
# Warning: This will delete all data you created until now.
paver reset_hard

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

Before yoy continue you need to do some modifications to the GeoNode's own firewall settings.
```
vim /home/cloud-user/Envs/geonode/local/lib/python2.7/site-packages/django/http/request.py

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

Setup and start the system in DEV mode

```
paver setup
# This command downloads and extract the correct GeoServer version

paver sync
# This command prepares the DB tables and loads initial data

paver start
# This command allows you to start GeoNode in development mode
```


## Accessing GeoNode

After starting GeoNode with *paver start* Your terminal keeps on giving you the logs of the server. You can exit this view with ctrl+C, the server remains up and running.

Geonode should be available at port 8000 in the public ip address of your VM (http://<your-public-ip>:8000).

Also Geoserver at http://<your-public-ip>:8080/geoserver

**Make sure that your virtual machine has the firewall rules properly set (security groups in cPouta). Open the ports 8000 and 8080 as necessary.**

## Logs and data directory
To see the logs once server is running:
- http://docs.geonode.org/en/master/tutorials/admin/debug_geonode/
- tail /var/log/apache2/error.log
- tail /var/log/postgresql/postgresql-9.5-main.log
- tail /home/geonode/my_geonode/geoserver/data/logs/geoserver.log

GeoServer data directory:
Data directory 	/home/geonode/my_geonode/geoserver/data

Apache2 running in port 80


### Restarting GeoNode after machine reboot
```
workon geonode
cd /home/geonode/my_geonode

sudo service apache2 stop
sudo service tomcat8 stop
paver stop
paver start

# if Port 8080 is already in use... repeat until it works
```


### Troubleshooting
#### Reseting installation
If you run into some errors during the paver phase or need to change some settings, use the following commands to reset the installation (Warning: not tested with datasets loaded, data could be erased):
```
paver reset_hard
paver setup
paver sync
paver start
```

#### GeoServer version
TESTING Geoserver
http://193.167.189.204:8080/geoserver/web/
Works normally, got GS version 2.12.2 (were as in the docker installation you get 2.13... and also postgresql 9.6, here 9.5)
In the Geoserver gui, there is a geonode icon which sends you to http://localhost:8000/o/authorize/?response_type=code&client_id=Jrchz2oPY3akmzndmgUTYrs9gczlgoV20YPSvqaV&scope=write&redirect_uri=http://localhost:8080/geoserver/index.html
... how would this be needed to set so that it uses the actual ip, instead of localhost?

#### Where the GeoNode firewall settings should be fixed
For some reason these would not affect the installation so are not needed. Simply edit in the request.py mentioned above. Here are these for reference:

Stop the runnin app with ctrl+c and paver stop

Added ip to ALLOWED_HOSTS in settings.py
```
ALLOWED_HOSTS = ['django','193.167.189.204','localhost','127.0.0.1','::1'] if os.getenv('ALLOWED_HOSTS') is None \
    else re.split(r' *[,|:|;] *', os.getenv('ALLOWED_HOSTS'))

PROXY_ALLOWED_HOSTS += ('nominatim.openstreetmap.org','193.167.189.204','localhost','127.0.0.1','::1')
```

Reset paver: paver reset_hard (only stoping and start does not take changes into effect)

Restart paver: paver start


#### Install firevox to text localhost
Install firefox for testing locally
```
sudo apt install firefox
```

Test with http://localhost:8000




### Image in cPouta with basic steps DONE
For testing, htere is a semi ready image in cpouta "geonode-server-installed" with all the steps up to just before testing paver.

Use that image to test the configuration of the paver.

1. launch new VM from image
2. First thing, cp my_geonode/local_settings.py.sample my_geonode/local_settings.py (forgot to do that before creating the image)
3.  workon geonode
4. Make changes as needed...


4. paver setup from /home/geonode/my_geonode

The cPouta machine better have 8Gb memory, otherwise it starts to fail pretty quicly due to lack of memory.


### TODOs

Check admis workshop:
http://geonode.org/dev-workshop/#/3



See:
netstat -altpvn

And
sudo lsof -i -n -P
sudo netstat -tulnp
sudo lsof -i -n -P
