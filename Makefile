.PHONY: build
build:
	@docker compose build

.PHONY: up
up:
	@docker compose up -d

.PHONY: down
down:
	@docker compose down -v

.PHONY: run_dev
run_dev:
	@bash ./entrypoint.sh 

.PHONY: run_docker
run_docker:
	@docker compose run \
	-e MELTANO_ENVIRONMENT=docker \
	-e SRC_FILE=${SRC_FILE} \
	-e MINIO_ACCESS_KEY_ID=${MINIO_ACCESS_KEY_ID} \
	-e MINIO_SECRET_ACCESS_KEY=${MINIO_SECRET_ACCESS_KEY} \
	-e MINIO_REGION=${MINIO_REGION} \
	-v $(shell pwd)/.env:/project/.env \
	-v $(shell pwd)/data/db:/project/data/db \
	-v $(shell pwd)/logs:/project/.meltano/logs/elt \
	--entrypoint "/project/entrypoint.sh" \
	meltano

.PHONY: run_aws
run_aws:
	@docker compose run \
	-e MELTANO_ENVIRONMENT=aws \
	-e SRC_FILE=${SRC_FILE} \
	-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	-e AWS_REGION=${AWS_REGION} \
	-v $(shell pwd)/.env:/project/.env \
	-v $(shell pwd)/data/db:/project/data/db \
	-v $(shell pwd)/logs:/project/.meltano/logs/elt \
	--entrypoint "/project/entrypoint.sh" \
	meltano

.PHONY: generate_flights
generate_flights:
	@docker compose run \
	-v $(shell pwd)/apps/flights-generator:/app \
	--entrypoint "python /app/flights-generator.py" \
	flights_generator

  