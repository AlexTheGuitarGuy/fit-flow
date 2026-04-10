serve-all-backend:
	nx run-many -t serve -p api-gateway notification-service stats-service user-service workout-service

lint-all-backend:
	nx run-many -t lint -p api-gateway notification-service stats-service user-service workout-service

pre-commit-all:
	nx run-many -t build lint && nx run-many -t test --passWithNoTests

infra-up:
	docker compose -f local-infra/docker-compose.yml up -d

infra-down:
	docker compose -f local-infra/docker-compose.yml down
