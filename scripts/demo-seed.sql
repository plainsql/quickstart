-- Sample data for the public demo database. Helly has two posts, Mark has none,
-- and four more Lumon employees have one post each. Fixed IDs keep the
-- example calls consistent. Repeated runs preserve existing rows.

BEGIN;

INSERT INTO users (id, email, display_name)
OVERRIDING SYSTEM VALUE
VALUES
    (1, 'helly@example.com', 'Helly'),
    (2, 'mark@example.com', 'Mark'),
    (3, 'irving@example.com', 'Irving'),
    (4, 'dylan@example.com', 'Dylan'),
    (5, 'burt@example.com', 'Burt'),
    (6, 'milchick@example.com', 'Milchick')
ON CONFLICT (id) DO NOTHING;

INSERT INTO posts (id, user_id, title, body)
OVERRIDING SYSTEM VALUE
VALUES
    (1, 1, 'Hello, world', NULL),
    (2, 1, 'Rewriting my blog in Go', 'This time it will be simple.'),
    (3, 3, 'The handbook did not cover this hallway', 'Seven left turns. Same painting. I have filed a report with the painting.'),
    (4, 4, 'Waffle party acceptance speech', 'I would like to thank the numbers for being scary and the waffles for being waffles.'),
    (5, 5, 'Please enjoy each painting equally', 'The angry painting has noticed the difference.'),
    (6, 6, 'Your quarterly melon assessment', 'Your department has earned six melon cubes. Please appoint a cube representative.')
ON CONFLICT (id) DO NOTHING;

-- Move the identity sequences past the fixed ids.
DO $$
BEGIN
    PERFORM setval(pg_get_serial_sequence('users', 'id'), (SELECT max(id) FROM users));
    PERFORM setval(pg_get_serial_sequence('posts', 'id'), (SELECT max(id) FROM posts));
END
$$;

COMMIT;
