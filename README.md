# Animeshon Coming Soon Page

This is the coming soon page with all the connection to mailchimp.

# Build docker image

```
docker build -t gcr.io/gcp-animeshon/comingsoon:latest .
```

# Push docker image to Google Container Registry

Configure the docker credentials for Google Cloud (required only once):

```
gcloud auth configure-docker
```

Tag and push the docker image to the registry:

```
docker push gcr.io/gcp-animeshon/comingsoon:latest
```

# Run docker image locally

```
docker run --rm -p 8080:8080 comingsoon
```

Launch the browser at the address http://127.0.0.1:8080/.