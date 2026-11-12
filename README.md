# FRIENDS & CO. — Android consolidated development source

Use GitHub Actions workflow to compile an Android debug APK. This project is NOT compiler-tested in this environment and NOT a production-ready accounting system.

Included in source: godowns, godown-wise inventory, transfers, stock adjustments/history, products, customers, suppliers, basic sales/purchases, returns, customer/supplier outstanding and payments, cash/bank transaction ledger, expenses, estimated average-cost profit, reports, basic owner PIN, PDF invoice/payment/ledger sharing, offline JSON export and restore.

IMPORTANT limitations: only ONE product per invoice, no automatic cloud backup/sync, cash/bank ledger needs historical reconciliation, legacy sales may have unknown costs and payments, PIN is not secure encrypted authentication, and SharedPreferences is not an appropriate primary accounting database. PDF sharing requires Android device testing. Do not use for live business accounts before full tests and migration checks. JSON backups contain sensitive financial data and PIN in plaintext: store privately.

Install steps: upload `lib/main.dart`, `pubspec.yaml`, `.github/workflows/flutter-apk.yml`, and `assets/app_icon.png` to existing repository, commit, wait for Actions green check, download artifact `FRIENDS_CO_Flutter_APK`, extract `app-debug.apk` and install. Keep old data backed up before testing.
