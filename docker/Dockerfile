FROM ghcr.io/osgeo/gdal:ubuntu-small-3.9.1

RUN apt-get update && apt-get install --no-install-recommends --no-install-suggests -y python3-pip sqlite3
RUN pip install --break-system-packages https://github.com/acalcutt/rio-rgbify/archive/eaeaed75f99fc79dd47406add719eea2293ec390.zip

RUN apt-get update && apt-get install --no-install-recommends --no-install-suggests -y build-essential libsqlite3-dev zlib1g-dev curl
RUN curl -L https://github.com/felt/tippecanoe/archive/refs/tags/2.57.0.tar.gz | tar xz -C /opt/
RUN cd /opt/tippecanoe-2.57.0 && make -j install