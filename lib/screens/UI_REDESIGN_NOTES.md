# Lenyora Parent App UI update

The Flutter parent portal has been restyled to match the supplied mobile screenshots using a navy, royal-blue, white and pale-grey palette.

## Updated screens
- Announcements hub: school photo hero, real-time feed status, search, category filters and notice detail sheet.
- Curriculum & Subjects: course search, grade-band chips, department filters and subject cards, backed by the existing Supabase `subjects` table with local CAPS defaults if no rows are returned.
- Application tracking: status filters, stage progress bars, notes and admission pass indicator for approved records.
- Parent profile: profile details, learner/application shortcut, notification preference controls, account actions and support panel.
- Application wizard: Student, Parent, Academic/Student Support, Documents, and Legal Declaration/Sign-Off progress header. The document screen includes a review/sign stage before the existing Supabase submission flow.
- Shared parent portal header and five-item bottom navigation.

## Run
From `lenyora_parent_app`:

```powershell
flutter pub get
flutter analyze
flutter run -d chrome
```

## Important notes
- Existing Supabase authentication, data queries, document upload and submission code have been retained.
- The push-alert, sound and biometric controls in Profile are UI preferences only; real push notifications and biometric authentication need separate platform setup and persistence.
- Subject descriptions, department categories and timeline milestones are presentation labels; the existing database schema does not currently store every field shown in the reference mockups.
- The project should be checked with `flutter analyze` and tested with a test account before replacing the currently working copy.
