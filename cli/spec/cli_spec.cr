require "./spec_helper"
require "file_utils"

# End-to-end-ish tests that exercise the built binary against a fixture
# JSON blob. We invoke `bin/weapons --data <fixture>` so the HTTP / cache
# layers are bypassed and the specs stay hermetic.
#
# A handful of tests that exercise the cache layer use a per-test temp
# XDG_CACHE_HOME so they don't interfere with a developer's real cache.
#
# Run `shards build` once before `crystal spec` so bin/weapons exists.

BINARY  = File.expand_path("../bin/weapons", __DIR__)
FIXTURE = File.expand_path("fixtures/weapons.json", __DIR__)

def run_cli(*args : String, env : Hash(String, String)? = nil) : {Int32, String, String}
  stdout = IO::Memory.new
  stderr = IO::Memory.new
  status = Process.run(
    BINARY,
    args: ["--no-color"] + args.to_a,
    output: stdout,
    error: stderr,
    env: env,
  )
  {status.exit_code, stdout.to_s, stderr.to_s}
end

def run_with_fixture(*args : String) : {Int32, String, String}
  run_cli("--data", FIXTURE, *args)
end

describe "weapons CLI" do
  it "prints stats with all counts" do
    exit_code, out, _err = run_with_fixture("stats")
    exit_code.should eq 0
    out.should contain "Total:"
    out.should contain "Type"
    out.should contain "Language"
    out.should contain "Category"
  end

  it "lists weapons filtered by type" do
    exit_code, out, _err = run_with_fixture("list", "--type", "Proxy")
    exit_code.should eq 0
    out.should contain "mitmproxy"
    out.should_not contain "Amass"
  end

  it "searches in name and description" do
    exit_code, out, _err = run_with_fixture("search", "dalfox")
    exit_code.should eq 0
    out.should contain "dalfox"
  end

  it "prints detail via info on exact slug" do
    exit_code, out, _err = run_with_fixture("info", "dalfox")
    exit_code.should eq 0
    out.should contain "slug:     dalfox"
    out.should contain "source:"
  end

  it "emits JSON when requested" do
    result = run_with_fixture("info", "amass", "--json")
    result[0].should eq 0
    parsed = JSON.parse(result[1])
    parsed["name"].as_s.should eq "Amass"
    parsed["url"].as_a.size.should be >= 1
  end

  it "exits 1 on unknown command" do
    exit_code, _out, err = run_with_fixture("nope")
    exit_code.should eq 1
    err.should contain "unknown command"
  end

  it "exits 1 when info target does not exist" do
    exit_code, _out, err = run_with_fixture("info", "definitely-not-a-weapon")
    exit_code.should eq 1
    err.should contain "no weapon matches"
  end

  it "lists candidates when info is ambiguous" do
    # The fixture has subfinder and subjack — both slugs start with "sub".
    exit_code, _out, err = run_with_fixture("info", "sub")
    exit_code.should eq 1
    err.should contain "matches 2 weapons"
    err.should contain "subfinder"
    err.should contain "subjack"
  end

  it "exact slug wins over substring when ambiguous" do
    # `amass` matches only itself, but prove exact wins even if substring
    # matches would have worked.
    exit_code, out, _err = run_with_fixture("info", "amass")
    exit_code.should eq 0
    out.should contain "slug:     amass"
  end

  describe "cache fallback" do
    tmp = ""

    before_each do
      tmp = File.tempname("weapons-cache-")
      Dir.mkdir_p(File.join(tmp, "weapons"))
      # Prime the cache so stale-fallback has something to serve.
      File.copy(FIXTURE, File.join(tmp, "weapons", "weapons.json"))
    end

    after_each do
      FileUtils.rm_rf(tmp) if File.exists?(tmp)
    end

    it "falls back to cached copy when the network fails" do
      env = {"XDG_CACHE_HOME" => tmp}
      # Force a fresh fetch (--refresh bypasses the 24h TTL check) against
      # a black-hole URL; expect the CLI to warn and serve stale data.
      exit_code, out, err = run_cli(
        "--api-url", "http://127.0.0.1:1/nope",
        "--refresh",
        "list", "--type", "Proxy",
        env: env,
      )
      exit_code.should eq 0
      out.should contain "mitmproxy"
      err.should contain "falling back to cached copy"
    end

    it "--strict turns stale-cache fallback off" do
      env = {"XDG_CACHE_HOME" => tmp}
      exit_code, _out, err = run_cli(
        "--api-url", "http://127.0.0.1:1/nope",
        "--refresh",
        "--strict",
        "list",
        env: env,
      )
      exit_code.should eq 1
      err.should contain "could not reach"
    end
  end
end
