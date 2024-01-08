# OpenShift Let's Encrypt Job (AWS)

A `Job` that runs the Acme.sh script to generate Let's Encrypt certs for the "api" endpoint of your OpenShift cluster, as well as the "apps" wildcard subdomain.

This is only for AWS (Route53) currently.

To run:
1) Clone this repo and update the "cloud-dns-credentials.yaml" secret to include your AWS secret key and ID (a user with Route53 permissions should do fine).
2) `oc apply -k job`

Done!

This will take a few minutes, but once the job succeeds, you should have good certs for your api endpoint as well as wildcard cert for your "apps" domain.

If you need to add additional Route53-maintained domains to your certificate, set the `LE_EXTRA_FLAGS` environment variable in `job.yaml` like so:
```
          env:
            - name: LE_EXTRA_FLAGS
              value: '-d one.example.com -d another.example.com'
```
