#
# バージョンを変えた場合はlib/gyazo.rbとMakefileのバージョン番号を変えること
#

VERSION=0.1.0

localinstall:
	rake package
	sudo gem install pkg/gyazo-${VERSION}.gem
gempush:
	rake package
	gem push pkg/gyazo-${VERSION}.gem
gitpush:
	git push git@github.com:masui/gyazo-ruby.git
#	git push pitecan.com:/home/masui/git/gyazo-ruby.git



