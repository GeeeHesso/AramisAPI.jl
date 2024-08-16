FROM python:3.7-bullseye

RUN apt update && apt install -y curl && \
    curl -fsSL https://install.julialang.org > install.sh && \
    bash install.sh -y -p /usr/local/julia && \
    ln -s /usr/local/julia/bin/julia /usr/bin/julia && \
    rm install.sh

RUN python -m pip install --upgrade pip && python -m pip install pandas scikit-learn

RUN julia -e 'using Pkg; Pkg.add(url="https://github.com/GeeeHesso/AramisAPI.jl"); Pkg.precompile()'

EXPOSE 8080

CMD ["julia", "-e", "using AramisAPI; start_server(host=\"0.0.0.0\")"]