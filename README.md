# Animeshon Artists Page

This is the artists page with all the connection to mailchimp.

# Build docker image

```
docker build -t gcr.io/gcp-animeshon-general/artists-animeshon-com:latest .
```

# Push docker image to Google Container Registry

Configure the docker credentials for Google Cloud (required only once):

```
gcloud auth configure-docker
```

Tag and push the docker image to the registry:

```
docker push gcr.io/gcp-animeshon-general/artists-animeshon-com:latest
```

# Run docker image locally

```
docker run --rm -p 8080:8080 artists-animeshon-com
```

Launch the browser at the address http://127.0.0.1:8080/.