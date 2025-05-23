FROM python:3.6-bullseye

WORKDIR /app

RUN python -m pip install --upgrade pip && python -m pip install pandas scikit-learn

RUN apt update && apt install -y curl && \
  curl -fsSL https://install.julialang.org > /tmp/install-julia.sh && \
  bash /tmp/install-julia.sh -y -p /usr/local/julia && \
  /usr/local/julia/bin/juliaup config startupselfupdateinterval 0 && \
  ln -s /usr/local/julia/bin/julia /usr/bin/julia && \
  rm /tmp/install-julia.sh && apt remove -y curl

RUN julia -e 'using Pkg; Pkg.add(path="https://github.com/GeeeHesso/AramisAPI.jl"); Pkg.precompile()'

EXPOSE 8080

CMD ["julia", "-e", "using AramisAPI; start_server(host=\"0.0.0.0\")"]
