-- ============================================================================
-- 0023_fix_conversation_insert_policies.sql
-- REAL BUG FIX: conversations and conversation_participants had RLS enabled
-- (migration 0014) but NO insert policy was ever created (migration 0017
-- only added SELECT policies). This silently blocked every attempt to start
-- a new conversation — RLS defaults to deny when no policy matches, which
-- is exactly why messaging never actually persisted to Supabase.
-- ============================================================================

-- Any authenticated user may create a new conversation shell. The row itself
-- holds no sensitive data (just an id/timestamp) — real access control
-- happens entirely through conversation_participants membership below.
create policy conversations_insert on conversations for insert with check (true);

-- A user may always add themself as a participant. They may add a DIFFERENT
-- user only to a conversation they are already a member of — this is what
-- makes starting a new 1-on-1 conversation possible in two safe steps:
-- (1) insert yourself first, (2) then insert the other participant, which
-- is now allowed because you're already a member of that conversation_id.
create policy conversation_participants_insert on conversation_participants for insert with check (
  user_id = auth.uid()
  or exists (
    select 1 from conversation_participants cp
    where cp.conversation_id = conversation_participants.conversation_id
      and cp.user_id = auth.uid()
  )
);
