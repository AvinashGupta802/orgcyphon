FROM ubuntu:18.04

RUN apt-get update

RUN apt-get install -y curl 

RUN apt-get install -y \
    apt-transport-https \
    ca-certificates \
    software-properties-common
	
RUN apt-get -y install python-pip



ARG UID=1000
ARG GID=1000

ENV CYPHON_HOME /usr/src/app
ENV LOG_DIR     /var/log/cyphon
ENV PATH        $PATH:$CYPHON_HOME
ENV NLTK_DATA   /usr/share/nltk_data

COPY requirements.txt $CYPHON_HOME/requirements.txt

RUN add-apt-repository ppa:ubuntugis/ppa 

RUN apt-get update

RUN apt-get install -y python3-pip

RUN pip install -r $CYPHON_HOME/requirements.txt 

RUN python3 -m pip install -r $CYPHON_HOME/requirements.txt 

RUN python -m nltk.downloader -d /usr/local/share/nltk_data punkt wordnet

# create unprivileged user
RUN groupadd  -g 1000 cyphon
RUN adduser --system --ingroup cyphon -u 1000 cyphon

# create application subdirectories
RUN mkdir -p $CYPHON_HOME \
             $CYPHON_HOME/media \
             $CYPHON_HOME/static \
             $LOG_DIR

# copy project to the image
COPY cyphon $CYPHON_HOME/cyphon

# copy entrypoint scripts to the image
COPY entrypoints $CYPHON_HOME/entrypoints

COPY cyphon/cyphon/settings/base.example.py $CYPHON_HOME/cyphon/cyphon/settings/base.py
COPY cyphon/cyphon/settings/conf.example.py $CYPHON_HOME/cyphon/cyphon/settings/conf.py
COPY cyphon/cyphon/settings/dev.example.py $CYPHON_HOME/cyphon/cyphon/settings/dev.py
COPY cyphon/cyphon/settings/prod.example.py $CYPHON_HOME/cyphon/cyphon/settings/prod.py


# set owner:group and permissions
RUN chown -R cyphon:cyphon $CYPHON_HOME \
 && chmod -R 775 $CYPHON_HOME \
 && chown -R cyphon:cyphon $LOG_DIR \
 && chmod -R 775 $LOG_DIR
 
 
WORKDIR $CYPHON_HOME/cyphon

VOLUME ["$CYPHON_HOME/keys", "$CYPHON_HOME/media", "$CYPHON_HOME/static"]

EXPOSE 8000

RUN apt-get -y install gdal-bin

RUN pip3 install psycopg2-binary

RUN apt-get -y install vim sudo

CMD $CYPHON_HOME/entrypoints/run.sh
