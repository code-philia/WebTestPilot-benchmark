FROM mcr.microsoft.com/playwright/python:v1.60.0-noble
RUN pip install playwright==1.60.0 --root-user-action=ignore && \
    apt-get update && apt-get install -y --no-install-recommends nginx && \
    rm -rf /var/lib/apt/lists/*