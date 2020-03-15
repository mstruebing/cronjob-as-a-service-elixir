connect-db:
	docker-compose exec postgresql 'psql --user postgres cronjob_as_a_service_dev'
