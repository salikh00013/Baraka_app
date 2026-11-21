# BARAKA

BARAKA is a multi-store shopping and delivery platform launching in To‘raqo‘rg‘on, Namangan, Uzbekistan.

## Planned clients
- Flutter app for Android and iOS
- Web admin dashboard
- Future customer web store

## Business model
- Customers choose products and quantities, not source stores.
- A courier collects items from one or more partner stores and delivers one combined order.
- Customers see BARAKA retail prices only.
- Substitutions or changes require customer approval.
- Sale prices and actual source costs are recorded separately for accurate profit reporting.

## Technology
- Flutter mobile application
- Supabase (PostgreSQL, Auth, Row Level Security, Storage)
- Shared backend for mobile and web clients

## Development status
Initial project setup. Supabase schema has been created separately. Supabase URL and anon key still need to be configured. Security policies require review before production.

## Security
Never place a Supabase service-role key in a mobile app. Review Row Level Security and order/fulfillment permissions before launch.
