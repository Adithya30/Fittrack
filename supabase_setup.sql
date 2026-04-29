-- ============================================
-- Fit Track App - Supabase Database Setup
-- ============================================
-- Run this script in your Supabase SQL Editor
-- Go to: Supabase Dashboard > SQL Editor > New Query

-- ============================================
-- 1. Create user_biometrics table
-- ============================================
CREATE TABLE IF NOT EXISTS user_biometrics (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  height DECIMAL(5,2) NOT NULL CHECK (height > 0 AND height < 300),
  weight DECIMAL(5,2) NOT NULL CHECK (weight > 0 AND weight < 500),
  age INTEGER NOT NULL CHECK (age > 0 AND age < 150),
  gender TEXT NOT NULL CHECK (gender IN ('male', 'female', 'other')),
  goal TEXT NOT NULL CHECK (goal IN ('bulk', 'cut', 'maintain', 'lean_bulk')),
  body_fat_percentage DECIMAL(5,2) CHECK (body_fat_percentage IS NULL OR (body_fat_percentage >= 0 AND body_fat_percentage <= 100)),
  activity_level TEXT NOT NULL CHECK (activity_level IN ('sedentary', 'light', 'moderate', 'active', 'very_active')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id)
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_user_biometrics_user_id ON user_biometrics(user_id);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to auto-update updated_at
CREATE TRIGGER update_user_biometrics_updated_at 
    BEFORE UPDATE ON user_biometrics 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 2. Create recipes table
-- ============================================
CREATE TABLE IF NOT EXISTS recipes (
  id TEXT PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  ingredients TEXT[] NOT NULL DEFAULT '{}',
  instructions TEXT[] NOT NULL DEFAULT '{}',
  nutrition JSONB NOT NULL DEFAULT '{}',
  cuisine_type TEXT DEFAULT 'kerala',
  meal_type TEXT NOT NULL CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack')),
  prep_time INTEGER DEFAULT 0 CHECK (prep_time >= 0),
  cook_time INTEGER DEFAULT 0 CHECK (cook_time >= 0),
  servings INTEGER DEFAULT 1 CHECK (servings > 0),
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_recipes_user_id ON recipes(user_id);
CREATE INDEX IF NOT EXISTS idx_recipes_created_at ON recipes(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_recipes_meal_type ON recipes(meal_type);

-- ============================================
-- 3. Enable Row Level Security (RLS)
-- ============================================

-- Enable RLS on user_biometrics
ALTER TABLE user_biometrics ENABLE ROW LEVEL SECURITY;

-- Enable RLS on recipes
ALTER TABLE recipes ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 4. Create RLS Policies for user_biometrics
-- ============================================

-- Policy: Users can view their own biometrics
CREATE POLICY "Users can view their own biometrics"
ON user_biometrics
FOR SELECT
USING (auth.uid() = user_id);

-- Policy: Users can insert their own biometrics
CREATE POLICY "Users can insert their own biometrics"
ON user_biometrics
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own biometrics
CREATE POLICY "Users can update their own biometrics"
ON user_biometrics
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own biometrics
CREATE POLICY "Users can delete their own biometrics"
ON user_biometrics
FOR DELETE
USING (auth.uid() = user_id);

-- ============================================
-- 5. Create RLS Policies for recipes
-- ============================================

-- Policy: Users can view their own recipes
CREATE POLICY "Users can view their own recipes"
ON recipes
FOR SELECT
USING (auth.uid() = user_id);

-- Policy: Users can insert their own recipes
CREATE POLICY "Users can insert their own recipes"
ON recipes
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own recipes
CREATE POLICY "Users can update their own recipes"
ON recipes
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own recipes
CREATE POLICY "Users can delete their own recipes"
ON recipes
FOR DELETE
USING (auth.uid() = user_id);

-- ============================================
-- Setup Complete!
-- ============================================
-- Your tables are now created with proper security policies.
-- Users can only access their own data.
