# Supabase Table Setup Guide

## Quick Setup Instructions

### Step 1: Open Supabase SQL Editor
1. Go to your Supabase project dashboard: https://supabase.com/dashboard
2. Select your project
3. Click on **SQL Editor** in the left sidebar
4. Click **New Query**

### Step 2: Run the SQL Script
1. Open the file `supabase_setup.sql` in this project
2. Copy the entire contents
3. Paste it into the Supabase SQL Editor
4. Click **Run** (or press Ctrl+Enter / Cmd+Enter)

### Step 3: Verify Tables Created
1. Go to **Table Editor** in the left sidebar
2. You should see two new tables:
   - `user_biometrics`
   - `recipes`

## What Gets Created

### Tables

#### 1. `user_biometrics`
Stores user fitness and health metrics:
- `id` - Unique identifier (UUID)
- `user_id` - References auth.users (UUID)
- `height` - Height in cm (DECIMAL)
- `weight` - Weight in kg (DECIMAL)
- `age` - Age in years (INTEGER)
- `gender` - Gender ('male', 'female', 'other')
- `goal` - Fitness goal ('bulk', 'cut', 'maintain', 'lean_bulk')
- `body_fat_percentage` - Optional body fat % (DECIMAL)
- `activity_level` - Activity level ('sedentary', 'light', 'moderate', 'active', 'very_active')
- `created_at` - Creation timestamp
- `updated_at` - Last update timestamp (auto-updated)

#### 2. `recipes`
Stores AI-generated recipes:
- `id` - Unique identifier (TEXT)
- `user_id` - References auth.users (UUID)
- `title` - Recipe title (TEXT)
- `description` - Recipe description (TEXT)
- `ingredients` - Array of ingredients (TEXT[])
- `instructions` - Array of cooking steps (TEXT[])
- `nutrition` - Nutrition info as JSON (JSONB)
- `cuisine_type` - Type of cuisine (default: 'kerala')
- `meal_type` - Meal type ('breakfast', 'lunch', 'dinner', 'snack')
- `prep_time` - Preparation time in minutes (INTEGER)
- `cook_time` - Cooking time in minutes (INTEGER)
- `servings` - Number of servings (INTEGER)
- `image_url` - Optional image URL (TEXT)
- `created_at` - Creation timestamp

### Security Features

✅ **Row Level Security (RLS)** enabled on both tables
✅ **Policies** ensure users can only access their own data
✅ **Automatic timestamp updates** for `updated_at` field
✅ **Data validation** with CHECK constraints
✅ **Cascade deletion** - when a user is deleted, their data is automatically removed

## Troubleshooting

### Error: "relation already exists"
If you see this error, the tables already exist. You can either:
1. Drop existing tables first (⚠️ **WARNING**: This deletes all data!)
2. Use `CREATE TABLE IF NOT EXISTS` (already included in the script)

### Error: "permission denied"
Make sure you're running the SQL as a database administrator. The script needs elevated permissions to create tables and policies.

### Error: "function uuid_generate_v4() does not exist"
Run this first:
```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

### Verify RLS is Working
Test that RLS is working correctly:
1. Create a test user in Authentication
2. Try to query the tables - you should only see your own data
3. Try to insert/update/delete - should only work for your own records

## Next Steps

After running the SQL script:
1. ✅ Tables are created
2. ✅ Security policies are active
3. ✅ Your Flutter app can now connect and use the database
4. Test the app by:
   - Signing up a new user
   - Adding biometrics
   - Generating a recipe

## Manual Table Creation (Alternative)

If you prefer to create tables manually through the UI:

1. Go to **Table Editor** > **New Table**
2. Create `user_biometrics` with the columns listed above
3. Create `recipes` with the columns listed above
4. Go to **Authentication** > **Policies** to set up RLS

However, using the SQL script is recommended as it ensures proper setup with all constraints and policies.
