My entire private server as code including testing

```mermaid
C4Context
title System Context diagram for my Private Server

Person(developer, "Redline", "A Developer with Yak Shaving Syndrome.")
System(hetzner, "Hetzner", "German Cloud Provider.")
System(github, "GitHub", "Code and Documentation Storage (You are Here).")
System(cloudflare, "Cloudflare", "DNS Hosting.")
System(porkbun, "Porkbun", "DNS Registrar.")
System(server, "Private Server", "Private Unmanaged Server.")
System(hashicorp, "Hashicorp", "Stores Server Provisioning State.")

Rel(github, cloudflare, "Configures")
Rel(github, hetzner, "Configures")
Rel(github, hashicorp, "Stores Configuration")

Rel(hetzner, server, "Hosts")
Rel(porkbun, cloudflare, "Specifies Authoritative Domain Server")
Rel(cloudflare, server, "Tell client to connect to")

Rel(developer, github, "Changes.")
```
