-- Add target_weight column to user_biometrics table if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'user_biometrics'
        AND column_name = 'target_weight'
    ) THEN
        ALTER TABLE user_biometrics ADD COLUMN target_weight numeric;
    END IF;
END $$;
