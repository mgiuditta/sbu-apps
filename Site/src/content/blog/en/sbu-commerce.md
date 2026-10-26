---
title: "Sbu Commerce: Spartacus on an open-source backend"
description: Sbu Commerce v0.1.0 is an open-source commerce backend that speaks the OCC API. An unmodified Spartacus storefront runs on it.
date: 2026-11-10
draft: true
---

If your storefront is built on Spartacus, it talks to its backend through one API: OCC. Paths, `fields`, error envelopes, the OAuth2 login. Everything the storefront knows about the backend goes through that contract.

Sbu Commerce is a backend that speaks that contract. I pointed a stock Spartacus storefront at it, changed nothing in the storefront, and went through the whole B2C flow: home, search, product page, cart, registration, login, checkout, order history. It works.

Today it is public: version 0.1.0, Apache-2.0 licence, on GitHub.

## Why I built it

I work on SAP Commerce and Spartacus projects. Teams that want to leave a licensed platform usually hear the same answer: replatform. A new backend means a new storefront, new integrations, months of work. The investment in the storefront is thrown away.

It doesn't have to be. If the backend speaks the same API, you change the server, not the site.

## What is in 0.1.0

More than a storefront needs to boot:

- the 33 OCC operations of a Spartacus B2C storefront, with `fields` projections, OCC errors, CORS and code + PKCE login;
- accounts, saved carts, wishlists, stores, returns, customer support and assisted service;
- B2B: units, budgets, cost centers, order approvals, quotes, replenishment orders, PunchOut;
- promotions, vouchers and coupons; bundles, gift cards, configurators, subscriptions;
- OMS and warehousing: sourcing, consignments, order and return processes;
- a Console to manage catalog, orders and customers, a Studio to edit pages, a platform Admin.

It is TypeScript on NestJS, with Postgres and Redis. One app, one container. You extend it with modules outside the core: add a field to Product and it is stored, exposed through OCC, searchable and editable in the Console, without touching the core.

## What is missing

Being honest about this matters more than the list above. Price rows with taxes and discounts, OData and webhook integration, high availability and staff SSO are next. There are about 120 small compatibility differences I know of, each tracked with a test plan. The [roadmap](https://github.com/mgiuditta/sbu-commerce/blob/main/ROADMAP.md) has all of them.

So: compatible, verified with a stock Spartacus, not identical. Not yet.

## Try it

```sh
git clone https://github.com/mgiuditta/sbu-commerce.git && cd sbu-commerce
docker compose -f infra/compose/compose.yaml up -d --build --wait
curl 'localhost:3000/occ/v2/electronics/products/search?query=camera'
```

It starts with a demo catalog, a B2C site and a B2B site. The README explains how to point Spartacus at it.

## What I'd like from you

Try it with your storefront, then [open an issue](https://github.com/mgiuditta/sbu-commerce/issues) with what is missing for your case. That is the most useful thing you can do for the project right now.

---

*Sbu Commerce is an independent project, not affiliated with the makers of the platforms it is compatible with.*
