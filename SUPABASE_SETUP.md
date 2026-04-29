# Supabase Setup Guide

## Getting Started

1. **Create a Supabase Project**
   - Go to [https://supabase.com](https://supabase.com)
   - Sign up or log in
   - Create a new project

2. **Get Your Credentials**
   - In your Supabase project dashboard, go to **Settings** → **API**
   - Copy your **Project URL** and **anon/public key**

3. **Configure the App**
   - Open `lib/config/supabase_config.dart`
   - Replace `YOUR_SUPABASE_URL` with your Project URL
   - Replace `YOUR_SUPABASE_ANON_KEY` with your anon/public key

4. **Install Dependencies**
   ```bash
   flutter pub get
   ```

5. **Run the App**
   ```bash
   flutter run
   ```

## Features

- ✅ Glassmorphic login screen with email and password
- ✅ User authentication with Supabase
- ✅ Automatic session persistence (saved automatically by Supabase)
- ✅ Sign up and sign in functionality
- ✅ Beautiful gradient background
- ✅ Responsive UI

## Session Management

The user session is automatically saved by Supabase when you sign in. The session persists across app restarts, so users don't need to log in every time they open the app.

The `AuthWrapper` widget in `main.dart` checks for an existing session on app startup and routes users accordingly:
- If authenticated → Home Screen
- If not authenticated → Login Screen
