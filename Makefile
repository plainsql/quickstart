PLAINSQL ?= plainsql

.PHONY: generate check run

generate:
	$(PLAINSQL) generate

check:
	$(PLAINSQL) check
	go test ./...

run:
	go run main.go
