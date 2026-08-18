CynemaX Web patch

Files:
- lib/main.dart
- .github/workflows/main.yml

Keep your existing:
- lib/core/config/app_config.dart
- pubspec.yaml
- assets/

GitHub phone steps:
1. Create or replace lib/main.dart with the supplied file.
2. Replace .github/workflows/main.yml with the supplied workflow.
3. Commit both changes to main.
4. Open Actions > Build Flutter Web.
5. Wait for the build.
6. If green, download the CynemaX-Web artifact.
7. Extract it and deploy the contents to Netlify.

Note:
The Railway backend must allow CORS from the Netlify site domain.
The API response shape may differ; this starter UI handles several common list keys and shows raw item JSON on tap.
