-- +goose Up
CREATE TABLE users (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email text NOT NULL UNIQUE,
    display_name text,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE posts (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id bigint NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    title text NOT NULL,
    body text,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX posts_user_id_idx ON posts (user_id);

-- +goose Down
DROP TABLE posts;
DROP TABLE users;
