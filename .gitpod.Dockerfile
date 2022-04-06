FROM gitpod/workspace-full

RUN sudo apt-get -q update && \
    sudo apt-get install -yq texlive-full inotify-tools && \
    sudo rm -rf /var/lib/apt/lists/*

USER gitpod

RUN brew install pandoc pandoc-include-code pandoc-plot pandoc-crossref
