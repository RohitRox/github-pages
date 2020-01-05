install: ;bundle install
server: ;jekyll server --config _config.yml,_config.dev.yml
build: ;jekyll build
post: ;rake make_post["$(title)"]
