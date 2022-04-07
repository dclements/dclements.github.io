FROM gitpod/workspace-full

RUN echo "rvm_gems_path=/home/gitpod/.rvm" > ~/.rvmrc

USER gitpod

RUN brew install pandoc pandoc-include-code pandoc-plot pandoc-crossref

RUN /bin/bash -l -c "gem install jekyll"
RUN /bin/bash -l -c "gem install bundler"
RUN /bin/bash -l -c "gem install jekyll-spaceship"