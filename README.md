# Animeshon Coming Soon Page

[![Codefresh build status]( https://g.codefresh.io/api/badges/pipeline/animeshon/Coming%20Soon%2FTier%200?branch=master&key=eyJhbGciOiJIUzI1NiJ9.NWUzYWUzM2I1NGM2NDUxYzQ2YzgzNjZh.ocqU9NR7lHh3Osvn2spDqw1E2pWq2gzA_mlx_NKdTfQ&type=cf-1)]( https%3A%2F%2Fg.codefresh.io%2Fpipelines%2FTier%200%2Fbuilds%3FrepoOwner%3Danimeshon%26repoName%3Dcomingsoon%26serviceName%3Danimeshon%252Fcomingsoon%26filter%3Dtrigger%3Abuild~Build%3Bbranch%3Amaster%3Bpipeline%3A5e45e222c807ee1f146070d7~Tier%200)

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