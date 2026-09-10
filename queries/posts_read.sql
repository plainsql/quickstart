-- plainsql: query ListRecentPosts returns many
SELECT
    p.title,
    coalesce(u.display_name, u.email) AS author,
    p.created_at
FROM posts AS p
JOIN users AS u ON u.id = p.user_id
ORDER BY p.created_at DESC, p.id DESC
LIMIT $1;
