# Supabase testing checklist

Run these checks after executing schema.sql.

## 1. Auth
Register a new parent in the Flutter app.
Expected:
- A user appears under Authentication > Users.
- A row appears in `public.profiles`.
- `profiles.id` equals the Auth user's UUID.
- `profiles.role` is `parent`.

## 2. Profile
Edit the phone number in the Flutter Profile screen.
Expected:
- The value changes in `public.profiles`.

## 3. Application
Submit one application.
Expected:
- One row in `learners`.
- One row in `applications`.
- Three or more rows in `documents`, depending on selected optional documents.
- Files appear under `Storage > application-documents > <auth-user-id> / <application-id>`.

## 4. Status
Change an application status manually in Supabase from `Pending` to `Approved`.
Open My Applications in Flutter.
Expected:
- The application displays `Approved`.

## 5. Announcements
Insert a published announcement.
Expected:
- It appears in Flutter Announcements.
- A new/updated announcement is received through the realtime subscription.

## 6. Subjects
Insert:
subject_name = Mathematics
grade = Grade 4

Expected:
- Mathematics appears when Grade 4 is selected.
