require "./spec_helper"

# End-to-end-ish tests that exercise the built binary against a fixture
# JSON blob. We invoke `bin/weapons --data <fixture>` so the HTTP / cache
# layers are bypassed and the specs stay hermetic.
#
# Run `shards build` once before `crystal spec` so bin/weapons exists.

BINARY  = File.expand_path("../bin/weapons", __DIR__)
FIXTURE = File.expand_path("fixtures/weapons.json", __DIR__)

def run_cli(*args : String) : {Int32, String, String}
  stdout = IO::Memory.new
  stderr = IO::Memory.new
  status = Process.run(BINARY, args: ["--data", FIXTURE, "--no-color"] + args.to_a,
    output: stdout, error: stderr)
  {status.exit_code, stdout.to_s, stderr.to_s}
end

describe "weapons CLI" do
  it "prints stats with all counts" do
    exit_code, out, _err = run_cli("stats")
    exit_code.should eq 0
    out.should contain "Total:"
    out.should contain "Type"
    out.should contain "Language"
    out.should contain "Category"
  end

  it "lists weapons filtered by type" do
    exit_code, out, _err = run_cli("list", "--type", "Proxy")
    exit_code.should eq 0
    out.should contain "mitmproxy"
    out.should_not contain "Amass"
  end

  it "searches in name and description" do
    exit_code, out, _err = run_cli("search", "dalfox")
    exit_code.should eq 0
    out.should contain "dalfox"
  end

  it "prints detail via info" do
    exit_code, out, _err = run_cli("info", "dalfox")
    exit_code.should eq 0
    out.should contain "slug:     dalfox"
    out.should contain "source:"
  end

  it "emits JSON when requested" do
    result = run_cli("info", "amass", "--json")
    result[0].should eq 0
    parsed = JSON.parse(result[1])
    parsed["name"].as_s.should eq "Amass"
    parsed["url"].as_a.size.should be >= 1
  end

  it "exits 1 on unknown command" do
    exit_code, _out, err = run_cli("nope")
    exit_code.should eq 1
    err.should contain "unknown command"
  end

  it "exits 1 when info target does not exist" do
    exit_code, _out, err = run_cli("info", "definitely-not-a-weapon")
    exit_code.should eq 1
    err.should contain "no weapon matches"
  end
end
