serve-all-backend:
	nx run-many -t serve -p api-gateway notification-service stats-service user-service workout-service

lint-all-backend:
	nx run-many -t lint -p api-gateway notification-service stats-service user-service workout-service

precommit-all:
	nx run-many -t build lint test -p api-gateway notification-service stats-service user-service workout-service

infra-up:
	docker compose -f local-infra/docker-compose.yml up -d

infra-down:
	docker compose -f local-infra/docker-compose.yml down
