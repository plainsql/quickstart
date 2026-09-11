package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"text/tabwriter"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/plainsql/quickstart/internal/dbgen"
)

func main() {
	ctx := context.Background()
	pool, err := pgxpool.New(ctx, os.Getenv("DATABASE_URL"))
	if err != nil {
		log.Fatal(err)
	}
	defer pool.Close()

	// New wraps the pool. Every generated query is a method on the result.
	queries := dbgen.New(pool)

	// ListRecentPosts is the method generated from queries/posts_read.sql.
	// The 10 fills the $1 placeholder in LIMIT $1. Each post has typed Title,
	// Author, and CreatedAt fields, so there is no manual row scanning.
	posts, err := queries.ListRecentPosts(ctx, 10)
	if err != nil {
		log.Fatal(err)
	}
	w := tabwriter.NewWriter(os.Stdout, 0, 4, 2, ' ', 0)
	fmt.Fprintln(w, "CREATED (UTC)\tAUTHOR\tTITLE")
	for _, post := range posts {
		fmt.Fprintf(w, "%s\t%s\t%s\n",
			post.CreatedAt.UTC().Format("2006-01-02 15:04"), post.Author, post.Title)
	}
	if err := w.Flush(); err != nil {
		log.Fatal(err)
	}
}
