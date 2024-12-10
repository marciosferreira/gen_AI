# Use o Ubuntu 24.04 como base
FROM ubuntu:24.04

# Atualize pacotes do sistema e instale dependências necessárias
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

# Atualize o pip para a última versão
RUN python3.10 -m pip install --upgrade pip

# Defina o diretório de trabalho no contêiner
WORKDIR /app

# Configure a variável de ambiente LLAMA_CUBLAS durante o build (para llama_cpp_python)
ENV LLAMA_CUBLAS=1

# Copie os arquivos do projeto para o contêiner
COPY . .
 
# Instale as dependências do projeto a partir do requirements.txt # --no-cache-dir
RUN pip install -r requirements.txt  

# Exponha a porta necessária
EXPOSE 8000

# Garantir que o arquivo entrypoint.sh esteja executável
RUN chmod +x entrypoint.sh


# Comando padrão para executar o app
CMD ["sh", "-c", "./entrypoint.sh &"]


