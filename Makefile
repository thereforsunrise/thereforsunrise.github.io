dc_mysite = CURRENT_UID=$(shell id -u):$(shell id -g) docker-compose run mysite
dc_web = CURRENT_UID=$(shell id -u):$(shell id -g) docker-compose run web

.DEFAULT_GOAL := preview

FORCE:

clean: FORCE
	@$(dc_mysite) find *.html -delete

install: FORCE
	@$(dc_mysite) bundle install

generate: FORCE
	@$(dc_mysite) bundle exec ruby ./generate.rb

install_generate: install generate

shell: FORCE
	@$(dc_mysite) /bin/sh

shell-web: FORCE
	@$(dc_web) /bin/sh

up: FORCE
	@docker-compose down
	@docker-compose up --build -d

link: FORCE
	@echo "http://localhost:5555"

preview: up link

sync: FORCE
	@$(dc_mysite) bundle exec ruby ./sync.rb /journals 

deploy: generate
	@git add .
	@git commit -m "dont know much about history"
	@git push origin main

deploy_nuke: generate
	@git checkout --orphan latest_branch
	@git add -A
	@git commit -am "commit message"
	@git branch -D main
	@git branch -m main
	@git push -f origin main
