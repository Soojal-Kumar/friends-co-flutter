# FRIENDS & CO. — Flutter Test App

Flutter Material 3 interface (no HTML WebView), gold/navy branding and launcher icon.

## Build with GitHub Actions
Create a **new** repository for this Flutter version, upload all contents of this ZIP (including hidden `.github`), then go to Actions > Build Flutter Android APK > Run workflow. Download `FRIENDS_CO_Flutter_APK` after a successful run and extract the APK.

The GitHub runner generates the Android platform scaffolding using `flutter create`, installs packages and builds a debug APK. The build has NOT been tested locally because Flutter SDK is unavailable in the authoring environment.

## Testing limitations
- Local-only records stored in shared_preferences. No cloud backup or secure business database.
- Supports basic product, customer, supplier, expense entry and single-product sales/purchases.
- No multi-godown, real ledgers, payments, PDF invoices, returns, average-cost profit, audit trail or sync.
- Not suitable for production business accounting. Data may be lost when uninstalling/clearing app data.
