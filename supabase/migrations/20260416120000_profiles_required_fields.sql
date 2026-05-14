-- Defense-in-depth for the onboarding flow: reject empty strings in the
-- language fields at the DB layer. We intentionally allow NULL so legacy rows
-- (created before the atomic upsert landed) are not rejected; the app-side
-- router gate in main.dart re-routes those users through onboarding, which
-- then populates the fields properly.
ALTER TABLE public.profiles
  DROP CONSTRAINT IF EXISTS profiles_onboarding_fields_non_empty;

ALTER TABLE public.profiles
  ADD CONSTRAINT profiles_onboarding_fields_non_empty
  CHECK (
    (target_language IS NULL OR length(trim(target_language)) > 0)
    AND (native_language IS NULL OR length(trim(native_language)) > 0)
  );

-- Makes it cheap to query which rows still need back-filling.
CREATE INDEX IF NOT EXISTS idx_profiles_incomplete
  ON public.profiles (id)
  WHERE target_language IS NULL
     OR native_language IS NULL
     OR weekly_goal IS NULL;
