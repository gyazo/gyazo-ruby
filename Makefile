#
# バージョンを変えた場合はlib/gyazo/version.rbを変えること
#

localinstall:
	rake install
gempush:
	rake release
gitpush:
	git push git@github.com:masui/gyazo-ruby.git
	git push pitecan.com:/home/masui/git/gyazo-ruby.git

test: test_always
test_always:
	bundle exec rake test




