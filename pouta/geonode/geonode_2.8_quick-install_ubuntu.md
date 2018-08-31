# Quick-install of Geonode in Ubuntu16.04
Start with a clean Ubuntu16.04 virtual machine. It can be a GUI machine or a server machine and it can be running locally in for ex. VirtualBox or in the cloud for ex in CSC's cPouta.

Some differences may arise depending on the starting machine and what is installed in it by default.

For reference, the official quick-install documentation can be found at the [GeoNode's Quick Installation Guide](http://docs.geonode.org/en/master/tutorials/install_and_admin/quick_install.html).

The instructions below have been tested in in CSC's cPouta cloud using a default Ubuntu16.04 server machine.

## Create a cPouta Ubuntu16.04 virtual machine

In cPouta create a virtual machine configuration (flavor) with at least 8Gb of memory. For example **Standard.Large** flavor.

Make sure that you have SSH access to the VM (in cPouta this means having properly configured security groups, public IP, ssh keys...).

cPouta VM images come with a single user named "cloud-user". Log in to the machine as "cloud-user".

See the [CSC's Pouta User Guide](https://research.csc.fi/pouta-user-guide) for detailed instructions.

## GeoNode installation
```
sudo apt update; sudo apt -y upgrade

sudo apt install -y python-setuptools

# Install necessary tools
sudo easy_install pip
python --version
pip --version

# Install postgres to avoid errors with postgis.control file missing, which creates problems in database creation
sudo apt install -y postgresql-9.5-postgis-2.2 postgresql-9.5-postgis-scripts
```
```
# Add geonode ppa
sudo add-apt-repository ppa:geonode/stable
sudo apt-get update; sudo apt-get upgrade; sudo apt-get autoremove

# Install geonode
sudo apt-get -y install geonode
geonode help
```


Finally set the public IP of your server as the GeoNode entry point.
```
# Set up your public IP for Geonode
sudo geonode-updateip <your public ip>
# This restarts the server, it will take a bit for it to be up and running again

# Default user:pass admin:admin, in geoserver admin:geoserver
# First time you login, it may take quite long (over 1 min)... why?
```

Set up the proxy in GeoServer with your GeoNode public IP:
```
# Open geoserver and go to Settings>Global, set Proxy Base URL
# From: http://localhost:8080/geoserver
# To: http://<your public ip>:8080/geoserver

# Go back to GeoNode and test uploading a shapefile dataset, select all files related to the .shp file (same name, different extension)
# The layer should be visible now in Explore Layers
```



## Other settings and info
In some versions of the quick install documentation it is requested to create a geonode super user:
```
# Why createsuperuser?
geonode createsuperuser
```

If you need to restart geoserver (ref: http://docs.geonode.org/en/master/tutorials/install_and_admin/geonode_install/install_geoserver_application.html)
```
sudo service tomcat8 restart
```

To connect to the PostgreSQL database:
```
sudo sudo -u postgres psql -d geonode_data
```
### GeoSever installation path
GeoServer is installed in /usr/share/geoserver

### GDAL installation
Default GDAL version is very old 1.1, you may want to install newer
```
ogrinfo --version
sudo add-apt-repository ppa:ubuntugis/ppa && sudo apt-get update
sudo apt install gdal-bin
ogrinfo --version
sudo service tomcat8 restart
```
### Testing: adding other GDAL drivers
Ref: http://docs.geonode.org/en/master/tutorials/advanced/adv_data_mgmt/adding_data/gdal_format.html
- testing:
  - error jp2 not supported from geonode
  - check geoserver version 2.12.15, check gdal extension version... compared to the correct 2.12.15... different, download extension, delete unmatched gdal related files and copy plus overwrite extension files to `/usr/share/geoserver/WEB-INF/lib/`
  - still fails...
  - install newer gdal (default one is 1.1) http://www.sarasafavi.com/installing-gdalogr-on-ubuntu.html
  -


## Troubleshooting

### Error during GeoNode installation
- setuptools error
  - Fix by installing setuptools before  geonode `sudo apt install python-pip`

- postgis.control error occurs...
  - Fix by installing postgis before geonode (see above)
  - If you did not install postgis before geonode, install it again with the commands above, then fix the permissions as indicated in next error fix -> See reinstalling postgis and scripts. See also https://gis.stackexchange.com/questions/71302/running-create-extension-postgis-gives-error-could-not-open-extension-control-fi

- if postgis error uploading layer -> somehow the postgis extension and rights were not succesfully setup -> See the postgis.control error above, maybe related -> http://osgeo-org.1560.x6.nabble.com/An-exception-occurred-loading-data-to-PostGIS-java-io-IOException-Error-occurred-creating-table-td5241618.html -> http://docs.geonode.org/en/latest/tutorials/install_and_admin/geonode_install/create_geonode_db.html

  - fix If you did not install PostgreSQL before installing GeoNode (as recommended above), you may run into problems with PostGIS when uploading a vector layer:

    ```
    # In case you get postgis error while uploading a layer in geonode, it may be caused by fauty automatic settings in database creation
    # An exception occurred loading data to PostGIS- java.io.IOException
    # Follow manual steps from: hhtp:...

    sudo -u postgres psql -d geonode_data -c 'CREATE EXTENSION postgis;'
    sudo -u postgres psql -d geonode_data -c 'GRANT ALL ON spatial_ref_sys TO PUBLIC;'
    sudo -u postgres psql -d geonode_data -c 'GRANT ALL ON geometry_columns TO PUBLIC;'
    sudo -u postgres psql -d geonode_data -c 'GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO geonode;'
    ```
