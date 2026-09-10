# PlainSQL quickstart

The runnable example for the [PlainSQL quickstart](https://plainsql.com/docs/quickstart/).

## Run

Use Go 1.27 or newer. The public demo database accepts read-only connections.

```sh
git clone https://github.com/plainsql/quickstart.git
cd quickstart
export DATABASE_URL='postgresql://demo:demopassword1@ep-mute-bar-ae5vh57t-pooler.c-2.us-east-2.aws.neon.tech/blog'
go run main.go

CREATED (UTC)     AUTHOR    TITLE
2026-09-10 08:28  Milchick  Your quarterly melon assessment
2026-09-10 08:28  Burt      Please enjoy each painting equally
2026-09-10 08:28  Dylan     Waffle party acceptance speech
2026-09-10 08:28  Irving    The handbook did not cover this hallway
2026-09-09 08:39  Helly     Rewriting my blog in Go
2026-09-09 08:39  Helly     Hello, world
```

## Change the query

Install PlainSQL:

```sh
go install github.com/plainsql/plainsql@latest
```

Edit `queries/posts_read.sql`, then regenerate and run the program:

```sh
make generate
make run
```

## More Examples

The [examples repository](https://github.com/plainsql/examples) contains larger
applications and additional query examples.
