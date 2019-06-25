#
# Copyright 2018-2019 IBM Corp. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

FROM codait/max-base:v1.1.3

# Fill in these with a link to the bucket containing the model and the model file name
ARG model_bucket=https://max-assets-prod.s3.us-south.cloud-object-storage.appdomain.cloud/max-image-completer/1.0.0
ARG model_file=assets.tar.gz


WORKDIR /workspace


RUN wget -nv --show-progress --progress=bar:force:noscroll ${model_bucket}/${model_file} --output-document=assets/${model_file} && \
  tar -x -C assets/ -f assets/${model_file} -v && rm assets/${model_file}

COPY requirements.txt /workspace
RUN pip install -r requirements.txt

RUN git clone https://github.com/cmusatyalab/openface.git && \
        cd openface && \
        git checkout c2d3b2df055ae8637eff28422d7916c1575a6e83 && \
        git reset --hard
RUN conda install -c menpo dlib opencv
RUN python openface/setup.py install
RUN openface/models/get-models.sh

COPY . /workspace
RUN ls -Ral /workspace/assets

EXPOSE 5000

CMD python app.py
