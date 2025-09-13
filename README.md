# 🦆 NixOS Homelab

---
<p align="left">
  <a href="https://github.com/AkashRajvanshi/hl-nixos-remote/blob/main/LICENSE"><img src="https://img.shields.io/github/license/AkashRajvanshi/hl-nixos-remote?style=flat-square&logo=opensourceinitiative&logoColor=white&color=A931EC" alt="license"></a>
  <img src="https://img.shields.io/github/last-commit/AkashRajvanshi/hl-nixos-remote?style=flat-square&logo=git&logoColor=white&color=A931EC" alt="last-commit">
  <img src="https://img.shields.io/github/languages/top/AkashRajvanshi/hl-nixos-remote?style=flat-square&color=A931EC" alt="repo-top-language">
</p>

<em>A declarative and reproducible NixOS configuration for my personal homelab, built with **Nix Flakes** and deployed remotely with **Colmena**.</em>

---

## ✨ Core Concepts

* **Declarative & Reproducible:** The entire system state is defined as code. [Nix Flakes](https://nixos.wiki/wiki/Flakes) lock all dependencies for consistent, reliable builds.
* **Remote Management:** [Colmena](https://colmena.cli.rs/) deploys configurations to remote machines seamlessly over SSH.
* **Secrets Management:** Sensitive information is encrypted using [sops-nix](https://github.com/Mic92/sops-nix) and is never committed to the repository in plaintext.

---

## 🛠️ Tech Stack & Services

This configuration deploys a service-oriented homelab using the following key components:

* **Reverse Proxy:** [Traefik](https://traefik.io/traefik/) for routing traffic to services.
* **Identity & Access:** [Keycloak](https://www.keycloak.org/) for centralized authentication, secured with `oidc-middleware`.
* **Database:** [PostgreSQL](https://www.postgresql.org/) for persistent data storage.
* **Komodo:** [Komodo](https://komo.do/) for a Docker-based build and deployment system.

---

## 🚀 Getting Started

If you want to understand the methodology behind this setup and build a similar system from scratch, these blog posts provide an excellent foundation:

* **Part 1:** [It’s Alive! Bootstrapping a Declarative NixOS Homelab](https://medium.com/aws-in-plain-english/its-alive-bootstrapping-a-declarative-nixos-homelab-part-1-79d11e917de2)
* **Part 2:** [Flipping the Switches: Adding Services to a Declarative NixOS Homelab](https://medium.com/aws-in-plain-english/flipping-the-switches-adding-services-to-a-declarative-nixos-homelab-part-2-eb6255f30027)
