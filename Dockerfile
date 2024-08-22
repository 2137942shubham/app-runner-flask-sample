# Define global arguments
ARG APP_DIR="/app"

#
# Build image
#
FROM python:3.11-slim-bookworm AS build-env
ARG APP_DIR

# Setup gunicorn
RUN pip install --no-cache-dir gunicorn

# Install application
COPY "app/requirements.txt" "${APP_DIR}/requirements.txt"
RUN pip install --no-cache-dir -r "${APP_DIR}/requirements.txt"

#
# Application image
#
FROM gcr.io/distroless/python3-debian12
ARG APP_DIR

# Copy Application (Using style from the second example)
ENV APP_HOME ${APP_DIR}
WORKDIR ${APP_HOME}
COPY . ./

# Copy dependencies from build stage
COPY --from=build-env /usr/local/lib/python3.11/site-packages /root/.local/lib/python3.11/site-packages
COPY --from=build-env /usr/local/bin/gunicorn /usr/local/bin/gunicorn

# Command settings (Modified as per second example)
ENV PORT 5000 # Explicitly define the port
CMD exec gunicorn --bind :$PORT --workers 4 --threads 2 --timeout 300 app:app
