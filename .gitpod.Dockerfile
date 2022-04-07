FROM gitpod/workspace-full

USER gitpod

RUN brew install pandoc pandoc-include-code pandoc-plot pandoc-crossref
