# Fit Track App - Architecture Documentation

## Overview
Fit Track is a cross-platform Flutter mobile application featuring an Anti-Gravity UI design, Supabase backend integration, and Google Gemini AI-powered nutrition coaching focused on healthy Kerala cuisine.

## Technology Stack

### Frontend
- **Flutter SDK**: ^3.10.4
- **UI Framework**: Material Design 3
- **State Management**: StatefulWidget (can be extended with Provider/Riverpod)
- **UI Packages**:
  - `glassmorphism: ^3.0.0` - Glassmorphic effects
  - `flutter_animate: ^4.5.0` - Animations
  - `shimmer: ^3.0.0` - Loading effects

### Backend
- **Supabase**: Serverless backend
  - Authentication (Email/Password)
  - PostgreSQL database
  - Real-time subscriptions
  - Row Level Security (RLS)

### AI Integration
- **Google Gemini API**: `google_generative_ai: ^0.4.0`
  - Personalized recipe generation
  - Nutrition advice
  - Kerala cuisine focus

## Project Structure

```
lib/
├── config/
│   ├── supabase_config.dart      # Supabase initialization
│   └── gemini_config.dart         # Gemini API configuration
├── models/
│   ├── user_biometrics.dart       # User biometrics data model
│   └── recipe.dart                # Recipe data model
├── services/
│   ├── auth_service.dart          # Authentication service
│   ├── database_service.dart      # Supabase database operations
│   └── gemini_service.dart        # Gemini AI service
├── screens/
│   ├── login_screen.dart          # Authentication screen
│   ├── home_screen.dart           # Main dashboard
│   ├── biometrics_screen.dart    # User profile/biometrics
│   ├── nutrition_coach_screen.dart # AI coach interface
│   └── recipe_screen.dart         # Recipe display
├── theme/
│   └── anti_gravity_theme.dart    # Black/white theme configuration
├── widgets/
│   └── glassmorphic_container.dart # Reusable glassmorphic widget
└── main.dart                       # App entry point
```

## Architecture Patterns

### 1. Service Layer Pattern
- **AuthService**: Handles all authentication operations
- **DatabaseService**: Manages Supabase database interactions
- **GeminiService**: Handles AI-powered recipe generation and advice

### 2. Model Layer
- **UserBiometrics**: Contains user physical metrics and calculated values (BMI, BMR, TDEE)
- **Recipe**: Stores recipe data with nutrition information

### 3. UI Layer
- **Screens**: Full-screen views for major features
- **Widgets**: Reusable UI components
- **Theme**: Centralized styling and theming

## Key Features

### 1. Authentication Flow
```
Login Screen → AuthService → Supabase Auth → Session Management
```
- Email/password authentication
- Automatic session persistence
- Auth state listener for real-time updates

### 2. Biometrics Management
```
Biometrics Screen → DatabaseService → Supabase (user_biometrics table)
```
- User profile data storage
- Automatic calculation of BMI, BMR, TDEE
- Macro targets based on fitness goals

### 3. AI Nutrition Coach
```
Nutrition Coach Screen → GeminiService → Google Gemini API
```
- Personalized Kerala recipe generation
- Nutrition advice based on user biometrics
- Real-time recipe creation with ingredient lists

### 4. Recipe Generation Flow
```
User Input (Meal Type) → GeminiService → Gemini API → Recipe Model → DatabaseService → Recipe Screen
```

## Database Schema (Supabase)

### Table: `user_biometrics`
```sql
CREATE TABLE user_biometrics (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id),
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
```

### Table: `recipes`
```sql
CREATE TABLE recipes (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
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
```

## API Integration

### Supabase Configuration
- **URL**: Configured in `lib/config/supabase_config.dart`
- **Anon Key**: Stored securely in config file
- **RLS Policies**: Should be configured in Supabase dashboard

### Google Gemini API
- **API Key**: Configured in `lib/config/gemini_config.dart`
- **Model**: `gemini-pro`
- **Usage**: Free tier available (check current limits)

## UI/UX Design

### Anti-Gravity Theme
- **Color Scheme**: Pure black (#000000) and white (#FFFFFF)
- **Glassmorphism**: Translucent containers with blur effects
- **Gradients**: Black-to-gray mesh gradients for backgrounds
- **Typography**: Bold, uppercase text with letter spacing

### Design Principles
1. **Minimalism**: Clean, uncluttered interfaces
2. **Contrast**: High contrast black/white for readability
3. **Depth**: Glassmorphic effects create visual hierarchy
4. **Consistency**: Uniform styling across all screens

## Security Considerations

1. **API Keys**: Store in environment variables (not committed)
2. **RLS Policies**: Implement Row Level Security in Supabase
3. **Input Validation**: Validate all user inputs
4. **Session Management**: Automatic session handling by Supabase

## Performance Optimizations

1. **Lazy Loading**: Load data only when needed
2. **Caching**: Cache user biometrics locally
3. **Efficient Queries**: Optimize Supabase queries
4. **Image Optimization**: Compress recipe images if added

## Future Enhancements

1. **State Management**: Migrate to Provider/Riverpod
2. **Offline Support**: Local database caching
3. **Recipe History**: View previously generated recipes
4. **Meal Planning**: Weekly meal plan generation
5. **Progress Tracking**: Track weight/body metrics over time
6. **Social Features**: Share recipes with community

## Deployment

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Free Tier Services
- **Supabase**: Free tier includes 500MB database, 2GB bandwidth
- **Google Gemini**: Free tier with rate limits
- **Flutter**: Open source, no cost

## Setup Instructions

1. **Clone Repository**
2. **Install Dependencies**: `flutter pub get`
3. **Configure Supabase**: Add URL and anon key in `supabase_config.dart`
4. **Configure Gemini**: Add API key in `gemini_config.dart`
5. **Run Database Migrations**: Create tables in Supabase dashboard
6. **Run App**: `flutter run`

## Testing

- Unit tests for services
- Widget tests for UI components
- Integration tests for user flows

## License

This project is designed as a portfolio piece for MCA graduates in 2026.
