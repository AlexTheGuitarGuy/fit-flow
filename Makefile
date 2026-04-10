serve-all-backend:
	nx run-many -t serve -p api-gateway notification-service stats-service user-service workout-service

lint-all-backend:
	nx run-many -t lint -p api-gateway notification-service stats-service user-service workout-service

validate-all:
	nx affected -t build lint && nx affected -t test --passWithNoTests

infra-up:
	docker compose -f local-infra/docker-compose.yml up -d

infra-down:
	docker compose -f local-infra/docker-compose.yml down
