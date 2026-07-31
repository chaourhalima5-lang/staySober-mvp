-- ============================================================================
-- 0024_community_feed_view_and_realtime.sql
-- Two additions for the Community module upgrade:
--
-- 1. community_posts_feed — a view that pre-aggregates real like/comment
--    counts per post. The frontend was previously hardcoding these to 0 on
--    every load (a real, confirmed bug) since no query ever computed them.
--    security_invoker = true means this view runs with the QUERYING USER's
--    own permissions, not the view owner's — so it fully respects the
--    existing RLS policies on community_posts/likes/comments underneath.
--    No new RLS policies are needed on the view itself for this reason.
--
-- 2. Realtime publication — required for the frontend to receive live
--    postgres_changes events over WebSocket. Without this, no realtime
--    subscription can ever receive events, regardless of frontend code.
-- ============================================================================

create view community_posts_feed
with (security_invoker = true) as
select
  p.id, p.post_type, p.body, p.image_url, p.video_url, p.pinned, p.is_hidden,
  p.created_at, p.author_id,
  coalesce(l.like_count, 0) as like_count,
  coalesce(c.comment_count, 0) as comment_count
from community_posts p
left join (
  select post_id, count(*) as like_count from likes group by post_id
) l on l.post_id = p.id
left join (
  select post_id, count(*) as comment_count from comments group by post_id
) c on c.post_id = p.id;

alter publication supabase_realtime add table community_posts;
alter publication supabase_realtime add table likes;
alter publication supabase_realtime add table comments;
