# Use o Ubuntu 24.04 como base
FROM ubuntu:24.04

# Atualize pacotes do sistema e instale dependências necessárias para compilar Python
RUN apt-get update && apt-get install -y \
    software-properties-common \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    wget \
    curl \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libffi-dev \
    liblzma-dev \
    && apt-get clean

# Baixe e compile o Python 3.10.16
RUN wget https://www.python.org/ftp/python/3.10.16/Python-3.10.16.tgz && \
    tar xvf Python-3.10.16.tgz && \
    cd Python-3.10.16 && \
    ./configure --enable-optimizations && \
    make && \
    make install && \
    cd .. && \
    rm -rf Python-3.10.16 Python-3.10.16.tgz

# Atualize o pip e instale ferramentas necessárias
RUN python3.10 -m pip install --upgrade pip setuptools wheel ipykernel jupyter

# Defina o Python 3.10.16 como padrão para evitar conflitos
RUN update-alternatives --install /usr/bin/python python /usr/local/bin/python3.10 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/local/bin/python3.10 1 && \
    update-alternatives --set python /usr/local/bin/python3.10 && \
    update-alternatives --set python3 /usr/local/bin/python3.10

# Verifique as versões do Python e do pip
RUN python --version && pip --version

# Configure o Jupyter para permitir conexões remotas
RUN mkdir -p /root/.jupyter && \
    echo "c.NotebookApp.ip = '0.0.0.0'" >> /root/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.open_browser = False" >> /root/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.token = ''" >> /root/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.password = ''" >> /root/.jupyter/jupyter_notebook_config.py

# Copie o arquivo requirements.txt e instale as dependências globalmente
COPY requirements.txt /app/requirements.txt
RUN pip install -r /app/requirements.txt

# Defina o diretório de trabalho no contêiner
WORKDIR /app

# Configure a variável de ambiente LLAMA_CUBLAS durante o build (para llama_cpp_python)
ENV LLAMA_CUBLAS=1

# Copie os arquivos do projeto para o contêiner
COPY . .

# Exponha as portas necessárias
EXPOSE 8000 8888

# Garantir que o arquivo entrypoint.sh esteja executável
RUN chmod +x ./app/entrypoint.sh

# Defina o comando padrão para rodar o contêiner
#CMD ["sh", "-c", "./app/entrypoint.sh & tail -f /dev/null"]
CMD ["jupyter", "notebook", "--port=8000", "--no-browser", "--ip=0.0.0.0", "--allow-root"]
