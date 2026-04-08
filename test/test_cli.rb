require File.expand_path 'test_helper', File.dirname(__FILE__)
require 'gyazo/cli'
require 'tmpdir'

class TestCLI < MiniTest::Test
  def setup
    @cli = Gyazo::CLI.new
    @tmpdir = Dir.mktmpdir
    @config_file = File.join(@tmpdir, 'config')
    # Override CONFIG_FILE constant for tests
    Gyazo::CLI.send(:remove_const, :CONFIG_FILE) if Gyazo::CLI.const_defined?(:CONFIG_FILE)
    Gyazo::CLI.const_set(:CONFIG_FILE, @config_file)
  end

  def teardown
    FileUtils.rm_rf(@tmpdir)
    # Restore original
    Gyazo::CLI.send(:remove_const, :CONFIG_FILE) if Gyazo::CLI.const_defined?(:CONFIG_FILE)
    Gyazo::CLI.const_set(:CONFIG_FILE, File.join(Dir.home, '.config', 'gyazo', 'config'))
  end

  # --- Token resolution ---

  def test_load_token_returns_nil_when_no_config
    assert_nil @cli.send(:load_token)
  end

  def test_save_and_load_token
    @cli.send(:save_token, 'mytoken123')
    assert_equal 'mytoken123', @cli.send(:load_token)
  end

  def test_save_token_sets_permissions
    @cli.send(:save_token, 'mytoken123')
    mode = File.stat(@config_file).mode & 0o777
    assert_equal 0o600, mode
  end

  def test_resolve_token_prefers_option_flag
    @cli.send(:save_token, 'fromfile')
    ENV['GYAZO_ACCESS_TOKEN'] = 'fromenv'
    token = @cli.send(:resolve_token, { token: 'fromflag' })
    assert_equal 'fromflag', token
  ensure
    ENV.delete('GYAZO_ACCESS_TOKEN')
  end

  def test_resolve_token_prefers_env_over_file
    @cli.send(:save_token, 'fromfile')
    ENV['GYAZO_ACCESS_TOKEN'] = 'fromenv'
    token = @cli.send(:resolve_token, {})
    assert_equal 'fromenv', token
  ensure
    ENV.delete('GYAZO_ACCESS_TOKEN')
  end

  def test_resolve_token_falls_back_to_file
    ENV.delete('GYAZO_ACCESS_TOKEN')
    @cli.send(:save_token, 'fromfile')
    token = @cli.send(:resolve_token, {})
    assert_equal 'fromfile', token
  end

  def test_resolve_token_returns_nil_when_nothing
    ENV.delete('GYAZO_ACCESS_TOKEN')
    assert_nil @cli.send(:resolve_token, {})
  end

  # --- Output formatting ---

  def test_output_text_format
    data = { image_id: 'abc123', permalink_url: 'https://gyazo.com/abc123' }
    out = capture_stdout { @cli.send(:output, data, {}) }
    assert_includes out, 'image_id: abc123'
    assert_includes out, 'permalink_url: https://gyazo.com/abc123'
  end

  def test_output_json_format
    data = { image_id: 'abc123', permalink_url: 'https://gyazo.com/abc123' }
    out = capture_stdout { @cli.send(:output, data, { format: 'json' }) }
    parsed = JSON.parse(out, symbolize_names: true)
    assert_equal 'abc123', parsed[:image_id]
  end

  def test_output_nested_hash
    data = { metadata: { title: 'My Image', desc: 'A test' } }
    out = capture_stdout { @cli.send(:output, data, {}) }
    assert_includes out, 'metadata:'
    assert_includes out, 'title: My Image'
  end

  def test_output_escapes_newlines_in_values
    data = { desc: "line1\nline2\r\nline3" }
    out = capture_stdout { @cli.send(:output, data, {}) }
    # 値の中の改行がエスケープされ、出力が1行になること
    assert_equal 1, out.lines.length
    assert_includes out, 'desc: line1\nline2\nline3'
  end

  def test_output_array_shows_count
    data = { images: [1, 2, 3] }
    out = capture_stdout { @cli.send(:output, data, {}) }
    assert_includes out, 'images: [3 items]'
  end

  # --- version command ---

  def test_version_command
    out = capture_stdout { @cli.run(['version']) }
    assert_equal Gyazo::VERSION, out.chomp
  end

  # --- upload validation ---

  def test_upload_aborts_without_file_argument
    err = assert_raises(SystemExit) do
      capture_stderr { @cli.run(['--token', 'dummy', 'upload']) }
    end
    assert_equal 1, err.status
  end

  def test_upload_aborts_with_nonexistent_file
    err = assert_raises(SystemExit) do
      capture_stderr { @cli.run(['--token', 'dummy', 'upload', '/nonexistent/file.png']) }
    end
    assert_equal 1, err.status
  end

  # --- auth commands ---

  def test_auth_logout_when_no_token
    out = capture_stdout { @cli.run(['auth', 'logout']) }
    assert_includes out, 'No token found'
  end

  def test_auth_logout_removes_config
    @cli.send(:save_token, 'mytoken')
    assert File.exist?(@config_file)
    capture_stdout { @cli.run(['auth', 'logout']) }
    refute File.exist?(@config_file)
  end

  def test_auth_unknown_subcommand
    err = assert_raises(SystemExit) do
      capture_stderr { @cli.run(['auth', 'unknown']) }
    end
    assert_equal 1, err.status
  end

  private

  def capture_stdout
    old = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = old
  end

  def capture_stderr
    old = $stderr
    $stderr = StringIO.new
    yield
    $stderr.string
  ensure
    $stderr = old
  end
end
