# Fit Track App - Setup Instructions

## Prerequisites
- Flutter SDK 3.10.4 or higher
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Supabase account (free tier)
- Google Gemini API key (free tier)

## Step 1: Clone and Install Dependencies

```bash
cd fit_track_app
flutter pub get
```

## Step 2: Configure Supabase

1. Create a Supabase project at [supabase.com](https://supabase.com)
2. Go to Settings → API
3. Copy your Project URL and anon/public key
4. Update `lib/config/supabase_config.dart`:
   ```dart
   static const String supabaseUrl = 'YOUR_SUPABASE_URL';
   static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
   ```

## Step 3: Set Up Database Tables

Run these SQL commands in Supabase SQL Editor:

### Create user_biometrics table:
```sql
CREATE TABLE user_biometrics (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  height DECIMAL NOT NULL,
  weight DECIMAL NOT NULL,
  age INTEGER NOT NULL,
  gender TEXT NOT NULL,
  goal TEXT NOT NULL,
  body_fat_percentage DECIMAL,
  activity_level TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE user_biometrics ENABLE ROW LEVEL SECURITY;

-- Create policy for users to manage their own data
CREATE POLICY "Users can manage their own biometrics"
ON user_biometrics
FOR ALL
USING (auth.uid() = user_id);
```

### Create recipes table:
```sql
CREATE TABLE recipes (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  ingredients TEXT[] NOT NULL,
  instructions TEXT[] NOT NULL,
  nutrition JSONB NOT NULL,
  cuisine_type TEXT DEFAULT 'kerala',
  meal_type TEXT NOT NULL,
  prep_time INTEGER,
  cook_time INTEGER,
  servings INTEGER,
  image_url TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE recipes ENABLE ROW LEVEL SECURITY;

-- Create policy for users to manage their own recipes
CREATE POLICY "Users can manage their own recipes"
ON recipes
FOR ALL
USING (auth.uid() = user_id);
```

## Step 4: Configure Google Gemini API

1. Get API key from [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Update `lib/config/gemini_config.dart`:
   ```dart
   static const String apiKey = 'YOUR_GEMINI_API_KEY';
   ```

## Step 5: Run the App

```bash
flutter run
```

## Features Overview

### 1. Authentication
- Email/password sign up and sign in
- Automatic session persistence
- Secure authentication via Supabase

### 2. Biometrics Management
- Enter height, weight, age, gender
- Select fitness goal (bulk, lean bulk, cut, maintain)
- Set activity level
- Automatic calculation of BMI, BMR, TDEE, and macro targets

### 3. AI Nutrition Coach
- Generate personalized Kerala cuisine recipes
- Get nutrition advice based on biometrics
- Select meal type (breakfast, lunch, dinner, snack)
- Recipes include detailed ingredients and instructions

### 4. Recipe Display
- Beautiful recipe cards with nutrition info
- Step-by-step cooking instructions
- Ingredient lists with quantities
- Nutrition breakdown per serving

## Troubleshooting

### Common Issues:

1. **Supabase Connection Error**
   - Verify URL and anon key are correct
   - Check internet connection
   - Ensure Supabase project is active

2. **Gemini API Error**
   - Verify API key is correct
   - Check API quota/limits
   - Ensure internet connection

3. **Database Errors**
   - Verify tables are created
   - Check RLS policies are set up
   - Ensure user is authenticated

4. **Build Errors**
   - Run `flutter clean`
   - Run `flutter pub get`
   - Check Flutter SDK version

## Free Tier Limits

- **Supabase**: 500MB database, 2GB bandwidth/month
- **Google Gemini**: Check current free tier limits
- **Flutter**: No limits (open source)

## Next Steps

1. Customize the UI theme in `lib/theme/anti_gravity_theme.dart`
2. Add more recipe types or cuisines
3. Implement recipe history/favorites
4. Add progress tracking features
5. Implement meal planning

## Support

For issues or questions, refer to:
- Flutter Documentation: https://flutter.dev/docs
- Supabase Documentation: https://supabase.com/docs
- Google Gemini API: https://ai.google.dev/docs
