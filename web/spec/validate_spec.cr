require "./spec_helper"

describe "scripts/validate.cr" do
  it "passes on a clean fixture" do
    with_fixture_dirs do |data_dir, _|
      File.write(File.join(data_dir, "amass.toml"), weapon_toml)
      exit_code, out, _err = run_script("validate.cr", data_dir: data_dir)
      exit_code.should eq 0
      out.should contain "0 error(s)"
    end
  end

  it "errors on missing name" do
    with_fixture_dirs do |data_dir, _|
      File.write(File.join(data_dir, "broken.toml"), weapon_toml(name: ""))
      exit_code, _out, _err = run_script("validate.cr", data_dir: data_dir)
      exit_code.should eq 1
    end
  end

  it "errors when both url and source are missing" do
    with_fixture_dirs do |data_dir, _|
      content = <<-TOML
      name = "NoLink"
      description = "has no url or source"
      category = "tool"
      type = "Utils"
      platform = ["linux"]
      lang = "Go"
      tags = []
      TOML
      File.write(File.join(data_dir, "nolink.toml"), content)
      exit_code, out, _err = run_script("validate.cr", data_dir: data_dir)
      exit_code.should eq 1
      out.should contain "at least one of `url` or `source`"
    end
  end

  it "errors on non-http url scheme" do
    with_fixture_dirs do |data_dir, _|
      File.write(File.join(data_dir, "x.toml"), weapon_toml(url: "ftp://example.com"))
      exit_code, out, _err = run_script("validate.cr", data_dir: data_dir)
      exit_code.should eq 1
      out.should contain "must start with http"
    end
  end

  it "errors on non-canonical category" do
    with_fixture_dirs do |data_dir, _|
      File.write(File.join(data_dir, "x.toml"), weapon_toml(category: "nonsense"))
      exit_code, out, _err = run_script("validate.cr", data_dir: data_dir)
      exit_code.should eq 1
      out.should contain "category"
      out.should contain "nonsense"
    end
  end

  it "errors on non-canonical type" do
    with_fixture_dirs do |data_dir, _|
      File.write(File.join(data_dir, "x.toml"), weapon_toml(type: "utils"))
      exit_code, out, _err = run_script("validate.cr", data_dir: data_dir)
      exit_code.should eq 1
      out.should contain "type"
    end
  end

  it "errors on non-canonical platform value" do
    with_fixture_dirs do |data_dir, _|
      File.write(File.join(data_dir, "x.toml"),
        weapon_toml(platform: %q(["linux", "haiku"])))
      exit_code, out, _err = run_script("validate.cr", data_dir: data_dir)
      exit_code.should eq 1
      out.should contain "platform"
    end
  end

  it "errors on slug collision across two files" do
    with_fixture_dirs do |data_dir, _|
      # Both names slugify to "foo-bar".
      File.write(File.join(data_dir, "foo-bar.toml"), weapon_toml(name: "Foo-Bar"))
      File.write(File.join(data_dir, "foo_bar.toml"), weapon_toml(name: "Foo_Bar"))
      exit_code, out, _err = run_script("validate.cr", data_dir: data_dir)
      exit_code.should eq 1
      out.should contain "collides"
    end
  end

  it "warns (but does not fail) on missing lang" do
    with_fixture_dirs do |data_dir, _|
      # Filename matches the slug so only the lang warning fires.
      File.write(File.join(data_dir, "amass.toml"), weapon_toml(lang: ""))
      exit_code, out, _err = run_script("validate.cr", data_dir: data_dir)
      exit_code.should eq 0
      out.should contain "`lang` missing"
      out.should contain "1 warning(s)"
    end
  end

  it "emits valid JSON with --json" do
    with_fixture_dirs do |data_dir, _|
      File.write(File.join(data_dir, "a.toml"), weapon_toml)
      File.write(File.join(data_dir, "b.toml"), weapon_toml(name: "Dalfox", url: "https://github.com/hahwul/dalfox"))
      result = run_script("validate.cr", script_args: ["--json"], data_dir: data_dir)
      result[0].should eq 0
      payload = JSON.parse(result[1])
      payload["files"].as_i.should eq 2
      payload["errors"].as_i.should eq 0
    end
  end
end
