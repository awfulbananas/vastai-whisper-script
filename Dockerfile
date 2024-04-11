FROM pytorch/pytorch

#run all the setup commands for git and whisperx
RUN <<EOF bash
apt-get -y update
apt-get -y install git
apt update && apt install ffmpeg -y

set -x

conda init bash

# inline copy-pasta of the conda init entry in .bashrc.
__conda_setup="\$('/opt/conda/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
  eval "\$__conda_setup"
else
  if [ -f "/opt/conda/etc/profile.d/conda.sh" ]; then
      . "/opt/conda/etc/profile.d/conda.sh"
  else
      export PATH="/opt/conda/bin:\$PATH"
  fi
fi
unset __conda_setup

# Create the environment if it doesn't exist.
if ! grep -q whisperx .conda/environments.txt; then
 conda create -y --name whisperx python=3.10
fi


conda install pytorch==2.2.2 torchaudio==2.2.2 pytorch-cuda=11.8 -c pytorch -c nvidia
conda run --name whisperx pip install git+https://github.com/m-bain/whisperx.git
conda run --name whisperx pip install pyannote.audio==3.1
EOF

WORKDIR /usr/src

COPY . .

CMD python transcribe_worker.py