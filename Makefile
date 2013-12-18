#
# バージョンを変えた場合はlib/gyazo.rbとMakefileのバージョン番号を変えること
#

# リスト取得、情報取得を含むAPI
VERSION=0.4.2

localinstall:
	rake package
	sudo gem install pkg/gyazo-${VERSION}.gem
gempush:
	rake package
	gem push pkg/gyazo-${VERSION}.gem
gitpush:
	git push git@github.com:masui/gyazo-ruby.git
	git push pitecan.com:/home/masui/git/gyazo-ruby.git

test: test_always
test_always:
	rake test




