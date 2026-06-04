# Terraform >> APP >>> my own domain?

### TLDR

Created another infrastructure that creates the server, then an app that shows "Hello World!" (because I wanted to be original). 

## The boilerplate

First of all, it was again rinse and repeat, create:
- `main.tf`
- `outputs.tf`
- `providers.tf`
- `variables.tf`

> Spoiler alert: My next project here is going make my life easier as I keep building

There was more boilerplate to do, such as:

`npx create-next-app@latest app --no-git` (creating an app dir and no git)

Removed all the code and just add a casual, original:

```tsx
<div>
    <h1 className="text-3xl font-bold underline">Hello world!</h1>
</div>
````

That sorted, back to the infra.

## Terraform, activate

### Providers

That was the basic `Hetzner cloud` setup, same as the other projects, think of this like a sequel, you need to see the others so I don't repeat myself:

```hcl
required_providers {
hcloud = {
    source = "hetznercloud/hcloud"
}
````

### Main

> same firewall setup as previous projects

Used the module that calls that first [up-down](https://github.com/Makariuz/up-down) resource.

### user_data

> 💡 **cloud-init.sh** - this script was done in a lot of stages, not all at once

Followed docker.com suggestions to remove any incompatible with ubuntu, then installed it:

```bash
apt-get remove -y docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc || true

apt update -y
apt install ca-certificates curl -y
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

apt update

apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
systemctl enable --now docker

````

We are deep now, no turning back:

```bash
rm -rf /opt/nextjs-repository
git clone --depth 1 https://github.com/Makariuz/nextjs-repository.git /opt/nextjs-repository
````

We need to make sure the folder was clean before cloning, cloning done? Good, lets build the image:

```bash
docker build -t nextjs-app /opt/nextjs-repository/app
docker rm -f nextjs-app || true
docker run -d \
  --name nextjs-app \
  --restart unless-stopped \
  -p 127.0.0.1:3000:3000 \
  nextjs-app
```

So now this is running (maybe a docker-compose.yaml would be easier to read / run?).

Add the site and point it to my domain, or attempt (it didn't quite work, but the ip in outputs.tf worked).

127.0.0.1:3000:3000 binds to localhost, the outside world will never know about it, secret between nginx and .. well 127.0.0.1:3000

### Outputs

I mean, if you saw the preivous projects, its self explanatory, but yes, after Terraform does its thing, it outputs the ID and the IPv4.

### Variables

A lot of hush hush stuff, but I moved to the cloud, `Terraform Cloud`, which is so much more better, because it feels like America, you know, United `State`.

> Sorry, its late in the evening, but basically having the terraform state remotely is much better and safer, this is the truth.

## Read, set, (github)ACTION

This was quite something, I needed to learn:

1. Run `Terraform init`;
2. Run `Terraform fmt -check`;
3. Run `Terraform plan`;
4. Run `Terraform apply`;
5. Run `Terraform plan -destroy`;

This right [here](https://github.com/hashicorp/setup-terraform) was the biggest help in figuring this out. The conditionals are quite clear:

```yaml
jobs:
  plan:
    if: github.ref != 'refs/heads/main' && github.event.inputs.destroy != 'true'
```
You can run, but as long as you're not the main branch and not set to destroy.

So I wanted each `push` to run an `action` of `planning` and when I merge to main, it would run `apply`.



