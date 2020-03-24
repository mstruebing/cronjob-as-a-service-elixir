connect-db:
	docker-compose exec postgresql 'psql --user postgres cronjob_as_a_service_dev'

start-backend: 
	cd backend && mix phx.server

start-frontend:
	cd frontend && yarn dev

generate:
	cd frontend && yarn generate
