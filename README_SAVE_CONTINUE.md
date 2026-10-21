# Application Wizard: Save and Continue

The parent application flow now uses a four-step wizard matching the supplied mobile screenshots:

1. Parent / guardian details
2. Learner details
3. Medical and emergency details
4. Supporting documents and submission

## Included behaviour

- Burgundy Lenyora header, four-step progress indicator, cards and bottom navigation.
- Save Progress and Save & Exit controls.
- Automatic local draft saving while typing and when moving between steps.
- Resume a saved draft or start a fresh application.
- Learner date-of-birth parsing and age calculation.
- Required document upload controls for birth certificate, parent ID/passport, and proof of residence.
- Optional latest report and proof-of-transfer uploads.
- PDF, JPG, JPEG and PNG support, with a 10 MB per-file limit.
- Application and document submission through the existing Supabase tables/storage bucket.

## Draft limitations

Drafts are saved locally on the same device/browser for the signed-in account. They do not sync between devices. The selected document names can be remembered, but file bytes are not stored in local preferences; after restarting the app, select the required files again before submitting.

## Run and verify

From `lenyora_parent_app`:

```powershell
flutter pub get
dart format lib
flutter analyze
flutter run
```

Check that your Supabase schema includes the `learners`, `applications`, and `documents` tables and the `application-documents` storage bucket with the correct row-level security policies before testing live submissions.
