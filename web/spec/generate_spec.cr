require "./spec_helper"

describe "scripts/generate.cr" do
  it "emits markdown + JSON + site.data for a valid fixture" do
    with_fixture_dirs do |data_dir, web_root|
      File.write(File.join(data_dir, "amass.toml"), weapon_toml)

      exit_code, out, _err = run_script("generate.cr", data_dir: data_dir, web_root: web_root)
      exit_code.should eq 0
      out.should contain "generated 1 weapons"

      # Per-weapon markdown
      md_path = File.join(web_root, "content", "weapons", "amass.md")
      File.exists?(md_path).should be_true
      md = File.read(md_path)
      md.should contain "title = \"Amass\""
      md.should contain "template = \"weapon\""

      # Per-weapon JSON
      json_path = File.join(web_root, "static", "api", "weapons", "amass.json")
      File.exists?(json_path).should be_true
      parsed = JSON.parse(File.read(json_path))
      parsed["name"].as_s.should eq "Amass"
      parsed["url"].as_a.size.should eq 1
      parsed["slug"].as_s.should eq "amass"

      # data/weapons.json (array consumed by the Hwaro templates)
      data_json = File.read(File.join(web_root, "data", "weapons.json"))
      JSON.parse(data_json).as_a.size.should eq 1

      # Aggregate API + stats
      File.exists?(File.join(web_root, "static", "api", "weapons.json")).should be_true
      File.exists?(File.join(web_root, "static", "api", "stats.json")).should be_true
    end
  end

  it "preserves backslashes in description through the TOML → JSON round-trip" do
    # Written manually because weapon_toml() can't safely embed a lone `\T` —
    # it would be an invalid TOML escape. Basic strings need `\\` to mean one
    # backslash. This mirrors weapons/DeepViolet.toml in real data.
    with_fixture_dirs do |data_dir, web_root|
      File.write(File.join(data_dir, "weird.toml"), <<-TOML)
      name = "Weird"
      description = "uses SSL\\\\TLS negotiation"
      url = ["https://example.com/"]
      category = "tool"
      type = "Utils"
      platform = ["linux"]
      lang = "Go"
      tags = []
      TOML

      exit_code, _out, _err = run_script("generate.cr", data_dir: data_dir, web_root: web_root)
      exit_code.should eq 0

      json_path = File.join(web_root, "static", "api", "weapons", "weird.json")
      parsed = JSON.parse(File.read(json_path))
      parsed["description"].as_s.should eq %q(uses SSL\TLS negotiation)

      # The emitted markdown must also have a correctly escaped description.
      md = File.read(File.join(web_root, "content", "weapons", "weird.md"))
      md.should contain %q(description = "uses SSL\\TLS negotiation")
    end
  end

  it "skips the second file on slug collision and keeps going" do
    with_fixture_dirs do |data_dir, web_root|
      File.write(File.join(data_dir, "first.toml"), weapon_toml(name: "Foo-Bar"))
      File.write(File.join(data_dir, "second.toml"), weapon_toml(name: "Foo_Bar"))

      exit_code, out, err = run_script("generate.cr", data_dir: data_dir, web_root: web_root)
      exit_code.should eq 0
      out.should contain "generated 1 weapons" # one survived, one shadowed
      err.should contain "slug collision"
    end
  end

  it "exits 1 with a clear message on invalid category" do
    with_fixture_dirs do |data_dir, web_root|
      File.write(File.join(data_dir, "bad.toml"), weapon_toml(category: "nonsense"))
      exit_code, _out, err = run_script("generate.cr", data_dir: data_dir, web_root: web_root)
      exit_code.should eq 1
      err.should contain "category"
      err.should contain "nonsense"
    end
  end

  it "populates optional `source` and survives no-source entries" do
    with_fixture_dirs do |data_dir, web_root|
      File.write(File.join(data_dir, "withsrc.toml"), <<-TOML)
      name = "WithSrc"
      description = "has source"
      url = ["https://github.com/x/y"]
      source = "https://github.com/x/y"
      category = "tool"
      type = "Utils"
      platform = ["linux"]
      lang = "Go"
      tags = []
      TOML
      File.write(File.join(data_dir, "nosrc.toml"), <<-TOML)
      name = "NoSrc"
      description = "no source"
      url = ["https://example.com/"]
      category = "tool"
      type = "Utils"
      platform = ["linux"]
      lang = "Go"
      tags = []
      TOML

      exit_code, _out, _err = run_script("generate.cr", data_dir: data_dir, web_root: web_root)
      exit_code.should eq 0

      with_src = JSON.parse(File.read(File.join(web_root, "static", "api", "weapons", "withsrc.json")))
      with_src["source"].as_s.should eq "https://github.com/x/y"

      no_src = JSON.parse(File.read(File.join(web_root, "static", "api", "weapons", "nosrc.json")))
      # nil source should not be rendered in pretty JSON — key either absent or null
      (no_src["source"]?.try(&.raw)).should be_nil
    end
  end
end
