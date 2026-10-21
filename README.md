# Lenyora Primary School Digital Application System – Phase 2

This version connects the Flutter parent application to Supabase.

## What is fixed

- Parent registration and login use Supabase Auth.
- Parent profile is stored in `profiles`.
- Application form data is retained across all four steps.
- Learner details are stored in `learners`.
- Applications are stored in `applications`.
- Required documents are uploaded to the private `application-documents` bucket and recorded in `documents`.
- Application status is read from Supabase.
- Announcements are read from Supabase and subscribe to realtime updates.
- Subjects are read from Supabase and filtered by grade.
- Profile details can be viewed/updated.

## Important

Do NOT put the Supabase `service_role` key in Flutter. Flutter must use the public anon/publishable key.

Open `lib/supabase_config.dart` and replace the placeholders with the URL and anon/publishable key from the Supabase project you are actually using.

## Setup

1. Open the project in VS Code.
2. Replace the values in `lib/supabase_config.dart`.
3. Open Supabase SQL Editor.
4. Run `supabase/schema.sql` completely.
5. In Supabase Authentication > Providers, enable Email.
6. For easy classroom testing, you may disable "Confirm email". For production, keep email confirmation enabled.
7. In a terminal run:
   flutter clean
   flutter pub get
   flutter create .
   flutter run

If `flutter create .` asks about existing files, keep the `lib` files from this project.

## Test order

1. Register a new parent account.
2. Log in.
3. Open Profile and verify the profile is stored.
4. Open Announcements and Subjects.
5. Start an application.
6. Complete Applicant -> Learner -> Medical -> Documents.
7. Select at least the required documents and submit.
8. Open My Applications and confirm the row comes from Supabase.
9. In Supabase Table Editor, check:
   profiles
   learners
   applications
   documents

## Phase 2 mapping

SRS requirement -> implementation

FR1 -> Supabase Auth registration/login
FR2/FR3 -> announcements table + realtime subscription
FR4/FR5 -> subjects table + grade filter
FR6 -> four-step application + Storage + documents table
FR7 -> application status screen
FR8/FR9 -> database structure ready for admin portal
FR10 -> form validation before database insert
FR11 -> visible error messages

The Phase 2 architecture also calls for an ASP.NET Core admin portal. This Flutter project implements the parent/mobile side and Supabase backend first. The admin portal can use the same tables and policies through the planned API layer.

## UI refresh (October 2026)

The app now uses a consistent Lenyora maroon-and-white theme, rounded form controls and cards, and a welcome screen with Get Started and Login actions. The profile includes shortcuts to My Applications, Change Password, and Help & Support. Help & Support includes school contact information and FAQs; Change Password uses the signed-in Supabase user's update flow. The subjects screen shows grade-specific curriculum defaults when the Supabase `subjects` table has no rows, while continuing to use live database rows when available. The home screen shows a latest-announcement preview backed by published Supabase announcements when available.

Before running, configure `lib/supabase_config.dart` with your Supabase project URL and public anon/publishable key, then apply `supabase/schema.sql` and configure the required Storage bucket and Row Level Security policies described in the testing checklist.



## Document picker troubleshooting patch
The document picker now reports selection errors instead of silently leaving
"No file selected". It accepts files when either bytes or a local path is
provided, and reads file bytes from the path at submission when needed.
Accepted file types: PDF, JPG, JPEG, PNG.
