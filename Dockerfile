FROM codait/max-base:v1.1.1

RUN apt-get update && apt-get -y install g++ gcc cmake libsm6 libxext6 libxrender-dev libglib2.0-dev libc6-i386 && \
 rm -rf /var/lib/apt/lists/*

# Fill in these with a link to the bucket containing the model and the model file name
ARG model_bucket=http://max-assets.s3.us.cloud-object-storage.appdomain.cloud/image-completer/1.0
ARG model_file=checkpoint.tar.gz

WORKDIR /workspace


RUN wget -nv --show-progress --progress=bar:force:noscroll ${model_bucket}/${model_file} --output-document=assets/${model_file} && \
  tar -x -C assets/ -f assets/${model_file} -v && rm assets/${model_file}

COPY requirements.txt /workspace

RUN pip install -r requirements.txt

RUN git clone https://github.com/cmusatyalab/openface.git && \
        cd openface && \
        git checkout cff4f882f2db647671004c2bb6d60bdc4aff75f5 && \
        git reset --hard && \
        models/get-models.sh

COPY . /workspace
EXPOSE 5000

CMD python app.py
